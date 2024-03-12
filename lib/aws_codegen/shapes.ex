defmodule AWS.CodeGen.Shapes do

  defmodule Shape do
    defstruct name: nil,
            type: nil,
            members: [],
            member: [],
            enum: [],
            min: nil,
            required: [],
            is_input: nil
  end

  def get_input_shape(operation_spec) do
    get_in(operation_spec, ["input", "target"])
  end

  def get_output_shape(operation_spec) do
    get_in(operation_spec, ["output", "target"])
  end

  def collect_shapes(_language, api_spec) do
    api_spec["shapes"]
    |> Map.new(fn {name, shape} ->
      {name,
       %Shape{
         name: name,
         type: shape["type"],
         member: shape["member"],
         members: shape["members"],
         min: shape["min"],
         enum: shape["enum"],
         is_input: is_input?(shape)
       }}
    end)
  end

  def body_as_binary?(shapes, shape) do
    ## TODO: Should we validate or search for trait `smithy.api#httpPayload` rather than
    ##  trust that the member is always named `Body`?
    inner_spec = get_in(shapes, [shape, "members", "Body"])
    if is_map(inner_spec) && Map.has_key?(inner_spec, "target") do
      ## TODO: we should extract the type from the actual shape `type` rather than infer it from the naming
      inner_spec["target"]
      |> String.downcase()
      |> String.contains?(["blob", "string"])
    else
      false
    end
  end

  def is_input?(shape) do
    !Map.has_key?(shape, "traits") or Map.has_key?(shape["traits"], "smithy.api#input")
  end

end
