defmodule AWS.CodeGen.PostService do
  alias AWS.CodeGen.Docstring
  alias AWS.CodeGen.Service

  defmodule Action do
    defstruct arity: nil,
              docstring: nil,
              function_name: nil,
              host_prefix: nil,
              name: nil
  end

  @configuration %{
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
    metadata = spec.api["metadata"]
    actions = collect_actions(language, spec.api, spec.doc)

    endpoint_prefix = metadata["endpointPrefix"]
    endpoint_info = endpoints_spec["services"][endpoint_prefix]
    is_global = not is_nil(endpoint_info) and not Map.get(endpoint_info, "isRegionalized", true)

    credential_scope =
      if is_global do
        endpoint_info["endpoints"]["aws-global"]["credentialScope"]["region"]
      end

    json_version = metadata["jsonVersion"]
    protocol = metadata["protocol"]
    content_type = @configuration[protocol][:content_type]
    content_type = content_type <> if protocol == "json", do: json_version, else: ""

    signing_name =
      case metadata["signingName"] do
        nil -> endpoint_prefix
        sn -> sn
      end

    %Service{
      abbreviation: metadata["serviceAbbreviation"],
      actions: actions,
      api_version: metadata["apiVersion"],
      credential_scope: credential_scope,
      content_type: content_type,
      docstring: Docstring.format(language, spec.doc["service"]),
      decode: Map.fetch!(@configuration[protocol][language], :decode),
      encode: Map.fetch!(@configuration[protocol][language], :encode),
      endpoint_prefix: endpoint_prefix,
      is_global: is_global,
      json_version: json_version,
      language: language,
      module_name: spec.module_name,
      protocol: protocol,
      signing_name: signing_name,
      signature_version: metadata["signatureVersion"],
      service_id: metadata["serviceId"],
      target_prefix: metadata["targetPrefix"]
    }
  end

  defp collect_actions(language, api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn {operation, metadata} ->
      %Action{
        arity: 3,
        docstring:
          Docstring.format(
            language,
            doc_spec["operations"][operation]
          ),
        function_name: AWS.CodeGen.Name.to_snake_case(operation),
        host_prefix: get_in(metadata, ["endpoint", "hostPrefix"]),
        name: operation
      }
    end)
    |> Enum.sort(fn a, b -> a.function_name < b.function_name end)
  end
end
