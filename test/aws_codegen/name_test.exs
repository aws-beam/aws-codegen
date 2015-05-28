defmodule AWS.CodeGen.NameTest do
  use ExUnit.Case
  alias AWS.CodeGen.Name

  test "to_snake_case/1 converts CamelCase to snake_case" do
    assert "camel_case" = Name.to_snake_case("CamelCase")
  end

  test "to_snake_case/1 converts nerdyCaps to snake_case" do
    assert "nerdy_caps" = Name.to_snake_case("nerdyCaps")
  end
end
