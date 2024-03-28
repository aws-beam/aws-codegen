defmodule AWS.CodeGen.ShapesTest do
  use ExUnit.Case
  alias AWS.CodeGen.Shapes

  test "body_as_binary?/2" do
    shapes = %{
      "com.amazonaws.s3#PutObjectRequest" => %{
        "type" => "structure",
        "members" => %{
          "ACL" => %{
            "target" => "com.amazonaws.s3#ObjectCannedACL"
          },
          "Body" => %{
            "target" => "com.amazonaws.s3#StreamingBlob"
          }
        }
      },
      "com.amazonaws.s3#StreamingBlob" => %{
        "type" => "blob",
        "traits" => %{
          "smithy.api#streaming" => %{}
        }
      },
      "com.amazonaws.s3#PutObjectAclRequest" => %{
        "type" => "structure",
        "members" => %{
          "ACL" => %{
            "target" => "com.amazonaws.s3#ObjectCannedACL"
          },
          "AccessControlPolicy" => %{
            "target" => "com.amazonaws.s3#AccessControlPolicy"
          }
        }
      }
    }

    assert Shapes.body_as_binary?(shapes, "com.amazonaws.s3#PutObjectRequest")

    refute Shapes.body_as_binary?(shapes, "com.amazonaws.s3#PutObjectAclRequest")
    refute Shapes.body_as_binary?(shapes, "com.amazonaws.s3#AnotherShape")
  end
end
