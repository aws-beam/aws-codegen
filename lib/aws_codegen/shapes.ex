defmodule AWS.CodeGen.Shapes do
  @moduledoc false

  def get_input_shape(operation_spec) do
    get_in(operation_spec, ["input", "shape"])
  end

  def send_body_as_binary?(shapes, input_shape) do
    with %{"shape" => inner_shape} = inner_spec <-
           get_in(shapes, [input_shape, "members", "Body"]),
         true <- !Map.has_key?(inner_spec, "location"),
         %{"type" => type} <- Map.get(shapes, inner_shape) do
      type in ~w(blob string)
    else
      _ ->
        false
    end
  end
end
