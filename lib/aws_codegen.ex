defmodule AWS.CodeGen do

  @elixir_services [
    {:json, "AWS.AppStream", "appstream/2016-12-01", "appstream.ex", []},
    {:json, "AWS.AppAutoScaling", "application-autoscaling/2016-02-06", "app_autoscaling.ex", []},
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
    {:json, "AWS.DataPipeline", "datapipeline/2012-10-29", "data_pipeline.ex", []},
    {:json, "AWS.DeviceFarm", "devicefarm/2015-06-23", "device_farm.ex", []},
    {:json, "AWS.DirectConnect", "directconnect/2012-10-25", "direct_connect.ex", []},
    {:json, "AWS.DirectoryService", "ds/2015-04-16", "directory_service.ex", []},
    {:json, "AWS.Discovery", "discovery/2015-11-01", "discovery.ex", []},
    {:json, "AWS.DynamoDB", "dynamodb/2012-08-10", "dynamodb.ex", []},
    {:json, "AWS.DynamoDB.Streams", "streams.dynamodb/2012-08-10", "dynamodb_streams.ex", []},
    {:json, "AWS.DMS", "dms/2016-01-01", "dms.ex", []},
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
    {:json, "AWS.SecretsManager", "secretsmanager/2017-10-17", "secrets_manager.ex", []},
    {:json, "AWS.ServiceCatalog", "servicecatalog/2015-12-10", "service_catalog.ex", []},
    {:json, "AWS.Shield", "shield/2016-06-02", "shield.ex", []},
    {:json, "AWS.Snowball", "snowball/2016-06-30", "snowball.ex", []},
    {:json, "AWS.StepFunctions", "states/2016-11-23", "step_functions.ex", []},
    {:json, "AWS.StorageGateway", "storagegateway/2013-06-30", "storage_gateway.ex", []},
    {:json, "AWS.Support", "support/2013-04-15", "support.ex", []},
    {:json, "AWS.SMS", "sms/2016-10-24", "sms.ex", []},
    {:json, "AWS.SSM", "ssm/2014-11-06", "ssm.ex", []},
    {:json, "AWS.SWF", "swf/2012-01-25", "swf.ex", []},
    {:json, "AWS.WAF", "waf/2015-08-24", "waf.ex", []},
    {:json, "AWS.WAF.Regional", "waf-regional/2016-11-28", "waf_regional.ex", []},
    {:json, "AWS.Workspaces", "workspaces/2015-04-08", "workspaces.ex", []},
    {:rest_json, "AWS.APIGateway", "apigateway/2015-07-09", "api_gateway.ex", []},
    {:rest_json, "AWS.Batch", "batch/2016-08-10", "batch.ex", []},
    {:rest_json, "AWS.CloudDirectory", "clouddirectory/2017-01-11", "cloud_directory.ex", []},
    {:rest_json, "AWS.Cognito.Sync", "cognito-sync/2014-06-30", "cognito_sync.ex", []},
    {:rest_json, "AWS.Connect", "connect/2017-08-08", "connect.ex", []},
    {:rest_json, "AWS.EFS", "elasticfilesystem/2015-02-01", "efs.ex", []},
    {:rest_json, "AWS.Glacier", "glacier/2012-06-01", "glacier.ex", []},
    {:rest_json, "AWS.IoT", "iot/2015-05-28", "iot.ex", []},
    {:rest_json, "AWS.IoT.DataPlane", "iot-data/2015-05-28", "iot_data.ex", []},
    {:rest_json, "AWS.Lambda", "lambda/2015-03-31", "lambda.ex", []},
    {:rest_json, "AWS.MobileAnalytics", "mobileanalytics/2014-06-05", "mobile_analytics.ex", []},
    {:rest_json, "AWS.Pinpoint", "pinpoint/2016-12-01", "pinpoint.ex", []},
    {:rest_json, "AWS.Polly", "polly/2016-06-10", "polly.ex", []},
    {:rest_json, "AWS.LexRuntime", "runtime.lex/2016-11-28", "lex_runtime.ex", []},
    {:rest_json, "AWS.Transcoder", "elastictranscoder/2012-09-25", "transcoder.ex", []},
    {:rest_json, "AWS.XRay", "xray/2016-04-12", "xray.ex", []},
    {:rest_xml, "AWS.Cloudfront", "cloudfront/2020-05-31", "cloudfront.ex", []},
    {:rest_xml, "AWS.Route53", "route53/2013-04-01", "route53.ex", []},
    {:rest_xml, "AWS.S3", "s3/2006-03-01", "s3.ex", []},
    {:rest_xml, "AWS.S3Control", "s3control/2018-08-20", "s3control.ex", []},
    {:query, "AWS.Autoscaling", "autoscaling/2011-01-01", "autoscaling.ex", []},
    {:query, "AWS.CloudFormation", "cloudformation/2010-05-15", "cloud_formation.ex", []},
    {:query, "AWS.CloudSearch", "cloudsearch/2013-01-01", "cloud_search.ex", []},
    {:query, "AWS.DocDB", "docdb/2014-10-31", "doc_db.ex", []},
    {:query, "AWS.ElastiCache", "elasticache/2015-02-02", "elasticache.ex", []},
    {:query, "AWS.ElasticBeanstalk", "elasticbeanstalk/2010-12-01", "elastic_beanstalk.ex", []},
    {:query, "AWS.ElasticLoadBalancing", "elasticloadbalancing/2012-06-01", "elastic_load_balancing.ex", []},
    {:query, "AWS.ElasticLoadBalancingV2", "elasticloadbalancingv2/2015-12-01", "elastic_load_balancing_v2.ex", []},
    {:query, "AWS.Email", "email/2010-12-01", "email.ex", []},
    {:query, "AWS.IAM", "iam/2010-05-08", "iam.ex", []},
    {:query, "AWS.ImportExport", "importexport/2010-06-01", "import_export.ex", []},
    {:query, "AWS.Monitoring", "monitoring/2010-08-01", "monitoring.ex", []},
    {:query, "AWS.Neptune", "neptune/2014-10-31", "neptune.ex", []},
    {:query, "AWS.RDS", "rds/2014-10-31", "rds.ex", []},
    {:query, "AWS.Redshift", "redshift/2012-12-01", "redshift.ex", []},
    {:query, "AWS.SDB", "sdb/2009-04-15", "sdb.ex", []},
    {:query, "AWS.SNS", "sns/2010-03-31", "sns.ex", []},
    {:query, "AWS.SQS", "sqs/2012-11-05", "sqs.ex", []},
    {:query, "AWS.STS", "sts/2011-06-15", "sts.ex", []},
  ]

  @erlang_services [
    {:json, "aws_appstream", "appstream/2016-12-01", "aws_appstream.erl", []},
    {:json, "aws_app_autoscaling", "application-autoscaling/2016-02-06", "aws_app_autoscaling.erl", []},
    {:json, "aws_budgets", "budgets/2016-10-20", "aws_budgets.erl", []},
    {:json, "aws_certificate_manager", "acm/2015-12-08", "aws_certificate_manager.erl", []},
    {:json, "aws_cloud_hsm", "cloudhsm/2014-05-30", "aws_cloud_hsm.erl", []},
    {:json, "aws_cloud_trail", "cloudtrail/2013-11-01", "aws_cloud_trail.erl", []},
    {:json, "aws_cloudwatch_events", "events/2015-10-07", "aws_cloudwatch_events.erl", []},
    {:json, "aws_code_build", "codebuild/2016-10-06", "aws_code_build.erl", []},
    {:json, "aws_code_commit", "codecommit/2015-04-13", "aws_code_commit.erl", []},
    {:json, "aws_code_deploy", "codedeploy/2014-10-06", "aws_code_deploy.erl", []},
    {:json, "aws_code_pipeline", "codepipeline/2015-07-09", "aws_code_pipeline.erl", []},
    {:json, "aws_cognito", "cognito-identity/2014-06-30", "aws_cognito.erl", []},
    {:json, "aws_cognito_idp", "cognito-idp/2016-04-18", "aws_cognito_idp.erl", []},
    {:json, "aws_config", "config/2014-11-12", "aws_config.erl", []},
    {:json, "aws_cost_and_usage_report", "cur/2017-01-06", "aws_cost_and_usage_report.erl", []},
    {:json, "aws_data_pipeline", "datapipeline/2012-10-29", "aws_data_pipeline.erl", []},
    {:json, "aws_device_farm", "devicefarm/2015-06-23", "aws_device_farm.erl", []},
    {:json, "aws_direct_connect", "directconnect/2012-10-25", "aws_direct_connect.erl", []},
    {:json, "aws_directory_service", "ds/2015-04-16", "aws_directory_service.erl", []},
    {:json, "aws_discovery", "discovery/2015-11-01", "aws_discovery.erl", []},
    {:json, "aws_dynamodb", "dynamodb/2012-08-10", "aws_dynamodb.erl", []},
    {:json, "aws_dynamodb_streams", "streams.dynamodb/2012-08-10", "aws_dynamodb_streams.erl", []},
    {:json, "aws_dms", "dms/2016-01-01", "aws_dms.erl", []},
    {:json, "aws_ecr", "ecr/2015-09-21", "aws_ecr.erl", []},
    {:json, "aws_ecs", "ecs/2014-11-13", "aws_ecs.erl", []},
    {:json, "aws_emr", "elasticmapreduce/2009-03-31", "aws_emr.erl", []},
    {:json, "aws_gamelift", "gamelift/2015-10-01", "aws_gamelift.erl", []},
    {:json, "aws_health", "health/2016-08-04", "aws_health.erl", []},
    {:json, "aws_inspector", "inspector/2016-02-16", "aws_inspector.erl", []},
    {:json, "aws_kinesis", "kinesis/2013-12-02", "aws_kinesis.erl", []},
    {:json, "aws_kinesis_analytics", "kinesisanalytics/2015-08-14", "aws_kinesis_analytics.erl", []},
    {:json, "aws_kinesis_firehose", "firehose/2015-08-04", "aws_kinesis_firehose.erl", []},
    {:json, "aws_kms", "kms/2014-11-01", "aws_kms.erl", []},
    {:json, "aws_lightsail", "lightsail/2016-11-28", "aws_lightsail.erl", []},
    {:json, "aws_logs", "logs/2014-03-28", "aws_logs.erl", []},
    {:json, "aws_machine_learning", "machinelearning/2014-12-12", "aws_machine_learning.erl", []},
    {:json, "aws_marketplace_commerce_analytics", "marketplacecommerceanalytics/2015-07-01", "aws_marketplace_commerce_analytics.erl", []},
    {:json, "aws_marketplace_metering", "meteringmarketplace/2016-01-14", "aws_marketplace_metering.erl", []},
    {:json, "aws_mechanical_turk", "mturk-requester/2017-01-17", "aws_mechanical_turk.erl", []},
    {:json, "aws_ops_works", "opsworks/2013-02-18", "aws_ops_works.erl", []},
    {:json, "aws_ops_works_chef_automate", "opsworkscm/2016-11-01", "aws_ops_works_chef_automate.erl", []},
    {:json, "aws_organizations", "organizations/2016-11-28", "aws_organizations.erl", []},
    {:json, "aws_rekognition", "rekognition/2016-06-27", "aws_rekognition.erl", []},
    {:json, "aws_route53_domains", "route53domains/2014-05-15", "aws_route53_domains.erl", []},
    {:json, "aws_secrets_manager", "secretsmanager/2017-10-17", "aws_secrets_manager.erl", []},
    {:json, "aws_service_catalog", "servicecatalog/2015-12-10", "aws_service_catalog.erl", []},
    {:json, "aws_shield", "shield/2016-06-02", "aws_shield.erl", []},
    {:json, "aws_snowball", "snowball/2016-06-30", "aws_snowball.erl", []},
    {:json, "aws_step_functions", "states/2016-11-23", "aws_step_functions.erl", []},
    {:json, "aws_storage_gateway", "storagegateway/2013-06-30", "aws_storage_gateway.erl", []},
    {:json, "aws_support", "support/2013-04-15", "aws_support.erl", []},
    {:json, "aws_sms", "sms/2016-10-24", "aws_sms.erl", []},
    {:json, "aws_ssm", "ssm/2014-11-06", "aws_ssm.erl", []},
    {:json, "aws_swf", "swf/2012-01-25", "aws_swf.erl", []},
    {:json, "aws_waf", "waf/2015-08-24", "aws_waf.erl", []},
    {:json, "aws_waf_regional", "waf-regional/2016-11-28", "aws_waf_regional.erl", []},
    {:json, "aws_workspaces", "workspaces/2015-04-08", "aws_workspaces.erl", []},
    {:rest_json, "aws_api_gateway", "apigateway/2015-07-09", "aws_api_gateway.erl", []},
    {:rest_json, "aws_batch", "batch/2016-08-10", "aws_batch.erl", []},
    {:rest_json, "aws_cloud_directory", "clouddirectory/2017-01-11", "aws_cloud_directory.erl", []},
    {:rest_json, "aws_cognito_sync", "cognito-sync/2014-06-30", "aws_cognito_sync.erl", []},
    {:rest_json, "aws_connect", "connect/2017-08-08", "aws_connect.erl", []},
    {:rest_json, "aws_efs", "elasticfilesystem/2015-02-01", "aws_efs.erl", []},
    {:rest_json, "aws_glacier", "glacier/2012-06-01", "aws_glacier.erl", []},
    {:rest_json, "aws_iot", "iot/2015-05-28", "aws_iot.erl", []},
    {:rest_json, "aws_iot_data", "iot-data/2015-05-28", "aws_iot_data.erl", []},
    {:rest_json, "aws_lambda", "lambda/2015-03-31", "aws_lambda.erl", []},
    {:rest_json, "aws_mobile_analytics", "mobileanalytics/2014-06-05", "aws_mobile_analytics.erl", []},
    {:rest_json, "aws_pinpoint", "pinpoint/2016-12-01", "aws_pinpoint.erl", []},
    {:rest_json, "aws_polly", "polly/2016-06-10", "aws_polly.erl", []},
    {:rest_json, "aws_lex_runtime", "runtime.lex/2016-11-28", "aws_lex_runtime.erl", []},
    {:rest_json, "aws_transcoder", "elastictranscoder/2012-09-25", "aws_transcoder.erl", []},
    {:rest_json, "aws_xray", "xray/2016-04-12", "aws_xray.erl", []},
    {:rest_xml, "aws_cloudfront", "cloudfront/2020-05-31", "aws_cloudfront.erl", []},
    {:rest_xml, "aws_route53", "route53/2013-04-01", "aws_route53.erl", []},
    {:rest_xml, "aws_s3", "s3/2006-03-01", "aws_s3.erl", []},
    {:rest_xml, "aws_s3control", "s3control/2018-08-20", "aws_s3control.erl", []},
    {:query, "aws_autoscaling", "autoscaling/2011-01-01", "aws_autoscaling.erl", []},
    {:query, "aws_cloudformation", "cloudformation/2010-05-15", "aws_cloudformation.erl", []},
    {:query, "aws_cloudsearch", "cloudsearch/2013-01-01", "aws_cloudsearch.erl", []},
    {:query, "aws_docdb", "docdb/2014-10-31", "aws_docdb.erl", []},
    {:query, "aws_elasticache", "elasticache/2015-02-02", "aws_elasticache.erl", []},
    {:query, "aws_elasticbeanstalk", "elasticbeanstalk/2010-12-01", "aws_elasticbeanstalk.erl", []},
    {:query, "aws_elasticloadbalancing", "elasticloadbalancing/2012-06-01", "aws_elasticloadbalancing.erl", []},
    {:query, "aws_elasticloadbalancingv2", "elasticloadbalancingv2/2015-12-01", "aws_elasticloadbalancingv2.erl", []},
    {:query, "aws_email", "email/2010-12-01", "aws_email.erl", []},
    {:query, "aws_iam", "iam/2010-05-08", "aws_iam.erl", []},
    {:query, "aws_importexport", "importexport/2010-06-01", "aws_importexport.erl", []},
    {:query, "aws_monitoring", "monitoring/2010-08-01", "aws_monitoring.erl", []},
    {:query, "aws_neptune", "neptune/2014-10-31", "aws_neptune.erl", []},
    {:query, "aws_rds", "rds/2014-10-31", "aws_rds.erl", []},
    {:query, "aws_redshift", "redshift/2012-12-01", "aws_redshift.erl", []},
    {:query, "aws_sdb", "sdb/2009-04-15", "aws_sdb.erl", []},
    {:query, "aws_sns", "sns/2010-03-31", "aws_sns.erl", []},
    {:query, "aws_sqs", "sqs/2012-11-05", "aws_sqs.erl", []},
    {:query, "aws_sts", "sts/2011-06-15", "aws_sts.erl", []},
  ]

  @configuration %{
    :api_specs => %{
      :elixir => @elixir_services,
      :erlang => @erlang_services
    },
    :protocols => %{
      :json => %{
        :module => AWS.CodeGen.PostService,
        :template => %{
          :elixir => "post.ex.eex",
          :erlang => "post.erl.eex"
        }
      },
      :rest_json => %{
        :module => AWS.CodeGen.RestService,
        :template => %{
          :elixir => "rest.ex.eex",
          :erlang => "rest.erl.eex"
        }
      },
      :query => %{
        :module => AWS.CodeGen.PostService,
        :template => %{
          :elixir => "post.ex.eex",
          :erlang => "post.erl.eex"
        }
      },
      :rest_xml => %{
        :module => AWS.CodeGen.RestService,
        :template => %{
          :elixir => "rest.ex.eex",
          :erlang => "rest.erl.eex"
        }
      }
    }
  }

  def generate(language, spec_base_path, template_base_path, output_base_path) do
    endpoints_spec = get_endpoints_spec(spec_base_path)
    tasks = Enum.map(@configuration[:api_specs][language],
      fn({protocol, module_name, spec_path, output_filename, options}) ->
        api_spec_path = make_spec_path(spec_base_path, spec_path, "api-2.json")
        doc_spec_path = make_spec_path(spec_base_path, spec_path, "docs-2.json")
        output_path = Path.join(output_base_path, output_filename)
        args = [language, protocol, module_name, endpoints_spec,
                api_spec_path, doc_spec_path,
                template_base_path, output_path, options]
        Task.async(AWS.CodeGen, :generate_code, args)
      end)
    Enum.each(tasks, fn(task) -> Task.await(task) end)
  end

  def generate_code(
    language, protocol, module_name, endpoints_spec,
    api_spec_path, doc_spec_path,
    template_base_path, output_path, options
  ) do
    template = @configuration[:protocols][protocol][:template][language]
    protocol_service = @configuration[:protocols][protocol][:module]
    template_path = Path.join(template_base_path, template)
    args = [language, module_name, endpoints_spec,
            parse_spec(api_spec_path), parse_spec(doc_spec_path),
            options]
    context = apply(protocol_service, :load_context, args)
    code = apply(protocol_service, :render, [context, template_path])
    IO.puts(["Writing ", module_name, " to ", output_path])
    File.write(output_path, code)
  end

  defp make_spec_path(spec_base_path, spec_path, filename) do
    spec_base_path |> Path.join(spec_path) |> Path.join(filename)
  end

  defp get_endpoints_spec(base_path) do
    Path.join([base_path, "..", "endpoints", "endpoints.json"])
    |> parse_spec
    |> get_in(["partitions"])
    |> Enum.filter(fn(x) -> x["partition"] == "aws" end)
    |> List.first
  end

  defp parse_spec(path) do
    path |> File.read! |> Poison.Parser.parse!(%{})
  end

end
