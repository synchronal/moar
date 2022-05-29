defmodule Moar.MapTest do
  # @related [subject](/lib/map.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Map

  describe "atomize_key" do
    test "converts a key from a string to an atom" do
      %{"key1" => "value1", "key2" => "value2"}
      |> Moar.Map.atomize_key("key2")
      |> assert_eq(%{"key1" => "value1", :key2 => "value2"})
    end

    test "works if the given key is already an atom" do
      %{"key1" => "value1", :key2 => "value2"}
      |> Moar.Map.atomize_key(:key2)
      |> assert_eq(%{"key1" => "value1", :key2 => "value2"})
    end

    @tag :skip
    test "works if the key does not exist in the map" do
      %{"key1" => "value1", "key2" => "value2"}
      |> Moar.Map.atomize_key("key3")
      |> assert_eq(%{"key1" => "value1", "key2" => "value2"})
    end

    test "optionally accepts a function that modifies the value" do
      %{"key1" => "value1", "key2" => "value2"}
      |> Moar.Map.atomize_key("key2", &String.upcase/1)
      |> assert_eq(%{"key1" => "value1", :key2 => "VALUE2"})
    end

    test "modifies the value even if the key was already an atom" do
      %{"key1" => "value1", :key2 => "value2"}
      |> Moar.Map.atomize_key(:key2, &String.upcase/1)
      |> assert_eq(%{"key1" => "value1", :key2 => "VALUE2"})
    end

    test "raises if converting a string to an already-existing atom" do
      assert_raise KeyError, ~s|key :key1 already exists in %{:key1 => "value1", "key1" => "value2"}|, fn ->
        %{:key1 => "value1", "key1" => "value2"}
        |> Moar.Map.atomize_key("key1")
      end
    end
  end

  describe "atomize_key!" do
    test "raises if the key does not exist in the map" do
      assert_raise KeyError, ~s|key "key3" not found in: %{"key1" => "value1", "key2" => "value2"}|, fn ->
        %{"key1" => "value1", "key2" => "value2"}
        |> Moar.Map.atomize_key!("key3")
      end
    end
  end

  describe "atomize_keys" do
    test "converts keys from strings to atoms" do
      %{"item1" => "chapstick", "item2" => "mask"}
      |> Moar.Map.atomize_keys()
      |> assert_eq(%{item1: "chapstick", item2: "mask"})
    end

    test "handles keys that are already atoms" do
      %{:item1 => 1, "item2" => 2}
      |> Moar.Map.atomize_keys()
      |> assert_eq(%{item1: 1, item2: 2})
    end

    test "handles a list of maps" do
      [%{a: :b}, %{"d" => :f}]
      |> Moar.Map.deep_atomize_keys()
      |> assert_eq([%{a: :b}, %{d: :f}])
    end
  end

  describe "deep_atomize_keys" do
    test "deeply converts keys from strings to atoms" do
      %{"item1" => "chapstick", "item2" => %{"item3" => "mask"}}
      |> Moar.Map.deep_atomize_keys()
      |> assert_eq(%{item1: "chapstick", item2: %{item3: "mask"}})
    end

    test "handles keys that are already atoms" do
      %{:item1 => %{"item3" => "mask"}, "item2" => 2}
      |> Moar.Map.deep_atomize_keys()
      |> assert_eq(%{item1: %{item3: "mask"}, item2: 2})
    end

    test "raises if there are duplicate keys where one is a string and one is an atom" do
      assert_raise KeyError, ~s|key :item1 already exists in %{:item1 => 1, "item1" => 2, "item2" => 3}|, fn ->
        %{:item1 => 1, "item1" => 2, "item2" => 3}
        |> Moar.Map.deep_atomize_keys()
      end

      assert_raise KeyError, ~s|key :item2 already exists in %{:item2 => 1, "item2" => 2}|, fn ->
        %{:item1 => %{:item2 => 1, "item2" => 2}}
        |> Moar.Map.deep_atomize_keys()
      end
    end

    test "handles values that are lists" do
      %{
        "item1" => "chapstick",
        "item2" => %{
          "item3" => ["mask", "altoids"],
          "item4" => [%{"size" => "s", "color" => "blue"}, %{"size" => "m", "color" => "red"}]
        }
      }
      |> Moar.Map.deep_atomize_keys()
      |> assert_eq(%{
        item1: "chapstick",
        item2: %{item3: ["mask", "altoids"], item4: [%{size: "s", color: "blue"}, %{size: "m", color: "red"}]}
      })
    end
  end

  describe "deep merge" do
    test "can do a shallow merge of maps" do
      %{a: 1, b: 2} |> Moar.Map.deep_merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "can do a shallow merge of other enumerables" do
      %{a: 1, b: 2} |> Moar.Map.deep_merge(b: 3, c: 4) |> assert_eq(%{a: 1, b: 3, c: 4})
      [a: 1, b: 2] |> Moar.Map.deep_merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "can do a deep merge of maps" do
      %{a: %{aa: %{aaa: 1}}, b: 2}
      |> Moar.Map.deep_merge(%{c: 1, a: %{aa: %{ab: 3}}})
      |> assert_eq(%{a: %{aa: %{aaa: 1, ab: 3}}, b: 2, c: 1})
    end

    test "can do a deep merge of other enumerables" do
      [a: [aa: [aaa: 1]], b: 2]
      |> Moar.Map.deep_merge(%{c: 1, a: %{aa: %{ab: 3}}})
      |> assert_eq(%{a: %{aa: %{aaa: 1, ab: 3}}, b: 2, c: 1})
    end
  end

  describe "merge" do
    test "with two maps" do
      %{a: 1, b: 2} |> Moar.Map.merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "with other enumerables" do
      %{a: 1, b: 2} |> Moar.Map.merge(b: 3, c: 4) |> assert_eq(%{a: 1, b: 3, c: 4})
      [a: 1, b: 2] |> Moar.Map.merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end
  end

  describe "rename_key" do
    test "renames a key" do
      %{"color" => "red", "size" => "medium"}
      |> Moar.Map.rename_key("color", "colour")
      |> assert_eq(%{"colour" => "red", "size" => "medium"})
    end

    test "accepts tuple for renaming" do
      %{"color" => "red", "size" => "medium"}
      |> Moar.Map.rename_key({"color", "colour"})
      |> assert_eq(%{"colour" => "red", "size" => "medium"})
    end

    test "does nothing if the key doesn't exist" do
      %{"color" => "red", "size" => "medium"}
      |> Moar.Map.rename_key("behavior", "behaviour")
      |> assert_eq(%{"color" => "red", "size" => "medium"})
    end

    test "renames the key if the value is nil" do
      %{"color" => nil, "size" => "medium"}
      |> Moar.Map.rename_key("color", "colour")
      |> assert_eq(%{"colour" => nil, "size" => "medium"})
    end
  end

  describe "rename_key!" do
    test "raises if the key doesn't exist" do
      assert_raise KeyError, ~s|key "behavior" not found in: %{"color" => "red", "size" => "medium"}|, fn ->
        %{"color" => "red", "size" => "medium"}
        |> Moar.Map.rename_key!("behavior", "behaviour")
      end
    end

    test "raises if the key doesn't exist (tuple variant)" do
      assert_raise KeyError, ~s|key "behavior" not found in: %{"color" => "red", "size" => "medium"}|, fn ->
        %{"color" => "red", "size" => "medium"}
        |> Moar.Map.rename_key!({"behavior", "behaviour"})
      end
    end
  end

  describe "rename_keys" do
    test "renames multiple keys" do
      %{"behavior" => "chill", "color" => "red", "size" => "medium"}
      |> Moar.Map.rename_keys(%{"behavior" => "behaviour", "color" => "colour"})
      |> assert_eq(%{"behaviour" => "chill", "colour" => "red", "size" => "medium"})
    end

    test "does nothing if the key doesn't exist" do
      %{"color" => "red", "size" => "medium"}
      |> Moar.Map.rename_keys(%{"behavior" => "behaviour"})
      |> assert_eq(%{"color" => "red", "size" => "medium"})
    end

    test "renames the key if the value is nil" do
      %{"color" => nil, "size" => "medium"}
      |> Moar.Map.rename_keys(%{"behavior" => "behaviour"})
      |> assert_eq(%{"color" => nil, "size" => "medium"})
    end
  end

  describe "rename_keys!" do
    test "raises if the key doesn't exist" do
      assert_raise KeyError, ~s|key "behavior" not found in: %{"color" => "red", "size" => "medium"}|, fn ->
        %{"color" => "red", "size" => "medium"}
        |> Moar.Map.rename_keys!(%{"behavior" => "behaviour"})
      end
    end
  end

  describe "stringify_keys" do
    test "converts keys from atoms to strings" do
      %{item1: "chapstick", item2: "mask"}
      |> Moar.Map.stringify_keys()
      |> assert_eq(%{"item1" => "chapstick", "item2" => "mask"})
    end

    test "gracefully handles keys that are already strings" do
      %{"item1" => "chapstick", "item2" => "mask"}
      |> Moar.Map.stringify_keys()
      |> assert_eq(%{"item1" => "chapstick", "item2" => "mask"})

      assert_raise ArgumentError, fn ->
        Moar.Map.stringify_keys(%{nil => 1})
      end
    end
  end

  describe "transform" do
    test "transforms values using the transform function" do
      %{"foo" => "chicken", "bar" => "cow", "baz" => "pig"}
      |> Moar.Map.transform(["foo", "bar"], &String.upcase/1)
      |> assert_eq(%{"foo" => "CHICKEN", "bar" => "COW", "baz" => "pig"})
    end

    test "does nothing if a key doesn't exist" do
      %{"foo" => "chicken", "bar" => "cow"}
      |> Moar.Map.transform(["foo", "baz"], &String.upcase/1)
      |> assert_eq(%{"foo" => "CHICKEN", "bar" => "cow"})
    end

    test "it accepts a single key" do
      %{"foo" => "chicken", "bar" => "cow"}
      |> Moar.Map.transform("foo", &String.upcase/1)
      |> assert_eq(%{"foo" => "CHICKEN", "bar" => "cow"})
    end

    test "it can accept any key type" do
      %{{:foo, 1} => "chicken", {:bar, 2} => "cow"}
      |> Moar.Map.transform({:foo, 1}, &String.upcase/1)
      |> assert_eq(%{{:foo, 1} => "CHICKEN", {:bar, 2} => "cow"})
    end
  end
end
