defmodule AWS.CodeGen.Types do

  # Unfortunately, gotta patch over auto-defining types that already exist in Elixir

  def shape_to_type(:elixir, "String", _) do
    "String.t()"
  end
  def shape_to_type(:erlang, "String", _) do
    "string()"
  end

  def shape_to_type(:elixir, "string", _) do
    "String.t()"
  end
  def shape_to_type(:erlang, "string", _) do
    "string()"
  end

  def shape_to_type(:elixir, "Identifier", _) do
    "String.t()"
  end
  def shape_to_type(:erlang, "Identifier", _) do
    "string()"
  end

  def shape_to_type(:elixir, "identifier", _) do
    "String.t()"
  end
  def shape_to_type(:erlang, "identifier", _) do
    "string()"
  end

  def shape_to_type(:elixir, "XmlString" <> _rest, _) do
    "String.t()"
  end
  def shape_to_type(:erlang, "XmlString" <> _rest, _) do
    "string"
  end

  def shape_to_type(:elixir, "NullablePositiveInteger", _) do
    "nil | non_neg_integer()"
  end
  def shape_to_type(:erlang, "NullablePositiveInteger", _) do
    "undefined | non_neg_integer()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: type}, _module_name) when type in ["float", "double", "long"] do
    "float()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: type}, _module_name) when type in ["float", "double", "long"] do
    "float()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "timestamp"}, _module_name) do
    "non_neg_integer()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "timestamp"}, _module_name) do
    "non_neg_integer()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "map"}, _module_name) do
    "map()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "map"}, _module_name) do
    "map()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "blob"}, _module_name) do
    "binary()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "blob"}, _module_name) do
    "binary()"
  end

  def shape_to_type(:elixir, %AWS.CodeGen.PostService.Shape{type: "string"}, _module_name) do
    "String.t()"
  end
  def shape_to_type(:erlang, %AWS.CodeGen.PostService.Shape{type: "string"}, _module_name) do
    "string()"
  end
  def shape_to_type(:elixir, %AWS.CodeGen.RestService.Shape{type: "string"}, _module_name) do
    "String.t()"
  end
  def shape_to_type(:erlang, %AWS.CodeGen.RestService.Shape{type: "string"}, _module_name) do
    "string()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "integer"}, _module_name) do
    "integer()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "integer"}, _module_name) do
    "integer()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "boolean"}, _module_name) do
    "boolean()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "boolean"}, _module_name) do
    "boolean()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "enum"}, _module_name) do
    "list(any())"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "enum"}, _module_name) do
    "list(any())"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "union"}, _module_name) do
    "list()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "union"}, _module_name) do
    "list()"
  end

  def shape_to_type(_, %AWS.CodeGen.PostService.Shape{type: "document"}, _module_name) do
    "any()"
  end
  def shape_to_type(_, %AWS.CodeGen.RestService.Shape{type: "document"}, _module_name) do
    "any()"
  end

  def shape_to_type(context, shape_name, module_name, all_shapes) do
    case shape_name do
      "smithy.api#String" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "string"}, module_name)}]"

      "smithy.api#Integer" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "integer"}, module_name)}]"

      "smithy.api#Timestamp" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "timestamp"}, module_name)}]"

      "smithy.api#PrimitiveLong" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "long"}, module_name)}]"

      "smithy.api#Long" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "long"}, module_name)}]"

      "smithy.api#Boolean" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "boolean"}, module_name)}]"

      "smithy.api#PrimitiveBoolean" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "boolean"}, module_name)}]"

      "smithy.api#Double" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "double"}, module_name)}]"

      "smithy.api#Document" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "document"}, module_name)}]"

      "smithy.api#Unit" ->
        "[]"

      "smithy.api#Float" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "float"}, module_name)}]"

      "smithy.api#Blob" ->
        "[#{shape_to_type(context.language, %AWS.CodeGen.RestService.Shape{type: "blob"}, module_name)}]"

      _ ->
        case all_shapes[shape_name] do
          %AWS.CodeGen.PostService.Shape{type: "structure"} ->
            type = "#{AWS.CodeGen.Name.to_snake_case(String.replace(shape_name, ~r/com\.amazonaws\.[^#]+#/, ""))}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}()"
            else
              "#{type}()"
            end

          %AWS.CodeGen.RestService.Shape{type: "structure"} ->
            type = "#{AWS.CodeGen.Name.to_snake_case(String.replace(shape_name, ~r/com\.amazonaws\.[^#]+#/, ""))}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}()"
            else
              "#{type}()"
            end

          %AWS.CodeGen.PostService.Shape{type: "list", member: member} ->
            type = "#{shape_to_type(context, member["target"], module_name, all_shapes)}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "list(#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}())"
            else
              "list(#{type}())"
            end

          %AWS.CodeGen.RestService.Shape{type: "list", member: member} ->
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
