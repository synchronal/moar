defmodule Moar.NaiveDateTime do
  # @related [test](/test/naive_datetime_test.exs)

  @moduledoc "NaiveDateTime-related functions."

  @doc """
  Like `NaiveDateTime.add` but takes a `Moar.Duration`.

  See also `Moar.DateTime`.

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
  Like `NaiveDateTime.to_iso8601/1` but rounds to the nearest second first.

  ```elixir
  iex> Moar.NaiveDateTime.to_iso8601_rounded(~N[2022-01-01T01:02:03.456789])
  "2022-01-01T01:02:03"
  ```
  """
  @spec to_iso8601_rounded(date_time :: NaiveDateTime.t()) :: String.t()
  def to_iso8601_rounded(date), do: date |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601()
end
