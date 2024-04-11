defmodule Moar.UUIDTest do
  # @related [subject](/lib/uuid.ex)

  use Moar.SimpleCase, async: true
  doctest Moar.UUID

  @invalid_regex "a3357225-COWZ-48b6-9ce5-10a580489b3f"
  @valid_regex "a3357225-ed23-48b6-9ce5-10a580489b3f"

  describe "regex" do
    test "returns a regex that matches UUIDs" do
      refute Regex.match?(Moar.UUID.regex(), @invalid_regex)
      assert Regex.match?(Moar.UUID.regex(), @valid_regex)
    end
  end

  describe "valid?" do
    test "returns true if the UUID is valid" do
      assert Moar.UUID.valid?(@valid_regex)
    end

    test "returns false if the UUID is not valid" do
      refute Moar.UUID.valid?(nil)
      refute Moar.UUID.valid?(@invalid_regex)
    end

    test "raises if the UUID is not a string or `nil`" do
      assert_raise FunctionClauseError, fn -> Moar.UUID.valid?(42) end
    end
  end
end
