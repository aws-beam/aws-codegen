defmodule AWS.CodeGen.Shapes do
  alias AWS.CodeGen.Name
  @moduledoc false

  def get_input_shape(operation_spec) do
    get_in(operation_spec, ["input", "shape"])
  end

  def get_output_shape(operation_spec) do
    get_in(operation_spec, ["output", "shape"])
  end

  def body_as_binary?(shapes, shape) do
    with %{"shape" => body_shape} = inner_spec <-
           get_in(shapes, [shape, "members", "Body"]),
         true <- !Map.has_key?(inner_spec, "location"),
         %{"type" => type} <- Map.get(shapes, body_shape) do
      type in ~w(blob string)
    else
      _ ->
        false
    end
  end
end
