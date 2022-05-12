defmodule Moar.Tuple do
  # @related [test](/test/tuple_test.exs)

  @doc """
  Converts a list of tuples to a single tuple where the first element is the first element of the first tuple,
  and the second element is a list of the second elements of each tuple.
  Raises if the first element in each tuple is not homogeneous.

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
end
