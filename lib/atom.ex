defmodule Moar.Atom do
  # @related [test](/test/atom_test.exs)

  @moduledoc "Atom-related functions"

  @doc """
  When given a string, converts it to an atom via `String.to_atom/1`. When given an atom, returns it unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom and want an atom.
  """
  @spec from_string(atom() | binary()) :: atom()
  def from_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into an atom")
  def from_string(s) when is_binary(s), do: String.to_atom(s)
  def from_string(a) when is_atom(a), do: a

  @doc """
  When given an atom, converts it to a string via `Atom.to_string/1`. When given a string, returns it unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom and want a string.
  """
  @spec to_string(atom() | binary()) :: binary()
  def to_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into a string")
  def to_string(a) when is_atom(a), do: Atom.to_string(a)
  def to_string(s) when is_binary(s), do: s
end
