defmodule AWS.CodeGen.ShapesTest do
  use ExUnit.Case
  alias AWS.CodeGen.Shapes

  test "send_body_as_binary?/2" do
    shapes = %{
      "Body" => %{"type" => "blob"},
      "PutObjectRequest" => %{
        "type" => "structure",
        "members" => %{
          "Body" => %{
            "shape" => "Body",
            "streaming" => true
          }
        }
      },
      "PutObjectAclRequest" => %{
        "type" => "structure",
        "members" => %{
          "ACL" => %{
            "shape" => "ObjectCannedACL",
            "location" => "header",
            "locationName" => "x-amz-acl"
          }
        }
      }
    }

    assert Shapes.send_body_as_binary?(shapes, "PutObjectRequest")

    refute Shapes.send_body_as_binary?(shapes, "PutObjectAclRequest")
    refute Shapes.send_body_as_binary?(shapes, "AnotherShape")
  end
end
