defmodule AWS.CodeGen.RestService do
  alias AWS.CodeGen.Docstring
  alias AWS.CodeGen.Service
  alias AWS.CodeGen.Shapes

  defmodule Action do
    alias AWS.CodeGen.RestService.Parameter

    defstruct arity: nil,
              docstring: nil,
              docstring_header: nil,
              docs_url: nil,
              method: nil,
              request_uri: nil,
              success_status_code: nil,
              function_name: nil,
              name: nil,
              url_parameters: [],
              has_body?: false,
              body_required?: false,
              body_parameters: [],
              required_body_parameters: [],
              optional_body_parameters: [],
              query_parameters: [],
              required_query_parameters: [],
              optional_query_parameters: [],
              request_header_parameters: [],
              request_headers_parameters: [],
              required_request_header_parameters: [],
              optional_request_header_parameters: [],
              response_header_parameters: [],
              send_body_as_binary?: false,
              receive_body_as_binary?: false,
              host_prefix: nil,
              language: nil,
              input: nil,
              output: nil,
              errors: []

    def method(action) do
      result = action.method |> String.downcase() |> String.to_atom()
      "#{if action.language == :elixir, do: ":", else: ""}#{result}"
    end

    def url_path(action) do
      Enum.reduce(action.url_parameters, action.request_uri, fn parameter, acc ->
        multi_segment = Parameter.multi_segment?(parameter, acc)

        name =
          if action.language == :elixir do
            if multi_segment do
              Enum.join([
                ~S(#{),
                "AWS.Util.encode_multi_segment_uri(",
                parameter.code_name,
                ")",
                ~S(})
              ])
            else
              Enum.join([~S(#{), "AWS.Util.encode_uri(", parameter.code_name, ")", ~S(})])
            end
          else
            if multi_segment do
              Enum.join(["\", aws_util:encode_multi_segment_uri(", parameter.code_name, "), \""])
            else
              Enum.join(["\", aws_util:encode_uri(", parameter.code_name, "), \""])
            end
          end

        # Some url parameters have a trailing "+" indicating they are
        # multi-segment. This regex takes that into account.
        {:ok, re} = Regex.compile("{#{parameter.location_name}\\+?}")
        String.replace(acc, re, name)
      end)
    end
  end

  defmodule Context do
    def s3_context?(context) do
      context.endpoint_prefix == "s3" and context.endpoint_prefix != "s3-control"
    end
  end

  defmodule Parameter do
    defstruct code_name: nil,
              name: nil,
              location_name: nil,
              required: false,
              type: nil,
              docs: nil

    def multi_segment?(parameter, request_uri) do
      {:ok, re} = Regex.compile("{#{parameter.location_name}\\+}")
      String.match?(request_uri, re)
    end
  end

  @configuration %{
    :rest_xml => %{
      content_type: "text/xml",
      elixir: %{
        decode: "xml",
        encode: "xml"
      },
      erlang: %{
        decode: "aws_util:decode_xml(Body)",
        encode: "aws_util:encode_xml(Input)"
      }
    },
    :rest_json => %{
      content_type: "application/x-amz-json-1.1",
      elixir: %{
        decode: "json",
        encode: "json"
      },
      erlang: %{
        decode: "jsx:decode(Body)",
        encode: "jsx:encode(Input)"
      }
    }
  }

  @doc """
  Load REST API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, %AWS.CodeGen.Spec{} = spec, endpoints_spec) do
    service = spec.api["shapes"][spec.shape_name]
    traits = service["traits"]
    actions = collect_actions(language, spec.api)
    protocol = spec.protocol
    ## TODO: for some reason this field is not always present and docs are not clear on what to do
    endpoint_prefix =
      traits["aws.api#service"]["endpointPrefix"] || traits["aws.api#service"]["arnNamespace"]

    endpoint_info = endpoints_spec["services"][endpoint_prefix]
    is_global = not is_nil(endpoint_info) and not Map.get(endpoint_info, "isRegionalized", true)

    credential_scope =
      if is_global do
        endpoint_info["endpoints"]["aws-global"]["credentialScope"]["region"]
      end

    hostname =
      if is_global do
        endpoint_info["endpoints"]["aws-global"]["hostname"]
      end

    signing_name = traits["aws.auth#sigv4"]["name"] || endpoint_prefix

    %Service{
      actions: actions,
      api_version: service["version"],
      docstring: Docstring.format(language, AWS.CodeGen.Util.service_docs(service)),
      credential_scope: credential_scope,
      content_type: @configuration[protocol][:content_type],
      decode: Map.fetch!(@configuration[protocol][language], :decode),
      encode: Map.fetch!(@configuration[protocol][language], :encode),
      endpoint_prefix: endpoint_prefix,
      is_global: is_global,
      hostname: hostname,
      json_version: AWS.CodeGen.Util.get_json_version(service),
      language: language,
      module_name: spec.module_name,
      protocol: protocol |> to_string() |> String.replace("_", "-"),
      signing_name: signing_name,
      signature_version: AWS.CodeGen.Util.get_signature_version(service),
      service_id: AWS.CodeGen.Util.get_service_id(service),
      ## TODO: metadata["targetPrefix"],
      target_prefix: nil,
      shapes: Shapes.collect_shapes(language, spec.api)
    }
  end

  @doc """
  Render required function parameters, if any, in a way that can be inserted directly
  into the code template.
  """
  def required_function_parameters(action) do
    function_parameters(action, true)
  end

  @doc """
  Render function parameters, if any, in a way that can be inserted directly
  into the code template. It can be asked to only return the required ones.
  """
  def function_parameters(action, required_only \\ false) do
    language = action.language

    Enum.join([
      join_parameters(action.url_parameters, language)
      | case action.method do
          "GET" ->
            case required_only do
              false ->
                [
                  join_parameters(action.query_parameters, language),
                  join_parameters(action.request_header_parameters, language),
                  join_parameters(action.request_headers_parameters, language)
                ]

              true ->
                [
                  join_parameters(action.required_query_parameters, language),
                  join_parameters(action.required_request_header_parameters, language)
                ]
            end

          _ ->
            case required_only do
              false ->
                [
                  join_parameters(action.query_parameters, language),
                  join_parameters(action.request_header_parameters, language),
                  join_parameters(action.request_headers_parameters, language)
                ]

              true ->
                [
                  join_parameters(action.required_query_parameters, language),
                  join_parameters(action.required_request_header_parameters, language)
                ]
            end
        end
    ])
  end

  defp join_parameters(parameters, language) do
    Enum.join(
      Enum.map(
        parameters,
        fn parameter ->
          if not parameter.required and language == :elixir do
            ", #{parameter.code_name} \\\\ nil"
          else
            ", #{parameter.code_name}"
          end
        end
      )
    )
  end

  defp collect_actions(language, api_spec) do
    shapes = api_spec["shapes"]

    operations =
      Enum.reduce(shapes, [], fn {_, shape}, acc ->
        case shape["type"] do
          "service" ->
            List.wrap(shape["operations"]) ++ acc

          "resource" ->
            [
              shape["operations"],
              shape["collectionOperations"],
              shape["create"],
              shape["put"],
              shape["read"],
              shape["update"],
              shape["delete"],
              shape["list"]
            ]
            |> Enum.reject(&is_nil/1)
            |> Kernel.++(acc)

          _ ->
            acc
        end
      end)
      |> List.flatten()
      |> Enum.map(fn %{"target" => target} -> target end)

    Enum.map(operations, fn operation ->
      operation_spec = shapes[operation]
      request_uri = operation_spec["traits"]["smithy.api#http"]["uri"]
      url_parameters = collect_url_parameters(language, api_spec, operation)

      body_parameters =
        collect_body_parameters(language, api_spec, operation)

      # if operation in [
      #      "com.amazonaws.apigatewayv2#ReimportApi"
      #    ] do
      #   dbg({url_parameters, body_parameters})
      # end

      query_parameters = collect_query_parameters(language, api_spec, operation)
      function_name = AWS.CodeGen.Name.to_snake_case(operation)
      request_header_parameters = collect_request_header_parameters(language, api_spec, operation)

      # The AWS Docs sometimes use an arbitrary service name, so we cannot build direct urls. Instead we just link to a search
      docs_url = Docstring.docs_url(shapes, operation)

      {required_query_params, opt_query_params} = split_parameters(query_parameters)

      {required_request_header_params, opt_request_header_params} =
        split_parameters(request_header_parameters)

      {required_body_params, opt_body_params} = split_parameters(body_parameters)

      method = operation_spec["traits"]["smithy.api#http"]["method"]

      len_for_method =
        case method do
          "GET" ->
            case language do
              :elixir ->
                2 + length(required_request_header_params) + length(required_query_params)

              :erlang ->
                4 + length(required_request_header_params) + length(required_query_params)
            end

          _ ->
            3
        end

      input_shape = Shapes.get_input_shape(operation_spec)
      output_shape = Shapes.get_output_shape(operation_spec)

      docstring =
        Docstring.format(
          language,
          operation_spec["traits"]["smithy.api#documentation"]
        )

      has_body? = method != "GET" and not Enum.empty?(body_parameters)
      send_body_as_binary? = Shapes.body_as_binary?(shapes, input_shape)
      body_required? = has_body? and not Enum.empty?(required_body_params)

      %Action{
        arity: length(url_parameters) + len_for_method,
        docstring: docstring,
        docs_url: docs_url,
        method: method,
        request_uri: request_uri,
        success_status_code: success_status_code(operation_spec),
        function_name: function_name,
        name: operation,
        url_parameters: url_parameters,
        query_parameters: query_parameters,
        body_parameters: body_parameters,
        required_body_parameters: required_body_params,
        optional_body_parameters: opt_body_params,
        has_body?: has_body?,
        body_required?: body_required?,
        required_query_parameters: required_query_params,
        optional_query_parameters: opt_query_params,
        request_header_parameters: request_header_parameters,
        required_request_header_parameters: required_request_header_params,
        optional_request_header_parameters: opt_request_header_params,
        response_header_parameters:
          collect_response_header_parameters(language, api_spec, operation),
        send_body_as_binary?: send_body_as_binary?,
        receive_body_as_binary?: Shapes.body_as_binary?(shapes, output_shape),
        host_prefix: operation_spec["traits"]["smithy.api#endpoint"]["hostPrefix"],
        language: language,
        input: operation_spec["input"],
        output: operation_spec["output"],
        errors: operation_spec["errors"]
      }
    end)
    |> Enum.sort(fn a, b -> a.function_name < b.function_name end)
    |> Enum.uniq()
  end

  defp success_status_code(operation_spec) do
    if Map.has_key?(operation_spec["traits"]["smithy.api#http"], "code") do
      operation_spec["traits"]["smithy.api#http"]["code"]
    else
      200
    end
  end

  defp collect_url_parameters(language, api_spec, operation) do
    url_params =
      collect_parameters(language, api_spec, operation, "input", "smithy.api#httpLabel")

    url_params
  end

  defp collect_body_parameters(language, api_spec, operation) do
    [
      collect_parameters(language, api_spec, operation, "input", "smithy.api#httpPayload"),
      collect_parameters(language, api_spec, operation, "input", "smithy.api#jsonName")
      # collect_parameters(language, api_spec, operation, "members", "smithy.api#jsonName")
    ]
    |> Enum.concat()
  end

  defp collect_query_parameters(language, api_spec, operation) do
    query_params =
      collect_parameters(language, api_spec, operation, "input", "smithy.api#httpQueryParams")

    params = collect_parameters(language, api_spec, operation, "input", "smithy.api#httpQuery")
    query_params ++ params
  end

  @spec split_parameters(any()) :: {list(any), list(any)}
  def split_parameters(params) do
    Enum.split_with(params, & &1.required)
  end

  defp collect_request_header_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "input", "smithy.api#httpHeader")
  end

  defp collect_response_header_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "output", "smithy.api#httpHeader")
  end

  def collect_parameters(language, api_spec, operation, data_type, param_type) do
    shape_name = api_spec["shapes"][operation][data_type]["target"]

    if shape_name do
      case api_spec["shapes"][shape_name] do
        nil ->
          []

        shape ->
          required_members =
            for {name, %{"traits" => traits}} <- shape["members"],
                Map.has_key?(traits, "smithy.api#required"),
                do: name

          shape["members"]
          |> Enum.filter(filter_fn(param_type))
          |> Enum.map(fn {name, x} ->
            required = Enum.member?(required_members, name)

            tynfo =
              get_type_info(x, api_spec)

            docs = get_in(x, ["traits", "smithy.api#documentation"])

            docs =
              if is_nil(docs) do
                ""
              else
                extract_param_docs_snippet(docs)
              end

            if is_nil(tynfo) do
              build_parameter(language, {name, x["traits"][param_type]}, required, "string", docs)
            else
              build_parameter(language, {name, x["traits"][param_type]}, required, tynfo, docs)
            end
          end)
      end
    else
      []
    end
  end

  def extract_param_docs_snippet(docs) do
    case Floki.parse_fragment(docs) do
      {:ok, [{"p", _attrs, inner_content} | _rest]} ->
        inner_content
        |> sanitize_html()
        |> Floki.text()

      {:ok, [first_node | _rest]} ->
        first_node
        |> sanitize_html()
        |> Floki.text()

      {:error, _} ->
        ""
    end
  end

  def sanitize_html(tree) do
    tree
    # NOTE: This doesn't work, because it only updates the inner part of the tag.
    # |> Floki.find_and_update("code", fn
    #   {"code", inner} ->
    #     "`#{inner}`"
    #
    #   other ->
    #     IO.inspect(other)
    #     other
    # end)
    |> Floki.find_and_update("p", fn
      {"p", inner} ->
        inner

      other ->
        other
    end)
  end

  def get_type_info(x, api_spec) do
    t = x["target"]
    type = api_spec["shapes"][t]

    # if is_nil(type) do
    #   # THIS IS SOMETIMES INCORRECT! t is not guaranteed to exist in api_spec["shapes"]...
    #   dbg({x, t, type})
    # end

    build_type_details(type, api_spec)
  end

  def build_type_details(type, _api_spec) when is_binary(type) do
    type
  end

  # If the timestamp has traits such as `http-date`, or `date-time` include them.
  def build_type_details(%{"type" => "timestamp", "traits" => _} = type, _api_spec) do
    fmt = type["traits"]["smithy.api#timestampFormat"]

    "timestamp[#{fmt}]"
  end

  def build_type_details(%{"type" => "enum"} = type, _api_spec) do
    keys =
      type["members"]
      |> Map.keys()

    ~s/enum["#{Enum.join(keys, "|")}"]/
  end

  def build_type_details(%{"type" => "list"} = type, api_spec) do
    deets =
      type["member"]["target"]
      |> build_type_details(api_spec)

    "list[#{deets}]"
  end

  # TODO: Should raise here on unknown types, but handling it elsewhere for now.
  # def build_type_details(nil, api_spec) do
  #   "string"
  # end

  def build_type_details(type, _api_spec) do
    type["type"]
  end

  defp filter_fn(location) do
    fn {_name, member_spec} ->
      not is_nil(member_spec["traits"][location])
    end
  end

  defp build_parameter(_, a, required, nil, docs) do
    dbg()
    raise "build_parameter type is nil"
  end

  defp build_parameter(language, {name, %{}}, required, type, docs) do
    %Parameter{
      code_name:
        if language == :elixir do
          AWS.CodeGen.Name.to_snake_case(name)
        else
          AWS.CodeGen.Name.upcase_first(name)
        end,
      name: name,
      location_name: name,
      required: required,
      type: type,
      docs: docs
    }
  end

  defp build_parameter(language, {name, data}, required, type, docs) do
    %Parameter{
      code_name:
        if language == :elixir do
          AWS.CodeGen.Name.to_snake_case(name)
        else
          AWS.CodeGen.Name.upcase_first(name)
        end,
      name: name,
      location_name: data,
      required: required,
      type: type,
      docs: docs
    }
  end
end
