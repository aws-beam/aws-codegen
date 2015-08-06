defmodule AWS.CodeGen.Name do
  @doc """
  Convert `CamelCase` or `nerdyCaps` to `snake_case`.
  """
  def to_snake_case(text) do
    String.replace(text, "iSCSI", "Iscsi")
    |> String.replace("VTL", "Vtl")
    |> String.replace("UUID", "Uuid")
    |> String.to_char_list
    |> Enum.map_join(&char_to_snake_case/1)
    |> String.lstrip(?_)
  end

  defp char_to_snake_case(char) do
    char = List.to_string([char])
    lower_char = String.downcase(char)
    case lower_char == char do
      true ->
        lower_char
      false ->
        "_#{lower_char}"
    end
  end
end
