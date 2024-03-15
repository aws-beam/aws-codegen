defmodule AWS.CodeGen.Types do

  alias AWS.CodeGen.Shapes.Shape

  # Unfortunately, gotta patch over auto-defining types that already exist in Elixir

  def shape_to_type(:elixir, "String", _), do: "String.t()"
  def shape_to_type(:erlang, "String", _), do: "string()"
  def shape_to_type(:elixir, "string", _), do: "String.t()"
  def shape_to_type(:erlang, "string", _), do: "string()"
  def shape_to_type(:elixir, "Identifier", _), do: "String.t()"
  def shape_to_type(:erlang, "Identifier", _), do: "string()"
  def shape_to_type(:elixir, "identifier", _), do: "String.t()"
  def shape_to_type(:erlang, "identifier", _), do: "string()"
  def shape_to_type(:elixir, "XmlString" <> _rest, _), do: "String.t()"
  def shape_to_type(:erlang, "XmlString" <> _rest, _), do: "string"
  def shape_to_type(:elixir, "NullablePositiveInteger", _), do: "nil | non_neg_integer()"
  def shape_to_type(:erlang, "NullablePositiveInteger", _), do: "undefined | non_neg_integer()"
  def shape_to_type(_, %Shape{type: type}, _module_name) when type in ["float", "double", "long"], do: "float()"
  def shape_to_type(_, %Shape{type: "timestamp"}, _module_name), do: "non_neg_integer()"
  def shape_to_type(_, %Shape{type: "map"}, _module_name), do: "map()"
  def shape_to_type(_, %Shape{type: "blob"}, _module_name), do: "binary()"
  def shape_to_type(:elixir, %Shape{type: "string"}, _module_name), do: "String.t()"
  def shape_to_type(:erlang, %Shape{type: "string"}, _module_name), do: "string()"
  def shape_to_type(_, %Shape{type: "integer"}, _module_name), do: "integer()"
  def shape_to_type(_, %Shape{type: "boolean"}, _module_name), do: "boolean()"
  def shape_to_type(_, %Shape{type: "enum"}, _module_name), do: "list(any())"
  def shape_to_type(_, %Shape{type: "union"}, _module_name), do: "list()"
  def shape_to_type(_, %Shape{type: "document"}, _module_name), do: "any()"

  def shape_to_type(context, shape_name, module_name, all_shapes) do
    case shape_name do
      "smithy.api#String" ->
        "[#{shape_to_type(context.language, %Shape{type: "string"}, module_name)}]"

      "smithy.api#Integer" ->
        "[#{shape_to_type(context.language, %Shape{type: "integer"}, module_name)}]"

      "smithy.api#Timestamp" ->
        "[#{shape_to_type(context.language, %Shape{type: "timestamp"}, module_name)}]"

      "smithy.api#PrimitiveLong" ->
        "[#{shape_to_type(context.language, %Shape{type: "long"}, module_name)}]"

      "smithy.api#Long" ->
        "[#{shape_to_type(context.language, %Shape{type: "long"}, module_name)}]"

      "smithy.api#Boolean" ->
        "[#{shape_to_type(context.language, %Shape{type: "boolean"}, module_name)}]"

      "smithy.api#PrimitiveBoolean" ->
        "[#{shape_to_type(context.language, %Shape{type: "boolean"}, module_name)}]"

      "smithy.api#Double" ->
        "[#{shape_to_type(context.language, %Shape{type: "double"}, module_name)}]"

      "smithy.api#Document" ->
        "[#{shape_to_type(context.language, %Shape{type: "document"}, module_name)}]"

      "smithy.api#Unit" ->
        "[]"

      "smithy.api#Float" ->
        "[#{shape_to_type(context.language, %Shape{type: "float"}, module_name)}]"

      "smithy.api#Blob" ->
        "[#{shape_to_type(context.language, %Shape{type: "blob"}, module_name)}]"

      _ ->
        case all_shapes[shape_name] do

          %Shape{type: "structure"} ->
            type = "#{AWS.CodeGen.Name.to_snake_case(String.replace(shape_name, ~r/com\.amazonaws\.[^#]+#/, ""))}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}()"
            else
              "#{type}()"
            end

          %Shape{type: "list", member: member} ->
            type = "#{shape_to_type(context, member["target"], module_name, all_shapes)}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "list(#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}())"
            else
              "list(#{type}())"
            end

          nil ->
            raise "Tried to reference an undefined shape for #{shape_name}"

          shape ->
            shape_to_type(context.language, shape, module_name)
        end
    end
  end
end
