defmodule Moar.Term do
  # @related [test](/test/term_test.exs)

  @moduledoc "Extra functions for terms."

  @doc "Returns true if the term is blank, nil, or empty"
  @spec blank?(any()) :: boolean()
  def blank?(nil), do: true
  def blank?(s) when is_binary(s), do: s |> String.trim() |> String.length() == 0
  def blank?([]), do: true
  def blank?(list) when is_list(list), do: false
  def blank?(m) when is_map(m), do: map_size(m) == 0
  def blank?(true), do: false
  def blank?(false), do: true
  def blank?(_), do: false

  @doc "Returns `value` unless it is blank, in which case it returns `default`"
  @spec or_default(any(), any()) :: any()
  def or_default(value, default), do: if(present?(value), do: value, else: default)

  @doc "Returns true if the term is not blank, nil, or empty"
  @spec present?(any()) :: boolean()
  def present?(term), do: !blank?(term)

  @doc "Returns the value if it is present (via `present?`), or else returns the default value"
  @spec presence(any(), any()) :: any()
  def presence(term, default \\ nil), do: if(present?(term), do: term, else: default)
end
