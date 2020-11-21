defmodule AWS.CodeGen.Spec do
  @moduledoc """
  Parse and process the specfication for an AWS service.
  """

  @module_acronyms ~w(SMS WAF API SES HSM FSx IoT MTurk QLDB DB RDS A2I XRay EC2)

  defstruct protocol: nil,
            module_name: nil,
            filename: nil,
            api: nil,
            doc: nil

  def parse(path, language) do
    api = path |> Path.join("api-2.json") |> parse_json

    protocol =
      api["metadata"]["protocol"]
      |> String.replace("-", "_")
      |> String.to_atom()

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
      path |> File.read!() |> Poison.Parser.parse!(%{})
    end
  end

  defp module_name(api, language) do
    service_name =
      (api["metadata"]["serviceId"] || api["metadata"]["endpointPrefix"])
      |> String.replace("-sync", "Sync")
      |> String.replace("Route 53", "Route53")
      |> String.replace(~r/ Service$/, "")
      |> String.replace("dynamodb", "DynamoDB")
      |> String.replace("api.pricing", "API.Pricing")
      |> String.replace("entitlement.marketplace", "Entitlement.Marketplace")

    case language do
      :elixir ->
        service_name =
          service_name
          |> String.replace(" connections", " Connections")
          |> String.replace(" ", "")
          |> AWS.CodeGen.Name.upcase_first()

        "AWS.#{service_name}"

      :erlang ->
        service_name =
          service_name
          |> String.replace(" ", "_")
          |> String.replace(".", "_")
          |> String.downcase()
          |> AWS.CodeGen.Name.to_snake_case()

        "aws_#{service_name}"
    end
  end

  defp filename(module_name, :elixir) do
    module_name =
      module_name
      |> String.replace("AWS.", "")
      |> String.replace(@module_acronyms ++ ~w(DynamoDB ElastiCache), &String.capitalize(&1))
      |> String.replace(".", "")

    name =
      if module_name == String.upcase(module_name) do
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
