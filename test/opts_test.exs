defmodule Moar.OptsTest do
  use Moar.SimpleCase, async: true

  alias Moar.Opts

  doctest Moar.Opts

  describe "get" do
    test "gets one item from the input" do
      assert Opts.get(%{a: 1, b: 2}, :a) == 1
    end

    test "returns nil if the item is not in the input" do
      assert Opts.get(%{a: 1, b: 2}, :c) == nil
    end

    test "returns a default value if the item is not in the input" do
      assert Opts.get(%{a: 1, b: 2}, :c, 3) == 3
    end
  end

  describe "take" do
    test "takes opts from input and returns a map" do
      assert Opts.take(%{a: 1, b: 2, c: 3}, [:a, :b]) == %{a: 1, b: 2}
    end

    test "unlike `Enum.take/2`, requested keys are taken even if not in the input" do
      assert Opts.take(%{a: 1, b: 2, c: 3}, [:a, :d]) == %{a: 1, d: nil}
    end

    test "default values can be set for some or all of the keys" do
      assert Opts.take(%{a: 1, b: 2}, [:a, b: 0, c: 4]) == %{a: 1, b: 2, c: 4}
    end
  end
end
