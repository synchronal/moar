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

  describe "first!" do
    test "returns the first item in the enum" do
      assert Moar.Enum.first!(["foo"]) == "foo"
      assert Moar.Enum.first!(["foo", "bar"]) == "foo"
    end

    test "blows up if the enum is empty" do
      assert_raise RuntimeError, "Expected enumerable to have at least one item", fn -> Moar.Enum.first!([]) end
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
    test "returns true for maps and keywords, false for other things" do
      assert Moar.Enum.is_map_or_keyword(%{a: 1})
      assert Moar.Enum.is_map_or_keyword(a: 1)
      assert Moar.Enum.is_map_or_keyword([{:a, 1}])

      refute Moar.Enum.is_map_or_keyword([:a, 1])
      refute Moar.Enum.is_map_or_keyword({:a, 1})
      refute Moar.Enum.is_map_or_keyword(:a)
      refute Moar.Enum.is_map_or_keyword("")
      refute Moar.Enum.is_map_or_keyword(nil)
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

  describe "tids" do
    test "returns :tid fields" do
      [%{tid: "a"}, %{tid: nil}, %{tid: "c"}] |> Moar.Enum.tids() |> assert_eq(["a", nil, "c"])
    end
  end
end
