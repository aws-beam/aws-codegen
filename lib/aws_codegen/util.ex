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

end
