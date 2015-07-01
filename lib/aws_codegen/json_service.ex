defmodule AWS.CodeGen.JSONService do
  alias AWS.CodeGen.Docstring

  defmodule Action do
    defstruct docstring: nil,
              function_name: nil,
              name: nil
  end

  defmodule Service do
    defstruct abbreviation: nil,
              actions: [],
              docstring: nil,
              endpoint_prefix: nil,
              json_version: nil,
              module_name: nil,
              protocol: nil,
              target_prefix: nil
  end

  @doc """
  Load JSON from the `api_spec_path` and `doc_spec_path` files and convert
  them into a context that can be used to generate code for an AWS service.
  """
  def load_context(module_name, api_spec_path, doc_spec_path) do
    api_spec = File.read!(api_spec_path) |> Poison.Parser.parse!
    doc_spec = File.read!(doc_spec_path) |> Poison.Parser.parse!
    build_context(module_name, api_spec, doc_spec)
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  defp build_context(module_name, api_spec, doc_spec) do
    actions = collect_actions(api_spec, doc_spec)
    %Service{actions: actions,
             docstring: Docstring.format(doc_spec["service"]),
             endpoint_prefix: api_spec["metadata"]["endpointPrefix"],
             json_version: api_spec["metadata"]["jsonVersion"],
             module_name: module_name,
             protocol: api_spec["metadata"]["json"],
             target_prefix: api_spec["metadata"]["targetPrefix"]}
  end

  defp collect_actions(api_spec, doc_spec) do
    Enum.map(api_spec["operations"], fn({operation, _metadata}) ->
      %Action{docstring: Docstring.format(doc_spec["operations"][operation]),
              function_name: AWS.CodeGen.Name.to_snake_case(operation),
              name: operation}
    end)
  end
end
