defmodule Moar.Duration.Unit do
  @moduledoc false
  require Record
  Record.defrecord(:unit, name: nil, long: nil, short: nil, conversion: nil)
end

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

  > #### Note {: .info}
  >
  > This module is naive and intentionally doesn't account for real-world calendars and all of their complexity,
  > such as leap years, leap days, daylight saving time, past and future calendar oddities, etc.
  >
  > As ["Falsehoods programmers believe about time"](https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca)
  > says, "If you think you understand everything about time, you're probably doing it wrong."
  >
  > See [`Cldr.Calendar.Duration`](https://hexdocs.pm/ex_cldr_calendars/Cldr.Calendar.Duration.html) for one example
  > of a full-featured library that is far more likely to be correct.
  """

  import Moar.Duration.Unit

  @approx_year unit(name: :approx_year, long: "year", short: "yr", conversion: {12, :approx_month})
  @approx_month unit(name: :approx_month, long: "month", short: "mo", conversion: {30, :day})
  @day unit(name: :day, long: "day", short: "d", conversion: {24, :hour})
  @hour unit(name: :hour, long: "hour", short: "h", conversion: {60, :minute})
  @minute unit(name: :minute, long: "minute", short: "m", conversion: {60, :second})
  @second unit(name: :second, long: "second", short: "s", conversion: {1000, :millisecond})
  @millisecond unit(name: :millisecond, long: "millisecond", short: "ms", conversion: {1000, :microsecond})
  @microsecond unit(name: :microsecond, long: "microsecond", short: "us", conversion: {1000, :nanosecond})
  @nanosecond unit(name: :nanosecond, long: "nanosecond", short: "ns", conversion: nil)

  @units_desc [@approx_year, @approx_month, @day, @hour, @minute, @second, @millisecond, @microsecond, @nanosecond]
  @unit_names_desc Enum.map(@units_desc, fn record -> unit(record, :name) end)
  @units_asc Enum.reverse(@units_desc)
  @unit_names_asc Enum.map(@units_asc, fn record -> unit(record, :name) end)
  @unit_map Map.new(@units_desc, fn record -> {unit(record, :name), record} end)

  # # #

  @type date_time_ish() :: DateTime.t() | NaiveDateTime.t() | binary()

  @type format_style() :: :long | :short

  @type format_transformer() :: :ago | :approx | :humanize
  @type format_transformers() :: format_transformer() | [format_transformer()]

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

  See also `from_now/1`.

  ```elixir
  iex> DateTime.utc_now()
  ...> |> Moar.DateTime.subtract({121, :minute})
  ...> |> Moar.Duration.ago()
  ...> |> Moar.Duration.shift(:minute)
  {121, :minute}
  ```
  """
  @spec ago(date_time_ish()) :: t()
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
  def approx(duration), do: approx(duration, @unit_names_desc)

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
  @spec between(date_time_ish(), date_time_ish()) :: t()
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
  def convert(from_duration, to_unit), do: shift(from_duration, to_unit) |> elem(0)

  @doc """
  Formats a duration in either a long or short style, with optional transformers and an optional suffix.

  * The first argument is a duration tuple, unless one of the transformers is `:ago`, in which case
    it can be a `DateTime`, `NaiveDateTime`, or an ISO8601-formatted string.
  * The second argument is optional and is the style, transformer, list of transformers, or suffix.
  * The third argument is optional and is the transformer, list of transformers, or suffix.
  * The fourth argument is optional and is the suffix.

  Styles:
    * `:long`, which formats like `"25 seconds"`.
    * `:short`, which formats like `"25s"`.
    * Defaults to `:long`
    
  Transformers:
    * `:ago` transforms via `ago/1`
    * `:approx` transforms via `approx/1`
    * `:humanize` transforms via `humanize/1`
    * If no transformers are specified, no transformations are applied.
    
  Suffix:
    * A string that will be appended to the formatted result.
    * If the `:ago` transformer is specified and a suffix is not specified, the suffix will default to `"ago"`.
      To use the "ago" transformer with no suffix, specify an empty string as the suffix (`nil` will not suffice).
    
  ```elixir
  iex> Moar.Duration.format({1, :second})
  "1 second"

  iex> Moar.Duration.format({120, :second})
  "120 seconds"

  iex> Moar.Duration.format({120, :second}, :long)
  "120 seconds"

  iex> Moar.Duration.format({120, :second}, :short)
  "120s"

  iex> Moar.Duration.format({120, :second}, "yonder")
  "120 seconds yonder"

  iex> Moar.Duration.format({120, :second}, :humanize)
  "2 minutes"

  iex> Moar.Duration.format({120, :second}, :humanize, "yonder")
  "2 minutes yonder"

  iex> Moar.Duration.format({310, :second})
  "310 seconds"

  iex> Moar.Duration.format({310, :second}, :approx)
  "5 minutes"

  iex> DateTime.utc_now()
  ...> |> Moar.DateTime.add({-310, :second})
  ...> |> Moar.Duration.format(:short, [:ago, :approx], "henceforth")
  "5m henceforth"
  ```
  """
  @format_styles [:long, :short]
  @spec format(
          t() | date_time_ish(),
          format_style() | format_transformers() | binary() | nil,
          format_transformers() | binary() | nil,
          binary() | nil
        ) :: binary()
  def format(duration_or_datetime, style_or_transformers_or_suffix \\ nil, transformers_or_suffix \\ nil, suffix \\ nil) do
    {style, transformers, suffix} =
      [style_or_transformers_or_suffix, transformers_or_suffix, suffix]
      |> Enum.reduce({nil, nil, nil}, fn
        style, acc when style in @format_styles ->
          put_elem(acc, 0, style)

        transformers, acc when is_list(transformers) or (is_atom(transformers) and not is_nil(transformers)) ->
          transformers = List.wrap(transformers) |> Enum.sort(fn a, _b -> a in [:ago, :from_now] end)
          acc = put_elem(acc, 1, transformers)

          cond do
            :ago in transformers -> put_elem(acc, 2, [" ", "ago"])
            :from_now in transformers -> put_elem(acc, 2, [" ", "from now"])
            true -> acc
          end

        "" = _suffix, acc ->
          put_elem(acc, 2, "")

        suffix, acc when is_binary(suffix) ->
          put_elem(acc, 2, [" ", suffix])

        nil, acc ->
          acc
      end)

    {time, unit} =
      transformers
      |> List.wrap()
      |> Enum.reduce(duration_or_datetime, fn
        :approx, acc -> approx(acc)
        :ago, {_time, _unit} = duration -> duration
        :ago, acc -> ago(acc)
        :from_now, {_time, _unit} = duration -> duration
        :from_now, acc -> from_now(acc)
        :humanize, acc -> humanize(acc)
        other, _acc -> raise "Unknown transformation: #{other}"
      end)

    unit_name =
      if style == :short,
        do: unit(@unit_map[unit], :short),
        else: [" ", Moar.String.pluralize(time, unit(@unit_map[unit], :long), &(&1 <> "s"))]

    [Kernel.to_string(time), unit_name, suffix] |> Moar.Enum.compact() |> Kernel.to_string()
  end

  @doc """
  Returns the duration between now and `datetime`, in the largest possible unit.

  `datetime` can be an ISO8601-formatted string, a `DateTime`, or a `NaiveDateTime`.

  See also `ago/1`.

  ```elixir
  iex> DateTime.utc_now()
  ...> |> Moar.DateTime.add({121, :minute})
  ...> |> Moar.Duration.from_now()
  ...> |> Moar.Duration.approx()
  {2, :hour}
  ```
  """
  @spec from_now(date_time_ish()) :: t()
  def from_now(datetime) when is_binary(datetime), do: datetime |> Moar.DateTime.from_iso8601!() |> from_now()
  def from_now(%module{} = datetime), do: between(module.utc_now(), datetime)

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
  def humanize(duration), do: humanize(duration, @unit_names_asc)

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
  def shift({_time, from_unit} = duration, to_unit) when from_unit == to_unit,
    do: duration

  def shift({_time, from_unit} = duration, to_unit) do
    from_index = Enum.find_index(@unit_names_desc, &(&1 == from_unit))
    to_index = Enum.find_index(@unit_names_desc, &(&1 == to_unit))

    if from_index < to_index,
      do: shift_down(duration) |> shift(to_unit),
      else: shift_up(duration) |> shift(to_unit)
  end

  @doc """
  Shifts `duration` to the next smaller unit. Raises if it's already at the smallest unit (nanosecond).

  ```elixir
  iex> Moar.Duration.shift_down({1, :hour})
  {60, :minute}
  ```
  """
  @spec shift_down(t()) :: t()
  def shift_down({time, from_unit} = duration) do
    case unit(@unit_map[from_unit], :conversion) do
      nil ->
        raise "Cannot shift #{inspect(duration)} to a smaller unit because #{from_unit} is the smallest supported unit."

      {conversion_multiplier, conversion_unit} ->
        {time * conversion_multiplier, conversion_unit}
    end
  end

  @doc """
  Shifts `duration` to the next larger unit. Raises if it's already at the largest unit (approx_year).
  Rounds the result towards zero.

  > #### Warning {: .warning}
  >
  > This function is lossy because it rounds down to the nearest whole number.

  ```elixir
  iex> Moar.Duration.shift_up({60, :minute})
  {1, :hour}

  iex> Moar.Duration.shift_up({125, :minute})
  {2, :hour}
  ```
  """
  def shift_up({time, from_unit} = duration) do
    from_index = Enum.find_index(@unit_names_desc, &(&1 == from_unit))

    if from_index == 0 do
      raise "Cannot shift #{inspect(duration)} to a larger unit because #{from_unit} is the largest supported unit."
    else
      higher_unit = Enum.at(@units_desc, from_index - 1)
      {conversion_multiplier, _conversion_unit} = unit(higher_unit, :conversion)
      {div(time, conversion_multiplier), unit(higher_unit, :name)}
    end
  end

  @doc """
  Shortcut to `format(duration, :long)`. See `format/4`.
  """
  @spec to_string(t()) :: String.t()
  def to_string(duration), do: format(duration, :long)
end
