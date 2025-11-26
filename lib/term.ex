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
  Returns true if the term is blank, nil, false, or empty.

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
  def blank?(s) when is_binary(s), do: s |> String.trim() == ""
  def blank?([]), do: true
  def blank?(list) when is_list(list), do: false
  def blank?(m) when is_map(m), do: map_size(m) == 0
  def blank?(true), do: false
  def blank?(false), do: true
  def blank?(_), do: false

  @doc """
  Like `blank?/1` but takes a keyword list containing `blank` and/or `present` keys that override the default behavior.

  ```elixir
  iex> Moar.Term.blank?("--")
  false

  iex> Moar.Term.blank?("--", blank: ["--"], present: [0, false])
  true
  ```
  """
  @spec blank?(any(), blank: [any()], present: [any()]) :: boolean()
  def blank?(value, config) do
    cond do
      value in Keyword.get(config, :blank, []) -> true
      value in Keyword.get(config, :present, []) -> false
      :else -> blank?(value)
    end
  end

  @doc """
  Returns true if the term is not blank, nil, false, or empty.

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
  Like `present?/1` but takes a keyword list containing `blank` and/or `present` keys that override the default behavior.

  ```elixir
  iex> Moar.Term.present?(false)
  false

  iex> Moar.Term.present?(false, blank: ["--"], present: [0, false])
  true
  ```
  """
  @spec present?(any(), keyword()) :: boolean()
  def present?(value, config) do
    cond do
      value in Keyword.get(config, :present, []) -> true
      value in Keyword.get(config, :blank, []) -> false
      :else -> present?(value)
    end
  end

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
  def presence(term, default \\ nil), do: when_present(term, term, default)

  @doc """
  Returns `present_value` when `term` is present (via `present?`), and `blank_value` when `term` is blank.
  If `present_value` and/or `blank_value` are functions, they are called with `term` as their argument.

  ```elixir
  iex> Moar.Term.when_present(20, "continue", "value missing")
  "continue"

  iex> Moar.Term.when_present(nil, "continue", "value missing")
  "value missing"

  iex> Moar.Term.when_present(20, fn value -> value * 2 end, "value missing")
  40

  iex> Moar.Term.when_present(nil, "continue", fn value -> "expected a number, got: \#{inspect(value)}" end)
  "expected a number, got: nil"
  ```
  """
  @spec when_present(any(), any(), any()) :: any()
  def when_present(term, present_value, blank_value) do
    value_fn = fn
      term, fun when is_function(fun) -> fun.(term)
      _term, value -> value
    end

    if present?(term),
      do: value_fn.(term, present_value),
      else: value_fn.(term, blank_value)
  end
end
