defmodule Moar.Map do
  # @related [test](/test/map_test.exs)

  @moduledoc "Map-related functions."

  @doc """
  Converts `key` in `map` to an atom, optionally transforming the value with `value_fn`.

  Raises if `key` is a string and `map` already has an atomized version of that key.
  """
  @spec atomize_key(map(), binary() | atom(), (any() -> any()) | nil) :: map()
  def atomize_key(map, key, value_fn \\ &Function.identity/1) do
    atomized_key =
      if is_atom(key) do
        key
      else
        Moar.Atom.from_string(key)
        |> tap(fn new_key ->
          if Map.has_key?(map, new_key),
            do: raise(KeyError, ["key ", inspect(new_key), " already exists in ", inspect(map)] |> to_string())
        end)
      end

    {value, map} = Map.pop!(map, key)
    Map.put(map, atomized_key, value_fn.(value))
  end

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
  Deeply merges two enumerables into a single map.

  ```elixir
  iex> Moar.Map.deep_merge(%{fruit: %{apples: 3, bananas: 5}, veggies: %{carrots: 10}}, [fruit: [cherries: 20]])
  %{fruit: %{apples: 3, bananas: 5, cherries: 20}, veggies: %{carrots: 10}}
  ```
  """
  @spec deep_merge(Enum.t(), Enum.t()) :: map()
  def deep_merge(a, b),
    do: deep_merge(nil, a, b)

  defp deep_merge(_key, a, b) do
    if Moar.Protocol.implements?(a, Enumerable) && Moar.Protocol.implements?(b, Enumerable),
      do: Map.merge(Enum.into(a, %{}), Enum.into(b, %{}), &deep_merge/3),
      else: b
  end

  @doc """
  Merges two enumerables into a single map.

  ```elixir
  iex> Moar.Map.merge(%{a: 1}, [b: 2])
  %{a: 1, b: 2}
  ```
  """
  @spec merge(Enum.t(), Enum.t()) :: map()
  def merge(a, b) when is_map(a) and is_map(b),
    do: Map.merge(a, b)

  def merge(a, b),
    do: Map.merge(Enum.into(a, %{}), Enum.into(b, %{}))

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
end
