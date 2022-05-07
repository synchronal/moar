defprotocol Moar.Difference do
  # @related [test](/test/difference_test.exs)

  @moduledoc """
  A protocol that defines `diff/2` for finding the difference between two terms.
  Includes implementations for `DateTime`, `NaiveDateTime`, and `BitString`.
  """

  @fallback_to_any true

  @doc """
  Returns the difference between `a` and `b`.
  The fallback implementation uses `Kernel.-/2` to subtract `b` from `a`.
  """
  @spec diff(any(), any()) :: any()
  def diff(a, b)
end

defimpl Moar.Difference, for: Any do
  def diff(a, b), do: a - b
end

defimpl Moar.Difference, for: DateTime do
  def diff(a, b), do: DateTime.diff(a, b, :microsecond)
end

defimpl Moar.Difference, for: NaiveDateTime do
  def diff(a, b), do: NaiveDateTime.diff(a, b, :microsecond)
end

defimpl Moar.Difference, for: BitString do
  def diff(a, b), do: DateTime.diff(Moar.DateTime.from_iso8601!(a), Moar.DateTime.from_iso8601!(b), :microsecond)
end
