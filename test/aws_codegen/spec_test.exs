defmodule AWS.CodeGen.SpecTest do
  use ExUnit.Case

  alias AWS.CodeGen.Spec

  test "parse/3" do
    assert %Spec{
             module_name: "AWS.MobileAnalytics",
             filename: "mobile_analytics.ex",
             api: api,
             doc: docs,
             protocol: :rest_json
           } =
             Spec.parse("test/fixtures/apis_specs", :elixir,
               api_filename: "mobileanalytics-2014-06-05-api-2.json",
               doc_filename: "mobileanalytics-2014-06-05-docs-2.json"
             )

    assert %Spec{
             module_name: "aws_mobileanalytics",
             filename: "aws_mobileanalytics.erl"
           } =
             Spec.parse("test/fixtures/apis_specs", :erlang,
               api_filename: "mobileanalytics-2014-06-05-api-2.json",
               doc_filename: "mobileanalytics-2014-06-05-docs-2.json"
             )

    assert api == %{
             "metadata" => %{
               "apiVersion" => "2014-06-05",
               "endpointPrefix" => "mobileanalytics",
               "protocol" => "rest-json",
               "serviceFullName" => "Amazon Mobile Analytics",
               "signatureVersion" => "v4"
             },
             "operations" => %{
               "PutEvents" => %{
                 "errors" => [
                   %{
                     "error" => %{"httpStatusCode" => 400},
                     "exception" => true,
                     "shape" => "BadRequestException"
                   }
                 ],
                 "http" => %{
                   "method" => "POST",
                   "requestUri" => "/2014-06-05/events",
                   "responseCode" => 202
                 },
                 "input" => %{"shape" => "PutEventsInput"},
                 "name" => "PutEvents"
               }
             },
             "shapes" => %{
               "BadRequestException" => %{
                 "error" => %{"httpStatusCode" => 400},
                 "exception" => true,
                 "members" => %{"message" => %{"shape" => "String"}},
                 "type" => "structure"
               },
               "Double" => %{"type" => "double"},
               "Event" => %{
                 "members" => %{
                   "attributes" => %{"shape" => "MapOfStringToString"},
                   "eventType" => %{"shape" => "String50Chars"},
                   "metrics" => %{"shape" => "MapOfStringToNumber"},
                   "session" => %{"shape" => "Session"},
                   "timestamp" => %{"shape" => "ISO8601Timestamp"},
                   "version" => %{"shape" => "String10Chars"}
                 },
                 "required" => ["eventType", "timestamp"],
                 "type" => "structure"
               },
               "EventListDefinition" => %{"member" => %{"shape" => "Event"}, "type" => "list"},
               "ISO8601Timestamp" => %{"type" => "string"},
               "Long" => %{"type" => "long"},
               "MapOfStringToNumber" => %{
                 "key" => %{"shape" => "String50Chars"},
                 "max" => 50,
                 "min" => 0,
                 "type" => "map",
                 "value" => %{"shape" => "Double"}
               },
               "MapOfStringToString" => %{
                 "key" => %{"shape" => "String50Chars"},
                 "max" => 50,
                 "min" => 0,
                 "type" => "map",
                 "value" => %{"shape" => "String0to1000Chars"}
               },
               "PutEventsInput" => %{
                 "members" => %{
                   "clientContext" => %{
                     "location" => "header",
                     "locationName" => "x-amz-Client-Context",
                     "shape" => "String"
                   },
                   "clientContextEncoding" => %{
                     "location" => "header",
                     "locationName" => "x-amz-Client-Context-Encoding",
                     "shape" => "String"
                   },
                   "events" => %{"shape" => "EventListDefinition"}
                 },
                 "required" => ["events", "clientContext"],
                 "type" => "structure"
               },
               "Session" => %{
                 "members" => %{
                   "duration" => %{"shape" => "Long"},
                   "id" => %{"shape" => "String50Chars"},
                   "startTimestamp" => %{"shape" => "ISO8601Timestamp"},
                   "stopTimestamp" => %{"shape" => "ISO8601Timestamp"}
                 },
                 "type" => "structure"
               },
               "String" => %{"type" => "string"},
               "String0to1000Chars" => %{"max" => 1000, "min" => 0, "type" => "string"},
               "String10Chars" => %{"max" => 10, "min" => 1, "type" => "string"},
               "String50Chars" => %{"max" => 50, "min" => 1, "type" => "string"}
             },
             "version" => "2.0"
           }

    assert %{
             "operations" => _operations,
             "service" => _service_description,
             "shapes" => _shapes,
             "version" => "2.0"
           } = docs
  end
end
