defmodule Moar.DateTime do
  # @related [test](/test/datetime_test.exs)

  @moduledoc """
  DateTime-related functions. See also `Moar.NaiveDateTime`.
  """

  @doc """
  Adds `duration` to `date_time`.

  See also `subtract/1` and `Moar.NaiveDateTime.add/2`.

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
  iex> start = ~U[2022-01-01T00:00:00.000Z]
  iex> Moar.DateTime.add(start, {3, :minute})
  ~U[2022-01-01T00:03:00.000Z]
  ```
  """
  @spec add(DateTime.t(), Moar.Duration.t()) :: DateTime.t()
  def add(date_time, duration),
    do: DateTime.add(date_time, Moar.Duration.convert(duration, :millisecond), :millisecond)

  @doc """
  Makes a `DateTime` at a particular `Time` today, optionally shifting by a `Duration`.

  ``` elixir
  iex> Moar.DateTime.at(~T[13:00:00])
  DateTime.new!(Date.utc_today(), ~T[13:00:00])

  iex> Moar.DateTime.at(~T[13:00:00], shift: [day: 2, hour: -3])
  DateTime.new!(Date.utc_today(), ~T[10:00:00]) |> DateTime.shift(day: 2)
  ```
  """
  @spec at(Time.t(), shift: Duration.t()) :: DateTime.t()
  def at(time, opts \\ []) do
    [shift: duration] = Keyword.validate!(opts, shift: nil)

    DateTime.new!(Date.utc_today(), time)
    |> Moar.Sugar.then_if(duration, &DateTime.shift(&1, duration))
  end

  @doc """
  Returns true if `date_time` is inclusively inside `range` which is a tuple containing a start datetime and an end
  datetime.

  ```elixir
  iex> Moar.DateTime.between?(~U[2022-01-01T02:00:00Z], {~U[2022-01-01T01:00:00Z], ~U[2022-01-01T03:00:00Z]})
  true

  iex> Moar.DateTime.between?(~U[2022-01-01T04:00:00Z], {~U[2022-01-01T01:00:00Z], ~U[2022-01-01T03:00:00Z]})
  false
  ```
  """
  @spec between?(DateTime.t(), {DateTime.t(), DateTime.t()}) :: boolean()
  def between?(date_time, {range_start, range_end} = _range),
    do: DateTime.compare(date_time, range_start) in [:eq, :gt] && DateTime.compare(date_time, range_end) in [:eq, :lt]

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
  Returns true if `date_time` is now or in the past and no older than `duration` ago (which defaults to 1 minute).
  Returns false if `date_time` is in the future.

  ```elixir
  iex> Moar.DateTime.recent?(Moar.DateTime.utc_now(minus: {30, :second}))
  true

  iex> Moar.DateTime.recent?(Moar.DateTime.utc_now(minus: {5, :minute}))
  false

  iex> Moar.DateTime.recent?(Moar.DateTime.utc_now(minus: {5, :minute}), {1, :hour})
  true

  iex> Moar.DateTime.recent?(Moar.DateTime.utc_now(plus: {5, :second}))
  false
  ```
  """
  @spec recent?(DateTime.t(), Moar.Duration.t() | nil) :: boolean()
  def recent?(date_time, duration \\ {1, :minute}) do
    case DateTime.diff(date_time, DateTime.utc_now(), :microsecond) do
      diff when diff > 0 -> false
      diff -> diff >= -1 * Moar.Duration.convert(duration, :microsecond)
    end
  end

  @doc """
  Subtracts `duration` from `date_time`.

  See also `add/1` and `Moar.NaiveDateTime.subtract/2`.

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
  iex> start = ~U[2022-01-01T00:03:00.000Z]
  iex> Moar.DateTime.subtract(start, {3, :minute})
  ~U[2022-01-01T00:00:00.000Z]
  ```
  """
  @spec subtract(DateTime.t(), Moar.Duration.t()) :: DateTime.t()
  def subtract(date_time, {time, unit} = _duration),
    do: DateTime.add(date_time, Moar.Duration.convert({-1 * time, unit}, :millisecond), :millisecond)

  @doc """
  Like `DateTime.to_iso8601/1` but rounds to the nearest second first.

  ```elixir
  iex> Moar.DateTime.to_iso8601_rounded(~U[2022-01-01T01:02:03.456789Z])
  "2022-01-01T01:02:03Z"
  ```
  """
  @spec to_iso8601_rounded(date_time :: DateTime.t()) :: String.t()
  def to_iso8601_rounded(date), do: date |> DateTime.truncate(:second) |> DateTime.to_iso8601()

  @doc """
  Returns the current UTC time plus or minus the given duration.

  ```elixir
  iex> Moar.DateTime.utc_now(plus: {10500, :millisecond})
  ...> |> Moar.Duration.format([:approx, :from_now])
  "10 seconds from now"

  iex> Moar.DateTime.utc_now(minus: {10, :second})
  ...> |> Moar.Duration.format([:approx, :ago])
  "10 seconds ago"
  ```
  """
  @spec utc_now([plus: Moar.Duration.t()] | [minus: Moar.Duration.t()]) :: DateTime.t()
  def utc_now(plus: duration), do: DateTime.utc_now() |> add(duration)
  def utc_now(minus: duration), do: DateTime.utc_now() |> subtract(duration)

  @doc """
  Returns true if `date_time` is no older than `duration` ago, and no later than `duration` from now.

  ```elixir
  iex> Moar.DateTime.within?(Moar.DateTime.utc_now(minus: {30, :second}), {1, :minute})
  true

  iex> Moar.DateTime.within?(Moar.DateTime.utc_now(plus: {30, :second}), {1, :minute})
  true

  iex> Moar.DateTime.within?(Moar.DateTime.utc_now(minus: {5, :minute}), {1, :minute})
  false

  iex> Moar.DateTime.within?(Moar.DateTime.utc_now(plus: {5, :minute}), {1, :minute})
  false
  ```
  """
  @spec within?(DateTime.t(), Moar.Duration.t() | nil) :: boolean()
  def within?(date_time, duration) do
    now = DateTime.utc_now()
    between?(date_time, {subtract(now, duration), add(now, duration)})
  end
end
