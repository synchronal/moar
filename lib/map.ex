defmodule Moar.Map do
  # @related [test](/test/map_test.exs)

  @moduledoc "Map-related functions."

  @doc """
  Converts keys in `map` to atoms.

  ```elixir
  iex> Moar.Map.atomize_keys(%{"a" => 1, "b" => 2})
  %{a: 1, b: 2}
  ```
  """
  @spec atomize_keys(map()) :: map()
  def atomize_keys(map),
    do: map |> Map.new(fn {k, v} -> {Moar.Atom.from_string(k), v} end)

  @doc """
  Converts keys to atoms, traversing through descendant lists and maps.

  ```elixir
  iex> Moar.Map.deep_atomize_keys(%{"a" => %{"aa" => 1}, "b" => [%{"bb" => 2}, %{"bbb" => 3}]})
  %{a: %{aa: 1}, b: [%{bb: 2}, %{bbb: 3}]}
  ```
  """
  @spec deep_atomize_keys(list() | map()) :: map()
  def deep_atomize_keys(list) when is_list(list),
    do: list |> Enum.map(&deep_atomize_keys(&1))

  def deep_atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_map(v) -> {Moar.Atom.from_string(k), deep_atomize_keys(v)}
      {k, list} when is_list(list) -> {Moar.Atom.from_string(k), Enum.map(list, fn v -> deep_atomize_keys(v) end)}
      {k, v} -> {Moar.Atom.from_string(k), v}
    end)
  end

  def deep_atomize_keys(not_a_map),
    do: not_a_map

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
  def transform(map, key, transformer) when is_binary(key) and is_map_key(map, key),
    do: Map.update!(map, key, transformer)

  def transform(map, keys, transformer) when is_list(keys),
    do: Enum.reduce(keys, map, fn key, new_map -> transform(new_map, key, transformer) end)

  def transform(map, _, _),
    do: map
end
