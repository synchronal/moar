defmodule Moar.OptsTest do
  # @related [subject](/lib/opts.ex)

  use Moar.SimpleCase, async: true

  alias Moar.Opts

  doctest Moar.Opts

  describe "get" do
    test "gets one item from the input" do
      assert Opts.get(%{a: 1, b: 2}, :a) == 1
      assert Opts.get([a: 1, b: 2], :a) == 1
    end

    test "returns nil if the item is not in the input" do
      assert Opts.get(%{a: 1, b: 2}, :c) == nil
      assert Opts.get([a: 1, b: 2], :c) == nil
    end

    test "returns a default value if the item is not in the input" do
      assert Opts.get(%{a: 1, b: 2}, :c, 3) == 3
      assert Opts.get([a: 1, b: 2], :c, 3) == 3
    end

    test "when given an atom in a list, treats its value as `true` or the default if given" do
      assert Opts.get([:a, b: 2], :a) == true
      assert Opts.get([:a, b: 2], :a, 1) == 1
    end
  end

  describe "pop" do
    test "pops one item from the input" do
      assert Opts.pop(%{a: 1, b: 2}, :a) == {1, %{b: 2}}
      assert Opts.pop([a: 1, b: 2], :a) == {1, [b: 2]}
    end

    test "returns nil if the item is not in the input" do
      assert Opts.pop(%{a: 1, b: 2}, :c) == {nil, %{a: 1, b: 2}}
      assert Opts.pop([a: 1, b: 2], :c) == {nil, [a: 1, b: 2]}
    end

    test "returns a default value if the item is not in the input" do
      assert Opts.pop(%{a: 1, b: 2}, :c, 3) == {3, %{a: 1, b: 2}}
      assert Opts.pop([a: 1, b: 2], :c, 3) == {3, [a: 1, b: 2]}
    end

    test "when given an atom in a list, treats its value as `true` or the default if given" do
      assert Opts.pop([:a, b: 2], :a) == {true, [b: 2]}
      assert Opts.pop([:a, b: 2], :a, 1) == {1, [b: 2]}
    end
  end

  describe "take" do
    test "takes opts from input and returns a map" do
      assert Opts.take(%{a: 1, b: 2, c: 3}, [:a, :b]) == %{a: 1, b: 2}
      assert Opts.take([a: 1, b: 2, c: 3], [:a, :b]) == %{a: 1, b: 2}
    end

    test "unlike `Enum.take/2`, requested keys are taken even if not in the input" do
      assert Opts.take(%{a: 1, b: 2, c: 3}, [:a, :d]) == %{a: 1, d: nil}
      assert Opts.take([a: 1, b: 2, c: 3], [:a, :d]) == %{a: 1, d: nil}
    end

    test "default values can be set for some or all of the keys" do
      assert Opts.take(%{a: 1, b: 2}, [:a, b: 0, c: 4]) == %{a: 1, b: 2, c: 4}
      assert Opts.take([a: 1, b: 2], [:a, b: 0, c: 4]) == %{a: 1, b: 2, c: 4}
    end

    test "when given an atom in a list, treats its value as `true`" do
      assert Opts.take([:a, :b, c: 3], [:a, :c, b: 2]) == %{a: true, b: 2, c: 3}
    end
  end
end
