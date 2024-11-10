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

    test "converts dashes to underscores" do
      %{"key-one" => "value1", "key-two" => "value2"}
      |> Moar.Map.atomize_key("key-two")
      |> assert_eq(%{"key-one" => "value1", :key_two => "value2"})
    end

    test "works if the given key is already an atom" do
      %{"key1" => "value1", :key2 => "value2"}
      |> Moar.Map.atomize_key(:key2)
      |> assert_eq(%{"key1" => "value1", :key2 => "value2"})
    end

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

  describe "compact" do
    test "removes keys where the value is nil" do
      assert Moar.Map.compact(%{a: 1, b: nil, c: ""}) == %{a: 1, c: ""}
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

    test "can do a shallow merge of keyword lists" do
      %{a: 1, b: 2} |> Moar.Map.deep_merge(b: 3, c: 4) |> assert_eq(%{a: 1, b: 3, c: 4})
      [a: 1, b: 2] |> Moar.Map.deep_merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "fails when inputs are not maps or keyword lists" do
      assert_raise RuntimeError,
                   "Expected first 2 arguments to be maps or keyword lists, got: %{a: 1} and {:b, 2}",
                   fn -> assert Moar.Map.deep_merge(%{a: 1}, {:b, 2}) == %{a: 1, b: 2} end
    end

    test "can do a deep merge of maps" do
      %{a: %{aa: %{aaa: 1}}, b: 2}
      |> Moar.Map.deep_merge(%{c: 1, a: %{aa: %{ab: 3}}})
      |> assert_eq(%{a: %{aa: %{aaa: 1, ab: 3}}, b: 2, c: 1})
    end

    test "can do a deep merge of keyword lists" do
      [a: [aa: [aaa: 1]], b: 2]
      |> Moar.Map.deep_merge(%{c: 1, a: %{aa: %{ab: 3}}})
      |> assert_eq(%{a: %{aa: %{aaa: 1, ab: 3}}, b: 2, c: 1})
    end

    test "non-map/keyword values from the second arg replace values from the first arg when keys match" do
      %{a: 1, b: 2} |> Moar.Map.deep_merge(%{a: 3}) |> assert_eq(%{a: 3, b: 2})
      %{a: %{b: 1, c: 2}} |> Moar.Map.deep_merge(a: [b: 3]) |> assert_eq(%{a: %{b: 3, c: 2}})
    end

    test "when the value is an empty list, it stays an empty list" do
      %{"key" => []} |> Moar.Map.deep_merge(%{"key" => []}) |> assert_eq(%{"key" => []})
    end

    test "when the value is a regular list, the values are not merged" do
      %{"key" => [1]} |> Moar.Map.deep_merge(%{"key" => []}) |> assert_eq(%{"key" => []})
      %{"key" => []} |> Moar.Map.deep_merge(%{"key" => [1]}) |> assert_eq(%{"key" => [1]})
      %{"key" => [1]} |> Moar.Map.deep_merge(%{"key" => [1]}) |> assert_eq(%{"key" => [1]})
      %{"key" => [1]} |> Moar.Map.deep_merge(%{"key" => [2]}) |> assert_eq(%{"key" => [2]})
    end

    test "a function can be provided to handle conflicts" do
      %{a: 1, b: 2} |> Moar.Map.deep_merge(%{b: 3}) |> assert_eq(%{a: 1, b: 3})
      %{a: 1, b: 2} |> Moar.Map.deep_merge(%{b: 3}, fn _x, y -> y end) |> assert_eq(%{a: 1, b: 3})
      %{a: 1, b: 2} |> Moar.Map.deep_merge(%{b: 3}, fn x, _y -> x end) |> assert_eq(%{a: 1, b: 2})

      %{a: %{aa: %{aaa: 1}}, b: 2}
      |> Moar.Map.deep_merge(%{c: 1, a: %{aa: %{aaa: 4, ab: 3}}}, fn x, _y -> x end)
      |> assert_eq(%{a: %{aa: %{aaa: 1, ab: 3}}, b: 2, c: 1})
    end

    test "the conflict function can be used to not update a value with a blank value" do
      conflict_fn = fn x, y -> if Moar.Term.blank?(y), do: x, else: y end

      %{a: %{b: %{c: 1}}}
      |> Moar.Map.deep_merge(%{a: %{b: %{c: ""}}}, conflict_fn)
      |> assert_eq(%{a: %{b: %{c: 1}}})

      %{a: %{b: %{c: ""}}}
      |> Moar.Map.deep_merge(%{a: %{b: %{c: 1}}}, conflict_fn)
      |> assert_eq(%{a: %{b: %{c: 1}}})
    end

    test "the conflict function can be used to update a list" do
      %{a: %{b: [1, 2]}}
      |> Moar.Map.deep_merge(%{a: %{b: 3}}, fn x, y -> x ++ [y] end)
      |> assert_eq(%{a: %{b: [1, 2, 3]}})
    end
  end

  describe "deep_stringify_keys" do
    test "deeply converts keys from atoms to strings" do
      %{item1: "chapstick", item2: %{"item3" => "mask"}}
      |> Moar.Map.deep_stringify_keys()
      |> assert_eq(%{"item1" => "chapstick", "item2" => %{"item3" => "mask"}})
    end

    test "handles keys that are already strings" do
      %{"item1" => %{:item3 => "mask"}, :item2 => 2}
      |> Moar.Map.deep_stringify_keys()
      |> assert_eq(%{"item1" => %{"item3" => "mask"}, "item2" => 2})
    end

    test "raises if there are duplicate keys where one is a string and one is an atom" do
      assert_raise KeyError, ~s|key "item1" already exists in %{:item1 => 1, "item1" => 2, "item2" => 3}|, fn ->
        %{:item1 => 1, "item1" => 2, "item2" => 3}
        |> Moar.Map.deep_stringify_keys()
      end

      assert_raise KeyError, ~s|key "item2" already exists in %{:item2 => 1, "item2" => 2}|, fn ->
        %{:item1 => %{:item2 => 1, "item2" => 2}}
        |> Moar.Map.deep_stringify_keys()
      end
    end

    test "handles values that are lists" do
      %{
        :item1 => "chapstick",
        :item2 => %{
          :item3 => ["mask", "altoids"],
          :item4 => [%{:size => "s", :color => "blue"}, %{:size => "m", :color => "red"}]
        }
      }
      |> Moar.Map.deep_stringify_keys()
      |> assert_eq(%{
        "item1" => "chapstick",
        "item2" => %{
          "item3" => ["mask", "altoids"],
          "item4" => [%{"size" => "s", "color" => "blue"}, %{"size" => "m", "color" => "red"}]
        }
      })
    end
  end

  describe "deep_take" do
    test "takes specific keys from a map" do
      %{a: 1, b: 2, c: 3, d: 4}
      |> Moar.Map.deep_take([:b, :c])
      |> assert_eq(%{b: 2, c: 3})
    end

    test "accepts keyword list of nested keys to take" do
      %{a: 1, b: %{d: 4, e: 5}, c: 3}
      |> Moar.Map.deep_take([:c, b: [:e]])
      |> assert_eq(%{b: %{e: 5}, c: 3})
    end

    test "accepts binary keys" do
      %{"a" => 1, "b" => 2}
      |> Moar.Map.deep_take(["b"])
      |> assert_eq(%{"b" => 2})

      %{"a" => 1, "b" => %{"c" => 2, "d" => 3}}
      |> Moar.Map.deep_take(%{"b" => ["c"]})
      |> assert_eq(%{"b" => %{"c" => 2}})
    end

    test "returns nil when the root value for nested keys is nil" do
      %{a: 1, b: nil, c: 3}
      |> Moar.Map.deep_take(b: [:e])
      |> assert_eq(%{b: nil})
    end

    test "ignores keys that are not in the map" do
      %{a: 1, b: 2}
      |> Moar.Map.deep_take([:b, :c, d: [:e]])
      |> assert_eq(%{b: 2})
    end

    test "takes to an arbitrary depth" do
      %{a: %{b: %{c: %{d: %{e: 1, f: 2}, z: 0}, z: 0}, z: 0}, z: 0}
      |> Moar.Map.deep_take(a: [b: [c: [d: [:e]]]])
      |> assert_eq(%{a: %{b: %{c: %{d: %{e: 1}}}}})
    end
  end

  describe "index_by" do
    test "converts a list of maps into a map of maps indexed by the value of a key" do
      [%{name: "Alice", tid: "alice"}, %{name: "Billy", tid: "billy"}]
      |> Moar.Map.index_by(:tid)
      |> assert_eq(%{"alice" => %{name: "Alice", tid: "alice"}, "billy" => %{name: "Billy", tid: "billy"}})
    end

    test "fails when the keys are not unique" do
      assert_raise RuntimeError, "Map already contains key: 10", fn ->
        [%{name: "Alice", age: 10}, %{name: "Billy", age: 11}, %{name: "Cindy", age: 10}]
        |> Moar.Map.index_by(:age)
      end
    end
  end

  describe "merge" do
    test "with two maps, acts just like Map.merge" do
      %{a: 1, b: 2} |> Moar.Map.merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "with other enumerables, converts to maps before calling Map.merge" do
      %{a: 1, b: 2} |> Moar.Map.merge(b: 3, c: 4) |> assert_eq(%{a: 1, b: 3, c: 4})
      [a: 1, b: 2] |> Moar.Map.merge(%{b: 3, c: 4}) |> assert_eq(%{a: 1, b: 3, c: 4})
    end

    test "supports nil arguments" do
      assert Moar.Map.merge(%{a: 1}, nil) == %{a: 1}
      assert Moar.Map.merge(nil, %{b: 1}) == %{b: 1}
      assert Moar.Map.merge(nil, nil) == %{}
    end
  end

  describe "merge_if_blank" do
    test "merges from right where the key is missing in the left map" do
      assert Moar.Map.merge_if_blank(%{a: 1}, %{a: 100, b: 2}) == %{a: 1, b: 2}
    end

    test "merges from right where the key is nil or blank in the left map" do
      assert Moar.Map.merge_if_blank(%{a: 1, b: nil, c: ""}, %{a: 100, b: 2, c: 3}) == %{a: 1, b: 2, c: 3}
    end
  end

  describe "put_if_blank" do
    test "adds the key/value pair if the key does not exist in the map" do
      assert Moar.Map.put_if_blank(%{a: 1}, :b, 2) == %{a: 1, b: 2}
    end

    test "adds the key/value pair if the value in the map is nil" do
      assert Moar.Map.put_if_blank(%{a: 1, b: nil}, :b, 2) == %{a: 1, b: 2}
    end

    test "adds the key/value pair if the value in the map is blank" do
      assert Moar.Map.put_if_blank(%{a: 1, b: []}, :b, 2) == %{a: 1, b: 2}
      assert Moar.Map.put_if_blank(%{a: 1, b: ""}, :b, 2) == %{a: 1, b: 2}
      assert Moar.Map.put_if_blank(%{a: 1, b: %{}}, :b, 2) == %{a: 1, b: 2}
    end

    test "does not add the key/value pair if the value in the map is not blank" do
      assert Moar.Map.put_if_blank(%{a: 1, b: 3}, :b, 2) == %{a: 1, b: 3}
      assert Moar.Map.put_if_blank(%{a: 1, b: [3]}, :b, 2) == %{a: 1, b: [3]}
      assert Moar.Map.put_if_blank(%{a: 1, b: %{x: 3}}, :b, 2) == %{a: 1, b: %{x: 3}}
    end

    test "a keyword list is first converted into a map" do
      assert Moar.Map.put_if_blank([a: 1], :b, 2) == %{a: 1, b: 2}
      assert Moar.Map.put_if_blank([a: 1, b: 3], :b, 2) == %{a: 1, b: 3}
    end
  end

  describe "put_new!" do
    test "puts `key` => `value` into `map` if it does not yet exist" do
      assert Moar.Map.put_new!(%{a: 1, b: 2}, :c, 3) == %{a: 1, b: 2, c: 3}
    end

    test "raises if `key` already exists in `map`" do
      assert_raise RuntimeError, "Map already contains key: :b", fn -> Moar.Map.put_new!(%{a: 1, b: 2}, :b, 3) end
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

  describe "validate_keys!" do
    test "verifies that the map's keys equal or are a subset of the keys in the given list" do
      map = %{a: 1, b: 2}
      assert Moar.Map.validate_keys!(map, [:a, :b]) == map
      assert Moar.Map.validate_keys!(map, [:a, :b, :c]) == map

      assert_raise ArgumentError, "Non-allowed keys found in map: [:b]", fn ->
        Moar.Map.validate_keys!(map, [:a, :c])
      end
    end

    test "verifies that the map's keys equal or are a subset of the keys in the given map" do
      map = %{a: 1, b: 2}
      assert Moar.Map.validate_keys!(map, %{a: nil, b: "foo"}) == map
      assert Moar.Map.validate_keys!(map, %{a: nil, b: "foo", c: :bar}) == map

      assert_raise ArgumentError, "Non-allowed keys found in map: [:b]", fn ->
        Moar.Map.validate_keys!(map, %{a: nil, c: :bar})
      end
    end

    test "verifies that the map's keys equal or are a subset of the keys in the given keyword list" do
      map = %{a: 1, b: 2}
      assert Moar.Map.validate_keys!(map, a: nil, b: "foo") == map
      assert Moar.Map.validate_keys!(map, a: nil, b: "foo", c: :bar) == map

      assert_raise ArgumentError, "Non-allowed keys found in map: [:b]", fn ->
        Moar.Map.validate_keys!(map, a: nil, c: :bar)
      end
    end

    defmodule TestStruct, do: defstruct([:a, :b, :c])

    test "verifies that the map's keys equal or are a subset of the keys in the given struct" do
      assert Moar.Map.validate_keys!(%{a: 1, b: 2}, %TestStruct{}) == %{a: 1, b: 2}

      assert_raise ArgumentError, "Non-allowed keys found in map: [:d]", fn ->
        Moar.Map.validate_keys!(%{a: 1, b: 2, d: 4}, %TestStruct{})
      end
    end

    test "raises when the list of valid keys is not a map, struct, or list" do
      map = %{a: 1, b: 2}

      assert_raise ArgumentError, "Expected a list, map, or struct, got: :foo", fn ->
        Moar.Map.validate_keys!(map, :foo)
      end
    end
  end
end
