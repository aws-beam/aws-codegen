defmodule AWS.CodeGen.NameTest do
  use ExUnit.Case
  alias AWS.CodeGen.Name

  test "to_snake_case/1 converts CamelCase to snake_case" do
    assert "camel_case" = Name.to_snake_case("CamelCase")
  end

  test "to_snake_case/1 converts nerdyCaps to snake_case" do
    assert "nerdy_caps" = Name.to_snake_case("nerdyCaps")
  end

  test "to_snake_case/1 special cases BGP" do
    assert "create_bgp_peer" = Name.to_snake_case("CreateBGPPeer")
  end

  test "to_snake_case/1 special cases CSV" do
    assert "get_csv_header" = Name.to_snake_case("GetCSVHeader")
  end

  test "to_snake_case/1 special cases NFS" do
    assert "create_nfs_peer" = Name.to_snake_case("CreateNFSPeer")
  end

  test "to_snake_case/1 special cases iSCSI" do
    assert "create_cached_iscsi_volume" = Name.to_snake_case("CreateCachediSCSIVolume")
  end

  test "to_snake_case/1 special cases VTL" do
    assert "describe_vtl_devices" = Name.to_snake_case("DescribeVTLDevices")
  end

  test "to_snake_case/1 special cases UUID" do
    assert "uuid" = Name.to_snake_case("UUID")
  end

  test "upcase_first/1" do
    assert "Elixir" = Name.upcase_first("elixir")
    assert "ElixirLang" = Name.upcase_first("elixirLang")
    assert "IEx" = Name.upcase_first("iEx")
  end
end
