defmodule Moar.NaiveDateTime do
  # @related [test](/test/naive_datetime_test.exs)

  @moduledoc """
  NaiveDateTime-related functions. See also `Moar.DateTime`.
  """

  @doc """
  Like `NaiveDateTime.add/2` but takes a `Moar.Duration`.

  See also `subtract/1` and `Moar.DateTime.add/2`.

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
  iex> start = ~N[2022-01-01T00:00:00]
  iex> Moar.NaiveDateTime.add(start, {3, :minute})
  ~N[2022-01-01T00:03:00]
  ```
  """
  @spec add(NaiveDateTime.t(), Moar.Duration.t()) :: NaiveDateTime.t()
  def add(date_time, duration),
    do: NaiveDateTime.add(date_time, Moar.Duration.convert(duration, :millisecond), :millisecond)

  @doc """
  Like `NaiveDateTime.from_iso8601/1` but raises if the string cannot be parsed.

  ```elixir
  iex> Moar.NaiveDateTime.from_iso8601!("2022-01-01T00:00:00")
  ~N[2022-01-01T00:00:00]

  iex> Moar.NaiveDateTime.from_iso8601!("2022-01-01T00:00:00+0800")
  ~N[2022-01-01T00:00:00]

  iex> Moar.NaiveDateTime.from_iso8601!("Next Thursday after lunch")
  ** (ArgumentError) Invalid ISO8601 format: "Next Thursday after lunch"
  ```
  """
  @spec from_iso8601!(date_time_string :: String.t()) :: NaiveDateTime.t()
  def from_iso8601!(date_time_string) when is_binary(date_time_string) do
    case NaiveDateTime.from_iso8601(date_time_string) do
      {:ok, date_time} ->
        date_time

      {:error, :invalid_format} ->
        raise ArgumentError, ~s|Invalid ISO8601 format: "#{date_time_string}"|
    end
  end

  @doc """
  Subtracts `duration` from `date_time`.

  See also `add/1` and `Moar.DateTime.subtract/2`.

  > #### Note {: .info}
  >
  > This function is naive and intentionally doesn't account for real-world calendars and all of their complexity,
  > such as leap years, leap days, daylight saving time, past and future calendar oddities, etc.
  >
  > As ["Falsehoods programmers believe about time"](https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca)
  > says, "If you think you understand everything about time, you're probably doing it wrong."
  >
  > See [`Cldr.Calendar.minus/4`](https://hexdocs.pm/ex_cldr_calendars/Cldr.Calendar.html#minus/4) for one example
  > of a function that is far more likely to be correct.

  ```elixir
  iex> start = ~N[2022-01-01T00:03:00]
  iex> Moar.NaiveDateTime.subtract(start, {3, :minute})
  ~N[2022-01-01T00:00:00]
  ```
  """
  @spec subtract(NaiveDateTime.t(), Moar.Duration.t()) :: NaiveDateTime.t()
  def subtract(date_time, {time, unit} = _duration),
    do: NaiveDateTime.add(date_time, Moar.Duration.convert({-1 * time, unit}, :millisecond), :millisecond)

  @doc """
  Like `NaiveDateTime.to_iso8601/1` but rounds to the nearest second first.

  ```elixir
  iex> Moar.NaiveDateTime.to_iso8601_rounded(~N[2022-01-01T01:02:03.456789])
  "2022-01-01T01:02:03"
  ```
  """
  @spec to_iso8601_rounded(date_time :: NaiveDateTime.t()) :: String.t()
  def to_iso8601_rounded(date), do: date |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601()

  @doc """
  Returns the current UTC time plus or minus the given duration.

  ```elixir
  iex> Moar.NaiveDateTime.utc_now(minus: {10, :second})
  ...> |> Moar.Duration.format([:approx, :ago])
  "10 seconds ago"
  ```
  """
  @spec utc_now([plus: Moar.Duration.t()] | [minus: Moar.Duration.t()]) :: NaiveDateTime.t()
  def utc_now(plus: duration), do: NaiveDateTime.utc_now() |> add(duration)
  def utc_now(minus: duration), do: NaiveDateTime.utc_now() |> subtract(duration)
end
