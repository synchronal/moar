defmodule Moar.ProtocolTest do
  # @related [subject](/lib/protocol.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Protocol

  describe "implements!" do
    test "returns the first param if it implements the given protocol" do
      assert Moar.Protocol.implements!(Date.new!(2000, 1, 2), String.Chars)
    end

    test "raises an exception if the first param does not implement the given protocol" do
      assert_raise RuntimeError, "Expected ~D[2000-01-02] to implement protocol Enumerable", fn ->
        Moar.Protocol.implements!(Date.new!(2000, 1, 2), Enumerable)
      end
    end
  end

  describe "implements?" do
    test "returns true if the term implements the protocol" do
      assert Moar.Protocol.implements?([], Enumerable) == true
      assert Moar.Protocol.implements?("hi", String.Chars) == true
    end

    test "returns false if the term does not implement the protocol" do
      assert Moar.Protocol.implements?("hi", Enumerable) == false
    end
  end
end
