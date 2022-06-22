defmodule Moar.Tuple do
  # @related [test](/test/tuple_test.exs)

  @moduledoc "Tuple-related functions."

  @doc """
  Converts a list of tuples to a single tuple whose first element is the first element of each tuple in
  the list (which must all be the same), and whose second element is a list containing the second elements
  of each tuple in the list.

  Raises if the list contains tuples whose first elements are not all the same.

  ```elixir
  iex> Moar.Tuple.from_list!([{:ok, :a}, {:ok, :b}])
  {:ok, [:a, :b]}

  iex> Moar.Tuple.from_list!([{:a, 1}, {:a, 2}, {:a, 3}])
  {:a, [1, 2, 3]}

  iex> Moar.Tuple.from_list!([{:a, 1}, {:b, 2}, {:a, 3}])
  ** (RuntimeError) Expected all items in the list to have have the same first element, but got: [:a, :b]
  ```
  """
  @spec from_list!([any()]) :: {any(), [any()]}
  def from_list!(list) do
    {keys, values} = Enum.unzip(list)

    case Enum.uniq(keys) do
      [key] -> {key, values}
      keys -> raise "Expected all items in the list to have have the same first element, but got: #{inspect(keys)}"
    end
  end

  @doc """
  Reduces a list of tuples to map where values are consolidated by the first element of each input tuple.

  ```elixir
  iex> Moar.Tuple.reduce([{:ok, 1}, {:ok, 2}])
  %{ok: [1, 2]}

  iex> Moar.Tuple.reduce([{:ok, 1}, {:ok, 2}, {:error, 3}, {:ok, 4}])
  %{ok: [1, 2, 4], error: [3]}
  ```
  """
  @spec reduce([any()]) :: map()
  def reduce(list) do
    Enum.reduce(list, %{}, fn {k, v}, acc ->
      Map.update(acc, k, [v], fn list -> [v | list] end)
    end)
    |> Map.new(fn {k, v} -> {k, Enum.reverse(v)} end)
  end
end
