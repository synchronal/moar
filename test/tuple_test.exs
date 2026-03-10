defmodule Moar.TupleTest do
  # @related [subject](lib/tuple.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Tuple

  describe "from_list!" do
    test "converts a list of {atom, element} tuples to an {atom, [element]} tuple" do
      assert Moar.Tuple.from_list!([{:ok, 1}, {:ok, 2}]) == {:ok, [1, 2]}
    end

    test "fails if the first item in each element of the list is not homogeneous" do
      assert_raise RuntimeError,
                   "Expected all items in the list to have have the same first element, but got: [:ok, :error]",
                   fn ->
                     Moar.Tuple.from_list!([{:ok, 1}, {:error, 2}])
                   end
    end
  end

  describe "reduce" do
    test "converts a list of {atom, element} tuples to a map" do
      assert Moar.Tuple.reduce([{:ok, 1}, {:ok, 2}]) == %{ok: [1, 2]}
    end

    test "collects multiple keys" do
      assert Moar.Tuple.reduce([{:ok, 1}, {:error, 2}, {:ok, 3}, {:error, 4}]) == %{ok: [1, 3], error: [2, 4]}
    end

    test "accepts a list of default keys, whose values will be `[]` if not found in the input" do
      assert Moar.Tuple.reduce([{:ok, 1}, {:ok, 2}], [:ok, :error, :foo]) == %{ok: [1, 2], error: [], foo: []}
    end
  end
end
