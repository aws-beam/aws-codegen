defmodule AWS.CodeGen.UtilTest do
  use ExUnit.Case, async: true
  doctest AWS.CodeGen.Util

  alias AWS.CodeGen.Util

  describe "endpoint_url_env_var/1" do
    test "derives the env var from a single-word sdkId" do
      service = build_service("DynamoDB")
      assert Util.endpoint_url_env_var(service) == "AWS_ENDPOINT_URL_DYNAMODB"
    end

    test "replaces interior spaces with underscores and uppercases the result" do
      service = build_service("Elastic Beanstalk")
      assert Util.endpoint_url_env_var(service) == "AWS_ENDPOINT_URL_ELASTIC_BEANSTALK"
    end

    test "handles multi-word sdkIds" do
      service = build_service("CloudTrail Data")
      assert Util.endpoint_url_env_var(service) == "AWS_ENDPOINT_URL_CLOUDTRAIL_DATA"
    end

    test "returns nil when the sdkId is missing" do
      assert Util.endpoint_url_env_var(%{"traits" => %{}}) == nil
      assert Util.endpoint_url_env_var(%{}) == nil
    end
  end

  defp build_service(sdk_id) do
    %{"traits" => %{"aws.api#service" => %{"sdkId" => sdk_id}}}
  end
end
