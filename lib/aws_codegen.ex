defmodule AWS.CodeGen do
  alias AWS.CodeGen.Docstring

  defmodule Action do
    defstruct name: nil,
              function_name: nil,
              docstring: nil
  end

  defmodule Service do
    defstruct api_version: nil,
              abbreviation: nil,
              endpoint_prefix: nil,
              protocol: nil,
              json_version: nil,
              docstring: nil,
              actions: []
  end

  @doc """
  Load JSON from the file `path` and convert it to a context that can be used
  to generate code for an AWS service.
  """
  def load_context(path) do
    File.read!(path) |> Poison.Parser.parse! |> build_context
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  defp build_context(data) do
    actions = collect_actions(data)
    %Service{api_version: data["metadata"]["apiVersion"],
             abbreviation: data["metadata"]["serviceAbbreviation"],
             endpoint_prefix: data["metadata"]["endpointPrefix"],
             protocol: data["metadata"]["json"],
             json_version: data["metadata"]["jsonVersion"],
             docstring: Docstring.format(data["documentation"]),
             actions: actions}
  end

  defp collect_actions(data) do
    Enum.map(data["operations"], fn({_action, metadata}) ->
      %Action{name: metadata["name"],
              function_name: AWS.CodeGen.Name.to_snake_case(metadata["name"]),
              docstring: Docstring.format(metadata["documentation"])}
    end)
  end
end
