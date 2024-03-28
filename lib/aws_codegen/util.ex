defmodule AWS.CodeGen.Util do
  def service_docs(service) do
    with "<p></p>" <- service["traits"]["smithy.api#documentation"], do: ""
  end

  def get_json_version(service) do
    traits = service["traits"]

    ["aws.protocols#" <> protocol | _] =
      Enum.filter(Map.keys(traits), &String.starts_with?(&1, "aws.protocols#"))

    case protocol do
      ## TODO: according to the docs this should result in application/json but our current code will make it application/x-amz-json-1.1
      "restJson1" -> "1.1"
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
        Enum.reduce(
          shape.members,
          [],
          fn
            {name, %{"traits" => traits}}, acc ->
              if Map.has_key?(traits, "smithy.api#required") do
                [name <> " Required: true" | acc]
              else
                [name <> " Required: false" | acc]
              end

            {name, _shape}, acc ->
              [name <> " Required: false" | acc]
          end
        )
        |> Enum.reverse()
    end
  end
end
