defmodule Moar.Assertions do
  # @related [test](/test/assertions_test.exs)

  @moduledoc """
  ExUnit assertions.

  See also: [siiibo/assert_match](https://github.com/siiibo/assert_match) which is similar to this module's
  `assert_eq` function but with pattern matching.
  """

  import ExUnit.Assertions

  @inspect_opts [custom_options: [sort_maps: true]]

  @type assert_eq_opts() ::
          {:except, list()}
          | {:ignore_order, boolean()}
          | {:ignore_whitespace, :leading_and_trailing}
          | {:only, list()}
          | {:returning, any()}
          | {:whitespace, :squish | :trim}
          | {:within, number() | {number(), Moar.Duration.time_unit()}}

  @doc """
  Asserts that the `left` list or map contains all of the items in the `right` list or map,
  or contains the single `right` element if it's not a list or map. Returns `left` or raises `ExUnit.AssertionError`.

  ```elixir
  iex> assert_contains([1, 2, 3], [1, 3])
  [1, 2, 3]

  iex> assert_contains(%{a: 1, b: 2, c: 3}, %{a: 1, c: 3})
  %{a: 1, b: 2, c: 3}

  iex> assert_contains([1, 2, 3], 2)
  [1, 2, 3]
  ```
  """
  @spec assert_contains(map(), map()) :: map()
  @spec assert_contains(list(), list() | any()) :: list()
  def assert_contains(left, right) when is_map(left) and is_map(right) do
    case Enum.filter(right, &(&1 not in left)) do
      [] ->
        left

      missing ->
        raise ExUnit.AssertionError,
              "Expected #{inspect(left, @inspect_opts)} to contain #{inspect(Map.new(missing), @inspect_opts)}"
    end
  end

  def assert_contains(left, right) when is_list(left) and is_list(right) do
    case Enum.filter(right, &(&1 not in left)) do
      [] ->
        left

      missing ->
        raise ExUnit.AssertionError,
              "Expected #{inspect(left, @inspect_opts)} to contain #{inspect(missing, @inspect_opts)}"
    end
  end

  def assert_contains(left, right) when is_list(left) and not is_list(right) do
    assert_contains(left, [right])
  end

  @doc """
  Asserts that the `left` and `right` values are equal. It returns the `left` value unless the assertion fails,
  or unless the `:returning` option is used. As a special case, if the first argument is a string and the second
  is a Regex, the comparison is done with the `=~` operator instead of the `==` operator.

  _Style note: the authors prefer to use `assert` in most cases, using `assert_eq` only when the extra options
  are helpful or when they want to make assertions in a pipeline._

  ```elixir
  iex> import Moar.Assertions

  # prefer regular `assert` when `assert_eq` is not necessary
  iex> assert Map.put(%{a: 1}, :b, 2) == %{a: 1, b: 2}
  true

  # works nicely with pipes
  iex> %{a: 1} |> Map.put(:b, 2) |> assert_eq(%{a: 1, b: 2})
  %{a: 1, b: 2}

  # returns an arbitrary value instead of the left value
  iex> map = %{a: 1, b: 2}
  iex> map |> Map.get(:a) |> assert_eq(1, returning: map)
  %{a: 1, b: 2}

  # compares using a regex if `left` is a string and `right` is a Regex
  iex> assert_eq "the length is 10cm", ~r/.*length is \\d{2}cm/
  ```

  `left` and `right` can be transformed by passing in one or more functions (optionally using the `apply:` keyword).
  If `left` and `right` are lists, all their values can be transformed using the `map:` option.

  ```elixir
  iex> import Moar.Assertions

  # apply a function
  iex> assert_eq("hello", "heLLo", &String.downcase/1)
  "hello"

  # apply multiple functions (left to right)
  iex> assert_eq("hello", "heLLo", [&String.downcase/1, &String.reverse/1])
  "olleh"

  # apply a function explicitly
  iex> assert_eq("hello", "heLLo", apply: &String.downcase/1)
  "hello"

  # map all elements with a function
  iex> assert_eq(["a", "B"], ["A", "b"], map: &String.downcase/1)
  ["a", "b"]

  # combine apply and map (left to right)
  iex> assert_eq(["a", "B", "C"], ["A", "b", "Z"], apply: &Enum.drop(&1, -1), map: &String.downcase/1)
  ["a", "b"]
  ```

  If `left` and `right` are maps, `only: <list>` will only consider the given keys, and `except: <list>` will ignore
  certain keys.

  ```elixir
  iex> import Moar.Assertions

  # ignore one or more keys of a map
  iex> assert_eq(%{a: 1, b: 2, c: 3}, %{a: 1, b: 100, c: 3}, except: [:b])
  %{a: 1, b: 2, c: 3}

  # only assert on one or more keys of a map
  iex> assert_eq(%{a: 1, b: 2, c: 3}, %{a: 1, b: 100, c: 3}, only: [:a, :c])
  %{a: 1, b: 2, c: 3}
  ```

  If `left` and `right` are lists, their order can be ignored using `:ignore_order`.

  ```elixir
  iex> import Moar.Assertions

  # ignoring order when comparing lists
  iex> assert_eq(["a", "b"], ["b", "a"], :ignore_order)
  ["a", "b"]
  ```

  For inexact numerical assertions, `within: <delta>` works like `ExUnit.Assertions.assert_in_delta/4`, and
  for inexact date and datetime assertions, `within: {<delta>, <time-unit>}` asserts that `left` and `right`
  are within some duration of each other. See `Moar.Duration` for more about time units, and also see
  `Moar.Assertions.assert_recent/2`. If `left` and `right` are strings, they are parsed as ISO8601 dates.

  ```elixir
  iex> import Moar.Assertions

  # assert within a delta (this particular case could use ExUnit.Assertions.assert_in_delta/4).
  iex> assert_eq(4/28, 0.14, within: 0.01)
  0.14285714285714285

  # assert within a time delta
  iex> inserted_at = ~U[2022-01-02 03:00:00Z]
  iex> updated_at = ~U[2022-01-02 03:04:00Z]
  iex> assert_eq(inserted_at, updated_at, within: {10, :minute})
  ~U[2022-01-02 03:00:00Z]

  # assert within a time delta when inputs are time strings
  iex> inserted_at = "2022-01-02T03:00:00Z"
  iex> updated_at = "2022-01-02T03:04:00Z"
  iex> assert_eq(inserted_at, updated_at, within: {10, :minute})
  "2022-01-02T03:00:00Z"
  ```

  The following transformation shortcuts are supported:
  * `:downcase` - if `left` and `right` are strings, converts them to lowercase before comparing
  * `:sort` - the same as `:ignore_order`
  * `:squish` - if `left` and `right` are strings, trims the strings and replaces consecutive whitespace characters
    with a single space using `Moar.String.squish/1` before comparing
  * `:trim` - if `left` and `right` are strings, trims the strings using `String.trim/1` before comparing

  ```elixir
  iex> import Moar.Assertions

  iex> assert_eq("FOO bar", "foo bar", :downcase)
  "foo bar"

  iex> assert_eq(" FOO   bar  ", "foo bar", [:downcase, :squish])
  "foo bar"
  ```

  The following options are deprecated:
  * `ignore_order: <boolean>` - use `:ignore_order` instead of `ignore_order: true`
  * `ignore_whitespace: :leading_and_trailing` - use `:squish` or `:trim` instead
  * `whitespace: :squish` - use `:squish` instead
  * `whitespace: :trim` - use `:trim` instead
  """
  @spec assert_eq(left :: any(), right :: any(), opts :: [assert_eq_opts()]) :: any()
  def assert_eq(left, right, opts \\ []) do
    opts = List.wrap(opts)

    {left, right, opts} =
      {left, right, opts}
      |> validate_opts(:ignore_order, [true, false], :list)
      |> validate_opts(:ignore_whitespace, [:leading_and_trailing], :string)
      |> validate_opts(:whitespace, [:squish, :trim], :string)
      |> transform_if(:ignore_whitespace, :leading_and_trailing, &String.trim/1)
      |> transform_if(:whitespace, :trim, &String.trim/1)
      |> transform_if(:whitespace, :squish, &Moar.String.squish/1)
      |> transform_if(:ignore_order, true, &Enum.sort/1)
      |> apply_and_map()

    within = Moar.Opts.get(opts, :within)

    cond do
      within -> assert_within(left, right, within)
      is_binary(left) && match?(%Regex{}, right) -> assert_regex_match(left, right)
      Moar.Opts.get(opts, :except) || Moar.Opts.get(opts, :only) -> assert_filtered(left, right, opts)
      :else -> assert left == right
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

  @shortcuts %{
    downcase: &String.downcase/1,
    sort: &Enum.sort/1,
    squish: &Moar.String.squish/1,
    trim: &String.trim/1
  }
  @shortcut_keys Map.keys(@shortcuts)

  defp apply_and_map({left, right, opts}) do
    {left, right} =
      Enum.reduce(opts, {left, right}, fn
        fun, {l, r} when is_function(fun) or fun in @shortcut_keys ->
          {shortcut(fun).(l), shortcut(fun).(r)}

        {:apply, fun}, {l, r} when is_function(fun) or fun in @shortcut_keys ->
          {shortcut(fun).(l), shortcut(fun).(r)}

        {:map, fun}, {l, r} when is_map(l) and is_map(r) and (is_function(fun) or fun in @shortcut_keys) ->
          {Map.new(l, fn {k, v} -> {k, shortcut(fun).(v)} end), Map.new(r, fn {k, v} -> {k, shortcut(fun).(v)} end)}

        {:map, fun}, {l, r} when is_function(fun) or fun in @shortcut_keys ->
          {Enum.map(l, shortcut(fun)), Enum.map(r, shortcut(fun))}

        _, {l, r} ->
          {l, r}
      end)

    {left, right, opts}
  end

  defp shortcut(shortcut) when shortcut in @shortcut_keys, do: @shortcuts[shortcut]
  defp shortcut(fun) when is_function(fun), do: fun

  defp assert_filtered(left, right, opts) when is_map(left) and is_map(right) do
    except = Moar.Opts.get(opts, :except, :none)
    only = Moar.Opts.get(opts, :only, :all)
    {filtered_left, filtered_right} = filter_map(left, right, only, except)
    assert filtered_left == filtered_right
  end

  defp assert_regex_match(binary, regex) do
    if binary =~ regex do
      binary
    else
      flunk("""
        Expected string to match regex
        left (string): #{binary}
        right (regex): #{inspect(regex)}
      """)
    end
  end

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

  defp transform_if({left, right, opts}, key, value, transform_fun) do
    if Moar.Opts.get(opts, key) == value,
      do: {transform_fun.(left), transform_fun.(right), opts},
      else: {left, right, opts}
  end

  defp validate_opts({left, right, opts}, key, valid_values, type) do
    type_check_fun =
      case type do
        :list -> &is_list/1
        :string -> &is_binary/1
      end

    if value = Moar.Opts.get(opts, key) do
      if value in valid_values do
        if type_check_fun.(left) && type_check_fun.(right),
          do: {left, right, opts},
          else: raise("`#{inspect(key)}` can only be used on #{type}s")
      else
        raise("`#{inspect(key)}` must be one of: #{inspect(valid_values)}")
      end
    else
      {left, right, opts}
    end
  end
end
