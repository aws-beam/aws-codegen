defmodule AWS.CodeGen.RestJSONService do
  alias AWS.CodeGen.Docstring

  defmodule Parameter do
    defstruct code_name: nil,
              name: nil
  end

  defmodule Action do
    defstruct docstring: nil,
              function_name: nil,
              name: nil,
              parameters: nil,
              expected_status_code: nil

    def function_parameters(action)
      ""
    end

    def url(action)
    end
  end

  defmodule Service do
    defstruct abbreviation: nil,
              actions: [],
              docstring: nil,
              endpoint_prefix: nil,
              json_version: nil,
              module_name: nil,
              target_prefix: nil
  end

  @doc """
  Load a JSON service specification from the file `path` and convert it to a
  context that can be used to generate code for an AWS service.
  """
  def load_context(module_name, path) do
    File.read!(path) |> Poison.Parser.parse! |> build_context(module_name)
  end

  @doc """
  Render a code template.
  """
  def render(context, template_path) do
    EEx.eval_file(template_path, [context: context])
  end

  defp build_context(data, module_name) do
    actions = collect_actions(data)
    %Service{actions: actions,
             docstring: Docstring.format(data["documentation"]),
             endpoint_prefix: data["metadata"]["endpointPrefix"],
             json_version: data["metadata"]["jsonVersion"],
             module_name: module_name,
             target_prefix: data["metadata"]["targetPrefix"]}
  end

  defp collect_actions(data) do
    Enum.map(data["operations"], fn({_action, metadata}) ->
      %Action{docstring: Docstring.format(metadata["documentation"]),
              function_name: AWS.CodeGen.Name.to_snake_case(metadata["name"]),
              name: metadata["name"]}
    end)
  end
end
