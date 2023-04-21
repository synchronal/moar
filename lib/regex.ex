defmodule Moar.Regex do
  # @related [test](/test/regex_test.exs)

  @moduledoc "Regex-related functions."

  @doc """
  Returns a single named capture. Can take the first two args in any order.

  ```
  iex> Moar.Regex.named_capture(~r/a(?<foo>b)c(?<bar>d)/, "abcd", "foo")
  "b"

  iex> Moar.Regex.named_capture("abcd", ~r/a(?<foo>b)c(?<bar>d)/, "foo")
  "b"
  ```
  """
  @spec named_capture(binary() | Regex.t(), binary() | Regex.t(), binary()) :: term()
  def named_capture(a, b, name),
    do: named_captures(a, b) |> Map.get(name)

  @doc """
  Like `Regex.named_captures/3` but can take the first two args in any order.

  ```
  iex> Moar.Regex.named_captures(~r/a(?<foo>b)c(?<bar>d)/, "abcd")
  %{"bar" => "d", "foo" => "b"}

  iex> Moar.Regex.named_captures("abcd", ~r/a(?<foo>b)c(?<bar>d)/)
  %{"bar" => "d", "foo" => "b"}
  ```
  """
  @spec named_captures(binary() | Regex.t(), binary() | Regex.t(), [term()]) :: map() | nil
  def named_captures(a, b, options \\ [])

  def named_captures(string, %Regex{} = regex, options) when is_binary(string),
    do: Regex.named_captures(regex, string, options)

  def named_captures(%Regex{} = regex, string, options) when is_binary(string),
    do: Regex.named_captures(regex, string, options)
end
