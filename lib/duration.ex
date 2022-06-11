defmodule Moar.Duration do
  # @related [test](/test/duration_test.exs)

  @moduledoc """
  A duration is a `{time, unit}` tuple.

  The time is a number and the unit is one of:
  * `:nanosecond`
  * `:microsecond`
  * `:millisecond`
  * `:second`
  * `:minute`
  * `:hour`
  * `:day`
  * `:approx_month` (30 days)
  * `:approx_year` (360 days)
  """

  @seconds_per_minute 60
  @seconds_per_hour @seconds_per_minute * 60
  @seconds_per_day @seconds_per_hour * 24
  @seconds_per_approx_month @seconds_per_day * 30
  @seconds_per_approx_year @seconds_per_approx_month * 12

  @units_kw_desc [
    approx_year: {"yr", "year"},
    approx_month: {"mo", "month"},
    day: {"d", "day"},
    hour: {"h", "hour"},
    minute: {"m", "minute"},
    second: {"s", "second"},
    millisecond: {"ms", "millisecond"},
    microsecond: {"us", "microsecond"},
    nanosecond: {"ns", "nanosecond"}
  ]
  @units_desc Keyword.keys(@units_kw_desc)
  @units_asc @units_desc |> Enum.reverse()
  @units_to_short_names Map.new(@units_kw_desc, fn {unit, {short_name, _}} -> {unit, short_name} end)
  @units_to_names Map.new(@units_kw_desc, fn {unit, {_, name}} -> {unit, name} end)

  @type t() :: {time :: number(), unit :: time_unit()}
  @type time_unit() ::
          :nanosecond
          | :microsecond
          | :millisecond
          | :second
          | :minute
          | :hour
          | :day
          | :approx_month
          | :approx_year

  @doc """
  Returns the duration between `datetime` and now, in the largest possible unit.

  `datetime` can be an ISO8601-formatted string, a `DateTime`, or a `NaiveDateTime`.

  ```elixir
  iex> DateTime.utc_now() |> Moar.DateTime.add({-121, :minute}) |> Moar.Duration.ago() |> Moar.Duration.shift(:minute)
  {121, :minute}
  ```
  """
  @spec ago(DateTime.t() | NaiveDateTime.t() | binary()) :: t()
  def ago(datetime) when is_binary(datetime), do: datetime |> Moar.DateTime.from_iso8601!() |> ago()
  def ago(%module{} = datetime), do: between(datetime, module.utc_now())

  @doc """
  Shifts `duration` to an approximately equal duration that's simpler. For example, `{121, :second}` would get
  shifted to `{2, :minute}`.

  > #### Warning {: .warning}
  >
  > This function is lossy because it intentionally loses precision.

  If the time value of the duration is exactly 1, the duration is returned unchanged: `{1, :minute}` => `{1, :minute}`.
  Otherwise, the duration is shifted to the highest unit where the time value is >= 2.

  ```elixir
  iex> Moar.Duration.approx({1, :minute})
  {1, :minute}

  iex> Moar.Duration.approx({7300, :second})
  {2, :hour}
  ```
  """
  @spec approx(t()) :: t()
  def approx({1, _unit} = duration), do: duration
  def approx(duration), do: approx(duration, @units_desc)

  defp approx(duration, [head_unit | tail_units] = _units_desc) do
    new_duration = {new_time, _new_unit} = shift(duration, head_unit)

    if new_time >= 2 || tail_units == [],
      do: new_duration,
      else: approx(duration, tail_units)
  end

  @doc """
  Returns the duration between `earlier` and `later`, in the largest possible unit.

  `earlier` and `later` can be ISO8601-formatted strings, `DateTime`s, or `NaiveDateTime`s.

  ```elixir
  iex> earlier = ~U[2020-01-01T00:00:00.000000Z]
  iex> later = ~U[2020-01-01T02:01:00.000000Z]
  iex> Moar.Duration.between(earlier, later)
  {121, :minute}
  ```
  """
  @spec between(DateTime.t() | NaiveDateTime.t() | binary(), DateTime.t() | NaiveDateTime.t() | binary()) :: t()
  def between(earlier, later), do: {Moar.Difference.diff(later, earlier), :microsecond} |> humanize()

  @doc """
  Converts a `{duration, time_unit}` tuple into a numeric duration, rounding down to the nearest whole number.

  > #### Warning {: .warning}
  >
  > This function is lossy because it rounds down to the nearest whole number.

  Uses `System.convert_time_unit/3` under the hood; see its documentation for more details.

  It is similar to `shift/1` but this function returns an integer value, while `shift/1` returns a duration tuple.

  ```elixir
  iex> Moar.Duration.convert({121, :second}, :minute)
  2
  ```
  """
  @spec convert(from :: t(), to :: time_unit()) :: number()
  def convert({time, :minute}, to_unit), do: convert({time * @seconds_per_minute, :second}, to_unit)
  def convert({time, :hour}, to_unit), do: convert({time * @seconds_per_hour, :second}, to_unit)
  def convert({time, :day}, to_unit), do: convert({time * @seconds_per_day, :second}, to_unit)
  def convert({time, :approx_month}, to_unit), do: convert({time * @seconds_per_approx_month, :second}, to_unit)
  def convert({time, :approx_year}, to_unit), do: convert({time * @seconds_per_approx_year, :second}, to_unit)
  def convert(duration, :minute), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_minute)
  def convert(duration, :hour), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_hour)
  def convert(duration, :day), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_day)
  def convert(duration, :approx_month), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_approx_month)
  def convert(duration, :approx_year), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_approx_year)
  def convert({time, from_unit}, to_unit), do: System.convert_time_unit(time, from_unit, to_unit)

  @doc """
  Formats a duration. Supports `:long` or `:short` style.

  ```elixir
  iex> Moar.Duration.format({1, :second}, :long)
  "1 second"

  iex> Moar.Duration.format({25, :millisecond}, :long)
  "25 milliseconds"

  iex> Moar.Duration.format({1, :second}, :short)
  "1s"

  iex> Moar.Duration.format({25, :millisecond}, :short)
  "25ms"
  ```
  """
  @spec format(t(), :long | :short) :: binary()
  def format({1, unit}, :long), do: "1 #{unit_name(unit)}"
  def format({-1, unit}, :long), do: "-1 #{unit_name(unit)}"
  def format({time, unit}, :long), do: "#{time} #{unit_name(unit)}s"

  def format({1, unit}, :short), do: "1#{short_unit_name(unit)}"
  def format({-1, unit}, :short), do: "-1#{short_unit_name(unit)}"
  def format({time, unit}, :short), do: "#{time}#{short_unit_name(unit)}"

  def format(duration_or_datetime, style, opts) do
    opts = Moar.Opts.take(opts, [:suffix, transform: []])
    transformers = List.wrap(opts.transform)
    suffix = if !opts.suffix && :ago in transformers, do: "ago", else: opts.suffix

    formatted =
      Enum.reduce(transformers, duration_or_datetime, fn
        :approx, acc -> approx(acc)
        :ago, {_time, _unit} = duration -> duration
        :ago, acc -> ago(acc)
        :humanize, acc -> humanize(acc)
        other, _acc -> raise "Unknown transformation: #{other}"
      end)
      |> format(style)

    if suffix,
      do: [formatted, " ", suffix] |> Kernel.to_string(),
      else: formatted
  end

  @doc """
  If possible, shifts `duration` to a higher time unit that is more readable to a human. Returns `duration`
  unchanged if it cannot be exactly shifted.

  ```elixir
  iex> Moar.Duration.humanize({60000, :millisecond})
  {1, :minute}

  iex> Moar.Duration.humanize({48, :hour})
  {2, :day}

  iex> Moar.Duration.humanize({49, :hour})
  {49, :hour}
  ```
  """
  @spec humanize(t()) :: t()
  def humanize(duration), do: humanize(duration, @units_asc)

  defp humanize({_time, current_unit} = duration, [head_unit | remaining_units] = _units) do
    cond do
      Enum.empty?(remaining_units) ->
        duration

      current_unit == head_unit ->
        [next_unit | _] = remaining_units
        up = shift(duration, next_unit)
        down = shift(up, current_unit)

        if down == duration,
          do: humanize(up, remaining_units),
          else: humanize(duration, remaining_units)

      true ->
        humanize(duration, remaining_units)
    end
  end

  @doc """
  Shifts `duration` to `time_unit`. It is similar to `convert/1` but this function returns a duration tuple,
  while `convert/1` just returns an integer value.

  > #### Warning {: .warning}
  >
  > This function is lossy because it rounds down to the nearest whole number.

  ```elixir
  iex> Moar.Duration.shift({121, :second}, :minute)
  {2, :minute}
  ```
  """
  @spec shift(t(), time_unit()) :: t()
  def shift(duration, to_unit), do: {convert(duration, to_unit), to_unit}

  @doc """
  Shortcut to `format(duration, :long)`. See `format/2`.
  """
  @spec to_string(t()) :: String.t()
  def to_string(duration), do: format(duration, :long)

  @doc """
  Returns the list of duration unit names in descending order.
  """
  @spec units() :: [time_unit()]
  def units, do: @units_desc

  # # #

  defp short_unit_name(unit), do: @units_to_short_names[unit]
  defp unit_name(unit), do: @units_to_names[unit]
end
