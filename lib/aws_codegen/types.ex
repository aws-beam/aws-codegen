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

  def shape_to_type(%Shape{name: shape_name} = shape, module_name) do
    raise "missing shape for type #{shape_name} #{inspect(shape, limit: :infinity)}"
    "#{module_name}.#{Name.to_snake_case(shape_name)}"
  end

  def shape_to_type(%{"shape" => shape}, module_name, all_shapes) do
    shape_to_type(shape, module_name, all_shapes)
  end

  def shape_to_type(shape_name, module_name, all_shapes) do
    case all_shapes[shape_name] do
      %Shape{type: "structure"} ->
        "#{module_name}.#{shape_name}.t()"

      %Shape{type: "list", member: member} ->
        "[#{shape_to_type(member, module_name, all_shapes)}]"

      nil ->
        raise "Tried to reference an undefined shape"

      shape ->
        shape_to_type(shape, module_name)
    end
  end
end
