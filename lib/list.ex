defmodule Moar.List do
  # @related [test](test/list_test.exs)

  @doc """
  Returns a list containing the first `count` items of `list`. If `list` is too small, it is repeated
  until the requested size is acheived.

  ```elixir
  iex> Moar.List.fill([1, 2, 3], 2)
  [1, 2]

  iex> Moar.List.fill([1, 2, 3], 7)
  [1, 2, 3, 1, 2, 3, 1]
  ```
  """
  @spec fill(list(), non_neg_integer()) :: list()
  def fill(list, count),
    do: list |> Stream.cycle() |> Enum.take(count)

  @doc """
  Converts a list to a keyword list, setting the value to `default_value`. The list can be a regular list, a keyword
  list (which is a no-op), or a list that's a mix of terms and keywords (e.g., `[:a, :b, c: 3, d: 4]`). The default
  value can be a term or a function that accepts a key and is expected to return a value.

  ```
  iex> Moar.List.to_keyword([:a, :b, c: 3, d: 4])
  [a: nil, b: nil, c: 3, d: 4]

  iex> Moar.List.to_keyword([:a, :b, c: 3, d: 4], 1)
  [a: 1, b: 1, c: 3, d: 4]

  iex> Moar.List.to_keyword([:ant, :bird, cheetah: 7, dingo: 5], fn key -> key |> to_string() |> String.length() end)
  [ant: 3, bird: 4, cheetah: 7, dingo: 5]
  ```
  """
  @spec to_keyword(list(), (atom() -> term()) | term()) :: keyword()
  def to_keyword(list, default_value \\ nil) do
    if Keyword.keyword?(list) do
      list
    else
      Keyword.new(list, fn
        {key, value} ->
          {key, value}

        key ->
          if is_function(default_value),
            do: {key, default_value.(key)},
            else: {key, default_value}
      end)
    end
  end

  @doc """
  Converts a list to a comma-separated list that has "and" before the last item. The items in the list are converted
  to strings via a mapper function, which defaults to `Kernel.to_string/1`.

  ```
  iex> Moar.List.to_sentence([])
  ""

  iex> Moar.List.to_sentence(["ant"])
  "ant"

  iex> Moar.List.to_sentence(["ant", :bat])
  "ant and bat"

  iex> Moar.List.to_sentence(["ant", :bat, "cat"])
  "ant, bat, and cat"

  iex> Moar.List.to_sentence(["ant", "bat", "cat"], &String.upcase/1)
  "ANT, BAT, and CAT"
  ```
  """
  @spec to_sentence([any()], (any() -> binary())) :: binary()
  def to_sentence(list, mapper \\ &Kernel.to_string/1) do
    case list |> List.wrap() |> Enum.reject(&Moar.Term.blank?/1) |> Enum.map(mapper) do
      [] -> ""
      [only] -> only
      [first, second] -> [first, " and ", second]
      list -> list |> Enum.intersperse(", ") |> List.insert_at(-2, "and ")
    end
    |> to_string()
  end

  @doc """
  Returns the argument if it is not a list. If it is a list, returns the only item
  in the list, or raises if the list is empty or has more than one item.

  ```
  iex> Moar.List.unwrap!([5])
  5

  iex> Moar.List.unwrap!(5)
  5

  iex> Moar.List.unwrap!([])
  ** (FunctionClauseError) no function clause matching in Moar.List.unwrap!/1

  iex> Moar.List.unwrap!([5, 9])
  ** (FunctionClauseError) no function clause matching in Moar.List.unwrap!/1
  ```
  """
  @spec unwrap!(any() | [any()]) :: any()
  def unwrap!([term]), do: term
  def unwrap!(term) when not is_list(term), do: term
end
