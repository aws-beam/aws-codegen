defmodule AWS.CodeGen do
  @elixir_services [
    {:json, "AWS.CloudHSM", "cloudhsm/2014-05-30", "cloud_hsm.ex"},
    {:json, "AWS.CloudTrail", "cloudtrail/2013-11-01", "cloud_trail.ex"},
    {:json, "AWS.CodeCommit", "codecommit/2015-04-13", "code_commit.ex"},
    {:json, "AWS.CodeDeploy", "codedeploy/2014-10-06", "code_deploy.ex"},
    {:json, "AWS.CodePipeline", "codepipeline/2015-07-09", "code_pipeline.ex"},
    {:json, "AWS.Cognito", "cognito-identity/2014-06-30", "cognito.ex"},
    {:json, "AWS.Config", "config/2014-11-12", "config.ex"},
    {:json, "AWS.DataPipeline", "datapipeline/2012-10-29", "data_pipeline.ex"},
    {:json, "AWS.DeviceFarm", "devicefarm/2015-06-23", "device_farm.ex"},
    {:json, "AWS.DirectConnect", "directconnect/2012-10-25", "direct_connect.ex"},
    {:json, "AWS.DirectoryService", "ds/2015-04-16", "directory_service.ex"},
    {:json, "AWS.DynamoDB", "dynamodb/2012-08-10", "dynamodb.ex"},
    {:json, "AWS.DynamoDB.Streams", "streams.dynamodb/2012-08-10", "dynamodb_streams.ex"},
    {:json, "AWS.ECS", "ecs/2014-11-13", "ecs.ex"},
    {:json, "AWS.EMR", "elasticmapreduce/2009-03-31", "emr.ex"},
    {:json, "AWS.GameLift", "gamelift/2015-10-01", "gamelift.ex"},
    {:json, "AWS.Kinesis", "kinesis/2013-12-02", "kinesis.ex"},
    {:json, "AWS.KMS", "kms/2014-11-01", "kms.ex"},
    {:json, "AWS.Logs", "logs/2014-03-28", "logs.ex"},
    {:json, "AWS.MCA", "marketplacecommerceanalytics/2015-07-01", "mca.ex"},
    {:json, "AWS.OpsWorks", "opsworks/2013-02-18", "ops_works.ex"},
    {:json, "AWS.Route53.Domains", "route53domains/2014-05-15", "route53_domains.ex"},
    {:json, "AWS.SSM", "ssm/2014-11-06", "ssm.ex"},
    {:json, "AWS.StorageGateway", "storagegateway/2013-06-30", "storage_gateway.ex"},
    {:json, "AWS.Support", "support/2013-04-15", "support.ex"},
    {:json, "AWS.SWF", "swf/2012-01-25", "swf.ex"},
    {:json, "AWS.WAF", "waf/2015-08-24", "waf.ex"},
    {:json, "AWS.Workspaces", "workspaces/2015-04-08", "workspaces.ex"},
    {:rest_json, "AWS.CloudSearch.Domain", "cloudsearchdomain/2013-01-01", "cloud_search_domain.ex"},
    {:rest_json, "AWS.Cognito.Sync", "cognito-sync/2014-06-30", "cognito_sync.ex"},
    {:rest_json, "AWS.EFS", "elasticfilesystem/2015-02-01", "efs.ex"},
    {:rest_json, "AWS.Glacier", "glacier/2012-06-01", "glacier.ex"},
    {:rest_json, "AWS.Lambda", "lambda/2015-03-31", "lambda.ex"},
    {:rest_json, "AWS.MobileAnalytics", "mobileanalytics/2014-06-05", "mobile_analytics.ex"},
    {:rest_json, "AWS.Transcoder", "elastictranscoder/2012-09-25", "transcoder.ex"},
  ]

  @erlang_services [
    {:json, "aws_cloud_hsm", "cloudhsm/2014-05-30", "aws_cloud_hsm.erl"},
    {:json, "aws_cloud_trail", "cloudtrail/2013-11-01", "aws_cloud_trail.erl"},
    {:json, "aws_code_commit", "codecommit/2015-04-13", "aws_code_commit.erl"},
    {:json, "aws_code_deploy", "codedeploy/2014-10-06", "aws_code_deploy.erl"},
    {:json, "aws_code_pipeline", "codepipeline/2015-07-09", "aws_code_pipeline.erl"},
    {:json, "aws_cognito", "cognito-identity/2014-06-30", "aws_cognito.erl"},
    {:json, "aws_config", "config/2014-11-12", "aws_config.erl"},
    {:json, "aws_data_pipeline", "datapipeline/2012-10-29", "aws_data_pipeline.erl"},
    {:json, "aws_device_farm", "devicefarm/2015-06-23", "aws_device_farm.erl"},
    {:json, "aws_direct_connect", "directconnect/2012-10-25", "aws_direct_connect.erl"},
    {:json, "aws_directory_service", "ds/2015-04-16", "aws_directory_service.erl"},
    {:json, "aws_dynamodb", "dynamodb/2012-08-10", "aws_dynamodb.erl"},
    {:json, "aws_dynamodb_streams", "streams.dynamodb/2012-08-10", "aws_dynamodb_streams.erl"},
    {:json, "aws_ecs", "ecs/2014-11-13", "aws_ecs.erl"},
    {:json, "aws_emr", "elasticmapreduce/2009-03-31", "aws_emr.erl"},
    {:json, "aws_gamelift", "gamelift/2015-10-01", "aws_gamelift.erl"},
    {:json, "aws_kinesis", "kinesis/2013-12-02", "aws_kinesis.erl"},
    {:json, "aws_kms", "kms/2014-11-01", "aws_kms.erl"},
    {:json, "aws_logs", "logs/2014-03-28", "aws_logs.erl"},
    {:json, "aws_mca", "marketplacecommerceanalytics/2015-07-01", "aws_mca.erl"},
    {:json, "aws_ops_works", "opsworks/2013-02-18", "aws_ops_works.erl"},
    {:json, "aws_route53_domains", "route53domains/2014-05-15", "aws_route53_domains.erl"},
    {:json, "aws_ssm", "ssm/2014-11-06", "aws_ssm.erl"},
    {:json, "aws_storage_gateway", "storagegateway/2013-06-30", "aws_storage_gateway.erl"},
    {:json, "aws_support", "support/2013-04-15", "aws_support.erl"},
    {:json, "aws_swf", "swf/2012-01-25", "aws_swf.erl"},
    {:json, "aws_waf", "waf/2015-08-24", "aws_waf.erl"},
    {:json, "aws_workspaces", "workspaces/2015-04-08", "aws_workspaces.erl"},
  ]

  def generate(language, spec_base_path, template_base_path, output_base_path) do
    tasks = Enum.map(api_specs(language), fn({protocol, module_name, spec_path, output_filename}) ->
      api_spec_path = make_spec_path(spec_base_path, spec_path, "api-2.json")
      doc_spec_path = make_spec_path(spec_base_path, spec_path, "docs-2.json")
      output_path = Path.join(output_base_path, output_filename)
      args = [language, protocol, module_name, api_spec_path, doc_spec_path,
              template_base_path, output_path]
      Task.async(AWS.CodeGen, :generate_code, args)
    end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
  end

  def api_specs(:elixir) do
    @elixir_services
  end

  def api_specs(:erlang) do
    @erlang_services
  end

  def generate_code(language, :json, module_name, api_spec_path, doc_spec_path,
                    template_base_path, output_path) do
    template_path = Path.join(template_base_path, json_spec_template(language))
    context = AWS.CodeGen.JSONService.load_context(language, module_name,
                                                   api_spec_path, doc_spec_path)
    code = AWS.CodeGen.JSONService.render(context, template_path)
    File.write(output_path, code)
  end

  defp json_spec_template(:elixir) do
    "json.ex.eex"
  end

  defp json_spec_template(:erlang) do
    "json.erl.eex"
  end

  def generate_code(language, :rest_json, module_name, api_spec_path,
                    doc_spec_path, template_base_path, output_path) do
    template_path = Path.join(template_base_path, rest_json_spec_template(language))
    context = AWS.CodeGen.RestJSONService.load_context(language, module_name,
                                                       api_spec_path,
                                                       doc_spec_path)
    code = AWS.CodeGen.RestJSONService.render(context, template_path)
    File.write(output_path, code)
  end

  defp rest_json_spec_template(:elixir) do
    "rest_json.ex.eex"
  end

  defp rest_json_spec_template(:erlang) do
    "rest_json.erl.eex"
  end

  defp make_spec_path(spec_base_path, spec_path, filename) do
    spec_base_path |> Path.join(spec_path) |> Path.join(filename)
  end
end
