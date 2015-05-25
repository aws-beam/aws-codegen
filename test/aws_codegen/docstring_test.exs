defmodule AWS.CodeGen.DocstringTest do
  use ExUnit.Case
  alias AWS.CodeGen.Docstring

  test "reflow/1 transforms HTML descriptions into docstrings" do
    expected = """
  Adds or updates tags for the specified Amazon Kinesis stream. Each stream
  can have up to 10 tags.

  If tags have already been assigned to the stream, `AddTagsToStream`
  overwrites any existing tags that correspond to the specified tag keys.
"""
    assert expected == Docstring.reflow("<p>Adds or updates tags for the specified Amazon Kinesis stream. Each stream can have up to 10 tags. </p> <p>If tags have already been assigned to the stream, <code>AddTagsToStream</code> overwrites any existing tags that correspond to the specified tag keys.</p>")
  end
end
