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

  @service_spec_custom_headers_file "test/fixtures/apis_specs/dataexchange.json"
  @service_spec_custom_headers_generated "test/fixtures/generated/data_exchange.ex"

  setup do
    service_specs =
      @service_spec_file
      |> File.read!()
      |> Poison.decode!()

    [specs: service_specs]
  end

  describe "render/2" do
    defp setup_context(language, specs, _docs \\ nil) do
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

    defp setup_dataexchange_context(language, specs, _docs \\ nil) do
      spec = %AWS.CodeGen.Spec{
        api: specs,
        module_name: "AWS.DataExchange",
        filename: "data_exchange.ex",
        protocol: :rest_json,
        language: :elixir,
        shape_name: "com.amazonaws.dataexchange#DataExchange"
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

                 @typedoc \"\"\"

                 ## Example:

                     audit_event() :: %{
                       \"eventData\" => [String.t()],
                       \"eventDataChecksum\" => [String.t()],
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     audit_event_result_entry() :: %{
                       \"eventID\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event_result_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_insufficient_permission() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_insufficient_permission() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_not_found() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_not_found() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_unsupported_schema() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_unsupported_schema() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     duplicated_audit_event_id() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type duplicated_audit_event_id() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     invalid_channel_arn() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\""
                 @type invalid_channel_arn() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_request() :: %{
                       optional(\"externalId\") => String.t(),
                       required(\"auditEvents\") => list(audit_event()()),
                       required(\"channelArn\") => String.t()
                     }

                 \"\"\"
                 @type put_audit_events_request() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_response() :: %{
                       required(\"failed\") => list(result_error_entry()()),
                       required(\"successful\") => list(audit_event_result_entry()())
                     }

                 \"\"\"
                 @type put_audit_events_response() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     result_error_entry() :: %{
                       \"errorCode\" => String.t(),
                       \"errorMessage\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type result_error_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     unsupported_operation_exception() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type unsupported_operation_exception() :: %{String.t() => any()}

                 @type put_audit_events_errors() ::
                         unsupported_operation_exception()
                         | invalid_channel_arn()
                         | duplicated_audit_event_id()
                         | channel_unsupported_schema()
                         | channel_not_found()
                         | channel_insufficient_permission()

                 def metadata do
                   %{
                     api_version: \"2021-08-11\",
                     content_type: \"application/x-amz-json-1.1\",
                     credential_scope: nil,
                     endpoint_prefix: \"cloudtrail-data\",
                     global?: false,
                     hostname: nil,
                     protocol: \"rest-json\",
                     service_id: \"CloudTrail Data\",
                     signature_version: \"v4\",
                     signing_name: \"cloudtrail-data\",
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
                 @spec put_audit_events(map(), put_audit_events_request(), list()) ::
                         {:ok, put_audit_events_response(), any()}
                         | {:error, {:unexpected_response, any()}}
                         | {:error, term()}
                         | {:error, put_audit_events_errors()}
                 def put_audit_events(%Client{} = client, input, options \\\\ []) do
                   url_path = \"/PutAuditEvents\"
                   headers = []
                   custom_headers = []

                   {query_params, input} =
                     [
                       {\"channelArn\", \"channelArn\"},
                       {\"externalId\", \"externalId\"}
                     ]
                     |> Request.build_params(input)

                   meta = metadata()

                   Request.request_rest(
                     client,
                     meta,
                     :post,
                     url_path,
                     query_params,
                     custom_headers ++ headers,
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

                 @typedoc \"\"\"

                 ## Example:

                     audit_event() :: %{
                       \"eventData\" => [String.t()],
                       \"eventDataChecksum\" => [String.t()],
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     audit_event_result_entry() :: %{
                       \"eventID\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event_result_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_insufficient_permission() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_insufficient_permission() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_not_found() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_not_found() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_unsupported_schema() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_unsupported_schema() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     duplicated_audit_event_id() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type duplicated_audit_event_id() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     invalid_channel_arn() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type invalid_channel_arn() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_request() :: %{
                       optional(\"externalId\") => String.t(),
                       required(\"auditEvents\") => list(audit_event()()),
                       required(\"channelArn\") => String.t()
                     }

                 \"\"\"
                 @type put_audit_events_request() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_response() :: %{
                       required(\"failed\") => list(result_error_entry()()),
                       required(\"successful\") => list(audit_event_result_entry()())
                     }

                 \"\"\"
                 @type put_audit_events_response() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     result_error_entry() :: %{
                       \"errorCode\" => String.t(),
                       \"errorMessage\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type result_error_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     unsupported_operation_exception() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type unsupported_operation_exception() :: %{String.t() => any()}

                 @type put_audit_events_errors() ::
                         unsupported_operation_exception()
                         | invalid_channel_arn()
                         | duplicated_audit_event_id()
                         | channel_unsupported_schema()
                         | channel_not_found()
                         | channel_insufficient_permission()

                 def metadata do
                   %{
                     api_version: \"2021-08-11\",
                     content_type: \"application/x-amz-json-1.1\",
                     credential_scope: nil,
                     endpoint_prefix: \"cloudtrail-data\",
                     global?: false,
                     hostname: nil,
                     protocol: \"rest-json\",
                     service_id: \"CloudTrail Data\",
                     signature_version: \"v4\",
                     signing_name: \"cloudtrail-data\",
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
                 @spec put_audit_events(map(), String.t(), String.t() | nil, list()) ::
                         {:ok, put_audit_events_response(), any()}
                         | {:error, {:unexpected_response, any()}}
                         | {:error, term()}
                         | {:error, put_audit_events_errors()}
                 def put_audit_events(%Client{} = client, channel_arn, external_id \\\\ nil, options \\\\ []) do
                   url_path = \"/PutAuditEvents\"
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

                 @typedoc \"\"\"

                 ## Example:

                     audit_event() :: %{
                       \"eventData\" => [String.t()],
                       \"eventDataChecksum\" => [String.t()],
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     audit_event_result_entry() :: %{
                       \"eventID\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type audit_event_result_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_insufficient_permission() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_insufficient_permission() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_not_found() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_not_found() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     channel_unsupported_schema() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type channel_unsupported_schema() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     duplicated_audit_event_id() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type duplicated_audit_event_id() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     invalid_channel_arn() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type invalid_channel_arn() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_request() :: %{
                       optional(\"externalId\") => String.t(),
                       required(\"auditEvents\") => list(audit_event()()),
                       required(\"channelArn\") => String.t()
                     }

                 \"\"\"
                 @type put_audit_events_request() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     put_audit_events_response() :: %{
                       required(\"failed\") => list(result_error_entry()()),
                       required(\"successful\") => list(audit_event_result_entry()())
                     }

                 \"\"\"
                 @type put_audit_events_response() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     result_error_entry() :: %{
                       \"errorCode\" => String.t(),
                       \"errorMessage\" => String.t(),
                       \"id\" => String.t()
                     }

                 \"\"\"
                 @type result_error_entry() :: %{String.t() => any()}

                 @typedoc \"\"\"

                 ## Example:

                     unsupported_operation_exception() :: %{
                       \"message\" => [String.t()]
                     }

                 \"\"\"
                 @type unsupported_operation_exception() :: %{String.t() => any()}

                 @type put_audit_events_errors() ::
                         unsupported_operation_exception()
                         | invalid_channel_arn()
                         | duplicated_audit_event_id()
                         | channel_unsupported_schema()
                         | channel_not_found()
                         | channel_insufficient_permission()

                 def metadata do
                   %{
                     api_version: \"2021-08-11\",
                     content_type: \"application/x-amz-json-1.1\",
                     credential_scope: nil,
                     endpoint_prefix: \"cloudtrail-data\",
                     global?: false,
                     hostname: nil,
                     protocol: \"rest-json\",
                     service_id: \"CloudTrail Data\",
                     signature_version: \"v4\",
                     signing_name: \"cloudtrail-data\",
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
                 @spec put_audit_events(map(), put_audit_events_request(), list()) ::
                         {:ok, put_audit_events_response(), any()}
                         | {:error, {:unexpected_response, any()}}
                         | {:error, term()}
                         | {:error, put_audit_events_errors()}
                 def put_audit_events(%Client{} = client, input, options \\\\ []) do
                   url_path = \"/PutAuditEvents\"
                   headers = []
                   custom_headers = []

                   {query_params, input} =
                     [
                       {\"channelArn\", \"channelArn\"},
                       {\"externalId\", \"externalId\"}
                     ]
                     |> Request.build_params(input)

                   meta = metadata() |> Map.put_new(:host_prefix, \"my-host-prefix.\")

                   Request.request_rest(
                     client,
                     meta,
                     :post,
                     url_path,
                     query_params,
                     custom_headers ++ headers,
                     input,
                     options,
                     200
                   )
                 end
               end
               """)
    end

    test "renders the Elixir module with custom headers" do
      specs_file =
        @service_spec_custom_headers_file
        |> File.read!()
        |> Poison.decode!()

      context = setup_dataexchange_context(:elixir, specs_file)

      result =
        context
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      generated = File.read!(@service_spec_custom_headers_generated)
      assert result == generated
    end
  end
end
