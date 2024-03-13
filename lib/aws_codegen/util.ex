defmodule AWS.CodeGen.Util do

  def service_docs(service) do
    with "<p></p>" <- service["traits"]["smithy.api#documentation"], do: ""
  end

  def get_json_version(service) do
    traits = service["traits"]
    ["aws.protocols#" <> protocol | _] = Enum.filter(Map.keys(traits), &String.starts_with?(&1, "aws.protocols#"))
    case protocol do
      "restJson1" -> "1.1" ## TODO: according to the docs this should result in application/json but our current code will make it application/x-amz-json-1.1
      "awsJson1_0" -> "1.0"
      "awsJson1_1" -> "1.1"
      "awsQuery" -> nil
      "restXml" -> nil
      "ec2Query" -> nil
    end
  end

  def get_signature_version(service) do
    traits = service["traits"]
    signature = Enum.filter(Map.keys(traits), &String.starts_with?(&1, "aws.auth#"))
    case signature do
      ["aws.auth#sig" <> version] -> version
      [] -> nil
    end
  end

  def get_service_id(service) do
    service["traits"]["aws.api#service"]["sdkId"]
  end

  def input_keys(action, context) do
    shapes = context.shapes
    input_shape = action.input["target"]
    maybe_shape = Enum.filter(shapes, fn {name, _shape} -> input_shape == name end)
    case maybe_shape do
      [] ->
        []
      [{_name, shape}] ->
        Enum.reduce(shape.members,
                    [],
                    fn {name, %{"traits" => traits}}, acc ->
                        if Map.has_key?(traits, "smithy.api#required") do
                          [name <> " Required: true" | acc]
                        else
                          [name <> " Required: false" | acc]
                        end
                       {name, _shape}, acc ->
                          [name <> " Required: false" | acc]
                    end)
        |> Enum.reverse()
    end
  end

  def types(context) do
    Enum.reduce(context.shapes,
                Map.new(),
                fn {_name, shape}, acc ->
                  if shape.type == "structure" and not is_nil(shape.members) do
                    type = AWS.CodeGen.Name.to_snake_case(String.replace(shape.name, ~r/com\.amazonaws\.[^#]+#/, ""))
                    types = Enum.reduce(shape.members,
                                        Map.new(),
                                        fn {name, shape_member}, a ->
                                          target = shape_member["target"]
                                          if Map.has_key?(shape_member, "traits") do
                                            traits = shape_member["traits"]
                                            if Map.has_key?(traits, "smithy.api#httpLabel") do
                                              a
                                            else
                                              shape_member_type = AWS.CodeGen.Types.shape_to_type(context, target, context.module_name, context.shapes)
                                              Map.put(a, is_required(context.language, shape.is_input, shape_member, name), shape_member_type)
                                            end
                                          else
                                            shape_member_type = AWS.CodeGen.Types.shape_to_type(context, target, context.module_name, context.shapes)
                                            Map.put(a, is_required(context.language, shape.is_input, shape_member, name), shape_member_type)
                                          end
                                        end)
                    if reserved_type(type) do
                      Map.put(acc, "#{String.downcase(String.replace(context.module_name, "AWS.", ""))}_#{type}", types)
                    else
                      Map.put(acc, type, types)
                    end
                  else
                    acc
                  end
                end)
  end

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

  def function_argument_type(:elixir, action) do
    case Map.fetch!(action.input, "target") do
      "smithy.api#Unit" -> "%{}"
      type ->
        "#{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}()"
    end
  end
  def function_argument_type(:erlang, action) do
    case Map.fetch!(action.input, "target") do
      "smithy.api#Unit" -> "\#{}"
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
        normal = "{:ok, #{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}(), any()}"
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
        normal = "{ok, #{AWS.CodeGen.Name.to_snake_case(String.replace(type, ~r/com\.amazonaws\.[^#]+#/, ""))}(), tuple()}"
        errors =
          if is_list(action.errors) do
            ["{error, #{action.function_name}_errors(), tuple()}"]
          else
            []
          end
        Enum.join([normal, "{error, any()}" | errors], " |\n    ")
    end
  end

  def reserved_type(type) do
    type == "node" || type == "term" || type == "function" || type == "reference"
  end

end
