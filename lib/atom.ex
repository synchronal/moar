defmodule Moar.Atom do
  # @related [test](/test/atom_test.exs)

  @moduledoc "Atom-related functions."

  @doc """
  Given an atom, returns the atom. Given a string, converts it into an atom, converting non-alphanumeric characters
  into underscores (via `Moar.String.slug/2`).

  ## Examples

  ```
  iex> Moar.Atom.atomize(:my_atom)
  :my_atom

  iex> Moar.Atom.atomize("my-atom")
  :my_atom
  ```
  """
  @spec atomize(atom() | binary()) :: atom()
  def atomize(atom) when is_atom(atom), do: atom
  def atomize(binary) when is_binary(binary), do: binary |> Moar.String.slug("_") |> from_string()

  @doc """
  Given a list of strings, returns `:ok` if all values have a corresponding atom that already exists.
  Otherwise, it returns an error tuple with a list of strings that don't have corresponding atoms.

  Any atom included in the argument will be considered an existing atom.

  ## Examples

  ```
  iex> :existing_atom
  iex> Moar.Atom.ensure_existing_atoms(["existing_atom", :another_existing_atom])
  :ok

  iex> :existing_atom
  iex> Moar.Atom.ensure_existing_atoms(["existing_atom", :another_existing_atom, "some_nonexisting_atom"])
  {:error, ["some_nonexisting_atom"]}
  ```
  """
  @spec ensure_existing_atoms([atom() | binary()]) :: :ok | {:error, [binary()]}
  def ensure_existing_atoms(values) do
    missing_atoms = Enum.reject(values, &existing_atom?/1)

    if Enum.empty?(missing_atoms), do: :ok, else: {:error, missing_atoms}
  end

  @doc """
  Given a string, returns `true` if a corresponding atom has been previously defined. Otherwise, returns `false`.

  Given an atom, returns `true`.

  ## Examples

  ```
  iex> :existing_atom
  iex> Moar.Atom.existing_atom?("existing_atom")
  true

  iex> Moar.Atom.existing_atom?(:another_existing_atom)
  true

  iex> Moar.Atom.existing_atom?("some_nonexisting_atom")
  false
  ```
  """
  @spec existing_atom?(atom() | binary()) :: boolean()
  def existing_atom?(value) when is_atom(value), do: true

  def existing_atom?(value) do
    String.to_existing_atom(value) && true
  rescue
    _ -> false
  end

  @doc """
  Converts a string to an atom (via `String.to_atom/1`), and returns atoms unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom.

  ## Examples

  ```elixir
  iex> Moar.Atom.from_string("foo")
  :foo

  iex> Moar.Atom.from_string(:bar)
  :bar

  iex> Moar.Atom.from_string(nil)
  ** (ArgumentError) Unable to convert nil into an atom
  ```
  """
  @spec from_string(atom() | binary()) :: atom()
  def from_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into an atom")
  def from_string(s) when is_binary(s), do: String.to_atom(s)
  def from_string(a) when is_atom(a), do: a

  @doc """
  Converts an atom to a string (via `Atom.to_string/1`), and returns strings unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom.

  ## Examples

  ```elixir
  iex> Moar.Atom.to_string("foo")
  "foo"

  iex> Moar.Atom.to_string(:bar)
  "bar"

  iex> Moar.Atom.to_string(nil)
  ** (ArgumentError) Unable to convert nil into a string
  ```
  """
  @spec to_string(atom() | binary()) :: binary()
  def to_string(nil), do: raise(ArgumentError, message: "Unable to convert nil into a string")
  def to_string(a) when is_atom(a), do: Atom.to_string(a)
  def to_string(s) when is_binary(s), do: s

  @doc """
  Converts a string to an existing atom (via `String.to_existing_atom/1`), and returns atoms unchanged.

  Useful when you aren't sure ahead of time whether you have a string or an atom.

  ## Examples

  ```elixir
  iex> Moar.Atom.to_existing_atom("foo")
  :foo

  iex> assert_raise ArgumentError, fn ->
  ...>   Moar.Atom.to_existing_atom("sadfasfsfasf")
  ...> end

  iex> Moar.Atom.to_existing_atom(:baz)
  :baz

  iex> Moar.Atom.to_existing_atom(nil)
  nil
  ```
  """
  @spec to_existing_atom(atom() | binary()) :: atom()
  def to_existing_atom(a) when is_atom(a), do: a
  def to_existing_atom(s) when is_binary(s), do: String.to_existing_atom(s)
end
