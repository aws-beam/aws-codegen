defmodule AWS.CodeGen.DocstringTest do
  use ExUnit.Case
  alias AWS.CodeGen.Docstring

  test "format/1 is effectively a no-op when an empty string is provided" do
    assert "" == Docstring.format("")
  end

  test "format/1 converts tags to Markdown and indents the text by 2 spaces" do
    text = "<p>Hello,</p> <p><code>world</code></p>!"
    assert "  Hello,\n\n  `world`\n\n  !" == Docstring.format(text)
  end

  test "html_to_markdown/1 replaces <code> tags with backticks" do
    text = "Hello, <code>world</code>!"
    assert "Hello, `world`!" == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 strips <fullname> tags and renders text as a paragraph" do
    text = "<fullname>Hello, world!</fullname>"
    assert "Hello, world!\n\n" == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 converts <p> tags to newline-separated paragraphs" do
    text = "<p>Hello,</p> <p>world!</p>"
    assert "Hello,\n\n world!\n\n" == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 converts <a> tags to Markdown links" do
    text = ~s(<a href="http://example.com">Hello, world!</a>)
    expected = ~s<[Hello, world!](http://example.com)>
    assert expected == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 replaces bare <a> tags with backticks" do
    text = "<a>Hello, world!</a>"
    assert "`Hello, world!`" == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 converts multiple <a> tags to Markdown links" do
    text = ~s(<a href="http://example.com">Hello, world!</a>)
    expected = ~s<[Hello, world!](http://example.com)>
    assert "#{expected} #{expected}" == Docstring.html_to_markdown("#{text} #{text}")
  end

  test "html_to_markdown/1 replaces <i> tags with asterisks" do
    text = "<i>Hello, world!</i>"
    assert "*Hello, world!*" == Docstring.html_to_markdown(text)
  end

  test "html_to_markdown/1 replaces <b> tags with double-asterisks" do
    text = "<b>Hello, world!</b>"
    assert "**Hello, world!**" == Docstring.html_to_markdown(text)
  end

  test "split_paragraphs/1 converts an empty paragraph to an empty list" do
    assert [] == Docstring.split_paragraphs("")
  end

  test "split_paragraphs/1 converts a single paragraph to a single item list" do
    assert ["Hello, world!"] == Docstring.split_paragraphs("Hello, world!")
  end

  test "split_paragraphs/1 splits paragraphs and returns them in a list" do
    paragraphs = "Hello, world!\nHow are you?"
    expected = ["Hello, world!", "How are you?"]
    assert expected == Docstring.split_paragraphs(paragraphs)
  end

  test "split_paragraphs/1 ignores empty lines" do
    paragraphs = "Hello, world!\n\nHow are you?\n"
    expected = ["Hello, world!", "How are you?"]
    assert expected == Docstring.split_paragraphs(paragraphs)
  end

  test "justify_line/2 is a no-op if the line to justify is empty" do
    assert "" == Docstring.justify_line("")
  end

  test "justify_line/2 is a no-op if the line to justify is shorter than the requested length" do
    assert "  Hello, world!" == Docstring.justify_line("Hello, world!")
  end

  test "justify_line/2 splits lines and strips trailing whitespace so that each line is shorter than the requested length" do
    assert "  Hello,\n  world!" == Docstring.justify_line("Hello, world!", 7)
  end

  test "justify_line/2 splits lines as early as possible when a word is longer than the requested length" do
    assert "  Hello,\n  world!" == Docstring.justify_line("Hello, world!", 3)
  end
end
