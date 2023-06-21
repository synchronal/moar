defmodule Moar.Version do
  # @related [test](/test/version_test.exs)

  @moduledoc "Version-related functions."

  @doc """
  Like `Version.compare/2` but first normalizes versions via `normalize/1`.

  ```
  iex> Elixir.Version.compare("1.2", "1.2.3")
  ** (Version.InvalidVersionError) invalid version: "1.2"

  iex> Moar.Version.compare("1.2", "1.2.3")
  :lt
  ```
  """
  @spec compare(binary(), binary()) :: :gt | :eq | :lt
  def compare(left, right),
    do: Version.compare(normalize(left), normalize(right))

  @doc """
  Adds major, minor, and patch versions if needed to create a string with major, minor, and patch numbers.
  Does not support versions that have anything other than numbers (like `1.2.3-beta4`).

  ```
  iex> Moar.Version.normalize("1.2")
  "1.2.0"
  ```
  """
  @spec normalize(binary()) :: binary()
  def normalize(version) do
    parts = version |> Moar.Term.presence("0.0.0") |> String.split(".") |> Enum.take(3)
    normalized = parts ++ List.duplicate("0", 3 - length(parts))
    Enum.join(normalized, ".")
  end
end
