defmodule AWS.CodeGen.Spec do
  @moduledoc """
  Parse and process the specfication for an AWS service.
  """

  @module_acronyms ~w(SMS WAF API SES HSM FSx IoT MTurk QLDB DB RDS A2I XRay EC2 SSO IVS MQ SDB OIDC ACMPCA SSM)

  @type t :: %__MODULE__{
          protocol: atom(),
          module_name: binary(),
          filename: binary(),
          api: map(),
          doc: map() | nil
        }

  defstruct protocol: nil,
            module_name: nil,
            filename: nil,
            api: nil,
            doc: nil

  def parse(path, language, opts \\ []) do
    api_filename = Keyword.get(opts, :api_filename, "api-2.json")
    doc_filename = Keyword.get(opts, :doc_filename, "docs-2.json")

    api = path |> Path.join(api_filename) |> parse_json()

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
      api: api,
      doc: path |> Path.join(doc_filename) |> parse_json
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
