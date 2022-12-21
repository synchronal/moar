defmodule Moar.EnumTest do
  # @related [subject](/lib/enum.ex)

  use Moar.SimpleCase, async: true

  describe "first!" do
    test "returns the first item in the enum" do
      assert Moar.Enum.first!(["foo"]) == "foo"
      assert Moar.Enum.first!(["foo", "bar"]) == "foo"
    end

    test "blows up if the enum is empty" do
      assert_raise RuntimeError, "Expected enumerable to have at least one item", fn -> Moar.Enum.first!([]) end
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
end
