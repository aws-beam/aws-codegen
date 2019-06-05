defmodule AWS.CodeGen do
  @elixir_services [
    {:json, "AWS.AppStream", "appstream/2016-12-01", "appstream.ex", []},
    {:json, "AWS.AutoScaling", "application-autoscaling/2016-02-06", "autoscaling.ex", []},
    {:json, "AWS.Budgets", "budgets/2016-10-20", "budgets.ex", []},
    {:json, "AWS.CertificateManager", "acm/2015-12-08", "certificate_manager.ex", []},
    {:json, "AWS.CloudHSM", "cloudhsm/2014-05-30", "cloud_hsm.ex", []},
    {:json, "AWS.CloudTrail", "cloudtrail/2013-11-01", "cloud_trail.ex", []},
    {:json, "AWS.CloudWatch.Events", "events/2015-10-07", "cloudwatch_events.ex", []},
    {:json, "AWS.CodeBuild", "codebuild/2016-10-06", "code_build.ex", []},
    {:json, "AWS.CodeCommit", "codecommit/2015-04-13", "code_commit.ex", []},
    {:json, "AWS.CodeDeploy", "codedeploy/2014-10-06", "code_deploy.ex", []},
    {:json, "AWS.CodePipeline", "codepipeline/2015-07-09", "code_pipeline.ex", []},
    {:json, "AWS.Cognito", "cognito-identity/2014-06-30", "cognito.ex", []},
    {:json, "AWS.Cognito.IdentityProvider", "cognito-idp/2016-04-18", "cognito_identity_provider.ex", []},
    {:json, "AWS.Config", "config/2014-11-12", "config.ex", []},
    {:json, "AWS.CostAndUsageReport", "cur/2017-01-06", "cost_and_usage_report.ex", []},
    {:json, "AWS.DMS", "dms/2016-01-01", "dms.ex", []},
    {:json, "AWS.DataPipeline", "datapipeline/2012-10-29", "data_pipeline.ex", []},
    {:json, "AWS.DeviceFarm", "devicefarm/2015-06-23", "device_farm.ex", []},
    {:json, "AWS.DirectConnect", "directconnect/2012-10-25", "direct_connect.ex", []},
    {:json, "AWS.DirectoryService", "ds/2015-04-16", "directory_service.ex", []},
    {:json, "AWS.Discovery", "discovery/2015-11-01", "discovery.ex", []},
    {:json, "AWS.DynamoDB", "dynamodb/2012-08-10", "dynamodb.ex", []},
    {:json, "AWS.DynamoDB.Streams", "streams.dynamodb/2012-08-10", "dynamodb_streams.ex", []},
    {:json, "AWS.ECR", "ecr/2015-09-21", "ecr.ex", []},
    {:json, "AWS.ECS", "ecs/2014-11-13", "ecs.ex", []},
    {:json, "AWS.EMR", "elasticmapreduce/2009-03-31", "emr.ex", []},
    {:json, "AWS.GameLift", "gamelift/2015-10-01", "gamelift.ex", []},
    {:json, "AWS.Health", "health/2016-08-04", "health.ex", []},
    {:json, "AWS.Inspector", "inspector/2016-02-16", "inspector.ex", []},
    {:json, "AWS.Kinesis", "kinesis/2013-12-02", "kinesis.ex", []},
    {:json, "AWS.Kinesis.Analytics", "kinesisanalytics/2015-08-14", "kinesis_analytics.ex", []},
    {:json, "AWS.Kinesis.Firehose", "firehose/2015-08-04", "kinesis_firehose.ex", []},
    {:json, "AWS.KMS", "kms/2014-11-01", "kms.ex", []},
    {:json, "AWS.Lightsail", "lightsail/2016-11-28", "lightsail.ex", []},
    {:json, "AWS.Logs", "logs/2014-03-28", "logs.ex", []},
    {:json, "AWS.MachineLearning", "machinelearning/2014-12-12", "machine_learning.ex", []},
    {:json, "AWS.Marketplace.CommerceAnalytics", "marketplacecommerceanalytics/2015-07-01", "marketplace_commerce_analytics.ex", []},
    {:json, "AWS.Marketplace.Metering", "meteringmarketplace/2016-01-14", "marketplace_metering.ex", []},
    {:json, "AWS.MechanicalTurk", "mturk-requester/2017-01-17", "mechanical_turk.ex", []},
    {:json, "AWS.OpsWorks", "opsworks/2013-02-18", "ops_works.ex", []},
    {:json, "AWS.OpsWorks.ChefAutomate", "opsworkscm/2016-11-01", "ops_works_chef_automate.ex", []},
    {:json, "AWS.Organizations", "organizations/2016-11-28", "organizations.ex", []},
    {:json, "AWS.Rekognition", "rekognition/2016-06-27", "rekognition.ex", []},
    {:json, "AWS.Route53.Domains", "route53domains/2014-05-15", "route53_domains.ex", []},
    {:json, "AWS.SSM", "ssm/2014-11-06", "ssm.ex", []},
    {:json, "AWS.ServiceCatalog", "servicecatalog/2015-12-10", "service_catalog.ex", []},
    {:json, "AWS.Shield", "shield/2016-06-02", "shield.ex", []},
    {:json, "AWS.Snowball", "snowball/2016-06-30", "snowball.ex", []},
    {:json, "AWS.StepFunctions", "states/2016-11-23", "step_functions.ex", []},
    {:json, "AWS.StorageGateway", "storagegateway/2013-06-30", "storage_gateway.ex", []},
    {:json, "AWS.Support", "support/2013-04-15", "support.ex", []},
    {:json, "AWS.SMS", "sms/2016-10-24", "sms.ex", []},
    {:json, "AWS.SSM", "ssm/2014-11-06", "ssm.ex", []},
    {:json, "AWS.STS", "sts/2011-06-15", "sts.ex", []},
    {:json, "AWS.SWF", "swf/2012-01-25", "swf.ex", []},
    {:json, "AWS.WAF", "waf/2015-08-24", "waf.ex", []},
    {:json, "AWS.WAF.Regional", "waf-regional/2016-11-28", "waf_regional.ex", []},
    {:json, "AWS.Workspaces", "workspaces/2015-04-08", "workspaces.ex", []},
    {:rest_json, "AWS.APIGateway", "apigateway/2015-07-09", "api_gateway.ex", [:strip_trailing_slash_in_url]},
    {:rest_json, "AWS.Batch", "batch/2016-08-10", "batch.ex", []},
    {:rest_json, "AWS.CloudDirectory", "clouddirectory/2017-01-11", "cloud_directory.ex", []},
    {:rest_json, "AWS.Cognito.Sync", "cognito-sync/2014-06-30", "cognito_sync.ex", []},
    {:rest_json, "AWS.EFS", "elasticfilesystem/2015-02-01", "efs.ex", []},
    {:rest_json, "AWS.Glacier", "glacier/2012-06-01", "glacier.ex", []},
    {:rest_json, "AWS.IoT", "iot/2015-05-28", "iot.ex", []},
    {:rest_json, "AWS.IoT.DataPlane", "iot-data/2015-05-28", "iot_data.ex", []},
    {:rest_json, "AWS.Lambda", "lambda/2015-03-31", "lambda.ex", []},
    {:rest_json, "AWS.MobileAnalytics", "mobileanalytics/2014-06-05", "mobile_analytics.ex", []},
    {:rest_json, "AWS.Polly", "polly/2016-06-10", "polly.ex", []},
    {:rest_json, "AWS.LexRuntime", "runtime.lex/2016-11-28", "lex_runtime.ex", []},
    {:rest_json, "AWS.Transcoder", "elastictranscoder/2012-09-25", "transcoder.ex", []},
    {:rest_json, "AWS.XRay", "xray/2016-04-12", "xray.ex", []},
  ]

  @erlang_services [
    {:json, "aws_autoscaling", "application-autoscaling/2016-02-06", "aws_autoscaling.erl", []},
    {:json, "aws_certificate_manager", "acm/2015-12-08", "aws_certificate_manager.erl", []},
    {:json, "aws_cloudwatch_events", "events/2015-10-07", "aws_cloudwatch_events.erl", []},
    {:json, "aws_cloud_hsm", "cloudhsm/2014-05-30", "aws_cloud_hsm.erl", []},
    {:json, "aws_cloud_trail", "cloudtrail/2013-11-01", "aws_cloud_trail.erl", []},
    {:json, "aws_code_commit", "codecommit/2015-04-13", "aws_code_commit.erl", []},
    {:json, "aws_code_deploy", "codedeploy/2014-10-06", "aws_code_deploy.erl", []},
    {:json, "aws_code_pipeline", "codepipeline/2015-07-09", "aws_code_pipeline.erl", []},
    {:json, "aws_cognito", "cognito-identity/2014-06-30", "aws_cognito.erl", []},
    {:json, "aws_cognito_idp", "cognito-idp/2016-04-18", "aws_cognito_idp.erl", []},
    {:json, "aws_config", "config/2014-11-12", "aws_config.erl", []},
    {:json, "aws_data_pipeline", "datapipeline/2012-10-29", "aws_data_pipeline.erl", []},
    {:json, "aws_device_farm", "devicefarm/2015-06-23", "aws_device_farm.erl", []},
    {:json, "aws_direct_connect", "directconnect/2012-10-25", "aws_direct_connect.erl", []},
    {:json, "aws_directory_service", "ds/2015-04-16", "aws_directory_service.erl", []},
    {:json, "aws_discovery", "discovery/2015-11-01", "aws_discovery.erl", []},
    {:json, "aws_dms", "dms/2016-01-01", "aws_dms.erl", []},
    {:json, "aws_dynamodb", "dynamodb/2012-08-10", "aws_dynamodb.erl", []},
    {:json, "aws_dynamodb_streams", "streams.dynamodb/2012-08-10", "aws_dynamodb_streams.erl", []},
    {:json, "aws_ecr", "ecr/2015-09-21", "aws_ecr.erl", []},
    {:json, "aws_ecs", "ecs/2014-11-13", "aws_ecs.erl", []},
    {:json, "aws_emr", "elasticmapreduce/2009-03-31", "aws_emr.erl", []},
    {:json, "aws_gamelift", "gamelift/2015-10-01", "aws_gamelift.erl", []},
    {:json, "aws_inspector", "inspector/2016-02-16", "aws_inspector.erl", []},
    {:json, "aws_kinesis", "kinesis/2013-12-02", "aws_kinesis.erl", []},
    {:json, "aws_kinesis_firehose", "firehose/2015-08-04", "aws_kinesis_firehose.erl", []},
    {:json, "aws_kms", "kms/2014-11-01", "aws_kms.erl", []},
    {:json, "aws_logs", "logs/2014-03-28", "aws_logs.erl", []},
    {:json, "aws_machine_learning", "machinelearning/2014-12-12", "aws_machine_learning.erl", []},
    {:json, "aws_marketplace_commerce_analytics", "marketplacecommerceanalytics/2015-07-01", "aws_marketplace_commerce_analytics.erl", []},
    {:json, "aws_marketplace_metering", "meteringmarketplace/2016-01-14", "aws_marketplace_metering.erl", []},
    {:json, "aws_ops_works", "opsworks/2013-02-18", "aws_ops_works.erl", []},
    {:json, "aws_route53_domains", "route53domains/2014-05-15", "aws_route53_domains.erl", []},
    {:json, "aws_service_catalog", "servicecatalog/2015-12-10", "aws_service_catalog.erl", []},
    {:json, "aws_ssm", "ssm/2014-11-06", "aws_ssm.erl", []},
    {:json, "aws_storage_gateway", "storagegateway/2013-06-30", "aws_storage_gateway.erl", []},
    {:json, "aws_support", "support/2013-04-15", "aws_support.erl", []},
    {:json, "aws_swf", "swf/2012-01-25", "aws_swf.erl", []},
    {:json, "aws_waf", "waf/2015-08-24", "aws_waf.erl", []},
    {:json, "aws_workspaces", "workspaces/2015-04-08", "aws_workspaces.erl", []},
  ]

  def generate(language, spec_base_path, template_base_path, output_base_path) do
    tasks = Enum.map(api_specs(language), fn({protocol, module_name, spec_path, output_filename, options}) ->
      api_spec_path = make_spec_path(spec_base_path, spec_path, "api-2.json")
      doc_spec_path = make_spec_path(spec_base_path, spec_path, "docs-2.json")
      output_path = Path.join(output_base_path, output_filename)
      args = [language, protocol, module_name, api_spec_path, doc_spec_path,
              template_base_path, output_path, options]
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
                    template_base_path, output_path, _options) do
    template_path = Path.join(template_base_path, json_spec_template(language))
    context = AWS.CodeGen.JSONService.load_context(language, module_name,
                                                   api_spec_path, doc_spec_path)
    code = AWS.CodeGen.JSONService.render(context, template_path)
    File.write(output_path, code)
  end

  def generate_code(language, :rest_json, module_name, api_spec_path,
                    doc_spec_path, template_base_path, output_path, options) do
    template_path = Path.join(template_base_path, rest_json_spec_template(language))
    context = AWS.CodeGen.RestJSONService.load_context(language, module_name,
                                                       api_spec_path,
                                                       doc_spec_path, options)
    code = AWS.CodeGen.RestJSONService.render(context, template_path)
    File.write(output_path, code)
  end

  defp json_spec_template(:elixir) do
    "json.ex.eex"
  end

  defp json_spec_template(:erlang) do
    "json.erl.eex"
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
