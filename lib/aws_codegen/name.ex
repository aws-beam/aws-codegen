defmodule AWS.CodeGen.Name do
  def to_snake_case(text) do
    String.to_char_list(text)
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
