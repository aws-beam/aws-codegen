defmodule AWS.CodeGen.Docstring do
  @max_elixir_line_length 98
  @two_spaces "&nbsp;&nbsp;"
  @list_tags ~w(ul ol)

  @doc """
  Tranform HTML text into Markdown suitable for inclusion in a docstring
  heredoc in generated Elixir code.
  """
  def format(:elixir, text) do
    text
    |> html_to_markdown()
    |> split_first_sentence_in_one_line()
    |> split_paragraphs()
    |> Enum.map(&justify_line(&1, @max_elixir_line_length))
    |> Enum.join("\n")
    |> fix_broken_markdown_links()
    |> fix_html_spaces()
    |> fix_long_break_lines()
    |> String.trim_trailing()
  end

  def format(:erlang, nil), do: ""
  def format(:erlang, ""), do: ""

  def format(:erlang, text) do
    "@doc #{text}"
    |> html_to_edoc
    |> split_paragraphs
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&justify_line(&1, 74, "%% "))
    |> Enum.join("\n%%\n")
  end

  defp split_first_sentence_in_one_line(doc) do
    String.replace(doc, ~r/^([^.!]*)([.!])\s/, "\\1\\2\n\n", global: false)
  end

  # It searches for links with breaking lines and remove the breaking line.
  # Since performance is not an issue here, we are doing this post processing.
  defp fix_broken_markdown_links(text) do
    String.replace(text, ~r/\[([^\n]+)\n\s\s([^]]+)\]/, "[\\1 \\2]")
  end

  defp fix_html_spaces(text) do
    String.replace(text, "&nbsp;", " ")
  end

  defp fix_long_break_lines(text) do
    String.replace(text, ~r/[\n]{3,}/, "\n\n")
  end

  @doc """
  Transform HTML tags into Markdown.
  """
  def html_to_markdown(nil), do: ""

  def html_to_markdown(text) do
    {:ok, document} = Floki.parse_fragment(text)

    tree =
      Floki.traverse_and_update(document, &update_nodes/1)
      |> Floki.traverse_and_update(fn
        {"ul", attrs, children} ->
          updated_children =
            children
            |> prepend_to_list_items("* ")
            |> append_new_line_to_list_items()

          {"ul", attrs, updated_children}

        {"ol", attrs, children} ->
          {_, elements} =
            Enum.reduce(children, {0, []}, fn el, {count, elements} ->
              case el do
                {"li", _, _} ->
                  count = count + 1
                  {count, [["#{count}. ", el] | elements]}

                other ->
                  {count, [other | elements]}
              end
            end)

          updated_children =
            elements
            |> Enum.reverse()
            |> List.flatten()
            |> append_new_line_to_list_items()

          {"ol", attrs, updated_children}

        other ->
          other
      end)
      |> Floki.traverse_and_update(fn
        {tag, _, children} when tag in @list_tags ->
          Floki.text(children)

        other ->
          other
      end)

    Floki.raw_html(tree, encode: false)
    |> String.replace(~r/<\/?(a|code)>/, "`")
    |> String.replace(~r/<\/?(b|strong)>/, "**")
    |> String.replace(~r/<\/?(i|em)>/, "*")
    |> String.replace(~r/<(p|fullname|note)( class=[^>]+)?>/, "")
    |> String.replace(~r/<\/(p|fullname|note)>/, "\n\n")
  end

  defp update_nodes({"a", attrs, content}) do
    case Enum.find(attrs, fn {attr, _} -> attr == "href" end) do
      {_, href} ->
        "[#{Floki.text(content)}](#{href})"

      nil ->
        "`#{Floki.text(content)}`"
    end
  end

  defp update_nodes({tag, attrs, content}) when tag in @list_tags do
    new_content = prepend_to_list_items(content, @two_spaces)

    subtree =
      Floki.traverse_and_update(new_content, fn
        {tag, attrs, children} when tag in @list_tags ->
          {tag, attrs, prepend_to_list_items(children, @two_spaces)}

        other ->
          other
      end)

    {tag, attrs, subtree}
  end

  defp update_nodes(other), do: other

  defp prepend_to_list_items(content, text) do
    content
    |> Enum.map(fn
      {"li", _, _} = li ->
        [text, li]

      other ->
        other
    end)
    |> List.flatten()
  end

  defp append_new_line_to_list_items(content) do
    content
    |> Enum.map(fn
      {"li", _, children} = li ->
        if with_html_lists?(children) do
          li
        else
          [li, "\n"]
        end

      other ->
        other
    end)
    |> List.flatten()
  end

  defp with_html_lists?(children) do
    Enum.any?(children, fn
      {tag, _, _} when tag in @list_tags -> true
      _ -> false
    end)
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
    |> Enum.map(&String.trim_trailing(&1))
  end

  @doc """
  Split a paragraph into individual lines, where each line is less than the
  specified maximum length.  Indent each line by two spaces to make it
  suitable for inclusion in a docstring heredoc in generated code.
  """
  def justify_line(text, max_length \\ 75, indent \\ "  ") do
    text
    |> break_line(max_length)
    |> Enum.map(&String.trim_trailing(&1))
    |> Enum.map(fn line ->
      if line == "" do
        line
      else
        "#{indent}#{line}"
      end
    end)
    |> Enum.join("\n")
  end

  defp break_line(text, max_length) do
    {lines, current} =
      List.foldl(String.split(text), {[], ""}, fn word, {lines, current} ->
        if String.length(current) + 1 + String.length(word) > max_length do
          if current == "" do
            # The current word is the first on the current line, and is
            # longer than our max_length, so append it as a new line.
            {lines ++ [word], current}
          else
            # The current word exceeds the max length, so append the last
            # line, and start a new one with the current word.
            {lines ++ [current], word}
          end
        else
          if current == "" do
            # The current word is the first on the current line, so append
            # it as a new line.
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
