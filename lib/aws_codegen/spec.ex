defmodule AWS.CodeGen.Spec do
  defstruct protocol: nil,
    module_name: nil,
    filename: nil,
    api: nil,
    doc: nil

  def parse(path, language) do
    api = path |> Path.join("api-2.json") |> parse_json
    protocol = api["metadata"]["protocol"]
    |> String.replace("-", "_")
    |> String.to_atom
    module_name = module_name(api, language)
    filename = filename(module_name, language)
    %AWS.CodeGen.Spec{
      protocol: protocol,
      module_name: module_name,
      filename: filename,
      api: path |> Path.join("api-2.json") |> parse_json,
      doc: path |> Path.join("docs-2.json") |> parse_json
    }
  end

  def parse_json(path) do
    if File.exists?(path) do
      path |> File.read! |> Poison.Parser.parse!(%{})
    end
  end

  defp module_name(api, language) do
    service_name = case api["metadata"]["serviceId"] do
                     nil -> api["metadata"]["endpointPrefix"]
                     service_id -> service_id
                   end
    |> String.replace("-sync", "Sync")
    |> String.replace("dynamodb", "DynamoDB")
    |> String.replace("api.pricing", "API.Pricing")
    |> String.replace("entitlement.marketplace", "Entitlement.Marketplace")
    case language do
      :elixir ->
        service_name = service_name
        |> String.replace(" connections", " Connections")
        |> String.replace(" ", "")
        |> AWS.CodeGen.Name.upcase_first
        "AWS.#{service_name}"
      :erlang ->
        service_name = service_name
        |> String.replace(" ", "_")
        |> String.replace(".", "_")
        |> String.downcase
        |> AWS.CodeGen.Name.to_snake_case
        "aws_#{service_name}"
    end
  end

  defp filename(module_name, :elixir) do
    module_name = module_name
    |> String.replace("AWS.", "")
    |> String.replace("SMS", "Sms")
    |> String.replace("WAF", "Waf")
    |> String.replace("API", "Api")
    |> String.replace("SES", "Ses")
    |> String.replace("HSM", "Hsm")
    |> String.replace("EC2", "Ec2")
    |> String.replace("DynamoDB", "Dynamodb")
    |> String.replace("ElastiCache", "Elasticache")
    |> String.replace("FSx", "Fsx")
    |> String.replace("IoT", "Iot")
    |> String.replace("MTurk", "Mturk")
    |> String.replace("QLDB", "Qldb")
    |> String.replace("DB", "Db")
    |> String.replace("RDS", "Rds")
    |> String.replace("A2I", "A2i")
    |> String.replace("XRay", "Xray")
    |> String.replace(".", "")
    name = if module_name == String.upcase(module_name) do
      String.downcase(module_name)
    else
      AWS.CodeGen.Name.to_snake_case(module_name)
    end
    "#{name}.ex"
  end
  defp filename(module_name, :erlang) do
    "#{module_name}.erl"
  end
end
