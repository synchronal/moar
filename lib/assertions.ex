defmodule Moar.Assertions do
  # @related [test](/test/assertions_test.exs)

  @moduledoc """
  ExUnit assertions.

  See also: [siiibo/assert_match](https://github.com/siiibo/assert_match) which is similar to this module's
  `assert_eq` function but with pattern matching.
  """

  import ExUnit.Assertions

  @type assert_eq_opts() ::
          {:except, list()}
          | {:ignore_order, boolean()}
          | {:ignore_whitespace, :leading_and_trailing}
          | {:only, list()}
          | {:returning, any()}
          | {:within, number() | {number(), Moar.Duration.time_unit()}}

  @doc """
  Asserts that the `left` list or map contains all of the items in the `right` list or map,
  or contains the single `right` element if it's not a list or map.

  ```elixir
  iex> assert_contains([1, 2, 3], [1, 3])
  [1, 2, 3]

  iex> assert_contains(%{a: 1, b: 2, c: 3}, %{a: 1, c: 3})
  %{a: 1, b: 2, c: 3}

  iex> assert_contains([1, 2, 3], 2)
  [1, 2, 3]
  """
  @spec assert_contains(map(), map()) :: map()
  @spec assert_contains(list(), list() | any()) :: list()
  def assert_contains(left, right) when is_map(left) and is_map(right) do
    case Enum.filter(right, &(&1 not in left)) do
      [] -> left
      missing -> raise ExUnit.AssertionError, "Expected #{inspect(left)} to contain #{inspect(Map.new(missing))}"
    end
  end

  def assert_contains(left, right) when is_list(left) and is_list(right) do
    case Enum.filter(right, &(&1 not in left)) do
      [] -> left
      missing -> raise ExUnit.AssertionError, "Expected #{inspect(left)} to contain #{inspect(missing)}"
    end
  end

  def assert_contains(left, right) when is_list(left) and not is_list(right) do
    assert_contains(left, [right])
  end

  @doc """
  Asserts that the `left` and `right` values are equal. Returns the `left` value unless the assertion fails,
  or unless the `:returning` option is used.

  Uses `assert left == right` under the hood, unless `left` is a string and
  `right` is a Regex, in which case they will be compared using the `=~` operator.

  _Style note: the authors prefer to use `assert` in most cases, using `assert_eq` only when the extra options
  are helpful or when they want to make assertions in a pipeline._

  Options:

  * `except: ~w[a b]a` - when comparing maps, remove these keys from each map if present.
  * `ignore_order: boolean` - if the `left` and `right` values are lists, ignores the order when checking equality.
  * `ignore_whitespace: :leading_and_trailing` - if the `left` and `right` values are strings, ignores leading and
    trailing space when checking equality.
  * `only: ~w[a b]a` - when comparing maps, filter each map to only these keys.
  * `returning: value` - returns `value` if the assertion passes, rather than returning the `left` value.
  * `within: delta` - asserts that the `left` and `right` values are within `delta` of each other.
  * `within: {delta, time_unit}` - like `within: delta` but performs time comparisons in the specified `time_unit`.
    See `Moar.Duration` for more about time units. If `left` and `right` are strings, they are parsed as ISO8601 dates.

  ## Examples

  ```elixir
  iex> import Moar.Assertions

  iex> %{a: 1} |> Map.put(:b, 2) |> assert_eq(%{a: 1, b: 2})
  %{a: 1, b: 2}

  iex> assert_eq([1, 2], [2, 1], ignore_order: true)
  [1, 2]

  iex> assert_eq("foo bar", "  foo bar\\n", ignore_whitespace: :leading_and_trailing)
  "foo bar"

  iex> map = %{a: 1, b: 2}
  iex> map |> Map.get(:a) |> assert_eq(1, returning: map)
  %{a: 1, b: 2}

  iex> assert_eq(4/28, 0.14, within: 0.01)
  0.14285714285714285

  iex> inserted_at = ~U[2022-01-02 03:00:00Z]
  iex> updated_at = ~U[2022-01-02 03:04:00Z]
  iex> assert_eq(inserted_at, updated_at, within: {10, :minute})
  ~U[2022-01-02 03:00:00Z]

  iex> inserted_at = "2022-01-02T03:00:00Z"
  iex> updated_at = "2022-01-02T03:04:00Z"
  iex> assert_eq(inserted_at, updated_at, within: {10, :minute})
  "2022-01-02T03:00:00Z"
  ```
  """
  @spec assert_eq(left :: any(), right :: any(), opts :: [assert_eq_opts()]) :: any()
  def assert_eq(left, right, opts \\ [])

  def assert_eq(left, right, opts) when is_list(left) and is_list(right) do
    {left, right} =
      if Keyword.get(opts, :ignore_order, false),
        do: {Enum.sort(left), Enum.sort(right)},
        else: {left, right}

    assert left == right
    returning(opts, left)
  end

  def assert_eq(string, %Regex{} = regex, opts) when is_binary(string) do
    unless string =~ regex do
      flunk("""
        Expected string to match regex
        left (string): #{string}
        right (regex): #{regex |> inspect}
      """)
    end

    returning(opts, string)
  end

  def assert_eq(left, right, opts) do
    cond do
      Keyword.has_key?(opts, :within) ->
        assert_within(left, right, Keyword.get(opts, :within))

      is_map(left) and is_map(right) ->
        {filtered_left, filtered_right} =
          filter_map(left, right, Keyword.get(opts, :only, :all), Keyword.get(opts, :except, :none))

        assert filtered_left == filtered_right

      Keyword.has_key?(opts, :ignore_whitespace) ->
        if !is_binary(left) || !is_binary(right),
          do: raise("assert_eq can only ignore whitespace when comparing strings")

        if Keyword.get(opts, :ignore_whitespace) != :leading_and_trailing,
          do: raise("if `:ignore_whitespace is used`, the value can only be `:leading_and_trailing`")

        assert String.trim(left) == String.trim(right)

      true ->
        assert left == right
    end

    returning(opts, left)
  end

  @doc """
  Asserts that `datetime` is within `recency` of now (in UTC), returning `datetime` if the assertion succeeeds.

  Uses `assert_eq(datetime, now, within: recency)` under the hood.

  * `datetime` can be a `DateTime`, a `NaiveDateTime`, or an ISO8601-formatted UTC datetime string.
  * `recency` is a `Moar.Duration` and defaults to `{10, :second}`.

  ```elixir
  iex> five_seconds_ago = Moar.DateTime.add(DateTime.utc_now(), {-5, :second})
  iex> assert_recent five_seconds_ago

  iex> twenty_seconds_ago = Moar.DateTime.add(DateTime.utc_now(), {-20, :second})
  iex> assert_recent twenty_seconds_ago, {25, :second}
  ```
  """
  @spec assert_recent(DateTime.t() | NaiveDateTime.t() | binary(), Moar.Duration.t()) ::
          DateTime.t() | NaiveDateTime.t() | binary()
  def assert_recent(datetime, recency \\ {10, :second})

  def assert_recent(%DateTime{} = datetime, recency),
    do: assert_eq(datetime, DateTime.utc_now(), within: recency)

  def assert_recent(%NaiveDateTime{} = datetime, recency),
    do: assert_eq(datetime, NaiveDateTime.utc_now(), within: recency)

  def assert_recent(datetime, recency) when is_binary(datetime),
    do: assert_eq(datetime, DateTime.utc_now() |> DateTime.to_iso8601(), within: recency)

  @doc """
  Asserts that a pre-condition and a post-condition are true after performing an action,
  returning the result of the action.

  To use an anonymous function as the action, wrap it in parentheses and call it with `.()`.

  ## Examples

  ```elixir
  iex> {:ok, agent} = Agent.start(fn -> 0 end)
  ...>
  iex> assert_that Agent.update(agent, fn s -> s + 1 end),
  ...>     changes: Agent.get(agent, fn s -> s end),
  ...>     from: 0,
  ...>     to: 1
  :ok
  ...>
  iex> assert_that Agent.update(agent, fn s -> s + 1 end),
  ...>     changes: Agent.get(agent, fn s -> s end),
  ...>     to: 2
  :ok
  ...>
  iex> assert_that (fn -> Agent.update(agent, fn s -> s + 1 end) end).(),
  ...>     changes: Agent.get(agent, fn s -> s end),
  ...>     to: 3
  :ok
  ```
  """
  @spec assert_that(any(), changes: any(), from: any(), to: any()) :: Macro.t()
  defmacro assert_that(command, changes: check, from: from, to: to) do
    quote do
      try do
        assert unquote(check) == unquote(from)
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Pre-condition failed"}, __STACKTRACE__
      end

      return_value = unquote(command)

      try do
        assert unquote(check) == unquote(to)
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Post-condition failed"}, __STACKTRACE__
      end

      return_value
    end
  end

  defmacro assert_that(command, changes: check, to: to) do
    quote location: :keep do
      pre_condition = unquote(check)
      return_value = unquote(command)
      post_condition = unquote(check)

      try do
        assert post_condition == unquote(to)
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Post-condition failed"}, __STACKTRACE__
      end

      try do
        assert post_condition != pre_condition
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Post-condition failed"}, __STACKTRACE__
      end

      return_value
    end
  end

  @doc """
  Refute that a condition is changed after performing an action, returning the result of the action.

  ## Examples

  ```elixir
  iex> {:ok, agent} = Agent.start(fn -> 0 end)
  ...>
  iex> refute_that Function.identity(1),
  ...>     changes: Agent.get(agent, fn s -> s end)
  1

  iex> refute_that Function.identity(5),
  ...>     changes: %{a: 1}
  5
  ```
  """
  @spec refute_that(any, [{:changes, any}]) :: Macro.t()
  defmacro refute_that(command, changes: check) do
    quote do
      before = unquote(check)
      return_value = unquote(command)
      later = unquote(check)

      assert before == later, """
      Post-condition failed
      before: #{inspect(before)}
      after: #{inspect(later)}
      """

      return_value
    end
  end

  # # #

  defp assert_within(left, right, {delta, unit}) do
    assert abs(Moar.Difference.diff(left, right)) <= Moar.Duration.convert({delta, unit}, :microsecond),
           ~s|Expected "#{left}" to be within #{Moar.Duration.to_string({delta, unit})} of "#{right}"|
  end

  defp assert_within(left, right, delta) do
    assert abs(Moar.Difference.diff(left, right)) <= delta,
           ~s|Expected "#{left}" to be within #{delta} of "#{right}"|
  end

  defp returning(opts, default) when is_list(opts),
    do: opts |> Keyword.get(:returning, default)

  defp filter_map(left, right, :all, :none), do: {left, right}
  defp filter_map(left, right, :right_keys, :none), do: filter_map(left, right, Map.keys(right), :none)
  defp filter_map(left, right, keys, :none) when is_list(keys), do: {Map.take(left, keys), Map.take(right, keys)}
  defp filter_map(left, right, :all, keys) when is_list(keys), do: {Map.drop(left, keys), Map.drop(right, keys)}
end
