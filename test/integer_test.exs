defmodule Moar.IntegerTest do
  # @related [subject](/lib/integer.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Integer

  describe "compare" do
    test "returns :eq, :lt, or :gt" do
      assert Moar.Integer.compare(123, 123) == :eq
      assert Moar.Integer.compare(0, 0) == :eq
      assert Moar.Integer.compare(-456, -456) == :eq

      assert Moar.Integer.compare(-12, 67) == :lt
      assert Moar.Integer.compare(-12, 0) == :lt
      assert Moar.Integer.compare(0, 400) == :lt
      assert Moar.Integer.compare(56, 400) == :lt

      assert Moar.Integer.compare(67, 12) == :gt
      assert Moar.Integer.compare(0, -120) == :gt
      assert Moar.Integer.compare(-15, -20) == :gt
    end
  end
end
