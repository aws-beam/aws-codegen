defmodule AWS.CodeGen.Shapes do
  @moduledoc false

  def get_input_shape(operation_spec) do
    get_in(operation_spec, ["input", "shape"])
  end

  @doc """
  It says if body should be encoded or not.

  This is needed for requests like the S3's "put object", where
  we need to send the raw body without encoding it.

  ## Example

      iex> shapes = %{
      iex>   "Body" => %{"type" => "blob"},
      iex>   "PutObjectRequest" => %{
      iex>     "type" => "structure",
      iex>     "members" => %{
      iex>       "Body" => %{
      iex>         "shape" => "Body",
      iex>         "streaming" => true
      iex>       }
      iex>     }
      iex>   }
      iex> }
      iex> input_shape = %{"shape" => "PutObjectRequest"}
      iex> AWS.CodeGen.Shapes.send_body_as_binary?(shapes, input_shape)
      true

  """
  def send_body_as_binary?(shapes, input_shape) do
    with %{"shape" => inner_shape} = inner_spec <-
           get_in(shapes, [input_shape, "members", "Body"]),
         true <- !Map.has_key?(IO.inspect(inner_spec, label: "inner shape"), "location"),
         %{"type" => type} <- Map.get(shapes, inner_shape) do
      type in ~w(blob string)
    else
      _ ->
        false
    end
  end
end
