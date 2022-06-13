defmodule Moar.DateTime do
  # @related [test](/test/datetime_test.exs)

  @moduledoc """
  DateTime-related functions. See also `Moar.NaiveDateTime`.
  """

  @doc """
  Like `DateTime.add/2` but takes a `Moar.Duration`.

  See also `Moar.NaiveDateTime.add/2`.

  > #### Note {: .info}
  >
  > This function is naive and intentionally doesn't account for real-world calendars and all of their complexity,
  > such as leap years, leap days, daylight saving time, past and future calendar oddities, etc.
  >
  > As ["Falsehoods programmers believe about time"](https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca)
  > says, "If you think you understand everything about time, you're probably doing it wrong."
  >
  > See [`Cldr.Calendar.plus/2`](https://hexdocs.pm/ex_cldr_calendars/Cldr.Calendar.html#plus/2) for one example
  > of a function that is far more likely to be correct.

  ```elixir
  iex> start = ~U[2022-01-01T00:00:00Z]
  iex> Moar.DateTime.add(start, {3, :minute})
  ~U[2022-01-01T00:03:00Z]
  ```
  """
  @spec add(DateTime.t(), Moar.Duration.t()) :: DateTime.t()
  def add(date_time, duration),
    do: DateTime.add(date_time, Moar.Duration.convert(duration, :millisecond), :millisecond)

  @doc """
  Like `DateTime.from_iso8601/1` but raises if the string cannot be parsed.

  ```elixir
  iex> Moar.DateTime.from_iso8601!("2022-01-01T00:00:00Z")
  ~U[2022-01-01T00:00:00Z]

  iex> Moar.DateTime.from_iso8601!("2022-01-01T00:00:00+0800")
  ** (ArgumentError) Expected \"2022-01-01T00:00:00+0800\" to have a UTC offset of 0, but was: 28800

  iex> Moar.DateTime.from_iso8601!("Next Thursday after lunch")
  ** (ArgumentError) Invalid ISO8601 format: "Next Thursday after lunch"
  ```
  """
  @spec from_iso8601!(date_time_string :: String.t()) :: DateTime.t()
  def from_iso8601!(date_time_string) when is_binary(date_time_string) do
    case DateTime.from_iso8601(date_time_string) do
      {:ok, date_time, 0} ->
        date_time

      {:ok, _date_time, other_offset} ->
        raise ArgumentError, ~s|Expected "#{date_time_string}" to have a UTC offset of 0, but was: #{other_offset}|

      {:error, :invalid_format} ->
        raise ArgumentError, ~s|Invalid ISO8601 format: "#{date_time_string}"|
    end
  end

  @doc """
  Like `DateTime.to_iso8601/1` but rounds to the nearest second first.

  ```elixir
  iex> Moar.DateTime.to_iso8601_rounded(~U[2022-01-01T01:02:03.456789Z])
  "2022-01-01T01:02:03Z"
  ```
  """
  @spec to_iso8601_rounded(date_time :: DateTime.t()) :: String.t()
  def to_iso8601_rounded(date), do: date |> DateTime.truncate(:second) |> DateTime.to_iso8601()
end
