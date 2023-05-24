defmodule Moar.Integer do
  # @related [test](/test/integer_test.exs)

  @moduledoc "Integer-related functions."

  @doc """
  Compares two integers, returning `:lt`, `:eq`, or `:gt`.

  ```
  iex> Moar.Integer.compare(1, 3)
  :lt

  iex> Moar.Integer.compare(1, -3)
  :gt

  iex> Moar.Integer.compare(-1, -1)
  :eq

  iex> Enum.sort([5, 6, 0, -1], Moar.Integer)
  [-1, 0, 5, 6]
  ```
  """
  @spec compare(integer(), integer()) :: :lt | :eg | :gt
  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left > right -> :gt
      left < right -> :lt
      true -> :eq
    end
  end
end
