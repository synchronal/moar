defmodule Moar.ListTest do
  # @related [subject](/lib/list.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.List

  describe "to_keyword" do
    test "when given a keyword list, returns it" do
      assert Moar.List.to_keyword(a: 1, b: 2) == [a: 1, b: 2]
    end

    test "when given a non-keyword list, converts it to a keyword list using the provided default" do
      assert Moar.List.to_keyword([:a, :b]) == [a: nil, b: nil]
      assert Moar.List.to_keyword([:a, :b], 1) == [a: 1, b: 1]
    end

    test "when give a list that's a hybrid list + keyword list, uses the provided default for non-keyword elements" do
      assert Moar.List.to_keyword([:a, :b, c: 3, d: 4]) == [a: nil, b: nil, c: 3, d: 4]
      assert Moar.List.to_keyword([:a, :b, c: 3, d: 4], 1) == [a: 1, b: 1, c: 3, d: 4]
    end

    test "accepts a 1-arity function as the default value" do
      assert Moar.List.to_keyword([:a, :b, c: "c", d: "d"], &to_string(&1)) == [a: "a", b: "b", c: "c", d: "d"]
    end

    test "fails when the values are not atoms" do
      assert_raise FunctionClauseError, fn -> Moar.List.to_keyword(["foo", "bar"]) end
    end
  end
end
