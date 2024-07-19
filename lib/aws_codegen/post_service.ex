defmodule AWS.CodeGen.PostService do
  alias AWS.CodeGen.Docstring
  alias AWS.CodeGen.Service
  alias AWS.CodeGen.Shapes

  defmodule Action do
    defstruct arity: nil,
              docstring: nil,
              docs_url: nil,
              function_name: nil,
              input: nil,
              output: nil,
              url_parameters: [],
              has_body?: true,
              body_required?: true,
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
              errors: %{},
              host_prefix: nil,
              name: nil,
              send_body_as_binary?: false,
              language: nil,
              method: :post
  end

  @configuration %{
    "ec2" => %{
      content_type: "application/x-www-form-urlencoded",
      elixir: %{
        decode: "xml",
        encode: "query"
      },
      erlang: %{
        decode: "aws_util:decode_xml(Body)",
        encode: "aws_util:encode_query(Input)"
      }
    },
    "query" => %{
      content_type: "application/x-www-form-urlencoded",
      elixir: %{
        decode: "xml",
        encode: "query"
      },
      erlang: %{
        decode: "aws_util:decode_xml(Body)",
        encode: "aws_util:encode_query(Input)"
      }
    },
    "json" => %{
      content_type: "application/x-amz-json-",
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
  Load POST API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, %AWS.CodeGen.Spec{} = spec, endpoints_spec) do
    %Service{actions: []}
    service = spec.api["shapes"][spec.shape_name]
    traits = service["traits"]
    actions = collect_actions(language, spec.api)
    shapes = Shapes.collect_shapes(language, spec.api)

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

    json_version = AWS.CodeGen.Util.get_json_version(service)
    protocol = spec.protocol |> to_string()
    content_type = @configuration[protocol][:content_type]
    content_type = content_type <> if protocol == "json", do: json_version, else: ""

    signing_name =
      if String.starts_with?(endpoint_prefix, "api.") do
        String.replace(endpoint_prefix, "api.", "")
      else
        endpoint_prefix
      end

    %Service{
      actions: actions,
      api_version: service["version"],
      credential_scope: credential_scope,
      content_type: content_type,
      docstring: Docstring.format(language, AWS.CodeGen.Util.service_docs(service)),
      decode: Map.fetch!(@configuration[protocol][language], :decode),
      encode: Map.fetch!(@configuration[protocol][language], :encode),
      endpoint_prefix: endpoint_prefix,
      is_global: is_global,
      hostname: hostname,
      json_version: json_version,
      language: language,
      module_name: spec.module_name,
      protocol: protocol |> to_string() |> String.replace("_", "-"),
      shapes: shapes,
      signing_name: signing_name,
      signature_version: AWS.CodeGen.Util.get_signature_version(service),
      service_id: AWS.CodeGen.Util.get_service_id(service),
      target_prefix: target_prefix(spec.api)
    }
  end

  defp target_prefix(api) do
    api["shapes"]
    |> Enum.find(fn {_key, value} -> match?(%{"type" => "service"}, value) end)
    |> case do
      {key, _} ->
        String.replace(key, ~r/.*#/, "")

      nil ->
        nil
    end
  end

  defp collect_params(language, api_spec, operation) do
    AWS.CodeGen.RestService.collect_parameters(
      language,
      api_spec,
      operation,
      "members",
      "smithy.api#input"
    )
  end

  defp collect_actions(language, api_spec) do
    shapes = api_spec["shapes"]

    operations =
      Enum.reduce(shapes, [], fn {_, shape}, acc ->
        case shape["type"] do
          "service" ->
            [acc | List.wrap(shape["operations"])]

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

      # The AWS Docs sometimes use an arbitrary service name, so we cannot build direct urls. Instead we just link to a search
      docs_url = Docstring.docs_url(shapes, operation)

      # input_shape = Shapes.get_input_shape(operation_spec)

      params =
        collect_params(language, api_spec, operation)

      %Action{
        arity: 3,
        docstring:
          Docstring.format(
            language,
            operation_spec["traits"]["smithy.api#documentation"]
          ),
        docs_url: docs_url,
        function_name: AWS.CodeGen.Name.to_snake_case(operation),
        host_prefix: operation_spec["traits"]["smithy.api#endpoint"]["hostPrefix"],
        name: String.replace(operation, ~r/com\.amazonaws\.[^#]+#/, ""),
        input: operation_spec["input"],
        output: operation_spec["output"],
        errors: operation_spec["errors"],
        language: language
      }
    end)
    |> Enum.sort(fn a, b -> a.function_name < b.function_name end)
    |> Enum.uniq()
  end
end
