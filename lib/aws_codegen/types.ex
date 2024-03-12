defmodule AWS.CodeGen.Types do
  alias AWS.CodeGen.PostService.Shape
  alias AWS.CodeGen.Name

  # Unfortunately, gotta patch over auto-defining types that already exist in Elixir

  def shape_to_type("String", _) do
    "String.t()"
  end

  def shape_to_type("string", _) do
    "String.t()"
  end

  def shape_to_type("Identifier", _) do
    "String.t()"
  end

  def shape_to_type("identifier", _) do
    "String.t()"
  end

  def shape_to_type("XmlString" <> _rest, _) do
    "String.t()"
  end

  def shape_to_type("NullablePositiveInteger", _) do
    "nil | non_neg_integer()"
  end

  def shape_to_type(%Shape{type: type}, _module_name) when type in ["float", "double", "long"] do
    "float()"
  end

  def shape_to_type(%Shape{type: "timestamp"}, _module_name) do
    "non_neg_integer()"
  end

  def shape_to_type(%Shape{type: "map"}, _module_name) do
    "map()"
  end

  def shape_to_type(%Shape{type: "blob"}, _module_name) do
    "binary()"
  end

  def shape_to_type(%Shape{type: "string"}, _module_name) do
    "String.t()"
  end

  def shape_to_type(%Shape{type: "integer"}, _module_name) do
    "integer()"
  end

  def shape_to_type(%Shape{type: "boolean"}, _module_name) do
    "boolean()"
  end

  def shape_to_type(%Shape{type: "enum"}, _module_name) do
    "list(any())"
  end

  def shape_to_type(%Shape{type: "union"}, _module_name) do
    "list()"
  end

  def shape_to_type(%Shape{type: "document"}, _module_name) do
    "any()"
  end

  def shape_to_type(%Shape{name: shape_name} = shape, module_name) do
    raise "missing shape for type #{shape_name} #{inspect(shape, limit: :infinity)}"
    "#{module_name}.#{Name.to_snake_case(shape_name)}"
  end

  def shape_to_type(context, shape_name, module_name, all_shapes) do
    case shape_name do
      "smithy.api#String" ->
        "[#{shape_to_type(%Shape{type: "string"}, module_name)}]"

      "smithy.api#Integer" ->
        "[#{shape_to_type(%Shape{type: "integer"}, module_name)}]"

      "smithy.api#Timestamp" ->
        "[#{shape_to_type(%Shape{type: "timestamp"}, module_name)}]"

      "smithy.api#PrimitiveLong" ->
        "[#{shape_to_type(%Shape{type: "long"}, module_name)}]"

      "smithy.api#Long" ->
        "[#{shape_to_type(%Shape{type: "long"}, module_name)}]"

      "smithy.api#Boolean" ->
        "[#{shape_to_type(%Shape{type: "boolean"}, module_name)}]"

      "smithy.api#PrimitiveBoolean" ->
        "[#{shape_to_type(%Shape{type: "boolean"}, module_name)}]"

      "smithy.api#Double" ->
        "[#{shape_to_type(%Shape{type: "double"}, module_name)}]"

      "smithy.api#Document" ->
        "[#{shape_to_type(%Shape{type: "document"}, module_name)}]"

      "smithy.api#Unit" ->
        "[]"

      _ ->
        case all_shapes[shape_name] do
          %Shape{type: "structure"} ->
            type = "#{AWS.CodeGen.Name.to_snake_case(String.replace(shape_name, ~r/com\.amazonaws\.[^#]+#/, ""))}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "#{String.downcase(String.replace(context.module_name, "AWS.", ""))}_#{type}()"
            else
              "#{type}()"
            end

          %Shape{type: "list", member: member} ->
            type = "#{shape_to_type(context, member["target"], module_name, all_shapes)}"
            if AWS.CodeGen.Util.reserved_type(type) do
              "list(#{String.downcase(String.replace(context.module_name, "AWS.", ""))}_#{type}())"
            else
              "list(#{type}())"
            end

          nil ->
            raise "Tried to reference an undefined shape for #{shape_name}"

          shape ->
            shape_to_type(shape, module_name)
        end
    end
  end
end
