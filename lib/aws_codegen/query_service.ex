defmodule AWS.CodeGen.QueryService do
  alias AWS.CodeGen.Docstring

  defmodule Service do
    defstruct api_version: nil,
              abbreviation: nil,
              actions: [],
              docstring: nil,
              signing_name: nil,
              endpoint_prefix: nil,
              module_name: nil,
              protocol: nil
  end

  defmodule Action do
    defstruct arity: nil,
              docstring: nil,
              function_name: nil,
              name: nil
  end

  @doc """
  Load Query API service and documentation specifications from the
  `api_spec_path` and `doc_spec_path` files and convert them into a context
  that can be used to generate code for an AWS service.  `language` must be
  `:elixir` or `:erlang`.
  """
  def load_context(language, module_name, api_spec_path, doc_spec_path, _options) do
    api_spec = File.read!(api_spec_path) |> Poison.Parser.parse!(%{})
    doc_spec = File.read!(doc_spec_path) |> Poison.Parser.parse!(%{})
    build_context(language, module_name, api_spec, doc_spec)
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  defp build_context(language, module_name, api_spec, doc_spec) do
    actions = collect_actions(language, api_spec, doc_spec)
    signing_name = case api_spec["metadata"]["signingName"] do
     nil -> api_spec["metadata"]["endpointPrefix"];
     sn -> sn
    end
    %Service{
      api_version: api_spec["metadata"]["apiVersion"],
      abbreviation: api_spec["metadata"]["serviceAbbreviation"],
      actions: actions,
      docstring: Docstring.format(language, doc_spec["service"]),
      signing_name: signing_name,
      endpoint_prefix: api_spec["metadata"]["endpointPrefix"],
      module_name: module_name,
      protocol: api_spec["metadata"]["protocol"]
    }
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
