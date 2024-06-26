defmodule AWS.CodeGen.SpecTest do
  use ExUnit.Case

  alias AWS.CodeGen.Spec

  test "parse/3" do
    assert %Spec{
             api: api,
             filename: "cloud_trail_data.ex",
             module_name: "AWS.CloudTrailData",
             protocol: :rest_json
           } = Spec.parse("test/fixtures/apis_specs/cloudtrail-data.json", :elixir)

    assert %Spec{
             filename: "aws_cloudtrail_data.erl",
             module_name: "aws_cloudtrail_data"
           } = Spec.parse("test/fixtures/apis_specs/cloudtrail-data.json", :erlang)

    assert api ==
             %{
               "shapes" => %{
                 "com.amazonaws.cloudtraildata#AuditEvent" => %{
                   "members" => %{
                     "eventData" => %{
                       "target" => "smithy.api#String",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The content of an audit event that comes from the event, such as <code>userIdentity</code>, \n         <code>userAgent</code>, and <code>eventSource</code>.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "eventDataChecksum" => %{
                       "target" => "smithy.api#String",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>A checksum is a base64-SHA256 algorithm that helps you verify that CloudTrail receives the event that matches \n         with the checksum. Calculate the checksum by running a command like the following:</p>\n         <p>\n            <code>printf %s <i>$eventdata</i> | openssl dgst -binary -sha256 | base64</code>\n         </p>"
                       }
                     },
                     "id" => %{
                       "target" => "com.amazonaws.cloudtraildata#Uuid",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The original event ID from the source event.</p>",
                         "smithy.api#required" => %{}
                       }
                     }
                   },
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>An event from a source outside of Amazon Web Services that you want CloudTrail \n      to log.</p>"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#AuditEventResultEntries" => %{
                   "member" => %{"target" => "com.amazonaws.cloudtraildata#AuditEventResultEntry"},
                   "traits" => %{"smithy.api#length" => %{"max" => 100, "min" => 0}},
                   "type" => "list"
                 },
                 "com.amazonaws.cloudtraildata#AuditEventResultEntry" => %{
                   "members" => %{
                     "eventID" => %{
                       "target" => "com.amazonaws.cloudtraildata#Uuid",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The event ID assigned by CloudTrail.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "id" => %{
                       "target" => "com.amazonaws.cloudtraildata#Uuid",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The original event ID from the source event.</p>",
                         "smithy.api#required" => %{}
                       }
                     }
                   },
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>A response that includes successful and failed event results.</p>"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#AuditEvents" => %{
                   "member" => %{"target" => "com.amazonaws.cloudtraildata#AuditEvent"},
                   "traits" => %{"smithy.api#length" => %{"max" => 100, "min" => 1}},
                   "type" => "list"
                 },
                 "com.amazonaws.cloudtraildata#ChannelArn" => %{
                   "traits" => %{
                     "aws.api#arnReference" => %{},
                     "smithy.api#pattern" => "^arn:.*$"
                   },
                   "type" => "string"
                 },
                 "com.amazonaws.cloudtraildata#ChannelInsufficientPermission" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>The caller's account ID must be the same as the channel owner's account ID.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#ChannelNotFound" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" => "<p>The channel could not be found.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#ChannelUnsupportedSchema" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>The schema type of the event is not supported.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#CloudTrailDataService" => %{
                   "operations" => [%{"target" => "com.amazonaws.cloudtraildata#PutAuditEvents"}],
                   "traits" => %{
                     "aws.api#service" => %{
                       "endpointPrefix" => "cloudtrail-data",
                       "sdkId" => "CloudTrail Data"
                     },
                     "aws.auth#sigv4" => %{"name" => "cloudtrail-data"},
                     "aws.protocols#restJson1" => %{},
                     "smithy.api#cors" => %{},
                     "smithy.api#documentation" =>
                       "<p>The CloudTrail Data Service lets you ingest events into CloudTrail from any source in your\nhybrid environments, such as in-house or SaaS applications hosted on-premises or in the cloud,\nvirtual machines, or containers. You can store, access, analyze, troubleshoot and take action on\nthis data without maintaining multiple log aggregators and reporting tools. After you run \n<code>PutAuditEvents</code> to ingest your application activity into CloudTrail, you can use CloudTrail Lake to search, query, and analyze the data that is logged\nfrom your applications.</p>",
                     "smithy.api#title" => "AWS CloudTrail Data Service",
                     "smithy.rules#endpointRuleSet" => %{
                       "parameters" => %{
                         "Endpoint" => %{
                           "builtIn" => "SDK::Endpoint",
                           "documentation" => "Override the endpoint used to send this request",
                           "required" => false,
                           "type" => "String"
                         },
                         "Region" => %{
                           "builtIn" => "AWS::Region",
                           "documentation" => "The AWS region used to dispatch the request.",
                           "required" => false,
                           "type" => "String"
                         },
                         "UseDualStack" => %{
                           "builtIn" => "AWS::UseDualStack",
                           "default" => false,
                           "documentation" =>
                             "When true, use the dual-stack endpoint. If the configured endpoint does not support dual-stack, dispatching the request MAY return an error.",
                           "required" => true,
                           "type" => "Boolean"
                         },
                         "UseFIPS" => %{
                           "builtIn" => "AWS::UseFIPS",
                           "default" => false,
                           "documentation" =>
                             "When true, send this request to the FIPS-compliant regional endpoint. If the configured endpoint does not have a FIPS compliant endpoint, dispatching the request will return an error.",
                           "required" => true,
                           "type" => "Boolean"
                         }
                       },
                       "rules" => [
                         %{
                           "conditions" => [
                             %{"argv" => [%{"ref" => "Endpoint"}], "fn" => "isSet"}
                           ],
                           "rules" => [
                             %{
                               "conditions" => [
                                 %{
                                   "argv" => [%{"ref" => "UseFIPS"}, true],
                                   "fn" => "booleanEquals"
                                 }
                               ],
                               "error" =>
                                 "Invalid Configuration: FIPS and custom endpoint are not supported",
                               "type" => "error"
                             },
                             %{
                               "conditions" => [],
                               "rules" => [
                                 %{
                                   "conditions" => [
                                     %{
                                       "argv" => [%{"ref" => "UseDualStack"}, true],
                                       "fn" => "booleanEquals"
                                     }
                                   ],
                                   "error" =>
                                     "Invalid Configuration: Dualstack and custom endpoint are not supported",
                                   "type" => "error"
                                 },
                                 %{
                                   "conditions" => [],
                                   "endpoint" => %{
                                     "headers" => %{},
                                     "properties" => %{},
                                     "url" => %{"ref" => "Endpoint"}
                                   },
                                   "type" => "endpoint"
                                 }
                               ],
                               "type" => "tree"
                             }
                           ],
                           "type" => "tree"
                         },
                         %{
                           "conditions" => [],
                           "rules" => [
                             %{
                               "conditions" => [
                                 %{"argv" => [%{"ref" => "Region"}], "fn" => "isSet"}
                               ],
                               "rules" => [
                                 %{
                                   "conditions" => [
                                     %{
                                       "argv" => [%{"ref" => "Region"}],
                                       "assign" => "PartitionResult",
                                       "fn" => "aws.partition"
                                     }
                                   ],
                                   "rules" => [
                                     %{
                                       "conditions" => [
                                         %{
                                           "argv" => [%{"ref" => "UseFIPS"}, true],
                                           "fn" => "booleanEquals"
                                         },
                                         %{
                                           "argv" => [%{"ref" => "UseDualStack"}, true],
                                           "fn" => "booleanEquals"
                                         }
                                       ],
                                       "rules" => [
                                         %{
                                           "conditions" => [
                                             %{
                                               "argv" => [
                                                 true,
                                                 %{
                                                   "argv" => [
                                                     %{"ref" => "PartitionResult"},
                                                     "supportsFIPS"
                                                   ],
                                                   "fn" => "getAttr"
                                                 }
                                               ],
                                               "fn" => "booleanEquals"
                                             },
                                             %{
                                               "argv" => [
                                                 true,
                                                 %{
                                                   "argv" => [
                                                     %{"ref" => "PartitionResult"},
                                                     "supportsDualStack"
                                                   ],
                                                   "fn" => "getAttr"
                                                 }
                                               ],
                                               "fn" => "booleanEquals"
                                             }
                                           ],
                                           "rules" => [
                                             %{
                                               "conditions" => [],
                                               "rules" => [
                                                 %{
                                                   "conditions" => [],
                                                   "endpoint" => %{
                                                     "headers" => %{},
                                                     "properties" => %{},
                                                     "url" =>
                                                       "https://cloudtrail-data-fips.{Region}.{PartitionResult#dualStackDnsSuffix}"
                                                   },
                                                   "type" => "endpoint"
                                                 }
                                               ],
                                               "type" => "tree"
                                             }
                                           ],
                                           "type" => "tree"
                                         },
                                         %{
                                           "conditions" => [],
                                           "error" =>
                                             "FIPS and DualStack are enabled, but this partition does not support one or both",
                                           "type" => "error"
                                         }
                                       ],
                                       "type" => "tree"
                                     },
                                     %{
                                       "conditions" => [
                                         %{
                                           "argv" => [%{"ref" => "UseFIPS"}, true],
                                           "fn" => "booleanEquals"
                                         }
                                       ],
                                       "rules" => [
                                         %{
                                           "conditions" => [
                                             %{
                                               "argv" => [
                                                 true,
                                                 %{
                                                   "argv" => [
                                                     %{"ref" => "PartitionResult"},
                                                     "supportsFIPS"
                                                   ],
                                                   "fn" => "getAttr"
                                                 }
                                               ],
                                               "fn" => "booleanEquals"
                                             }
                                           ],
                                           "rules" => [
                                             %{
                                               "conditions" => [],
                                               "rules" => [
                                                 %{
                                                   "conditions" => [],
                                                   "endpoint" => %{
                                                     "headers" => %{},
                                                     "properties" => %{},
                                                     "url" =>
                                                       "https://cloudtrail-data-fips.{Region}.{PartitionResult#dnsSuffix}"
                                                   },
                                                   "type" => "endpoint"
                                                 }
                                               ],
                                               "type" => "tree"
                                             }
                                           ],
                                           "type" => "tree"
                                         },
                                         %{
                                           "conditions" => [],
                                           "error" =>
                                             "FIPS is enabled but this partition does not support FIPS",
                                           "type" => "error"
                                         }
                                       ],
                                       "type" => "tree"
                                     },
                                     %{
                                       "conditions" => [
                                         %{
                                           "argv" => [%{"ref" => "UseDualStack"}, true],
                                           "fn" => "booleanEquals"
                                         }
                                       ],
                                       "rules" => [
                                         %{
                                           "conditions" => [
                                             %{
                                               "argv" => [
                                                 true,
                                                 %{
                                                   "argv" => [
                                                     %{"ref" => "PartitionResult"},
                                                     "supportsDualStack"
                                                   ],
                                                   "fn" => "getAttr"
                                                 }
                                               ],
                                               "fn" => "booleanEquals"
                                             }
                                           ],
                                           "rules" => [
                                             %{
                                               "conditions" => [],
                                               "rules" => [
                                                 %{
                                                   "conditions" => [],
                                                   "endpoint" => %{
                                                     "headers" => %{},
                                                     "properties" => %{},
                                                     "url" =>
                                                       "https://cloudtrail-data.{Region}.{PartitionResult#dualStackDnsSuffix}"
                                                   },
                                                   "type" => "endpoint"
                                                 }
                                               ],
                                               "type" => "tree"
                                             }
                                           ],
                                           "type" => "tree"
                                         },
                                         %{
                                           "conditions" => [],
                                           "error" =>
                                             "DualStack is enabled but this partition does not support DualStack",
                                           "type" => "error"
                                         }
                                       ],
                                       "type" => "tree"
                                     },
                                     %{
                                       "conditions" => [],
                                       "rules" => [
                                         %{
                                           "conditions" => [],
                                           "endpoint" => %{
                                             "headers" => %{},
                                             "properties" => %{},
                                             "url" =>
                                               "https://cloudtrail-data.{Region}.{PartitionResult#dnsSuffix}"
                                           },
                                           "type" => "endpoint"
                                         }
                                       ],
                                       "type" => "tree"
                                     }
                                   ],
                                   "type" => "tree"
                                 }
                               ],
                               "type" => "tree"
                             },
                             %{
                               "conditions" => [],
                               "error" => "Invalid Configuration: Missing Region",
                               "type" => "error"
                             }
                           ],
                           "type" => "tree"
                         }
                       ],
                       "version" => "1.0"
                     },
                     "smithy.rules#endpointTests" => %{
                       "testCases" => [
                         %{
                           "documentation" =>
                             "For region us-east-1 with FIPS enabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.us-east-1.api.aws"
                             }
                           },
                           "params" => %{
                             "Region" => "us-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-east-1 with FIPS enabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.us-east-1.amazonaws.com"
                             }
                           },
                           "params" => %{
                             "Region" => "us-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-east-1 with FIPS disabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{"url" => "https://cloudtrail-data.us-east-1.api.aws"}
                           },
                           "params" => %{
                             "Region" => "us-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-east-1 with FIPS disabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.us-east-1.amazonaws.com"
                             }
                           },
                           "params" => %{
                             "Region" => "us-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region cn-north-1 with FIPS enabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" =>
                                 "https://cloudtrail-data-fips.cn-north-1.api.amazonwebservices.com.cn"
                             }
                           },
                           "params" => %{
                             "Region" => "cn-north-1",
                             "UseDualStack" => true,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region cn-north-1 with FIPS enabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.cn-north-1.amazonaws.com.cn"
                             }
                           },
                           "params" => %{
                             "Region" => "cn-north-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region cn-north-1 with FIPS disabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" =>
                                 "https://cloudtrail-data.cn-north-1.api.amazonwebservices.com.cn"
                             }
                           },
                           "params" => %{
                             "Region" => "cn-north-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region cn-north-1 with FIPS disabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.cn-north-1.amazonaws.com.cn"
                             }
                           },
                           "params" => %{
                             "Region" => "cn-north-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-gov-east-1 with FIPS enabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.us-gov-east-1.api.aws"
                             }
                           },
                           "params" => %{
                             "Region" => "us-gov-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-gov-east-1 with FIPS enabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.us-gov-east-1.amazonaws.com"
                             }
                           },
                           "params" => %{
                             "Region" => "us-gov-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-gov-east-1 with FIPS disabled and DualStack enabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.us-gov-east-1.api.aws"
                             }
                           },
                           "params" => %{
                             "Region" => "us-gov-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-gov-east-1 with FIPS disabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.us-gov-east-1.amazonaws.com"
                             }
                           },
                           "params" => %{
                             "Region" => "us-gov-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-iso-east-1 with FIPS enabled and DualStack enabled",
                           "expect" => %{
                             "error" =>
                               "FIPS and DualStack are enabled, but this partition does not support one or both"
                           },
                           "params" => %{
                             "Region" => "us-iso-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-iso-east-1 with FIPS enabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data-fips.us-iso-east-1.c2s.ic.gov"
                             }
                           },
                           "params" => %{
                             "Region" => "us-iso-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-iso-east-1 with FIPS disabled and DualStack enabled",
                           "expect" => %{
                             "error" =>
                               "DualStack is enabled but this partition does not support DualStack"
                           },
                           "params" => %{
                             "Region" => "us-iso-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-iso-east-1 with FIPS disabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.us-iso-east-1.c2s.ic.gov"
                             }
                           },
                           "params" => %{
                             "Region" => "us-iso-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-isob-east-1 with FIPS enabled and DualStack enabled",
                           "expect" => %{
                             "error" =>
                               "FIPS and DualStack are enabled, but this partition does not support one or both"
                           },
                           "params" => %{
                             "Region" => "us-isob-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-isob-east-1 with FIPS enabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" =>
                                 "https://cloudtrail-data-fips.us-isob-east-1.sc2s.sgov.gov"
                             }
                           },
                           "params" => %{
                             "Region" => "us-isob-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-isob-east-1 with FIPS disabled and DualStack enabled",
                           "expect" => %{
                             "error" =>
                               "DualStack is enabled but this partition does not support DualStack"
                           },
                           "params" => %{
                             "Region" => "us-isob-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For region us-isob-east-1 with FIPS disabled and DualStack disabled",
                           "expect" => %{
                             "endpoint" => %{
                               "url" => "https://cloudtrail-data.us-isob-east-1.sc2s.sgov.gov"
                             }
                           },
                           "params" => %{
                             "Region" => "us-isob-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For custom endpoint with region set and fips disabled and dualstack disabled",
                           "expect" => %{"endpoint" => %{"url" => "https://example.com"}},
                           "params" => %{
                             "Endpoint" => "https://example.com",
                             "Region" => "us-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For custom endpoint with region not set and fips disabled and dualstack disabled",
                           "expect" => %{"endpoint" => %{"url" => "https://example.com"}},
                           "params" => %{
                             "Endpoint" => "https://example.com",
                             "UseDualStack" => false,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" =>
                             "For custom endpoint with fips enabled and dualstack disabled",
                           "expect" => %{
                             "error" =>
                               "Invalid Configuration: FIPS and custom endpoint are not supported"
                           },
                           "params" => %{
                             "Endpoint" => "https://example.com",
                             "Region" => "us-east-1",
                             "UseDualStack" => false,
                             "UseFIPS" => true
                           }
                         },
                         %{
                           "documentation" =>
                             "For custom endpoint with fips disabled and dualstack enabled",
                           "expect" => %{
                             "error" =>
                               "Invalid Configuration: Dualstack and custom endpoint are not supported"
                           },
                           "params" => %{
                             "Endpoint" => "https://example.com",
                             "Region" => "us-east-1",
                             "UseDualStack" => true,
                             "UseFIPS" => false
                           }
                         },
                         %{
                           "documentation" => "Missing region",
                           "expect" => %{"error" => "Invalid Configuration: Missing Region"}
                         }
                       ],
                       "version" => "1.0"
                     }
                   },
                   "type" => "service",
                   "version" => "2021-08-11"
                 },
                 "com.amazonaws.cloudtraildata#DuplicatedAuditEventId" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>Two or more entries in the request have the same event ID.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#ErrorCode" => %{
                   "traits" => %{"smithy.api#length" => %{"max" => 128, "min" => 1}},
                   "type" => "string"
                 },
                 "com.amazonaws.cloudtraildata#ErrorMessage" => %{
                   "traits" => %{"smithy.api#length" => %{"max" => 1024, "min" => 1}},
                   "type" => "string"
                 },
                 "com.amazonaws.cloudtraildata#ExternalId" => %{
                   "traits" => %{
                     "smithy.api#length" => %{"max" => 1224, "min" => 2},
                     "smithy.api#pattern" => "^[\\w+=,.@:\\/-]*$"
                   },
                   "type" => "string"
                 },
                 "com.amazonaws.cloudtraildata#InvalidChannelARN" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>The specified channel ARN is not a valid \n         channel ARN.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#PutAuditEvents" => %{
                   "errors" => [
                     %{"target" => "com.amazonaws.cloudtraildata#ChannelInsufficientPermission"},
                     %{"target" => "com.amazonaws.cloudtraildata#ChannelNotFound"},
                     %{"target" => "com.amazonaws.cloudtraildata#ChannelUnsupportedSchema"},
                     %{"target" => "com.amazonaws.cloudtraildata#DuplicatedAuditEventId"},
                     %{"target" => "com.amazonaws.cloudtraildata#InvalidChannelARN"},
                     %{"target" => "com.amazonaws.cloudtraildata#UnsupportedOperationException"}
                   ],
                   "input" => %{"target" => "com.amazonaws.cloudtraildata#PutAuditEventsRequest"},
                   "output" => %{
                     "target" => "com.amazonaws.cloudtraildata#PutAuditEventsResponse"
                   },
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>Ingests your application events into CloudTrail Lake. A required parameter,\n            <code>auditEvents</code>, accepts the JSON records (also called\n            <i>payload</i>) of events that you want CloudTrail to ingest. You\n         can add up to 100 of these events (or up to 1 MB) per <code>PutAuditEvents</code>\n         request.</p>",
                     "smithy.api#http" => %{"method" => "POST", "uri" => "/PutAuditEvents"}
                   },
                   "type" => "operation"
                 },
                 "com.amazonaws.cloudtraildata#PutAuditEventsRequest" => %{
                   "members" => %{
                     "auditEvents" => %{
                       "target" => "com.amazonaws.cloudtraildata#AuditEvents",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The JSON payload of events that you want to ingest. You can also point to the JSON event\n         payload in a file.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "channelArn" => %{
                       "target" => "com.amazonaws.cloudtraildata#ChannelArn",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The ARN or ID (the ARN suffix) of a channel.</p>",
                         "smithy.api#httpQuery" => "channelArn",
                         "smithy.api#required" => %{}
                       }
                     },
                     "externalId" => %{
                       "target" => "com.amazonaws.cloudtraildata#ExternalId",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>A unique identifier that is conditionally required when the channel's resource policy includes an external \n         ID. This value can be any string, \n         such as a passphrase or account number.</p>",
                         "smithy.api#httpQuery" => "externalId"
                       }
                     }
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#PutAuditEventsResponse" => %{
                   "members" => %{
                     "failed" => %{
                       "target" => "com.amazonaws.cloudtraildata#ResultErrorEntries",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>Lists events in the provided event payload that could not be \n         ingested into CloudTrail, and includes the error code and error message \n         returned for events that could not be ingested.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "successful" => %{
                       "target" => "com.amazonaws.cloudtraildata#AuditEventResultEntries",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>Lists events in the provided event payload that were successfully ingested \n      into CloudTrail.</p>",
                         "smithy.api#required" => %{}
                       }
                     }
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#ResultErrorEntries" => %{
                   "member" => %{"target" => "com.amazonaws.cloudtraildata#ResultErrorEntry"},
                   "traits" => %{"smithy.api#length" => %{"max" => 100, "min" => 0}},
                   "type" => "list"
                 },
                 "com.amazonaws.cloudtraildata#ResultErrorEntry" => %{
                   "members" => %{
                     "errorCode" => %{
                       "target" => "com.amazonaws.cloudtraildata#ErrorCode",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The error code for events that could not be ingested by CloudTrail. Possible error codes include: <code>FieldTooLong</code>, <code>FieldNotFound</code>, \n         <code>InvalidChecksum</code>, <code>InvalidData</code>, <code>InvalidRecipient</code>, <code>InvalidEventSource</code>, <code>AccountNotSubscribed</code>, \n         <code>Throttling</code>, and <code>InternalFailure</code>.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "errorMessage" => %{
                       "target" => "com.amazonaws.cloudtraildata#ErrorMessage",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The message that describes the error for events that could not be ingested by CloudTrail.</p>",
                         "smithy.api#required" => %{}
                       }
                     },
                     "id" => %{
                       "target" => "com.amazonaws.cloudtraildata#Uuid",
                       "traits" => %{
                         "smithy.api#documentation" =>
                           "<p>The original event ID from the source event that could not be ingested by CloudTrail.</p>",
                         "smithy.api#required" => %{}
                       }
                     }
                   },
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>Includes the error code and error message for events that could not be ingested by CloudTrail.</p>"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#UnsupportedOperationException" => %{
                   "members" => %{"message" => %{"target" => "smithy.api#String"}},
                   "traits" => %{
                     "smithy.api#documentation" =>
                       "<p>The operation requested is not supported in this region or account.</p>",
                     "smithy.api#error" => "client"
                   },
                   "type" => "structure"
                 },
                 "com.amazonaws.cloudtraildata#Uuid" => %{
                   "traits" => %{
                     "smithy.api#length" => %{"max" => 128, "min" => 1},
                     "smithy.api#pattern" => "^[-_A-Za-z0-9]+$"
                   },
                   "type" => "string"
                 }
               },
               "smithy" => "2.0"
             }
  end
end
