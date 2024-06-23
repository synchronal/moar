defmodule Moar.Random do
  # @related [test](/test/random_test.exs)

  @moduledoc "Generates random data."

  @type encoding() :: :base32 | :base64

  @doc """
  Returns a string that starts with `prefix` (defaults to "id") followed by a dash, followed by 10 random lowercase
  letters and numbers, like `foo-ag49cl29zd` or `id-ag49cl29zd`.
  """
  @spec dom_id(String.t()) :: String.t()
  def dom_id(prefix \\ "id"),
    do: "#{prefix}-#{string(10, :base32)}" |> String.downcase()

  @doc "Return a random float greater than or equal to `min` and less than `max`"
  @spec float(number(), number()) :: float()
  def float(min, max) when max > min,
    do: min + :rand.uniform() * (max - min)

  @doc """
  Randomly increases or decreases `number` by a random amount up to `percent` of `number`.
  For example, `Etc.Random.fuzz(100, 0.2)` could return a number as low as 80.0 or as high as 120.0.

  ```elixir
  iex> n = Etc.Random.fuzz(100, 0.2)
  iex> n <= 120 && n >= 80
  true
  iex> n > 120 || n <= 80
  false
  ```
  """
  @spec fuzz(number(), number()) :: number()
  def fuzz(number, percent) when is_number(number) and is_number(percent) and percent >= 0 and percent <= 1,
    do: number * (1.0 - Moar.Random.float(-percent, percent))

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
