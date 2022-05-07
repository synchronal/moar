defmodule Moar.Assertions do
  # @related [test](/test/assertions_test.exs)

  @moduledoc "Some ExUnit assertions"

  import ExUnit.Assertions

  @type assert_eq_opts() ::
          {:ignore_order, boolean()} | {:returning, any()} | {:within, number() | {number(), Moar.Duration.time_unit()}}

  @doc """
  Asserts that the `left` and `right` values are equal. Returns the `left` value unless the assertion fails,
  or if the `:returning` option is used. Uses `assert left == right` under the hood, but works nicely in a pipeline.

  Options:

  * `ignore_order: boolean` - if the `left` and `right` values are lists, ignores the order when checking equality.
  * `returning: value` - returns `value` if the assertion passes, rather than returning the `left` value.
  * `within: delta` - asserts that the `left` and `right` values are within `delta` of each other rather than strictly equal.
  * `within: {delta, time_unit}` - like `within: delta` but performs time comparisons in the specified `time_unit`.
    If `left` and `right` are strings, they are parsed as ISO8601 dates.
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

      true ->
        assert left == right
    end

    returning(opts, left)
  end

  @doc """
  Asserts that a pre-condition and a post-condition are true after performing an action.

  ## Examples

  ```
  {:ok, agent} = Agent.start(fn -> 0 end)

  assert_that(Agent.update(agent, fn s -> s + 1 end),
    changes: Agent.get(agent, fn s -> s end),
    from: 0,
    to: 1
  )
  ```
  """
  @spec assert_that(any, [{:changes, any} | {:from, any} | {:to, any}, ...]) :: {:__block__, [], [...]}
  defmacro assert_that(command, changes: check, from: from, to: to) do
    quote do
      try do
        assert unquote(check) == unquote(from)
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Pre-condition failed"}, __STACKTRACE__
      end

      unquote(command)

      try do
        assert unquote(check) == unquote(to)
      rescue
        error in ExUnit.AssertionError ->
          reraise %{error | message: "Post-condition failed"}, __STACKTRACE__
      end
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
