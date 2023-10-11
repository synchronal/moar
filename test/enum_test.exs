defmodule Moar.EnumTest do
  # @related [subject](/lib/enum.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Enum

  describe "at!" do
    test "like `Moar.Enum.at/3` but raises if the index is out of bounds" do
      ["A", "B", "C"] |> Moar.Enum.at!(1) |> assert_eq("B")

      assert_raise RuntimeError, ~s|Out of range: index 4 of enum with length 3: ["A", "B", "C"]|, fn ->
        ["A", "B", "C"] |> Moar.Enum.at!(4)
      end
    end
  end

  describe "find_indices" do
    test "Returns the indices of the given enum elements" do
      ~w[apple banana cherry donut]
      |> Moar.Enum.find_indices(["donut", "banana"])
      |> assert_eq([3, 1])
    end

    test "Returns nil for unfound elements" do
      ~w[apple banana cherry donut]
      |> Moar.Enum.find_indices(["donut", "banana", "happiness"])
      |> assert_eq([3, 1, nil])
    end

    test "accepts a function for comparisons" do
      ~w[apple banana cherry donut]
      |> Moar.Enum.find_indices(["DONUT", "BANANA"], fn a, b -> String.downcase(a) == String.downcase(b) end)
      |> assert_eq([3, 1])
    end
  end

  describe "find_indices!" do
    test "Returns the indices of the given enum elements" do
      ~w[apple banana cherry donut]
      |> Moar.Enum.find_indices!(["donut", "banana"])
      |> assert_eq([3, 1])
    end

    test "raises if element is not found" do
      assert_raise RuntimeError,
                   ~s|Element "happiness" not present in:\n["apple", "banana", "cherry", "donut"]|,
                   fn ->
                     ~w[apple banana cherry donut]
                     |> Moar.Enum.find_indices!(["donut", "banana", "happiness"])
                   end
    end

    test "accepts a function for comparisons" do
      ~w[apple banana cherry donut]
      |> Moar.Enum.find_indices!(["DONUT", "BANANA"], fn a, b -> String.downcase(a) == String.downcase(b) end)
      |> assert_eq([3, 1])
    end
  end

  describe "first!" do
    test "returns the first item in the enum" do
      assert Moar.Enum.first!(["foo"]) == "foo"
      assert Moar.Enum.first!(["foo", "bar"]) == "foo"
    end

    test "blows up if the enum is empty" do
      assert_raise RuntimeError, "Expected enumerable to have at least one item", fn -> Moar.Enum.first!([]) end
    end
  end

  describe "index_by" do
    test "returns a map of `index => value` from an enumerable and an index function" do
      [%{name: "Alice", tid: "alice"}, %{name: "Billy", tid: "billy"}]
      |> Moar.Enum.index_by(&String.upcase(&1.tid))
      |> assert_eq(%{"ALICE" => %{name: "Alice", tid: "alice"}, "BILLY" => %{name: "Billy", tid: "billy"}})
    end

    test "fails when the keys are not unique" do
      assert_raise RuntimeError, "Map already contains key: 10", fn ->
        [%{name: "Alice", age: 10}, %{name: "Billy", age: 11}, %{name: "Cindy", age: 10}]
        |> Moar.Enum.index_by(& &1.age)
      end
    end
  end

  describe "into!" do
    test "works like Enum.into" do
      assert Moar.Enum.into!([a: 1], %{}) == %{a: 1}
      assert Moar.Enum.into!(%{a: 1}, []) == [a: 1]
    end

    test "converts nil into empty enum" do
      assert Moar.Enum.into!(nil, %{}) == %{}
      assert Moar.Enum.into!(nil, []) == []
    end

    test "accepts structs" do
      assert ~D[2020-01-02] |> Moar.Enum.into!(%{}) == %{calendar: Calendar.ISO, day: 2, month: 1, year: 2020}
    end
  end

  describe "is_map_or_keyword" do
    test "returns true for maps and keyword lists (including empty lists), false for other things" do
      assert Moar.Enum.is_map_or_keyword(%{a: 1})
      assert Moar.Enum.is_map_or_keyword(a: 1)
      assert Moar.Enum.is_map_or_keyword([{:a, 1}])
      assert Moar.Enum.is_map_or_keyword([])

      refute Moar.Enum.is_map_or_keyword([:a, 1])
      refute Moar.Enum.is_map_or_keyword({:a, 1})
      refute Moar.Enum.is_map_or_keyword(:a)
      refute Moar.Enum.is_map_or_keyword("")
      refute Moar.Enum.is_map_or_keyword(nil)
    end
  end

  describe "is_map_or_nonempty_keyword" do
    test "returns true for maps and non-empty keyword lists, false for other things" do
      assert Moar.Enum.is_map_or_nonempty_keyword(%{a: 1})
      assert Moar.Enum.is_map_or_nonempty_keyword(a: 1)
      assert Moar.Enum.is_map_or_nonempty_keyword([{:a, 1}])

      refute Moar.Enum.is_map_or_nonempty_keyword([])
      refute Moar.Enum.is_map_or_nonempty_keyword([:a, 1])
      refute Moar.Enum.is_map_or_nonempty_keyword({:a, 1})
      refute Moar.Enum.is_map_or_nonempty_keyword(:a)
      refute Moar.Enum.is_map_or_nonempty_keyword("")
      refute Moar.Enum.is_map_or_nonempty_keyword(nil)
    end
  end

  describe "isort" do
    test "sorts strings case-insensitively" do
      assert Moar.Enum.isort(["Banana", "apple", "cherry"]) == ["apple", "Banana", "cherry"]
    end

    test "sorts non-strings by their string equivalents" do
      assert Moar.Enum.isort([48, "Pudding", "apple", :gorilla]) == [48, "apple", :gorilla, "Pudding"]
    end
  end

  describe "isort_by" do
    test "sorts by the mapper case-insensitively" do
      Moar.Enum.isort_by([%{name: "Banana"}, %{name: "apple"}, %{name: "cherry"}], & &1.name)
      |> assert_eq([%{name: "apple"}, %{name: "Banana"}, %{name: "cherry"}])
    end
  end

  describe "lists_to_maps" do
    test "converts a list of lists to a list of maps" do
      assert Moar.Enum.lists_to_maps([[1, 2], [3, 4]], ["a", "b"]) == [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]
    end

    test "can optionally use the first list as the keys" do
      assert Moar.Enum.lists_to_maps([["a", "b"], [1, 2], [3, 4]], :first_list) ==
               [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]
    end
  end

  describe "take_at" do
    test "returns a list of elements at the given indices, in the order given" do
      ["A", "B", "C"] |> Moar.Enum.take_at([1]) |> assert_eq(["B"])
      ["A", "B", "C"] |> Moar.Enum.take_at([1, 2]) |> assert_eq(["B", "C"])
      ["A", "B", "C"] |> Moar.Enum.take_at([2, 1]) |> assert_eq(["C", "B"])
      ["A", "B", "C"] |> Moar.Enum.take_at([1, 4]) |> assert_eq(["B", nil])
    end

    test "when given `:all`, returns the entire list" do
      ["A", "B", "C"] |> Moar.Enum.take_at(:all) |> assert_eq(["A", "B", "C"])
    end
  end

  describe "test_ids" do
    test "returns :test_id fields" do
      [%{test_id: "a"}, %{test_id: nil}, %{test_id: "c"}] |> Moar.Enum.test_ids() |> assert_eq(["a", nil, "c"])
    end

    test "can optionally sort the test_ids" do
      [%{test_id: "c"}, %{test_id: nil}, %{test_id: "a"}]
      |> Moar.Enum.test_ids(sorted: true)
      |> assert_eq([nil, "a", "c"])
    end
  end

  describe "tids" do
    test "returns :tid fields" do
      [%{tid: "a"}, %{tid: nil}, %{tid: "c"}] |> Moar.Enum.tids() |> assert_eq(["a", nil, "c"])
    end

    test "can optionally sort the tids" do
      [%{tid: "c"}, %{tid: nil}, %{tid: "a"}] |> Moar.Enum.tids(sorted: true) |> assert_eq([nil, "a", "c"])
    end
  end
end
