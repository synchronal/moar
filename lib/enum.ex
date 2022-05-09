defmodule Moar.Enum do
  # @related [test](/test/enum_test.exs)

  @moduledoc "Enum-related functions."

  @doc "Like `Enum.at/2` but raises if `index` is out of bounds."
  @spec at!(Enum.t(), integer()) :: any()
  def at!(enum, index) do
    if length(enum) < index + 1,
      do: raise("Out of range: index #{index} of enum with length #{length(enum)}: #{inspect(enum)}"),
      else: Enum.at(enum, index)
  end

  @doc "Removes nil elements from `enum`."
  @spec compact(Enum.t()) :: Enum.t()
  def compact(enum),
    do: enum |> Enum.reject(&is_nil(&1))

  @doc "Returns the first item of `enum`, or raises if it is empty."
  @spec first!(Enum.t()) :: any()
  def first!(enum),
    do: Enum.at(enum, 0) || raise("Expected enumerable to have at least one item")

  @doc "Sorts `enum` case-insensitively. Uses `Enum.sort_by/3` under the hood."
  @spec isort(Enum.t()) :: Enum.t()
  def isort(enum),
    do: enum |> isort_by(&to_string/1)

  @doc "Sorts `enum` case-insensitively by `mapper` function. Uses `Enum.sort_by/3` under the hood."
  @spec isort_by(Enum.t(), (any() -> any())) :: Enum.t()
  def isort_by(enum, mapper),
    do: enum |> Enum.sort_by(&(mapper.(&1) |> String.downcase()))

  @doc "Returns `:tid` fields from `enumerable`."
  @spec tids(Enum.t()) :: list()
  def tids(enumerable),
    do: enumerable |> Enum.map(& &1.tid)
end
