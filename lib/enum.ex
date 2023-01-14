defmodule Moar.Enum do
  # @related [test](/test/enum_test.exs)

  @moduledoc "Enum-related functions."

  @doc "Like `Enum.at/3` but raises if `index` is out of bounds."
  @spec at!(Enum.t(), integer() | [integer()], any()) :: any()
  def at!(enum, index, default \\ nil) when is_integer(index) do
    if length(enum) < index + 1,
      do: raise("Out of range: index #{index} of enum with length #{length(enum)}: #{inspect(enum)}"),
      else: Enum.at(enum, index, default)
  end

  @doc "Removes nil elements from `enum`."
  @spec compact(Enum.t()) :: Enum.t()
  def compact(enum),
    do: enum |> Enum.reject(&is_nil(&1))

  @doc "Returns the first item of `enum`, or raises if it is empty."
  @spec first!(Enum.t()) :: any()
  def first!(enum),
    do: Enum.at(enum, 0) || raise("Expected enumerable to have at least one item")

  @doc """
  Returns true if the value is a map or a keyword list.

  This cannot be used as a guard because it uses `Keyword.keyword?` under the hood. Also, because of that,
  it might scan an entire list to see if it's a keyword list, so it might be expensive.
  """
  @spec is_map_or_keyword(any()) :: boolean()
  def is_map_or_keyword(value),
    do: is_map(value) || (is_list(value) && Keyword.keyword?(value))

  @doc "Sorts `enum` case-insensitively. Uses `Enum.sort_by/3` under the hood."
  @spec isort(Enum.t()) :: Enum.t()
  def isort(enum),
    do: enum |> isort_by(&to_string/1)

  @doc "Sorts `enum` case-insensitively by `mapper` function. Uses `Enum.sort_by/3` under the hood."
  @spec isort_by(Enum.t(), (any() -> any())) :: Enum.t()
  def isort_by(enum, mapper),
    do: enum |> Enum.sort_by(&(mapper.(&1) |> String.downcase()))

  @doc """
  Returns a list of elements at the given indices. If `:all` is given instead of a list of indices, the entire
  enum is returned.

  ```elixir
  iex> Moar.Enum.take_at(["A", "B", "C"], [0, 2])
  ["A", "C"]

  iex> Moar.Enum.take_at(["A", "B", "C"], :all)
  ["A", "B", "C"]
  ```
  """
  @spec take_at(Enum.t(), integer() | [integer()] | :all) :: any()
  def take_at(enum, :all), do: enum
  def take_at(enum, list) when is_list(list), do: Enum.map(list, &Enum.at(enum, &1))

  @doc """
  Returns `:tid` fields from `enumerable`.

  This unusual function exists because the authors of Moar use tids (test IDs) extensively in tests.
  """
  @spec tids(Enum.t()) :: list()
  def tids(enumerable),
    do: enumerable |> Enum.map(& &1.tid)
end
