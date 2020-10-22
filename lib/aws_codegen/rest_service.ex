defmodule AWS.CodeGen.RestService do
  alias AWS.CodeGen.Docstring

  defmodule Service do
    defstruct abbreviation: nil,
              actions: [],
              credential_scope: nil,
              content_type: nil,
              docstring: nil,
              decode: nil,
              encode: nil,
              endpoint_prefix: nil,
              is_global: false,
              json_version: nil,
              module_name: nil,
              protocol: nil,
              signing_name: nil,
              target_prefix: nil
  end

  defmodule Action do
    alias AWS.CodeGen.RestService.Parameter
    defstruct arity: nil,
              docstring: nil,
              method: nil,
              request_uri: nil,
              success_status_code: nil,
              function_name: nil,
              name: nil,
              url_parameters: [],
              query_parameters: [],
              request_header_parameters: [],
              response_header_parameters: [],
              language: nil

    def method(action) do
      result = action.method |> String.downcase |> String.to_atom
      "#{if action.language == :elixir, do: ":", else: ""}#{result}"
    end

    def url_path(action) do
      Enum.reduce(action.url_parameters, action.request_uri,
        fn(parameter, acc) ->
          multi_segment = Parameter.multi_segment?(parameter, acc)
          name = if action.language == :elixir do
            if multi_segment do
              Enum.join([~S(#{), "AWS.Util.encode_uri(", parameter.code_name, ", true)", ~S(})])
            else
              Enum.join([~S(#{), "URI.encode(", parameter.code_name, ")", ~S(})])
            end
          else
            if multi_segment do
              Enum.join(["\", aws_util:encode_uri(", parameter.code_name,", true), \""])
            else
              Enum.join(["\", http_uri:encode(", parameter.code_name, "), \""])
            end
          end
          # Some url parameters have a trailing "+" indicating they are
          # multi-segment. This regex takes that into account.
          {:ok, re} = Regex.compile("{#{parameter.location_name}\\+?}")
          String.replace(acc, re, name)
        end)
    end
  end

  defmodule Parameter do
    defstruct code_name: nil,
              name: nil,
              location_name: nil,
              required: false

    def multi_segment?(parameter, request_uri) do
      {:ok, re} = Regex.compile("{#{parameter.location_name}\\+}")
      String.match?(request_uri, re)
    end
  end

  @configuration %{
    "rest-xml" => %{
      content_type: "text/xml",
      elixir: %{
        decode: "AWS.Util.decode_xml(body)",
        encode: "AWS.Util.encode_xml(input)"
      },
      erlang: %{
        decode: "aws_util:decode_xml(Body)",
        encode: "aws_util:encode_xml(Input)"
      }
    },
    "rest-json" => %{
      content_type: "application/x-amz-json-1.1",
      elixir: %{
        decode: "AWS.JSON.decode!(body)",
        encode: "AWS.JSON.encode!(input)"
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
  def load_context(language, module_name, endpoints_spec, api_spec, doc_spec) do
    actions = collect_actions(language, api_spec, doc_spec)
    protocol = api_spec["metadata"]["protocol"]
    endpoint_prefix = api_spec["metadata"]["endpointPrefix"]
    endpoint_info = endpoints_spec["services"][endpoint_prefix]
    is_global = not is_nil(endpoint_info) and not Map.get(endpoint_info, "isRegionalized", true)
    credential_scope = if is_global do
      endpoint_info["endpoints"]["aws-global"]["credentialScope"]["region"]
    else
      nil
    end
    signing_name = case api_spec["metadata"]["signingName"] do
                     nil -> endpoint_prefix
                     sn   -> sn
                   end
    %Service{actions: actions,
             docstring: Docstring.format(language, doc_spec["service"]),
             credential_scope: credential_scope,
             content_type: @configuration[protocol][:content_type],
             decode: Map.fetch!(@configuration[protocol][language], :decode),
             encode: Map.fetch!(@configuration[protocol][language], :encode),
             endpoint_prefix: endpoint_prefix,
             is_global: is_global,
             json_version: api_spec["metadata"]["jsonVersion"],
             module_name: module_name,
             protocol: api_spec["metadata"]["protocol"],
             signing_name: signing_name,
             target_prefix: api_spec["metadata"]["targetPrefix"]}
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  @doc """
  Render function parameter, if any, in a way that can be inserted directly
  into the code template.
  """
  def function_parameters(action) do
    language = action.language
    Enum.join([join_parameters(action.url_parameters, language) |
               case action.method do
                 "GET" ->
                   [join_parameters(action.query_parameters, language),
                    join_parameters(action.request_header_parameters, language)]
                 _ -> []
               end])
  end

  defp join_parameters(parameters, language) do
    Enum.join(Enum.map(parameters,
          fn(parameter) ->
            if not parameter.required and language == :elixir do
              ", #{parameter.code_name} \\\\ nil"
            else
              ", #{parameter.code_name}"
            end
          end))
  end

  defp collect_actions(language, api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn({operation, _metadata}) ->
      url_parameters = collect_url_parameters(language, api_spec, operation)
      query_parameters = collect_query_parameters(language, api_spec, operation)
      request_header_parameters = collect_request_header_parameters(language, api_spec, operation)
      method = api_spec["operations"][operation]["http"]["method"]
      arity = length(url_parameters) + case method do
                                         "GET" ->
                                           2 + length(request_header_parameters) + length(query_parameters)
                                         _ ->  3
                                       end
      %Action{
        arity: arity,
        docstring: Docstring.format(language,
                                          doc_spec["operations"][operation]),
        method: method,
        request_uri: api_spec["operations"][operation]["http"]["requestUri"],
        success_status_code: api_spec["operations"][operation]["http"]["responseCode"],
        function_name: AWS.CodeGen.Name.to_snake_case(operation),
        name: operation,
        url_parameters: url_parameters,
        query_parameters: query_parameters,
        request_header_parameters: request_header_parameters,
        response_header_parameters: collect_response_header_parameters(language, api_spec, operation),
        language: language
      }

    end)
    |> Enum.sort(fn(a, b) -> a.function_name < b.function_name end)
  end

  defp collect_url_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "input", "uri")
  end

  defp collect_query_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "input", "querystring")
  end

  defp collect_request_header_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "input", "header")
  end

  defp collect_response_header_parameters(language, api_spec, operation) do
    collect_parameters(language, api_spec, operation, "output", "header")
  end

  defp collect_parameters(language, api_spec, operation, data_type, param_type) do
    shape_name = api_spec["operations"][operation][data_type]["shape"]
    if shape_name do
      case api_spec["shapes"][shape_name] do
        nil ->
          []

        shape ->
          required_members = Access.get(shape, "required", [])
          shape["members"]
          |> Enum.filter(filter_fn(param_type))
          |> Enum.map(fn {name, _} = x ->
            required = Enum.member?(required_members, name)
            build_parameter(language, x, required)
          end)
      end
    else
      []
    end
  end

  defp filter_fn(location) do
    fn({_name, member_spec}) ->
      case member_spec["location"] do
        ^location -> true
        _ -> false
      end
    end
  end

  defp build_parameter(language, {name, data}, required) do
    %Parameter{
      code_name: if language == :elixir do
        AWS.CodeGen.Name.to_snake_case(name)
      else
        AWS.CodeGen.Name.upcase_first(name)
      end,
      name: name,
      location_name: data["locationName"],
      required: required
    }
  end
end
