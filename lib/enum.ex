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
    do: enum |> Enum.reject(&is_nil/1)

  @doc "Removes blank elements (as determined by `Moar.Term.blank?1`) from `enum`."
  @spec compact_blank(Enum.t()) :: Enum.t()
  def compact_blank(enum),
    do: enum |> Enum.reject(&Moar.Term.blank?/1)

  @doc """
  Returns the indices of `elements` in `enum`, using `fun` for comparisons (defaulting to `Kernel.==/2`)

  ```elixir
  iex> Moar.Enum.find_indices(~w[apple banana cherry], ~w[cherry apple])
  [2, 0]

  iex> Moar.Enum.find_indices(~w[apple banana cherry], ~w[CHERRY APPLE], fn a, b ->
  ...>   String.downcase(a) == String.downcase(b)
  ...> end)
  [2, 0]
  ```
  """
  @spec find_indices(Enum.t(), [any()], (any(), any() -> boolean())) :: [integer()]
  def find_indices(enum, elements, fun \\ &Kernel.==/2),
    do: Enum.map(elements, &Enum.find_index(enum, fn element -> fun.(element, &1) end))

  @doc """
  Returns the indices of `elements` in `enum`, raising if any member of `elements` is not found.

  ```elixir
  iex> Moar.Enum.find_indices!(~w[apple banana cherry], ~w[cherry apple])
  [2, 0]

  iex> Moar.Enum.find_indices!(~w[apple banana], ~w[cherry apple])
  ** (RuntimeError) Element "cherry" not present in:
  ["apple", "banana"]
  ```
  """
  @spec find_indices!(Enum.t(), [any()], (any(), any() -> boolean())) :: [integer()]
  def find_indices!(enum, elements, fun \\ &Kernel.==/2) do
    Enum.map(elements, fn element ->
      Enum.find_index(enum, fn member ->
        fun.(member, element)
      end) || raise("Element #{inspect(element)} not present in:\n#{inspect(enum)}")
    end)
  end

  @doc "Returns the first item of `enum`, or raises if it is empty."
  @spec first!(Enum.t()) :: any()
  def first!(enum),
    do: Enum.at(enum, 0) || raise("Expected enumerable to have at least one item")

  @doc """
  Converts an enum into a map of maps indexed by the return value of `index_fun`.
  See also the similar map-specific `Moar.Map.index_by/2`.

  ```elixir
  iex> Moar.Enum.index_by([%{name: "Alice", tid: "alice"}, %{name: "Billy", tid: "billy"}], & &1.tid)
  %{"alice" => %{name: "Alice", tid: "alice"}, "billy" => %{name: "Billy", tid: "billy"}}
  ```
  """
  @spec index_by(Enum.t(), (any() -> any())) :: map()
  def index_by(enum, index_fun) when is_function(index_fun),
    do: Enum.reduce(enum, %{}, fn value, acc -> Moar.Map.put_new!(acc, index_fun.(value), value) end)

  @doc "Like `Enum.into` but accepts `nil` as the first argument"
  @spec into!(nil | Enum.t(), Enum.t()) :: Enum.t()
  def into!(nil, enumerable), do: enumerable
  def into!(%_{} = struct, enumerable), do: struct |> Map.from_struct() |> into!(enumerable)
  def into!(other, enumerable), do: Enum.into(other, enumerable)

  @doc """
  Deprecated in favor of `map_or_keyword?/1`.
  """
  @spec is_map_or_keyword(any()) :: boolean()
  @deprecated "Use map_or_keyword?/1"
  def is_map_or_keyword(value),
    do: map_or_keyword?(value)

  @doc """
  Returns true if the value is a map or a keyword list. This uses standard Elixir functions for determining
  if a term is a map or a keyword, and therefore counts an empty list as a keyword list. See also
  `map_or_nonempty_keyword?/1`.

  This cannot be used as a guard because it uses `Keyword.keyword?` under the hood. Also, because of that,
  it might scan an entire list to see if it's a keyword list, so it might be expensive.
  """
  @spec map_or_keyword?(any()) :: boolean()
  def map_or_keyword?(value),
    do: (is_map(value) && !is_struct(value)) || (is_list(value) && Keyword.keyword?(value))

  @doc """
  Deprecated in favor of `map_or_nonempty_keyword?/1`.
  """
  @spec is_map_or_nonempty_keyword(any()) :: boolean()
  @deprecated "Use map_or_nonempty_keyword?/1"
  def is_map_or_nonempty_keyword(value),
    do: is_map(value) || (is_list(value) && !Enum.empty?(value) && Keyword.keyword?(value))

  @doc """
  Like `map_or_keyword?/1` but returns false if the term is an empty list.
  """
  @spec map_or_nonempty_keyword?(any()) :: boolean()
  def map_or_nonempty_keyword?(value),
    do: (is_map(value) && !is_struct(value)) || (is_list(value) && !Enum.empty?(value) && Keyword.keyword?(value))

  @doc "Sorts `enum` case-insensitively. Uses `Enum.sort_by/3` under the hood."
  @spec isort(Enum.t()) :: Enum.t()
  def isort(enum),
    do: enum |> isort_by(&to_string/1)

  @doc "Sorts `enum` case-insensitively by `mapper` function. Uses `Enum.sort_by/3` under the hood."
  @spec isort_by(Enum.t(), (any() -> any())) :: Enum.t()
  def isort_by(enum, mapper),
    do: enum |> Enum.sort_by(&(mapper.(&1) |> String.downcase()))

  @doc """
  Converts a list of lists to a list of maps with the given keys. The keys can be a list, or can be `:first_list`
  which uses the first list in `list_of_lists` as the keys and the remaining lists in `list_of_lists` as the values.

  ```elixir
  iex> Moar.Enum.lists_to_maps([[1, 2], [3, 4]], ["a", "b"])
  [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]

  iex> csv = [["a", "b"], [1, 2], [3, 4]]
  iex> [headers | rows] = csv
  iex> Moar.Enum.lists_to_maps(rows, headers)
  [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]

  iex> csv = [["a", "b"], [1, 2], [3, 4]]
  iex> Moar.Enum.lists_to_maps(csv, :first_list)
  [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]
  ```
  """
  @spec lists_to_maps(list(list(any())), list(any()) | :first_list) :: list(map())
  def lists_to_maps([first_list | remaining_lists], :first_list),
    do: lists_to_maps(remaining_lists, first_list)

  def lists_to_maps(list_of_lists, keys),
    do: Enum.map(list_of_lists, &Map.new(Enum.zip([keys, &1])))

  @doc """
  Returns a list of elements at the given indices, in the given order. If `:all` is given instead of a list of indices,
  the entire enum is returned.

  ```elixir
  iex> Moar.Enum.take_at(["A", "B", "C"], [0, 2])
  ["A", "C"]

  iex> Moar.Enum.take_at(["A", "B", "C"], [2, 0])
  ["C", "A"]

  iex> Moar.Enum.take_at(["A", "B", "C"], :all)
  ["A", "B", "C"]
  ```
  """
  @spec take_at(Enum.t(), integer() | [integer()] | :all) :: any()
  def take_at(enum, :all), do: enum
  def take_at(enum, list) when is_list(list), do: Enum.map(list, &Enum.at(enum, &1))

  @doc """
  Returns `:test_id` fields from `enumerable`.

  This unusual function exists because the authors of Moar use test_ids extensively in tests.
  See also `tids/2`.
  """
  @type test_ids_opts() :: {:sorted, boolean()}
  @spec test_ids(Enum.t(), [test_ids_opts()]) :: list()
  def test_ids(enumerable, opts \\ []) do
    test_ids = enumerable |> Enum.map(& &1.test_id)

    if Keyword.get(opts, :sorted),
      do: test_ids |> Enum.sort(),
      else: test_ids
  end

  @doc """
  Returns `:tid` fields from `enumerable`.

  This unusual function exists because the authors of Moar use tids (test IDs) extensively in tests.
  See also `test_ids/2`.
  """
  @type tids_opts() :: {:sorted, boolean()}
  @spec tids(Enum.t(), [tids_opts()]) :: list()
  def tids(enumerable, opts \\ []) do
    tids = enumerable |> Enum.map(& &1.tid)

    if Keyword.get(opts, :sorted),
      do: tids |> Enum.sort(),
      else: tids
  end
end
