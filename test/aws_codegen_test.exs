defmodule AWS.CodeGenTest do
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

  describe "render/2" do
    defp setup_context(language, specs, docs \\ nil) do
      spec = %AWS.CodeGen.Spec{
        api: specs,
        doc: docs,
        module_name: "AWS.MobileAnalytics",
        filename: "mobile_analytics.ex",
        protocol: :rest_json
      }

      RestService.load_context(language, spec, @endpoints_spec)
    end

    test "renders the Elixir module without docs", %{specs: specs} do
      context = setup_context(:elixir, specs)

      result =
        context
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.MobileAnalytics do
                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     abbreviation: nil,
                     api_version: "2014-06-05",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "mobileanalytics",
                     global?: false,
                     protocol: "rest-json",
                     service_id: nil,
                     signature_version: "v4",
                     signing_name: "mobileanalytics",
                     target_prefix: nil
                   }
                 end

                 def put_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/2014-06-05/events"

                   {headers, input} =
                     [
                       {"clientContext", "x-amz-Client-Context"},
                       {"clientContextEncoding", "x-amz-Client-Context-Encoding"}
                     ]
                     |> Request.build_params(input)

                   query_params = []

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
                     202
                   )
                 end
               end
               """)
    end

    test "renders the Elixir module with docs", %{specs: specs, docs: docs} do
      context = setup_context(:elixir, specs, docs)

      result =
        context
        |> AWS.CodeGen.render("priv/rest.ex.eex")
        |> IO.iodata_to_binary()

      assert result ==
               String.trim_leading("""
               # WARNING: DO NOT EDIT, AUTO-GENERATED CODE!
               # See https://github.com/aws-beam/aws-codegen for more details.

               defmodule AWS.MobileAnalytics do
                 @moduledoc \"\"\"
                 Amazon Mobile Analytics is a service for collecting, visualizing, and
                 understanding app usage data at scale.
                 \"\"\"

                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     abbreviation: nil,
                     api_version: "2014-06-05",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "mobileanalytics",
                     global?: false,
                     protocol: "rest-json",
                     service_id: nil,
                     signature_version: "v4",
                     signing_name: "mobileanalytics",
                     target_prefix: nil
                   }
                 end

                 @doc \"\"\"
                 The PutEvents operation records one or more events.

                 You can have up to 1,500 unique custom events per app, any combination of up to
                 40 attributes and metrics per custom event, and any number of attribute or
                 metric values.
                 \"\"\"
                 def put_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/2014-06-05/events"

                   {headers, input} =
                     [
                       {"clientContext", "x-amz-Client-Context"},
                       {"clientContextEncoding", "x-amz-Client-Context-Encoding"}
                     ]
                     |> Request.build_params(input)

                   query_params = []

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
                     202
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

               defmodule AWS.MobileAnalytics do
                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     abbreviation: nil,
                     api_version: "2014-06-05",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "mobileanalytics",
                     global?: false,
                     protocol: "rest-json",
                     service_id: nil,
                     signature_version: "v4",
                     signing_name: "mobileanalytics",
                     target_prefix: nil
                   }
                 end

                 def put_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/2014-06-05/events"

                   {headers, input} =
                     [
                       {"clientContext", "x-amz-Client-Context"},
                       {"clientContextEncoding", "x-amz-Client-Context-Encoding"}
                     ]
                     |> Request.build_params(input)

                   query_params = []

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
                     202
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

               defmodule AWS.MobileAnalytics do
                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     abbreviation: nil,
                     api_version: "2014-06-05",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "mobileanalytics",
                     global?: false,
                     protocol: "rest-json",
                     service_id: nil,
                     signature_version: "v4",
                     signing_name: "mobileanalytics",
                     target_prefix: nil
                   }
                 end

                 def put_events(
                       %Client{} = client,
                       client_context,
                       client_context_encoding \\\\ nil,
                       options \\\\ []
                     ) do
                   url_path = "/2014-06-05/events"
                   headers = []

                   headers =
                     if !is_nil(client_context) do
                       [{"x-amz-Client-Context", client_context} | headers]
                     else
                       headers
                     end

                   headers =
                     if !is_nil(client_context_encoding) do
                       [{"x-amz-Client-Context-Encoding", client_context_encoding} | headers]
                     else
                       headers
                     end

                   query_params = []

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

                   Request.request_rest(client, meta, :get, url_path, query_params, headers, nil, options, 202)
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

               defmodule AWS.MobileAnalytics do
                 alias AWS.Client
                 alias AWS.Request

                 def metadata do
                   %{
                     abbreviation: nil,
                     api_version: "2014-06-05",
                     content_type: "application/x-amz-json-1.1",
                     credential_scope: nil,
                     endpoint_prefix: "mobileanalytics",
                     global?: false,
                     protocol: "rest-json",
                     service_id: nil,
                     signature_version: "v4",
                     signing_name: "mobileanalytics",
                     target_prefix: nil
                   }
                 end

                 def put_events(%Client{} = client, input, options \\\\ []) do
                   url_path = "/2014-06-05/events"

                   {headers, input} =
                     [
                       {"clientContext", "x-amz-Client-Context"},
                       {"clientContextEncoding", "x-amz-Client-Context-Encoding"}
                     ]
                     |> Request.build_params(input)

                   query_params = []

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
                     202
                   )
                 end
               end
               """)
    end
  end
end
