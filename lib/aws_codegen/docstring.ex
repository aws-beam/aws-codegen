defmodule AWS.CodeGen.Docstring do
  @doc """
  Tranform HTML text into Markdown suitable for inclusion in a docstring
  heredoc in generated code.
  """
  def format(text) do
    html_to_markdown(text)
    |> split_paragraphs
    |> Enum.map(&(justify_line(&1)))
    |> Enum.join("\n\n")
  end

  @doc """
  Transform HTML tags into Markdown.
  """
  def html_to_markdown(text) do
    convert_links(text)
    |> convert_fullname
    |> String.replace("<a>", "`")
    |> String.replace("</a>", "`")
    |> String.replace("<b>", "**")
    |> String.replace("</b>", "**")
    |> String.replace("<code>", "`")
    |> String.replace("</code>", "`")
    |> String.replace("<fullname>", "")
    |> String.replace("</fullname>", "")
    |> String.replace("<i>", "*")
    |> String.replace("</i>", "*")
    |> String.replace("<p>", "")
    |> String.replace("</p>", "\n\n")
    |> String.replace("<ul>", "")
    |> String.replace("</ul>", "\n")
    |> String.replace("<li>", "* ")
    |> String.replace("</li>", "")
  end

  @doc """
  Split a block of text into a list of strings, each of which represent a
  paragraph.
  """
  def split_paragraphs(text) do
    String.split(text, "\n")
    |> Enum.map(&(String.strip(&1)))
    |> Enum.reject(&(&1 == ""))
  end

  @doc """
  Split a paragraph into individual lines, where each line is less than the
  specified maximum length.  Indent each line by two spaces to make it
  suitable for inclusion in a docstring heredoc in generated code.
  """
  def justify_line(text, max_length \\ 75) do
    break_line(text, max_length)
    |> Enum.map(&(String.strip(&1)))
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&("  #{&1}"))
    |> Enum.join("\n")
  end

  defp convert_links(text) do
    Regex.replace(~r{<a href="(.+?)">(.+?)</a>}, text, "[\\2](\\1)",
                  global: true)
  end

  defp convert_fullname(text) do
    Regex.replace(~r{<fullname>(.+?)</fullname>}, text, "", global: true)
  end

  defp break_line(text, max_length) do
    {lines, current} = List.foldl(String.split(text), {[], ""},
      fn word, {lines, current} ->
        if String.length(current) + 1 + String.length(word) > max_length do
          if current == "" do
            # The current word is the first on the current line, and is longer
            # than our max_length, so append it as a new line.
            {lines ++ [word], current}
          else
            # The current word exceeds the max length, so append the last
            # line, and start a new one with the current word.
            {lines ++ [current], word}
          end
        else
          if current == "" do
            # The current word is the first on the current line, so append it
            # as a new line.
            {lines, word}
          else
            # Append the current word to the current line.
            {lines, "#{current} #{word}"}
          end
        end
      end)
    List.flatten(lines ++ [current])
  end
end
