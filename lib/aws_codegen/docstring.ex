defmodule AWS.CodeGen.Docstring do
  def reflow(text) do
    split_paragraphs(text)
    |> justify_paragraphs
    |> indent_paragraphs
    |> join_paragraphs
  end

  defp split_paragraphs(text) do
    String.replace(text, "<code>", "`")
    |> String.replace("</code>", "`")
    |> String.replace("<fullname>", "")
    |> String.replace("</fullname>", "")
    |> String.replace("<p>", "")
    |> String.replace("</p>", "\n\n")
    |> String.split("\n")
    |> Enum.map(&(String.strip(&1)))
  end

  defp justify_paragraphs(paragraphs) do
    Enum.map(paragraphs, &justify_paragraph/1)
  end

  defp justify_paragraph(text) do
    String.to_char_list(text)
    |> Enum.with_index
    |> Enum.reverse
    |> justify_paragraph([])
    |> List.flatten
    |> List.to_string
  end

  defp justify_paragraph([], acc) do
    Enum.join(acc, "\n")
  end

  defp justify_paragraph(text, acc) do
    index = find_split_index(text)
    Enum.split(text, index)
  end

  defp find_split_index([{char, index}|tail]) do
    if index < 76 && char == ?  do
      index
    else
      find_split_index([{char, index}|tail] = tail)
    end
  end

  # defp justify_paragraphs(paragraphs) do
  #   Enum.map(paragraphs, &justify_paragraph/1)
  # end

  # defp justify_paragraph(text) do
  #   justify_paragraph(text, length(text), [])
  # end

  # defp justify_paragraph(text, length, acc) when length < 76 do
  #   [acc | String.strip(text)]
  # end

  # defp justify_paragraph(text, length, acc) do
  #   index = find_split_index(text)
  #   {text, remaining} = String.split_at(text, index)
  #   justify_paragraph(remaining, length(remaining), [acc | String.strip(text)])
  # end

  # defp find_split_index(text) do
  #   find_split_index(text, 0, 0)
  # end

  # defp find_split_index(text, last_split_index, index) do
  #   cond do
  #     text[index]
  #   end
  # end

  defp indent_paragraphs(paragraphs) do
    paragraphs
  end

  defp join_paragraphs(paragraphs) do
    paragraphs
  end
end
