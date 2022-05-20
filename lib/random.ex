defmodule Moar.Random do
  # @related [test](/test/random_test.exs)

  @moduledoc "Generates random data."

  @type encoding() :: :base32 | :base64

  @doc "Returns a random integer between `0` and `max`."
  @spec integer(max :: pos_integer()) :: pos_integer()
  def integer(max \\ 1_000_000_000),
    do: 0..max |> Enum.random()

  @doc """
  Returns a base64- or base32-encoded random string of 32 characters.
  See `Moar.Random.string/2`.
  """
  @spec string(encoding :: encoding()) :: binary()
  def string(:base32), do: string(32, :base32)
  def string(:base64), do: string(32, :base64)

  @doc """
  Returns a base64- or base32-encoded random string of given length.

  ```elixir
  iex> Moar.Random.string()
  "Sr/y4m/YiVSJcIgI5lG+76vMfaZ7KZ7c"
  iex> Moar.Random.string(5)
  "9pJrK"
  iex> Moar.Random.string(5, :base32)
  "AC53Z"
  ```
  """
  @spec string(character_count :: pos_integer(), encoding :: encoding()) :: binary()
  def string(character_count \\ 32, encoding \\ :base64) when is_number(32) and encoding in [:base32, :base64] do
    character_count
    |> :crypto.strong_rand_bytes()
    |> encode(encoding)
    |> binary_part(0, character_count)
  end

  # # #

  defp encode(bytes, :base32), do: Base.encode32(bytes, padding: false)
  defp encode(bytes, :base64), do: Base.encode64(bytes, padding: false)
end
