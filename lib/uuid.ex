defmodule Moar.UUID do
  # @related [test](test/uuid_test.exs)

  @moduledoc "UUID-related functions"

  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  @doc "Returns a regex that will match a UUID"
  @spec regex() :: Regex.t()
  def regex, do: @uuid_regex

  @doc """
  Returns `true` if the argument is a valid UUID, or `false` if it is nil or an invalid UUID.

  ```elixir
  iex> Moar.UUID.valid?(nil)
  false

  iex> Moar.UUID.valid?("cows")
  false

  iex> Moar.UUID.valid?("a3357225-ed23-48b6-9ce5-10a580489b3f")
  true
  ```
  """
  @spec valid?(nil | binary()) :: boolean()
  def valid?(nil), do: false
  def valid?(uuid), do: Regex.match?(@uuid_regex, uuid)
end
