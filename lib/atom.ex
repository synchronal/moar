defmodule Moar.Atom do
  # @related [test](/test/atom_test.exs)

  @moduledoc "Atom-related functions."

  @doc """
  Converts a string to an atom (via `String.to_atom/1`), and returns atoms unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom.
  """
  @spec from_string(atom() | binary()) :: atom()
  def from_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into an atom")
  def from_string(s) when is_binary(s), do: String.to_atom(s)
  def from_string(a) when is_atom(a), do: a

  @doc """
  Converts an atom to a string (via `Atom.to_string/1`), and returns strings unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom.
  """
  @spec to_string(atom() | binary()) :: binary()
  def to_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into a string")
  def to_string(a) when is_atom(a), do: Atom.to_string(a)
  def to_string(s) when is_binary(s), do: s
end
