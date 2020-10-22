defmodule AWS.CodeGen.PostService do
  alias AWS.CodeGen.Docstring

  defmodule Service do
    defstruct abbreviation: nil,
              actions: [],
              api_version: nil,
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
    defstruct arity: nil,
              docstring: nil,
              function_name: nil,
              name: nil
  end

  @configuration %{
    "query" => %{
      content_type: "application/x-www-form-urlencoded",
      elixir: %{
        decode: "AWS.Util.decode_xml(body)",
        encode: "AWS.Util.encode_query(input)"
      },
      erlang: %{
        decode: "aws_util:decode_xml(Body)",
        encode: "aws_util:encode_query(Input)"
      }
    },
    "json" => %{
      content_type: "application/x-amz-json-",
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
  Load POST API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, module_name, endpoints_spec, api_spec, doc_spec) do
    actions = collect_actions(language, api_spec, doc_spec)
    endpoint_prefix = api_spec["metadata"]["endpointPrefix"]
    endpoint_info = endpoints_spec["services"][endpoint_prefix]
    is_global = not is_nil(endpoint_info) and not Map.get(endpoint_info, "isRegionalized", true)
    credential_scope = if is_global do
      endpoint_info["endpoints"]["aws-global"]["credentialScope"]["region"]
    else
      nil
    end
    json_version = api_spec["metadata"]["jsonVersion"]
    protocol = api_spec["metadata"]["protocol"]
    content_type = @configuration[protocol][:content_type]
    content_type = content_type <>  if protocol == "json", do: json_version, else: ""
    signing_name = case api_spec["metadata"]["signingName"] do
     nil -> endpoint_prefix
     sn -> sn
    end
    %Service{abbreviation: api_spec["metadata"]["serviceAbbreviation"],
             actions: actions,
             api_version: api_spec["metadata"]["apiVersion"],
             credential_scope: credential_scope,
             content_type: content_type,
             docstring: Docstring.format(language, doc_spec["service"]),
             decode: Map.fetch!(@configuration[protocol][language], :decode),
             encode: Map.fetch!(@configuration[protocol][language], :encode),
             endpoint_prefix: endpoint_prefix,
             is_global: is_global,
             json_version: json_version,
             module_name: module_name,
             protocol: protocol,
             signing_name: signing_name,
             target_prefix: api_spec["metadata"]["targetPrefix"]}
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  defp collect_actions(language, api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn({operation, _metadata}) ->
      %Action{arity: 3,
              docstring: Docstring.format(language,
                                          doc_spec["operations"][operation]),
              function_name: AWS.CodeGen.Name.to_snake_case(operation),
              name: operation}
    end)
    |> Enum.sort(fn(a, b) -> a.function_name < b.function_name end)
  end
end
