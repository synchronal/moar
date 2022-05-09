defmodule Moar.Term do
  # @related [test](/test/term_test.exs)

  @moduledoc """
  Blank/present functions for terms.

  A term is considered present when it is not blank.

  A term is considered blank when:

  * it is `nil`
  * it is `false`
  * it is a string, and its length after being trimmed is 0
  * it is an empty list
  * it is an empty map
  """

  @doc """
  Returns true if the term is blank, nil, or empty.

  ```elixir
  iex> Moar.Term.blank?(nil)
  true

  iex> Moar.Term.blank?("   ")
  true

  iex> Moar.Term.blank?([])
  true

  iex> Moar.Term.blank?(%{})
  true
  ```
  """
  @spec blank?(any()) :: boolean()
  def blank?(nil), do: true
  def blank?(s) when is_binary(s), do: s |> String.trim() |> String.length() == 0
  def blank?([]), do: true
  def blank?(list) when is_list(list), do: false
  def blank?(m) when is_map(m), do: map_size(m) == 0
  def blank?(true), do: false
  def blank?(false), do: true
  def blank?(_), do: false

  @doc """
  Returns `value` unless it is blank, in which case it returns `default`.

  ```elixir
  iex> Moar.Term.or_default(%{}, %{color: :blue})
  %{color: :blue}
  ```
  """
  @spec or_default(any(), any()) :: any()
  def or_default(value, default), do: if(present?(value), do: value, else: default)

  @doc """
  Returns true if the term is not blank, nil, or empty.

  ```elixir
  iex> Moar.Term.present?(1)
  true

  iex> Moar.Term.present?([1])
  true

  iex> Moar.Term.present?(%{a: 1})
  true

  iex> Moar.Term.present?("1")
  true
  ```
  """
  @spec present?(any()) :: boolean()
  def present?(term), do: !blank?(term)

  @doc """
  Returns the value if it is present (via `present?`), or else returns the default value.

  ```elixir
  iex> Moar.Term.presence(20, 100)
  20

  iex> Moar.Term.presence(nil, 100)
  100
  ```
  """
  @spec presence(any(), any()) :: any()
  def presence(term, default \\ nil), do: if(present?(term), do: term, else: default)
end
