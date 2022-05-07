defmodule Moar.DateTime do
  # @related [test](/test/datetime_test.exs)

  @moduledoc "DateTime-related functions"

  @doc """
  Like `DateTime.from_iso8601/1` but raises if the string cannot be parsed.
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
  """
  @spec to_iso8601_rounded(date_time :: DateTime.t()) :: String.t()
  def to_iso8601_rounded(date), do: date |> DateTime.truncate(:second) |> DateTime.to_iso8601()
end
