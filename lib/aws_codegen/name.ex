defmodule AWS.CodeGen.Name do
  @names_to_capitalize ~w(iSCSI BGP CSV NFS VTL UUID)

  @doc """
  Convert `CamelCase` or `nerdyCaps` to `snake_case`.
  """
  def to_snake_case(text) do
    text
    |> String.replace(@names_to_capitalize, &String.capitalize(&1))
    |> String.to_charlist()
    |> Enum.map_join(&char_to_snake_case/1)
    |> String.trim_leading("_")
  end

  defp char_to_snake_case(char) do
    char = List.to_string([char])
    lower_char = String.downcase(char)

    if lower_char == char do
      lower_char
    else
      "_#{lower_char}"
    end
  end

  def upcase_first(<<first::utf8, rest::binary>>) do
    String.upcase(<<first::utf8>>) <> rest
  end
end
