defmodule AWS.CodeGen.Docstring do
  @max_elixir_line_length 80
  @max_erlang_line_length 74
  @two_spaces "&nbsp;&nbsp;"
  @two_break_lines "\n\n"
  @list_tags ~w(ul ol)

  @doc """
  Transform HTML text into Markdown suitable for inclusion in a docstring
  heredoc in generated Elixir or Erlang code.
  """
  def format(:elixir, text) do
    docstring =
      text
      |> html_to_markdown()
      |> fix_broken_markdown_links()
      |> fix_elixir_lookalike_format_strings()
      |> fix_html_spaces()
      |> fix_long_break_lines()
      |> transform_subtitles()
      |> String.trim_trailing()

    # Split off the beginning of the docs.
    [docstring_header, _docstring_rest] =
      case String.split(docstring, "\n", parts: 3, trim: true) do
        [a, b, rest] ->
          [a <> "\n" <> b, rest]

        [a, b] ->
          [a, b]

        [a] ->
          [a, ""]

        [] ->
          ["", ""]
      end

    docstring_header |> Excribe.format(width: 80, hanging: 2)
  end

  def format(:erlang, nil), do: ""
  def format(:erlang, ""), do: ""

  def format(:erlang, text) do
    html = html_to_edoc(text)

    "@doc #{split_first_sentence_in_one_line(html)}"
    |> split_paragraphs()
    |> Enum.map(&justify_line(&1, @max_erlang_line_length, "%% "))
    |> Enum.join("\n")
    |> fix_long_break_lines()
    |> escape_ellipsis_followed_by_dot()
    |> String.trim_trailing()
    |> String.replace(@two_break_lines, "\n%%\n")
    |> String.replace(~r/&#39;/, "'")
    # aws-sdk-go docs are broken for this, hack it to make the edocs work
    |> String.replace("`AVAILABLE`", "`AVAILABLE'")
    # aws-sdk-go docs are broken for this, hack it to make the edocs work
    |> String.replace("`PENDING`", "`PENDING'")
  end

  defp split_first_sentence_in_one_line(doc) do
    case String.split(doc, ~r/\.[\s\n]/, parts: 2) do
      [first, rest] ->
        first <> ".#{@two_break_lines}" <> rest

      [doc] ->
        doc
    end
  end

  # It searches for links with breaking lines and remove them.
  # Since performance is not an issue here, we are doing this post processing.
  defp fix_broken_markdown_links(text) do
    String.replace(text, ~r/\[([^\n]+)\n\s\s([^]]+)\]/, "[\\1 \\2]")
  end

  defp fix_elixir_lookalike_format_strings(text) do
    String.replace(text, ~r/#\{(.*?)\}/, "\\1")
  end

  # We added these spaces for each list level.
  defp fix_html_spaces(text) do
    String.replace(text, "&nbsp;", " ")
  end

  # aws-sdk-go docs may use .... to act as a "wildcard" which breaks edocs with the following error:
  # warning: found "..." followed by ".", please use parens around "..." instead
  # so let's do exactly what edoc is suggesting
  defp escape_ellipsis_followed_by_dot(text) do
    String.replace(text, "....", "(...).")
  end

  defp fix_long_break_lines(text) do
    String.replace(text, ~r/[\n]{3,}/, @two_break_lines)
  end

  # Transform `**Subtitle**` into `## Subtitle`
  defp transform_subtitles(text) do
    String.replace(text, ~r/[*]{2}([^*]+)[*]{2}\n/, "## \\1\n")
  end

  @doc """
  Transform HTML tags into Markdown.
  """
  def html_to_markdown(nil), do: ""

  def html_to_markdown(text) when is_binary(text) do
    {:ok, document} = Floki.parse_fragment(text)

    document
    |> Floki.traverse_and_update(&update_nodes/1)
    |> Floki.traverse_and_update(&format_html_lists/1)
    |> Floki.raw_html(encode: false)
  end

  defp format_html_lists({"ul", _, children}) do
    updated_children =
      children
      |> prepend_to_list_items("* ")
      |> append_new_line_to_list_items()

    Floki.text(updated_children) <> @two_break_lines
  end

  defp format_html_lists({"ol", _, children}) do
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

    Floki.text(updated_children) <> @two_break_lines
  end

  defp format_html_lists(other), do: other

  defp update_nodes({"code", _, children}) do
    text = Floki.text(children)

    if String.contains?(text, "\n") do
      "#{@two_break_lines}```\n#{text}\n```#{@two_break_lines}"
    else
      "`#{text}`"
    end
  end

  defp update_nodes({tag, _, children}) when tag in ~w(b strong),
    do: "**#{Floki.text(children)}**"

  defp update_nodes({tag, _, children}) when tag in ~w(i em), do: "*#{Floki.text(children)}*"

  defp update_nodes({tag, _, children}) when tag in ~w(p fullname note important),
    do: (Floki.text(children) |> String.replace("\n", " ")) <> @two_break_lines

  defp update_nodes({"a", attrs, children}) do
    case Enum.find(attrs, fn {attr, _} -> attr == "href" end) do
      {_, href} ->
        "[#{Floki.text(children)}](#{href})"

      nil ->
        "`#{Floki.text(children)}`"
    end
  end

  # We need to first prepend two HTML spaces to all lists
  # inside the tree before formatting it correctly.
  defp update_nodes({tag, attrs, children}) when tag in @list_tags do
    new_content = prepend_to_list_items(children, @two_spaces)

    subtree =
      Floki.traverse_and_update(new_content, fn
        {tag, attrs, children} when tag in @list_tags ->
          {tag, attrs, prepend_to_list_items(children, @two_spaces)}

        other ->
          other
      end)

    {tag, attrs, subtree}
  end

  defp update_nodes({"div", attrs, children}) do
    case attrs do
      [{"class", "seeAlso"}] ->
        "See also: " <> Floki.text(children) <> @two_break_lines

      _ ->
        Floki.text(children) <> @two_break_lines
    end
  end

  defp update_nodes({"dl", _, definitions}) do
    io_data = ["## Definitions", @two_break_lines]

    definitions
    |> Enum.reduce(io_data, fn element, data ->
      case element do
        {"dt", _, term} ->
          [data | ["### ", Floki.text(term), @two_break_lines]]

        {"dd", _, definition} ->
          [data | [Floki.text(definition), @two_break_lines]]

        other when is_binary(other) ->
          [data | other]

        other ->
          [data | Floki.text(other)]
      end
    end)
    |> IO.iodata_to_binary()
  end

  defp update_nodes({"pre", _, [content]}) when is_binary(content) do
    html_to_markdown(content)
  end

  defp update_nodes(other), do: other

  defp prepend_to_list_items(content, text) do
    Enum.flat_map(content, fn
      {"li", _, _} = li ->
        [text, li]

      other ->
        [other]
    end)
  end

  defp append_new_line_to_list_items(content) do
    Enum.flat_map(content, fn
      {"li", _, children} = li ->
        if with_html_lists?(children) do
          [li]
        else
          [li, "\n"]
        end

      other ->
        [other]
    end)
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

  def html_to_edoc(text) when is_binary(text) do
    {:ok, document} = Floki.parse_fragment(text)

    document
    |> Floki.traverse_and_update(fn
      {"p", [{"class", "title"}], title} ->
        text =
          title
          |> Floki.text()
          |> String.trim()

        "== #{text} ==#{@two_break_lines}"

      {tag, _, _} = html_node when tag in ~w(p fullname note important div) ->
        update_nodes(html_node)

      {"pre", _, children} ->
        children
        |> Floki.text()
        |> String.replace(~r/(^`|'$)/, "")

      {"code", _, children} ->
        text = Floki.text(children)

        if String.contains?(text, "\n") do
          "\n```\n#{String.replace(text, "\n", "")}'''"
        else
          ## ex_doc blows up on these sorts of things as it sees them as a reference to a function.
          ## Just ignore them as they refer to aws-sdk-go based implementations and we don't really care about that
          if String.ends_with?(text, "()") do
            ""
          else
            "`#{text}'"
          end
        end

      {"a", attrs, children} ->
        case Enum.find(attrs, fn {attr, _} -> attr == "href" end) do
          {_, href} ->
            text = Floki.text(children)

            if text == href do
              "[#{href}]"
            else
              "#{text}: #{href}"
            end

          nil ->
            "`#{Floki.text(children)}'"
        end

      {_, _attrs, children} ->
        "#{Floki.text(children)}"
    end)
    |> Floki.raw_html(encode: true)
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

  def docs_url(shapes, operation) do
    service_name =
      shapes
      |> Map.keys()
      |> List.first()
      |> then(fn name ->
        name
        |> String.split("#")
        |> hd()
        |> String.split(".")
        |> List.last()
      end)

    op_name = operation |> String.split("#") |> List.last()

    "https://docs.aws.amazon.com/search/doc-search.html?searchPath=documentation&searchQuery=#{service_name}%20#{op_name}&this_doc_guide=API%2520Reference"
  end
end
