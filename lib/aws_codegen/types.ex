defmodule AWS.CodeGen.Types do
  alias AWS.CodeGen.Shapes.Shape

  def types(context) do
    Enum.reduce(context.shapes, %{}, fn {_name, shape}, acc ->
      process_shape(context, shape, acc)
    end)
  end

  defp process_shape(context, shape, acc) do
    if shape.type == "structure" and not is_nil(shape.members) do
      process_structure_shape(context, shape, acc)
    else
      acc
    end
  end

  defp process_structure_shape(context, shape, acc) do
    type = normalize_type_name(shape.name)

    types = process_shape_members(context, shape)
    update_acc_with_types(acc, type, types, context)
  end

  defp normalize_type_name(name) do
    name
    |> String.replace(~r/com\.amazonaws\.[^#]+#/, "")
    |> AWS.CodeGen.Name.to_snake_case()
  end

  defp process_shape_members(context, shape) do
    Enum.reduce(shape.members, %{}, fn {name, shape_member}, a ->
      process_shape_member(context, shape, name, shape_member, a)
    end)
  end

  defp process_shape_member(context, shape, name, shape_member, a) do
    target = shape_member["target"]

    if Map.has_key?(shape_member, "traits") and has_http_label_trait(shape_member["traits"]) do
      a
    else
      shape_member_type = shape_to_type(context, target, context.module_name, context.shapes)

      Map.put(
        a,
        is_required(context.language, shape.is_input, shape_member, name),
        shape_member_type
      )
    end
  end

  defp has_http_label_trait(traits), do: Map.has_key?(traits, "smithy.api#httpLabel")

  defp update_acc_with_types(acc, type, types, context) do
    if reserved_type(type) do
      module_name = String.downcase(String.replace(context.module_name, "AWS.", ""))
      Map.put(acc, "#{module_name}_#{type}", types)
    else
      Map.put(acc, type, types)
    end
  end

  defp shape_to_type(context, shape_name, module_name, all_shapes) do
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
            type =
              "#{AWS.CodeGen.Name.to_snake_case(String.replace(shape_name, ~r/com\.amazonaws\.[^#]+#/, ""))}"

            if reserved_type(type) do
              "#{String.downcase(String.replace(context.module_name, ["aws_", "AWS."], ""))}_#{type}()"
            else
              "#{type}()"
            end

          %Shape{type: "list", member: member} ->
            type = "#{shape_to_type(context, member["target"], module_name, all_shapes)}"

            if reserved_type(type) do
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

  # Unfortunately, gotta patch over auto-defining types that already exist in Elixir
  defp shape_to_type(:elixir, "String", _), do: "String.t()"
  defp shape_to_type(:erlang, "String", _), do: "string()"
  defp shape_to_type(:elixir, "string", _), do: "String.t()"
  defp shape_to_type(:erlang, "string", _), do: "string()"
  defp shape_to_type(:elixir, "Identifier", _), do: "String.t()"
  defp shape_to_type(:erlang, "Identifier", _), do: "string()"
  defp shape_to_type(:elixir, "identifier", _), do: "String.t()"
  defp shape_to_type(:erlang, "identifier", _), do: "string()"
  defp shape_to_type(:elixir, "XmlString" <> _rest, _), do: "String.t()"
  defp shape_to_type(:erlang, "XmlString" <> _rest, _), do: "string"
  defp shape_to_type(:elixir, "NullablePositiveInteger", _), do: "nil | non_neg_integer()"
  defp shape_to_type(:erlang, "NullablePositiveInteger", _), do: "undefined | non_neg_integer()"

  defp shape_to_type(_, %Shape{type: type}, _module_name)
       when type in ["float", "double", "long"],
       do: "float()"

  defp shape_to_type(_, %Shape{type: "timestamp"}, _module_name), do: "non_neg_integer()"
  defp shape_to_type(_, %Shape{type: "map"}, _module_name), do: "map()"
  defp shape_to_type(_, %Shape{type: "blob"}, _module_name), do: "binary()"
  defp shape_to_type(:elixir, %Shape{type: "string"}, _module_name), do: "String.t()"
  defp shape_to_type(:erlang, %Shape{type: "string"}, _module_name), do: "string()"
  defp shape_to_type(_, %Shape{type: "integer"}, _module_name), do: "integer()"
  defp shape_to_type(_, %Shape{type: "boolean"}, _module_name), do: "boolean()"
  defp shape_to_type(_, %Shape{type: "enum"}, _module_name), do: "list(any())"
  defp shape_to_type(_, %Shape{type: "union"}, _module_name), do: "list()"
  defp shape_to_type(_, %Shape{type: "document"}, _module_name), do: "any()"

  defp is_required(:elixir, is_input, shape, target) do
    trimmed_name = String.replace(target, ~r/com\.amazonaws\.[^#]+#/, "")

    if is_input do
      if Map.has_key?(shape, "traits") do
        if Map.has_key?(shape["traits"], "smithy.api#required") do
          "required(\"#{trimmed_name}\") => "
        else
          "optional(\"#{trimmed_name}\") => "
        end
      else
        "optional(\"#{trimmed_name}\") => "
      end
    else
      "\"#{trimmed_name}\" => "
    end
  end

  defp is_required(:erlang, is_input, shape, target) do
    trimmed_name = String.replace(target, ~r/com\.amazonaws\.[^#]+#/, "")

    if is_input do
      if Map.has_key?(shape, "traits") do
        if Map.has_key?(shape["traits"], "smithy.api#required") do
          "<<\"#{trimmed_name}\">> := "
        else
          "<<\"#{trimmed_name}\">> => "
        end
      else
        "<<\"#{trimmed_name}\">> => "
      end
    else
      "<<\"#{trimmed_name}\">> => "
    end
  end

  defp reserved_type(type) do
    type == "node" || type == "term" || type == "function" || type == "reference" ||
      type == "identifier"
  end

  def function_argument_type(:elixir, action) do
    case Map.fetch!(action.input, "target") do
      "smithy.api#Unit" ->
        "%{}"

      type ->
        "#{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}()"
    end
  end

  def function_argument_type(:erlang, action) do
    case Map.fetch!(action.input, "target") do
      "smithy.api#Unit" ->
        "\#{}"

      type ->
        "#{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}()"
    end
  end

  def return_type(:elixir, action) do
    case Map.fetch!(action.output, "target") do
      "smithy.api#Unit" ->
        normal = "{:ok, nil, any()}"

        errors =
          if is_list(action.errors) do
            ["{:error, #{action.function_name}_errors()}"]
          else
            []
          end

        Enum.join([normal, "{:error, {:unexpected_response, any()}}" | errors], " | \n")

      type ->
        normal =
          "{:ok, #{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}(), any()}"

        errors =
          if is_list(action.errors) do
            ["{:error, #{action.function_name}_errors()}"]
          else
            []
          end

        Enum.join([normal, "{:error, {:unexpected_response, any()}}" | errors], " | \n")
    end
  end

  def return_type(:erlang, action) do
    case Map.get(action.output, "target") do
      "smithy.api#Unit" ->
        normal = "{ok, undefined, tuple()}"

        errors =
          if is_list(action.errors) do
            ["{error, #{action.function_name}_errors(), tuple()}"]
          else
            []
          end

        Enum.join([normal, "{error, any()}" | errors], " |\n    ")

      type ->
        normal =
          "{ok, #{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}(), tuple()}"

        errors =
          if is_list(action.errors) do
            ["{error, #{action.function_name}_errors(), tuple()}"]
          else
            []
          end

        Enum.join([normal, "{error, any()}" | errors], " |\n    ")
    end
  end

  def required_function_parameter_types(action) do
    function_parameter_types(action.method, action, true)
  end

  def function_parameter_types("GET", action, false = _required_only) do
    language = action.language

    Enum.join([
      join_parameter_types(action.url_parameters, language),
      join_parameter_types(action.query_parameters, language),
      join_parameter_types(action.request_header_parameters, language),
      join_parameter_types(action.request_headers_parameters, language)
    ])
  end

  def function_parameter_types("GET", action, true = _required_only) do
    language = action.language

    Enum.join([
      join_parameter_types(action.url_parameters, language),
      join_parameter_types(action.required_query_parameters, language),
      join_parameter_types(action.required_request_header_parameters, language)
    ])
  end

  def function_parameter_types(_method, action, _required_only) do
    language = action.language

    Enum.join([
      join_parameter_types(action.url_parameters, language),
      join_parameter_types(action.required_query_parameters, language),
      join_parameter_types(action.required_request_header_parameters, language)
    ])
  end

  defp join_parameter_types(parameters, :elixir) do
    Enum.map_join(
      parameters,
      fn parameter ->
        if not parameter.required do
          # TODO: map the types to elixir types here: ", #{parameter.type} | nil"
          ", String.t() | nil"
        else
          # TODO: map the types to elixir types here: ", #{parameter.type}"
          ", String.t()"
        end
      end
    )
  end

  defp join_parameter_types(parameters, :erlang) do
    Enum.join(Enum.map(parameters, fn _parameter -> ", binary() | list()" end))
  end
end
