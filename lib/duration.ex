defmodule Moar.Duration do
  # @related [test](/test/duration_test.exs)

  @moduledoc """
  A duration is a `{time, unit}` tuple.

  The time is a number and the unit is one of:
  `:nanosecond`, `:microsecond`, `:millisecond`, `:second`, `:minute`, `:hour`, `:day`.
  """

  @seconds_per_minute 60
  @seconds_per_hour 60 * 60
  @seconds_per_day 60 * 60 * 24

  @units_desc [day: "d", hour: "h", minute: "m", second: "s", millisecond: "ms", microsecond: "us", nanosecond: "ns"]
  @units_map Map.new(@units_desc)
  @units_names Keyword.keys(@units_desc)

  @type t() :: {time :: number(), unit :: time_unit()}
  @type time_unit() :: :nanosecond | :microsecond | :millisecond | :second | :minute | :hour | :day

  @doc """
  Converts a `{duration, time_unit}` tuple into a numeric duration, rounding down to the nearest whole number.

  Uses `System.convert_time_unit/3` under the hood; see its documentation for more details.

  ```elixir
  iex> Moar.Duration.convert({121, :second}, :minute)
  2
  ```
  """
  @spec convert(from :: t(), to :: time_unit()) :: number()
  def convert({time, :minute}, to_unit), do: convert({time * @seconds_per_minute, :second}, to_unit)
  def convert({time, :hour}, to_unit), do: convert({time * @seconds_per_hour, :second}, to_unit)
  def convert({time, :day}, to_unit), do: convert({time * @seconds_per_day, :second}, to_unit)
  def convert(duration, :minute), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_minute)
  def convert(duration, :hour), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_hour)
  def convert(duration, :day), do: convert(duration, :second) |> Integer.floor_div(@seconds_per_day)
  def convert({time, from_unit}, to_unit), do: System.convert_time_unit(time, from_unit, to_unit)

  @doc """
  Converts a `{duration, time_unit}` tuple into a compact string.

  ```elixir
  iex> Moar.Duration.to_short_string({1, :second})
  "1s"

  iex> Moar.Duration.to_short_string({25, :millisecond})
  "25ms"
  ```
  """
  @spec to_short_string({duration :: t(), unit :: time_unit()}) :: String.t()
  def to_short_string({1, unit}), do: "1#{@units_map[unit]}"
  def to_short_string({-1, unit}), do: "-1#{@units_map[unit]}"
  def to_short_string({time, unit}), do: "#{time}#{@units_map[unit]}"

  @doc """
  Converts a `{duration, time_unit}` tuple into a string.

  ```elixir
  iex> Moar.Duration.to_string({1, :second})
  "1 second"

  iex> Moar.Duration.to_string({25, :millisecond})
  "25 milliseconds"
  ```
  """
  @spec to_string({duration :: t(), unit :: time_unit()}) :: String.t()
  def to_string({1, unit}), do: "1 #{unit}"
  def to_string({-1, unit}), do: "-1 #{unit}"
  def to_string({time, unit}), do: "#{time} #{unit}s"

  @doc """
  Returns the list of duration unit names in descending order.
  """
  @spec units() :: [time_unit()]
  def units, do: @units_names
end
