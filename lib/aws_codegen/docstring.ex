defmodule AWS.CodeGen.Docstring do
  @doc """
  Tranform HTML text into Markdown suitable for inclusion in a docstring
  heredoc in generated Elixir code.
  """
  def format(:elixir, text) do
    text
    |> html_to_markdown
    |> split_paragraphs
    |> Enum.map(&(justify_line(&1)))
    |> Enum.join("\n\n")
  end

  @doc """
  Tranform HTML text into Markdown suitable for inclusion in a docstring
  heredoc in generated Erlang code.
  """
  def format(:erlang, nil), do: ""
  def format(:erlang, ""), do: ""
  def format(:erlang, text) do
    "@doc #{text}"
    |> html_to_edoc
    |> split_paragraphs
    |> Enum.map(&(justify_line(&1, 74, "%% ")))
    |> Enum.join("\n%%\n")
  end

  @doc """
  Transform HTML tags into Markdown.

  `UL` and `LI` tags are left unchanged because the simple conversion logic
  here doesn't handle nesting correctly.  Markdown lists would be nicer to
  read in text-format, but Pandoc correctly renders HTML lists in the ExDoc
  output.
  """
  def html_to_markdown(nil), do: ""
  def html_to_markdown(text) do
    text
    |> convert_links
    |> String.replace("<a>", "`")
    |> String.replace("</a>", "`")
    |> String.replace("<b>", "**")
    |> String.replace("</b>", "**")
    |> String.replace("<code>", "`")
    |> String.replace("</code>", "`")
    |> String.replace("<fullname>", "")
    |> String.replace("</fullname>", "\n\n")
    |> String.replace("<i>", "*")
    |> String.replace("</i>", "*")
    |> String.replace("<p>", "")
    |> String.replace("</p>", "\n\n")
  end

  @doc """
  Transform HTML tags into edoc.

  `P` tags are replaced with newlines and other tags are left unchanged.
  """
  def html_to_edoc(nil), do: ""
  def html_to_edoc(text) do
    text
    |> String.replace("</fullname>", "</fullname>\n\n")
    |> String.replace("<p>", "")
    |> String.replace("</p>", "\n\n")
  end

  @doc """
  Split a block of text into a list of strings, each of which represent a
  paragraph.
  """
  def split_paragraphs(text) do
    text
    |> String.split("\n")
    |> Enum.map(&(String.strip(&1)))
    |> Enum.reject(&(&1 == ""))
  end

  @doc """
  Split a paragraph into individual lines, where each line is less than the
  specified maximum length.  Indent each line by two spaces to make it
  suitable for inclusion in a docstring heredoc in generated code.
  """
  def justify_line(text, max_length \\ 75, indent \\ "  ") do
    text
    |> break_line(max_length)
    |> Enum.map(&(String.strip(&1)))
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&("#{indent}#{&1}"))
    |> Enum.join("\n")
  end

  defp convert_links(text) do
    Regex.replace(~r{<a href="(.+?)">(.+?)</a>}, text, "[\\2](\\1)",
                  global: true)
  end

  defp break_line(text, max_length) do
    {lines, current} = List.foldl(String.split(text), {[], ""},
      fn word, {lines, current} ->
        case String.length(current) + 1 + String.length(word) > max_length do
          true ->
            case current == "" do
              true ->
                # The current word is the first on the current line, and is
                # longer than our max_length, so append it as a new line.
                {lines ++ [word], current}
              false ->
                # The current word exceeds the max length, so append the last
                # line, and start a new one with the current word.
                {lines ++ [current], word}
            end
          false ->
            case current == "" do
              true ->
                # The current word is the first on the current line, so append
                # it as a new line.
                {lines, word}
              false ->
                # Append the current word to the current line.
                {lines, "#{current} #{word}"}
            end
        end
      end)
    List.flatten(lines ++ [current])
  end
end
