defmodule AWS.CodeGen do
  defmodule Action do
    defstruct name: nil,
              function_name: nil,
              documentation: nil,
              docstring: "implement docstring"
  end

  defmodule Service do
    defstruct api_version: nil,
              abbreviation: nil,
              endpoint_prefix: nil,
              protocol: nil,
              json_version: nil,
              documentation: nil,
              docstring: "implement docstring",
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

  @doc """
  Build a Service context struct from raw JSON data about an AWS service.
  """
  defp build_context(data) do
    actions = collect_actions(data)
    %Service{api_version: data["metadata"]["apiVersion"],
             abbreviation: data["metadata"]["serviceAbbreviation"],
             endpoint_prefix: data["metadata"]["endpointPrefix"],
             protocol: data["metadata"]["json"],
             json_version: data["metadata"]["jsonVersion"],
             documentation: data["documentation"],
             actions: actions}
  end

  @doc """
  Collect actions from the raw JSON data and transform them into Action
  context structs.
  """
  defp collect_actions(data) do
    Enum.map(data["operations"], fn({_action, metadata}) ->
      %Action{name: metadata["name"],
              function_name: AWS.CodeGen.Name.to_snake_case(metadata["name"]),
              documentation: metadata["documentation"]}
    end)
  end
end
