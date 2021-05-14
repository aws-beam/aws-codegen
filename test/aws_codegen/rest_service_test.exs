defmodule AWS.CodeGen.RestServiceTest do
  use ExUnit.Case, async: true

  alias AWS.CodeGen.RestService

  # This is the smallest spec for a service.
  # The original is at: https://github.com/aws/aws-sdk-go/blob/e2d6cb448883e4f4fcc5246650f89bde349041ec/models/apis/mobileanalytics/2014-06-05/api-2.json
  @service_spec_file "test/fixtures/apis_specs/mobileanalytics-2014-06-05-api-2.json"
  @service_docs_file "test/fixtures/apis_specs/mobileanalytics-2014-06-05-docs-2.json"
  @endpoints_spec %{
    "services" => %{
      "mobileanalytics" => %{
        "endpoints" => %{
          "us-east-1" => %{}
        }
      }
    }
  }

  setup do
    service_specs =
      @service_spec_file
      |> File.read!()
      |> Poison.decode!()

    docs =
      @service_docs_file
      |> File.read!()
      |> Poison.decode!()

    [specs: service_specs, docs: docs]
  end

  describe "load_context/5" do
    test "prepares context for Elixir", %{specs: specs, docs: docs} do
      spec = %AWS.CodeGen.Spec{
        api: specs,
        doc: docs,
        module_name: "AWS.MobileAnalytics",
        filename: "mobile_analytics.ex",
        protocol: :rest_json
      }

      assert %AWS.CodeGen.Service{
               abbreviation: nil,
               actions: [
                 action
               ],
               api_version: "2014-06-05",
               content_type: "application/x-amz-json-1.1",
               credential_scope: nil,
               decode: "json",
               docstring:
                 "  Amazon Mobile Analytics is a service for collecting, visualizing, and\n  understanding app usage data at scale.",
               encode: "json",
               endpoint_prefix: "mobileanalytics",
               is_global: false,
               json_version: nil,
               module_name: "AWS.MobileAnalytics",
               protocol: "rest-json",
               service_id: nil,
               signature_version: "v4",
               signing_name: "mobileanalytics",
               target_prefix: nil
             } = RestService.load_context(:elixir, spec, @endpoints_spec)

      assert action ==
               %RestService.Action{
                 arity: 3,
                 docstring:
                   "  The PutEvents operation records one or more events.\n\n  You can have up to 1,500 unique custom events per app, any combination of up to\n  40 attributes and metrics per custom event, and any number of attribute or\n  metric values.",
                 function_name: "put_events",
                 language: :elixir,
                 method: "POST",
                 name: "PutEvents",
                 query_parameters: [],
                 receive_body_as_binary?: false,
                 request_header_parameters: [
                   %RestService.Parameter{
                     code_name: "client_context",
                     location_name: "x-amz-Client-Context",
                     name: "clientContext",
                     required: true
                   },
                   %RestService.Parameter{
                     code_name: "client_context_encoding",
                     location_name: "x-amz-Client-Context-Encoding",
                     name: "clientContextEncoding",
                     required: false
                   }
                 ],
                 request_uri: "/2014-06-05/events",
                 required_query_parameters: [],
                 required_request_header_parameters: [
                   %RestService.Parameter{
                     code_name: "client_context",
                     location_name: "x-amz-Client-Context",
                     name: "clientContext",
                     required: true
                   }
                 ],
                 response_header_parameters: [],
                 send_body_as_binary?: false,
                 success_status_code: 202,
                 url_parameters: []
               }
    end
  end
end
