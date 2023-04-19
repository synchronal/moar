defmodule Moar.Map do
  # @related [test](/test/map_test.exs)

  @moduledoc "Map-related functions."

  @doc """
  Converts `key` in `map` to an atom, optionally transforming the value with `value_transformer`.

  Raises if `key` is a string and `map` already has an atomized version of that key.

  ```elixir
  iex> Moar.Map.atomize_key(%{"number-one" => "one", "number-two" => "two"}, "number-one")
  %{:number_one => "one", "number-two" => "two"}

  iex> Moar.Map.atomize_key(%{"number-one" => "one", "number-two" => "two"}, "number-one", &String.upcase/1)
  %{:number_one => "ONE", "number-two" => "two"}
  ```
  """
  @spec atomize_key(map(), binary() | atom(), (any() -> any()) | nil) :: map()
  def atomize_key(map, key, value_transformer \\ &Function.identity/1) do
    atomized_key = atomized_key(key, map)
    map |> rename_key(key, atomized_key) |> transform(atomized_key, value_transformer)
  end

  defp atomized_key(key, _map) when is_atom(key), do: key

  defp atomized_key(key, map) when is_binary(key) do
    key
    |> Moar.String.underscore()
    |> Moar.Atom.from_string()
    |> tap(fn new_key ->
      if Map.has_key?(map, new_key),
        do: raise(KeyError, ["key ", inspect(new_key), " already exists in ", inspect(map)] |> to_string())
    end)
  end

  @doc """
  Like `atomize_key/3` but raises if `key` is not in `map`.
  """
  @spec atomize_key!(map(), binary() | atom(), (any() -> any()) | nil) :: map()
  def atomize_key!(map, key, value_fn \\ &Function.identity/1)

  def atomize_key!(map, key, value_fn) when is_map_key(map, key),
    do: atomize_key(map, key, value_fn)

  def atomize_key!(map, key, _value_fn),
    do: raise(KeyError, ["key ", inspect(key), " not found in: ", inspect(map)] |> to_string())

  @doc """
  Converts keys in `map` to atoms.

  Raises if converting a key from a string to an atom would result in a key conflict.

  ```elixir
  iex> Moar.Map.atomize_keys(%{"a" => 1, "b" => 2})
  %{a: 1, b: 2}
  ```
  """
  @spec atomize_keys(map()) :: map()
  def atomize_keys(map),
    do: Enum.reduce(map, map, fn {k, _v}, acc -> atomize_key(acc, k) end)

  @doc """
  Removes keys from a map where the value is nil.

  ```elixir
  iex> Moar.Map.compact(%{a: 1, b: nil, c: ""})
  %{a: 1, c: ""}
  ```
  """
  @spec compact(map()) :: map()
  def compact(map) when is_map(map),
    do:
      Map.new(
        Enum.reject(map, fn
          {_k, nil} -> true
          _ -> false
        end)
      )

  @doc """
  Converts keys to atoms, traversing through descendant lists and maps.

  Raises if converting a key from a string to an atom would result in a key conflict.

  ```elixir
  iex> Moar.Map.deep_atomize_keys(%{"a" => %{"aa" => 1}, "b" => [%{"bb" => 2}, %{"bbb" => 3}]})
  %{a: %{aa: 1}, b: [%{bb: 2}, %{bbb: 3}]}
  ```
  """
  @spec deep_atomize_keys(list() | map()) :: map()
  def deep_atomize_keys(list) when is_list(list),
    do: list |> Enum.map(&deep_atomize_keys(&1))

  def deep_atomize_keys(map) when is_map(map) do
    Enum.reduce(map, map, fn
      {k, v}, acc when is_map(v) -> atomize_key(acc, k, &deep_atomize_keys/1)
      {k, list}, acc when is_list(list) -> atomize_key(acc, k, &Enum.map(&1, fn v -> deep_atomize_keys(v) end))
      {k, _v}, acc -> atomize_key(acc, k)
    end)
  end

  def deep_atomize_keys(not_a_map),
    do: not_a_map

  @doc """
  Deeply merges two maps into a single map. (It will also accept keyword lists and convert them to maps, as long
  as they are not empty lists.)

  Optionally accepts `conflict_fn` which gets called when both enumerables have values at the same keypath.
  It receives the conflicting values from each map and is expected to return the winning value.

  ```elixir
  iex> Moar.Map.deep_merge(%{fruit: %{apples: 3, bananas: 5}, veggies: %{carrots: 10}}, [fruit: [cherries: 20]])
  %{fruit: %{apples: 3, bananas: 5, cherries: 20}, veggies: %{carrots: 10}}

  iex> Moar.Map.deep_merge(%{a: %{b: 1}}, %{a: %{b: 2}})
  %{a: %{b: 2}}

  iex> Moar.Map.deep_merge(%{a: %{b: 1}}, %{a: %{b: 2}}, fn x, _y -> x end)
  %{a: %{b: 1}}

  iex> Moar.Map.deep_merge(%{a: %{b: 1}}, %{a: %{b: 2}}, fn x, y -> [x, y] end)
  %{a: %{b: [1, 2]}}
  ```
  """
  @spec deep_merge(map() | keyword(), map() | keyword(), (any(), any() -> any())) :: map()
  def deep_merge(a, b, conflict_fn \\ fn _val1, val2 -> val2 end) do
    if Moar.Enum.is_map_or_keyword(a) && Moar.Enum.is_map_or_keyword(b),
      do: deep_merge(nil, a, b, conflict_fn),
      else: raise("Expected first 2 arguments to be maps or keyword lists, got: #{inspect(a)} and #{inspect(b)}")
  end

  defp deep_merge(_key, a, b, conflict_fn) do
    if Moar.Enum.is_map_or_nonempty_keyword(a) && Moar.Enum.is_map_or_nonempty_keyword(b),
      do: Map.merge(Map.new(a), Map.new(b), fn k, v1, v2 -> deep_merge(k, v1, v2, conflict_fn) end),
      else: conflict_fn.(a, b)
  end

  @doc """
  Takes keys from nested maps.

  ```elixir
  iex> Moar.Map.deep_take(%{a: 1, b: %{c: 2, d: 3}, z: 9}, [:a, b: [:c]])
  %{a: 1, b: %{c: 2}}
  ```
  """
  @spec deep_take(map(), [atom() | binary() | {atom() | binary(), list() | map()}] | map()) :: map()
  def deep_take(map, keys) when is_map(map) and (is_list(keys) or is_map(keys)) do
    keys
    |> Enum.reduce(%{}, fn
      key, acc
      when (is_atom(key) or is_binary(key)) and is_map_key(map, key) ->
        Map.put(acc, key, Map.get(map, key))

      {key, nested_keys}, acc
      when (is_atom(key) or is_binary(key)) and is_map_key(map, key) ->
        case Map.get(map, key) do
          nil -> Map.put(acc, key, nil)
          %{} = submap -> Map.put(acc, key, deep_take(submap, nested_keys))
        end

      _, acc ->
        acc
    end)
  end

  @doc """
  Converts a list of maps into a map of maps indexed by the values of one of the map keys.
  It's a map-specific version of the more generic `Moar.Enum.index_by/2`.

  ```elixir
  iex> Moar.Map.index_by([%{name: "Alice", tid: "alice"}, %{name: "Billy", tid: "billy"}], :tid)
  %{"alice" => %{name: "Alice", tid: "alice"}, "billy" => %{name: "Billy", tid: "billy"}}
  ```
  """
  @spec index_by([map()], any()) :: map()
  def index_by(list_of_maps, key),
    do: Moar.Enum.index_by(list_of_maps, &Map.get(&1, key))

  @doc """
  Merges two enumerables into a single map. Supports `nil` values for either enumerable.

  ```elixir
  iex> Moar.Map.merge(%{a: 1}, [b: 2])
  %{a: 1, b: 2}

  iex> Moar.Map.merge(nil, [a: 1])
  %{a: 1}
  ```
  """
  @spec merge(Enum.t() | nil, Enum.t() | nil) :: map()
  def merge(a, b) when is_map(a) and is_map(b),
    do: Map.merge(a, b)

  def merge(a, b),
    do: Map.merge(Moar.Enum.into!(a, %{}), Moar.Enum.into!(b, %{}))

  @doc """
  Merges two maps, retaining any existing non-blank values.

  ```elixir
  iex> Moar.Map.merge_if_blank(%{a: 1, b: nil, c: ""}, %{a: 100, b: 2, c: 3, d: 4})
  %{a: 1, b: 2, c: 3, d: 4}
  ```
  """
  @spec merge_if_blank(map(), map()) :: map()
  def merge_if_blank(a, b) when is_map(a) and is_map(b) do
    existing_values = Map.filter(a, fn {_k, v} -> Moar.Term.present?(v) end)
    Map.merge(b, existing_values)
  end

  @doc """
  Puts a key/value pair into the given map if the key is not alredy in the map, or if the value in the map is
  blank as defined by `Moar.Term.blank?/1`.

  Also, the `map` parameter can be any enumerable that can be turned into a map via `Enum.into/2`.

  ```elixir
  iex> %{a: 1} |> Moar.Map.put_if_blank(:b, 2)
  %{a: 1, b: 2}

  iex> %{a: 1, b: nil} |> Moar.Map.put_if_blank(:b, 2)
  %{a: 1, b: 2}

  iex> %{a: 1, b: 3} |> Moar.Map.put_if_blank(:b, 2)
  %{a: 1, b: 3}
  ```
  """
  @spec put_if_blank(map() | keyword(), any(), any()) :: map()
  def put_if_blank(map, key, value) do
    map = Enum.into(map, %{})

    if Map.get(map, key) |> Moar.Term.present?(),
      do: map,
      else: Map.put(map, key, value)
  end

  @doc """
  Like `Map.put_new/3` but raises if `key` already exists in `map`.

  ```elixir
  iex> Moar.Map.put_new!(%{a: 1}, :b, 2)
  %{a: 1, b: 2}

  iex> Moar.Map.put_new!(%{a: 1, b: 2}, :b, 3)
  ** (RuntimeError) Map already contains key: :b
  ```
  """
  @spec put_new!(map(), any(), any()) :: map()
  def put_new!(map, key, value) do
    if Map.has_key?(map, key),
      do: raise("Map already contains key: #{inspect(key)}"),
      else: Map.put(map, key, value)
  end

  @doc """
  Returns a copy of `map` with `old_key_name` changed to `new_key_name`.

  ```elixir
  iex> %{"color" => "red", "size" => "medium"} |> Moar.Map.rename_key("color", "colour")
  %{"colour" => "red", "size" => "medium"}
  ```
  """
  @spec rename_key(map(), binary() | atom(), binary() | atom()) :: map()
  def rename_key(map, old_key_name, new_key_name) when is_map_key(map, old_key_name) do
    {value, new_map} = Map.pop(map, old_key_name)
    Map.put(new_map, new_key_name, value)
  end

  def rename_key(map, _, _),
    do: map

  @doc """
  Like `rename_key/2` but raises if `key` is not in `map`
  """
  @spec rename_key!(map(), {binary(), binary()}) :: map()
  def rename_key!(map, {old_key_name, new_key_name} = _old_and_new_key),
    do: rename_key!(map, old_key_name, new_key_name)

  @doc """
  Like `rename_key/3` but raises if `key` is not in `map`
  """
  @spec rename_key!(map(), binary() | atom(), binary() | atom()) :: map()
  def rename_key!(map, old_key_name, new_key_name) when is_map_key(map, old_key_name),
    do: rename_key(map, old_key_name, new_key_name)

  def rename_key!(map, old_key_name, _new_key_name),
    do: raise(KeyError, ["key ", inspect(old_key_name), " not found in: ", inspect(map)] |> to_string())

  @doc """
  Returns a copy of `map` with `old_key_name` changed to `new_key_name`.

  `old_key_name` and `new_key_name` are passed in as a `{old_key_name, new_key_name}` tuple.

  ```elixir
  iex> %{"color" => "red", "size" => "medium"} |> Moar.Map.rename_key({"color", "colour"})
  %{"colour" => "red", "size" => "medium"}
  ```
  """
  @spec rename_key(map(), {binary(), binary()}) :: map()
  def rename_key(map, {old_key_name, new_key_name} = _old_and_new_key),
    do: rename_key(map, old_key_name, new_key_name)

  @doc """
  Returns a copy of `map` after changing key names supplied by `keys_map`.

  ```elixir
  %{"behavior" => "chill", "color" => "red"} |> Moar.Map.rename_keys(%{"behavior" => "behaviour", "color" => "colour"})
  %{"behaviour" => "chill", "colour" => "red"}
  ```
  """
  @spec rename_keys(map(), map()) :: map()
  def rename_keys(map, keys_map),
    do: Enum.reduce(keys_map, map, &rename_key(&2, &1))

  @doc """
  Like `rename_keys/2` but raises if any key in `keys_map` is not in `map`.
  """
  @spec rename_keys!(map(), map()) :: map()
  def rename_keys!(map, keys_map),
    do: Enum.reduce(keys_map, map, &rename_key!(&2, &1))

  @doc """
  Converts keys in `map` to strings.

  ```elixir
  iex> Moar.Map.stringify_keys(%{a: 1, b: 2} )
  %{"a" => 1, "b" => 2}
  ```
  """
  @spec stringify_keys(map()) :: map()
  def stringify_keys(map),
    do: map |> Map.new(fn {k, v} -> {Moar.Atom.to_string(k), v} end)

  @doc """
  Transforms values of `map` using `transformer` function.

  ```elixir
  iex> %{"foo" => "chicken", "bar" => "cow", "baz" => "pig"} |> Moar.Map.transform("foo", &String.upcase/1)
  %{"foo" => "CHICKEN", "bar" => "cow", "baz" => "pig"}

  iex> %{"foo" => "chicken", "bar" => "cow", "baz" => "pig"} |> Moar.Map.transform(["foo", "bar"], &String.upcase/1)
  %{"foo" => "CHICKEN", "bar" => "COW", "baz" => "pig"}
  ```
  """
  @spec transform(map(), atom() | binary() | list(), (any() -> any())) :: map()
  def transform(map, keys, transformer) when is_list(keys),
    do: Enum.reduce(keys, map, fn key, new_map -> transform(new_map, key, transformer) end)

  def transform(map, key, transformer) when is_map_key(map, key),
    do: Map.update!(map, key, transformer)

  def transform(map, _, _),
    do: map

  @doc """
  Validates that the keys of `map` are equal to or a subset of `valid_keys`. In addition to being a list, `valid_keys`
  can be a map or struct, in which case the keys of the map or struct are used as the list of valid keys.

  It returns the input map, or raises an exception if there are non-allowed keys.

  ```elixir
  iex> Moar.Map.validate_keys!(%{a: 1, b: 2}, [:a, :b, :c])
  %{a: 1, b: 2}

  iex> Moar.Map.validate_keys!(%{a: 1, b: 2}, %{a: nil, b: 2, c: :foo})
  %{a: 1, b: 2}

  iex> Moar.Map.validate_keys!(%{a: 1, b: 2}, [:a, :c])
  ** (ArgumentError) Non-allowed keys found in map: [:b]
  ```
  """
  @spec validate_keys!(map(), list() | map() | struct()) :: map()
  def validate_keys!(map, valid_keys) do
    allowed_keys =
      cond do
        is_struct(valid_keys) -> valid_keys |> Map.delete(:__struct__) |> Map.keys()
        is_map(valid_keys) -> Map.keys(valid_keys)
        Keyword.keyword?(valid_keys) -> Keyword.keys(valid_keys)
        is_list(valid_keys) -> valid_keys
        true -> raise ArgumentError, "Expected a list, map, or struct, got: #{inspect(valid_keys)}"
      end

    case Map.keys(map) -- allowed_keys do
      [] -> map
      extra_keys -> raise ArgumentError, "Non-allowed keys found in map: #{inspect(extra_keys)}"
    end
  end
end
