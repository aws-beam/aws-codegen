defmodule AWS.CodeGen.RestServiceTest do
  use ExUnit.Case, async: true

  alias AWS.CodeGen.RestService

  @service_spec_file "test/fixtures/apis_specs/cloudtrail-data.json"
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

    [specs: service_specs]
  end

  describe "load_context/5" do
    test "prepares context for Elixir", %{specs: specs} do
      spec = %AWS.CodeGen.Spec{
        api: specs,
        module_name: "AWS.CloudTrailData",
        filename: "cloud_trail_data.ex",
        protocol: :rest_json,
        language: :elixir,
        shape_name: "com.amazonaws.cloudtraildata#CloudTrailDataService"
      }

      assert %AWS.CodeGen.Service{
               actions: [
                 action
               ],
               api_version: "2021-08-11",
               content_type: "application/x-amz-json-1.1",
               credential_scope: nil,
               decode: "json",
               docstring:
                 "  The CloudTrail Data Service lets you ingest events into CloudTrail from any\n  source in your\n  hybrid environments, such as in-house or SaaS applications hosted on-premises or\n  in the cloud,\n  virtual machines, or containers.\n\n  You can store, access, analyze, troubleshoot and take action on\n  this data without maintaining multiple log aggregators and reporting tools.\n  After you run\n  `PutAuditEvents` to ingest your application activity into CloudTrail, you can\n  use CloudTrail Lake to search, query, and analyze the data that is logged\n  from your applications.",
               encode: "json",
               endpoint_prefix: "cloudtrail-data",
               is_global: false,
               json_version: "1.1",
               module_name: "AWS.CloudTrailData",
               protocol: "rest-json",
               service_id: "CloudTrail Data",
               signature_version: "v4",
               signing_name: "cloudtrail-data",
               target_prefix: nil
             } = RestService.load_context(:elixir, spec, @endpoints_spec)

      assert action ==
               %RestService.Action{
                 arity: 3,
                 docstring:
                   "  Ingests your application events into CloudTrail Lake.\n\n  A required parameter,\n  `auditEvents`, accepts the JSON records (also called\n  *payload*) of events that you want CloudTrail to ingest. You\n  can add up to 100 of these events (or up to 1 MB) per `PutAuditEvents`\n  request.",
                 errors: [
                   %{"target" => "com.amazonaws.cloudtraildata#ChannelInsufficientPermission"},
                   %{"target" => "com.amazonaws.cloudtraildata#ChannelNotFound"},
                   %{"target" => "com.amazonaws.cloudtraildata#ChannelUnsupportedSchema"},
                   %{"target" => "com.amazonaws.cloudtraildata#DuplicatedAuditEventId"},
                   %{"target" => "com.amazonaws.cloudtraildata#InvalidChannelARN"},
                   %{"target" => "com.amazonaws.cloudtraildata#UnsupportedOperationException"}
                 ],
                 function_name: "put_audit_events",
                 language: :elixir,
                 method: "POST",
                 name: "com.amazonaws.cloudtraildata#PutAuditEvents",
                 input: %{"target" => "com.amazonaws.cloudtraildata#PutAuditEventsRequest"},
                 output: %{"target" => "com.amazonaws.cloudtraildata#PutAuditEventsResponse"},
                 query_parameters: [
                   %RestService.Parameter{
                     code_name: "channel_arn",
                     location_name: "channelArn",
                     name: "channelArn",
                     required: true
                   },
                   %RestService.Parameter{
                     code_name: "external_id",
                     location_name: "externalId",
                     name: "externalId",
                     required: false
                   }
                 ],
                 receive_body_as_binary?: false,
                 request_header_parameters: [],
                 request_uri: "/PutAuditEvents",
                 required_query_parameters: [
                   %RestService.Parameter{
                     code_name: "channel_arn",
                     location_name: "channelArn",
                     name: "channelArn",
                     required: true
                   }
                 ],
                 required_request_header_parameters: [],
                 response_header_parameters: [],
                 send_body_as_binary?: false,
                 success_status_code: 200,
                 url_parameters: []
               }
    end
  end
end
