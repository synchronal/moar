defmodule Moar.List do
  # @related [test](test/list_test.exs)

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
  to strings via `Kernel.to_string/1`.

  ```
  iex> Moar.List.to_sentence([])
  ""

  iex> Moar.List.to_sentence(["ant"])
  "ant"

  iex> Moar.List.to_sentence(["ant", "bat"])
  "ant and bat"

  iex> Moar.List.to_sentence(["ant", "bat", "cat"])
  "ant, bat, and cat"
  ```
  """
  @spec to_sentence([binary()]) :: binary()
  def to_sentence(list) do
    case list |> List.wrap() |> Enum.reject(&Moar.Term.blank?/1) do
      [] -> ""
      [only] -> only
      [first, second] -> [first, " and ", second]
      list -> list |> Enum.intersperse(", ") |> List.insert_at(-2, "and ")
    end
    |> to_string()
  end
end
