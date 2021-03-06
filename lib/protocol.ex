defmodule Moar.Protocol do
  # @related [test](/test/protocol_test.exs)

  @moduledoc "Protocol-related functions."

  @doc """
  Returns `x` or raises if `x` does not implment `protocol`.

  ```elixir
  iex> Moar.Protocol.implements!(~D[2000-01-02], String.Chars)
  ~D[2000-01-02]
  ```
  """
  @spec implements!(any(), module()) :: any()
  def implements!(x, protocol) do
    if implements?(x, protocol),
      do: x,
      else: raise("Expected #{inspect(x)} to implement protocol #{inspect(protocol)}")
  end

  @doc """
  Returns true if `x` implements `protocol`.

  ```elixir
  iex> Moar.Protocol.implements?(~D[2000-01-02], String.Chars)
  true
  ```
  """
  @spec implements?(any(), module()) :: boolean()
  def implements?(x, protocol), do: protocol.impl_for(x) != nil
end
