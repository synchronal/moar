defmodule Moar.Duration do
  # @related [test](/test/duration_test.exs)

  @moduledoc """
  A duration is a `{time, unit}` tuple, where the time is a number and the unit is one of:
  `:nanosecond`, `:microsecond`, `:millisecond`, `:second`, `:minute`, `:hour`, `:day`
  """

  @seconds_per_minute 60
  @seconds_per_hour 60 * 60
  @seconds_per_day 60 * 60 * 24

  @type duration() :: {time :: number(), unit :: time_unit()}
  @type time_unit() :: :nanosecond | :microsecond | :millisecond | :second | :minute | :hour | :day

  @doc """
  Converts a `{duration, time_unit}` tuple into a numeric duration. Rounds down to the nearest whole number.
  Uses `System.convert_time_unit/3` under the hood; see its documentation for more details.

  ## Examples

  ```elixir
  iex> Moar.Duration.convert({121, :second}, :minute)
  2
  ```
  """
  @spec convert(from :: duration(), to :: time_unit()) :: number()
  def convert({time, :minute} = _duration, to_unit), do: convert({time * @seconds_per_minute, :second}, to_unit)
  def convert({time, :hour} = _duration, to_unit), do: convert({time * @seconds_per_hour, :second}, to_unit)
  def convert({time, :day} = _duration, to_unit), do: convert({time * @seconds_per_day, :second}, to_unit)

  def convert({_time, _from_unit} = duration, :minute),
    do: convert(duration, :second) |> Integer.floor_div(@seconds_per_minute)

  def convert({_time, _from_unit} = duration, :hour),
    do: convert(duration, :second) |> Integer.floor_div(@seconds_per_hour)

  def convert({_time, _from_unit} = duration, :day),
    do: convert(duration, :second) |> Integer.floor_div(@seconds_per_day)

  def convert({time, from_unit} = _duration, to_unit), do: System.convert_time_unit(time, from_unit, to_unit)

  @doc """
  Converts a `{duration, time_unit}` tuple into a string.

  ## Examples

  ```elixir
  iex> Moar.Duration.to_string({1, :second})
  "1 second"

  iex> Moar.Duration.to_string({25, :millisecond})
  "25 milliseconds"
  ```
  """
  @spec to_string({duration :: duration(), unit :: time_unit()}) :: String.t()
  def to_string({1, unit}), do: "1 #{unit}"
  def to_string({-1, unit}), do: "-1 #{unit}"
  def to_string({time, unit}), do: "#{time} #{unit}s"
end
