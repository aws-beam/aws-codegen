defmodule AWS.CodeGen.Spec do
  @moduledoc """
  Parse and process the specfication for an AWS service.
  """

  @module_acronyms ~w(SMS WAF API SES HSM FSx IoT MTurk QLDB DB RDS A2I XRay EC2 SSO IVS MQ SDB OIDC ACMPCA SSM)

  @type t :: %__MODULE__{
          protocol: binary(),
          module_name: binary(),
          filename: binary(),
          api: map(),
          language: binary(),
          shape_name: binary()
        }

  defstruct protocol: nil,
            module_name: nil,
            filename: nil,
            api: nil,
            language: nil,
            shape_name: nil

  def parse(api_filename, language) do
    api_name =
      api_filename
      |> Path.basename()
      |> String.replace(["-", ".json"], "")

    api = parse_json(api_filename)

    service_name =
      api
      |> find_service()
      |> String.replace("com.amazonaws.#{api_name}#", "")

    traits = api["shapes"]["com.amazonaws." <> api_name <> "#" <> service_name]["traits"]

    protocol =
      Enum.find_value(traits, fn {k, _v} ->
        case String.split(k, "#") do
          ["aws.protocols", protocol] -> protocol
          _ -> nil
        end
      end)
      |> String.replace("restJson1", "rest_json")
      |> String.replace(["awsJson1_0", "awsJson1_1"], "json")
      |> String.replace("awsQuery", "query")
      |> String.replace("restXml", "rest_xml")
      |> String.replace("ec2Query", "ec2")
      |> then(fn value ->
        if value in ~w(rest_json json query rest_xml ec2) do
          value
        else
          raise "the protocol #{value} is not valid"
        end
      end)
      |> String.to_atom()

    module_name = module_name(traits, language)
    filename = filename(module_name, language)

    %AWS.CodeGen.Spec{
      protocol: protocol,
      module_name: module_name,
      filename: filename,
      api: api,
      language: language,
      shape_name: "com.amazonaws." <> api_name <> "#" <> service_name
    }
  end

  def find_service(api) do
    Enum.find_value(api["shapes"], fn {service, value} ->
      if match?(%{"type" => "service"}, value), do: service
    end)
  end

  def lowercase_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_map(v) -> {String.downcase(k), lowercase_keys(v)}
      {k, v} -> {String.downcase(k), v}
    end)
  end

  def parse_json(path) do
    if File.exists?(path) do
      path |> File.read!() |> Poison.Parser.parse!(%{})
    end
  end

  defp module_name(traits, language) do
    service_name =
      traits["aws.api#service"]["sdkId"]
      |> String.replace("-sync", "Sync")
      |> String.replace("Route 53", "Route53")
      |> String.replace(~r/ Service$/, "")
      |> String.replace("dynamodb", "DynamoDB")
      |> String.replace("api.pricing", "API.Pricing")
      |> String.replace("mobileanalytics", "MobileAnalytics")
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
        # TODO: fix cases like "mobileanalytics"
        service_name =
          service_name
          |> String.replace(" ", "_")
          |> String.replace(".", "_")
          |> String.replace("-", "_")
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
