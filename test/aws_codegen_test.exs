defmodule AWS.CodeGenTest do
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

  describe "render/2" do
    defp setup_context(language, specs, docs \\ nil) do
      spec = %AWS.CodeGen.Spec{
        api: specs,
        module_name: "AWS.CloudTrailData",
        filename: "cloud_trail_data.ex",
        protocol: :rest_json,
        language: :elixir,
        shape_name: "com.amazonaws.cloudtraildata#CloudTrailDataService"
      }

      RestService.load_context(language, spec, @endpoints_spec)
    end

    test "renders the Elixir module with docs", %{specs: specs} do
      context = setup_context(:elixir, specs)

      result =
        context
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.CloudTrailData do
                 @moduledoc \"\"\"
                 The CloudTrail Data Service lets you ingest events into CloudTrail from any
                 source in your
                 hybrid environments, such as in-house or SaaS applications hosted on-premises or
                 in the cloud,
                 virtual machines, or containers.

                 You can store, access, analyze, troubleshoot and take action on
                 this data without maintaining multiple log aggregators and reporting tools.
                 After you run
                 `PutAuditEvents` to ingest your application activity into CloudTrail, you can
                 use CloudTrail Lake to search, query, and analyze the data that is logged
                 from your applications.
                 \"\"\"

                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     api_version: "2021-08-11",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "cloudtrail-data",
                     global?: false,
                     protocol: "rest-json",
                     service_id: "CloudTrail Data",
                     signature_version: "v4",
                     signing_name: "cloudtrail-data",
                     target_prefix: nil
                   }
                 end

                 @doc \"\"\"
                 Ingests your application events into CloudTrail Lake.

                 A required parameter,
                 `auditEvents`, accepts the JSON records (also called
                 *payload*) of events that you want CloudTrail to ingest. You
                 can add up to 100 of these events (or up to 1 MB) per `PutAuditEvents`
                 request.
                 \"\"\"
                 def put_audit_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/PutAuditEvents"
                   headers = []

                   {query_params, input} =
                     [
                       {"channelArn", "channelArn"},
                       {"externalId", "externalId"}
                     ]
                     |> Request.build_params(input)

                   meta = metadata()

                   Request.request_rest(
                     client,
                     meta,
                     :post,
                     url_path,
                     query_params,
                     headers,
                     input,
                     options,
                     200
                   )
                 end
               end
               """)
    end

    test "renders POST action with options to send/receive binary", %{specs: specs} do
      context = setup_context(:elixir, specs)

      [action | _] = context.actions
      action = %{action | send_body_as_binary?: true, receive_body_as_binary?: true}

      result =
        %{context | actions: [action]}
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.CloudTrailData do
                 @moduledoc \"\"\"
                 The CloudTrail Data Service lets you ingest events into CloudTrail from any
                 source in your
                 hybrid environments, such as in-house or SaaS applications hosted on-premises or
                 in the cloud,
                 virtual machines, or containers.

                 You can store, access, analyze, troubleshoot and take action on
                 this data without maintaining multiple log aggregators and reporting tools.
                 After you run
                 `PutAuditEvents` to ingest your application activity into CloudTrail, you can
                 use CloudTrail Lake to search, query, and analyze the data that is logged
                 from your applications.
                 \"\"\"

                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     api_version: "2021-08-11",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "cloudtrail-data",
                     global?: false,
                     protocol: "rest-json",
                     service_id: "CloudTrail Data",
                     signature_version: "v4",
                     signing_name: "cloudtrail-data",
                     target_prefix: nil
                   }
                 end

                 @doc \"\"\"
                 Ingests your application events into CloudTrail Lake.

                 A required parameter,
                 `auditEvents`, accepts the JSON records (also called
                 *payload*) of events that you want CloudTrail to ingest. You
                 can add up to 100 of these events (or up to 1 MB) per `PutAuditEvents`
                 request.
                 \"\"\"
                 def put_audit_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/PutAuditEvents"
                   headers = []

                   {query_params, input} =
                     [
                       {"channelArn", "channelArn"},
                       {"externalId", "externalId"}
                     ]
                     |> Request.build_params(input)

                   options =
                     Keyword.put(
                       options,
                       :send_body_as_binary?,
                       true
                     )

                   options =
                     Keyword.put(
                       options,
                       :receive_body_as_binary?,
                       true
                     )

                   meta = metadata()

                   Request.request_rest(
                     client,
                     meta,
                     :post,
                     url_path,
                     query_params,
                     headers,
                     input,
                     options,
                     200
                   )
                 end
               end
               """)
    end

    test "renders GET action with options to send/receive binary", %{specs: specs} do
      context = setup_context(:elixir, specs)

      [action | _] = context.actions

      action = %{
        action
        | method: "GET",
          send_body_as_binary?: true,
          receive_body_as_binary?: true
      }

      result =
        %{context | actions: [action]}
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.CloudTrailData do
                 @moduledoc \"\"\"
                 The CloudTrail Data Service lets you ingest events into CloudTrail from any
                 source in your
                 hybrid environments, such as in-house or SaaS applications hosted on-premises or
                 in the cloud,
                 virtual machines, or containers.

                 You can store, access, analyze, troubleshoot and take action on
                 this data without maintaining multiple log aggregators and reporting tools.
                 After you run
                 `PutAuditEvents` to ingest your application activity into CloudTrail, you can
                 use CloudTrail Lake to search, query, and analyze the data that is logged
                 from your applications.
                 \"\"\"

                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     api_version: "2021-08-11",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "cloudtrail-data",
                     global?: false,
                     protocol: "rest-json",
                     service_id: "CloudTrail Data",
                     signature_version: "v4",
                     signing_name: "cloudtrail-data",
                     target_prefix: nil
                   }
                 end

                 @doc \"\"\"
                 Ingests your application events into CloudTrail Lake.

                 A required parameter,
                 `auditEvents`, accepts the JSON records (also called
                 *payload*) of events that you want CloudTrail to ingest. You
                 can add up to 100 of these events (or up to 1 MB) per `PutAuditEvents`
                 request.
                 \"\"\"
                 def put_audit_events(%Client{} = client, channel_arn, external_id \\\\ nil, options \\\\ []) do
                   url_path = "/PutAuditEvents"
                   headers = []
                   query_params = []

                   query_params =
                     if !is_nil(external_id) do
                       [{\"externalId\", external_id} | query_params]
                     else
                       query_params
                     end

                   query_params =
                     if !is_nil(channel_arn) do
                       [{\"channelArn\", channel_arn} | query_params]
                     else
                       query_params
                     end

                   options =
                     Keyword.put(
                       options,
                       :send_body_as_binary?,
                       true
                     )

                   options =
                     Keyword.put(
                       options,
                       :receive_body_as_binary?,
                       true
                     )

                   meta = metadata()

                   Request.request_rest(client, meta, :get, url_path, query_params, headers, nil, options, 200)
                 end
               end
               """)
    end

    test "renders the module with endpoint prefix with host prefix", %{specs: specs} do
      context = setup_context(:elixir, specs)

      [action | _] = context.actions

      action = %{action | host_prefix: "my-host-prefix."}

      result =
        %{context | actions: [action]}
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.CloudTrailData do
                 @moduledoc \"\"\"
                 The CloudTrail Data Service lets you ingest events into CloudTrail from any
                 source in your
                 hybrid environments, such as in-house or SaaS applications hosted on-premises or
                 in the cloud,
                 virtual machines, or containers.

                 You can store, access, analyze, troubleshoot and take action on
                 this data without maintaining multiple log aggregators and reporting tools.
                 After you run
                 `PutAuditEvents` to ingest your application activity into CloudTrail, you can
                 use CloudTrail Lake to search, query, and analyze the data that is logged
                 from your applications.
                 \"\"\"

                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     api_version: "2021-08-11",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "cloudtrail-data",
                     global?: false,
                     protocol: "rest-json",
                     service_id: "CloudTrail Data",
                     signature_version: "v4",
                     signing_name: "cloudtrail-data",
                     target_prefix: nil
                   }
                 end

                 @doc \"\"\"
                 Ingests your application events into CloudTrail Lake.

                 A required parameter,
                 `auditEvents`, accepts the JSON records (also called
                 *payload*) of events that you want CloudTrail to ingest. You
                 can add up to 100 of these events (or up to 1 MB) per `PutAuditEvents`
                 request.
                 \"\"\"
                 def put_audit_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/PutAuditEvents"
                   headers = []

                   {query_params, input} =
                     [
                       {"channelArn", "channelArn"},
                       {"externalId", "externalId"}
                     ]
                     |> Request.build_params(input)

                   meta = metadata() |> Map.put_new(:host_prefix, "my-host-prefix.")

                   Request.request_rest(
                     client,
                     meta,
                     :post,
                     url_path,
                     query_params,
                     headers,
                     input,
                     options,
                     200
                   )
                 end
               end
               """)
    end
  end
end
