defmodule Moar.AssertionsTest do
  # @related [subject](/lib/assertions.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Assertions

  describe "assert_contains" do
    test "passes when one enum contains another enum or scalar" do
      [1, 2, 3] |> assert_contains([1, 2, 3])
      [1, 2, 3] |> assert_contains([1, 3])
      [1, 2, 3] |> assert_contains(3)

      %{a: 1, b: 2, c: 3} |> assert_contains(%{a: 1, b: 2, c: 3})
      %{a: 1, b: 2, c: 3} |> assert_contains(%{a: 1, c: 3})
    end

    test "fails when one enum doesn't contain the other enum or scalar" do
      assert_raise ExUnit.AssertionError,
                   "\n\nExpected [1, 2, 3] to contain [4, 5, 6]\n",
                   fn -> [1, 2, 3] |> assert_contains([4, 5, 6]) end

      assert_raise ExUnit.AssertionError,
                   "\n\nExpected [1, 2, 3] to contain [4]\n",
                   fn -> [1, 2, 3] |> assert_contains([1, 2, 4]) end

      assert_raise ExUnit.AssertionError,
                   "\n\nExpected %{a: 1, b: 2, c: 3} to contain %{d: 4, e: 5}\n",
                   fn -> %{a: 1, b: 2, c: 3} |> assert_contains(%{b: 2, d: 4, e: 5}) end
    end
  end

  describe "assert_eq" do
    test "returns its first arg if the assertion passes" do
      assert assert_eq("arg", "arg") == "arg"
    end

    test "can optionally return something else, to make piping more fun" do
      assert assert_eq("arg", "arg", returning: "something else") == "something else"
    end

    # # # assert_eq: apply & map

    test "accepts one or more `:apply` functions to transform scalars" do
      assert_eq("foo", "FOO", apply: &String.downcase/1)
      assert_eq(" foo   ", "    FOO ", apply: &String.downcase/1, apply: &String.trim/1)
    end

    test "`:apply` keyword can be omitted" do
      assert_eq("foo", "FOO", &String.downcase/1)
      assert_eq(" foo   ", "    FOO ", [&String.downcase/1, &String.trim/1])
    end

    test "`:apply` keyword can be omitted when shortcuts are used" do
      assert_eq("foo", "FOO", :downcase)
      assert_eq(" foo   ", "    FOO ", [:downcase, :trim])
    end

    test "accepts one or more `:map` functions to transform enums" do
      assert_eq(["foo", "bar"], ["FOO", "bAr"], map: &String.downcase/1)
      assert_eq([" foo   ", " bar   "], ["    FOO ", "BaR   "], map: &String.downcase/1, map: &String.trim/1)

      assert_eq(%{a: " foo   ", b: " bar   "}, %{a: "    FOO ", b: "BaR   "},
        map: &String.downcase/1,
        map: &String.trim/1
      )

      assert_eq([" foo   ", " bar   "], ["BaR   ", "    FOO "],
        map: &String.downcase/1,
        map: &String.trim/1,
        apply: &Enum.sort/1
      )
    end

    test "shortcuts can be used for certain functions" do
      assert_eq("foo", "FOO", apply: :downcase)
      assert_eq(["foo"], ["FOO"], map: :downcase)
      assert_eq("foo bar", " foo    bar ", apply: :squish)
      assert_eq(["foo bar"], [" foo   bar "], map: :squish)
      assert_eq(:foo_bar, "foo_bar", apply: :to_string)
      assert_eq([:foo_bar], ["foo_bar"], map: :to_string)
      assert_eq("foo", " foo ", apply: :trim)
      assert_eq(["foo"], [" foo "], map: :trim)
    end

    test "shortcuts can be mixed with longcuts" do
      assert_eq("foo bar", "  FoO  BAr  ", apply: :downcase, apply: &Moar.String.squish/1)
      assert_eq("foo bar", "  FoO  BAr  ", [:downcase, apply: &Moar.String.squish/1])
    end

    # # # assert_eq: datetime

    test "when the arguments are DateTimes" do
      assert_eq(~U[2020-01-01T00:00:00Z], ~U[2020-01-01T00:00:00Z])
      assert_raise ExUnit.AssertionError, fn -> assert_eq(~U[2020-01-01T00:00:00Z], ~U[2020-01-02T00:00:00Z]) end
    end

    test "when the arguments are DateTimes, and the `within: {delta, unit}` option is given, it succeeds when the datetimes are within the delta" do
      assert_eq(~U[2020-01-01T00:00:00Z], ~U[2020-01-01T00:01:59Z], within: {2, :minute})

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(~U[2020-01-01T00:00:00Z], ~U[2020-01-02T00:02:01Z], within: {2, :minute})
      end
    end

    test "when the arguments are NaiveDateTimes, and the `within: {delta, unit}` option is given, it succeeds when the datetimes are within the delta" do
      assert_eq(~N[2020-01-01T00:00:00Z], ~N[2020-01-01T00:01:59Z], within: {2, :minute})

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(~N[2020-01-01T00:00:00Z], ~N[2020-01-02T00:02:01Z], within: {2, :minute})
      end
    end

    test "when the arguments are strings, and the `within: {delta, unit}` option is given, it converts from ISO8601 and succeeds when the datetimes are within the delta" do
      assert_eq("2020-01-01T00:00:00Z", "2020-01-01T00:01:59Z", within: {2, :minute})

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq("2020-01-01T00:00:00Z", "2020-01-02T00:02:01Z", within: {2, :minute})
      end
    end

    # # # assert_eq: ignoring order

    test "when the arguments are lists, and the `ignore_order: true` option is not given, it fails if the lists are not in the same order" do
      assert_raise ExUnit.AssertionError, fn -> assert_eq([1, 2, 3], [3, 2, 1]) end
      assert_raise ExUnit.AssertionError, fn -> assert_eq([1, 2, 3], [3, 2, 1], ignore_order: false) end
    end

    test "when the arguments are lists, the `ignore_order: true` option compares without respect to order" do
      assert_eq([1, 2, 3], [3, 2, 1], ignore_order: true)
    end

    test "when the arguments are not lists, :ignore_order is not allowed" do
      assert_raise RuntimeError, "`:ignore_order` can only be used on lists", fn ->
        assert_eq(1, 1, ignore_order: true)
      end
    end

    test ":ignore_order by itself is the same as ignore_order: true" do
      assert_eq([1, 2, 3], [3, 2, 1], :ignore_order)
    end

    # # # assert_eq: only and except

    test "when the arguments are maps, and no options are given, performs a regular map equality test" do
      assert_eq(%{a: 1, b: 2}, %{b: 2, a: 1})
      assert_raise ExUnit.AssertionError, fn -> assert_eq(%{a: 9, b: 9}, %{b: 2, a: 1}) end
    end

    test "when the arguments are maps, the `only` option compares only the desired keys" do
      left = %{desired: 1, random: 123}
      right = %{desired: 1, random: 2_039_420_423}
      assert_eq(left, right, only: [:desired])
    end

    test "when the arguments are maps, the `except` option ignores undesired keys" do
      left = %{desired: 1, random: 123}
      right = %{desired: 1, random: 2_039_420_423}
      assert_eq(left, right, except: [:random])
    end

    test "when the arguments are maps, the `only: :right_keys` option compares only keys found in the right map" do
      left = %{desired: 1, desired_2: 2, random: 123}
      right = %{desired: 1, desired_2: 2}

      assert_eq(left, right, only: :right_keys)
      assert_eq(left, right, only: :right_keys)
      assert_eq(Range.new(1, 5), %{first: 1}, only: :right_keys)
    end

    test "when the arguments are maps, returns the full left argument even if only some parts were used for the assertion" do
      left = %{desired: 1, random: 123}
      right = %{desired: 1, random: 2_039_420_423}
      assert assert_eq(left, right, only: [:desired]) == left
    end

    # # # assert_eq: regex

    test "when the first argument is a string and the second is a regex, it performs a regex match" do
      assert_eq("foo", ~r/foo/)
      assert_raise ExUnit.AssertionError, fn -> assert_eq("foo", ~r/bar/) end
    end

    # # # assert_eq: within

    test "when the `within` option is given, equality does not have to be exact" do
      assert_eq(1.1, 1.08, within: 0.1)

      assert_raise ExUnit.AssertionError,
                   ~s|\n\nExpected "1.1" to be within 0.01 of "1.08"\n|,
                   fn -> assert_eq(1.1, 1.08, within: 0.01) end
    end

    # # # assert_eq: whitespace

    test "when the args are strings, the `whitespace` option accepts `:squish`" do
      assert_eq(" foo bar", "foo bar    ", whitespace: :squish)
      assert_eq(" foo bar", "foo     bar    ", whitespace: :squish)

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(" foo bar", "foo zzz    ", whitespace: :squish)
      end
    end

    test "when the args are strings, the `whitespace` option accepts `:trim`" do
      assert_eq(" foo bar", "foo bar    ", whitespace: :trim)

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(" foo bar", "foo     bar    ", whitespace: :trim)
      end

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(" foo bar", "foo zzz    ", whitespace: :trim)
      end
    end

    # # # assert_eq: deprecated functions

    test "(deprecated) when the args are strings, the `ignore_whitespace` option accepts `:leading_and_trailing`" do
      assert_eq(" foo bar", "foo bar    ", ignore_whitespace: :leading_and_trailing)

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(" foo bar", "foo     bar    ", ignore_whitespace: :leading_and_trailing)
      end

      assert_raise ExUnit.AssertionError, fn ->
        assert_eq(" foo bar", "foo zzz    ", ignore_whitespace: :leading_and_trailing)
      end
    end

    test "(deprecated) when the arguments are not strings, the `ignore_whitespace` option is not allowed" do
      assert_raise RuntimeError,
                   "`:ignore_whitespace` can only be used on strings",
                   fn -> assert_eq(0, 0, ignore_whitespace: :leading_and_trailing) end
    end

    test "(deprecated) no other value is allowed for `ignore_whitespace`" do
      assert_raise RuntimeError,
                   "`:ignore_whitespace` must be one of: [:leading_and_trailing]",
                   fn -> assert_eq("a", "a", ignore_whitespace: :pie) end
    end
  end

  describe "assert_recent" do
    test "passes when given a datetime that's less than 10 seconds in the past" do
      assert_recent Moar.DateTime.add(DateTime.utc_now(), {-5, :second})
    end

    test "passes when given a datetime that's less than 10 seconds into the future" do
      assert_recent Moar.DateTime.add(DateTime.utc_now(), {5, :second})
    end

    test "fails when given a datetime that's more than 10 seconds in the past" do
      assert_raise ExUnit.AssertionError, fn -> assert_recent(Moar.DateTime.add(DateTime.utc_now(), {-12, :second})) end
    end

    test "fails when given a datetime that's more than 10 seconds into the future" do
      assert_raise ExUnit.AssertionError, fn -> assert_recent(Moar.DateTime.add(DateTime.utc_now(), {12, :second})) end
    end

    test "accepts a DateTime" do
      assert_recent Moar.DateTime.add(DateTime.utc_now(), {-5, :second})
    end

    test "accepts a NaiveDateTime" do
      assert_recent Moar.NaiveDateTime.add(NaiveDateTime.utc_now(), {-5, :second})
    end

    test "accepts an ISO8601-formatted UTC datetime string" do
      assert_recent Moar.DateTime.add(DateTime.utc_now(), {-5, :second}) |> DateTime.to_iso8601()
    end

    test "accepts a custom recency value" do
      assert_recent Moar.DateTime.add(DateTime.utc_now(), {30, :second}), {40, :second}
    end

    test "returns the first argument" do
      datetime = Moar.DateTime.add(DateTime.utc_now(), {-5, :second})
      assert assert_recent(datetime) == datetime
    end
  end

  describe "assert_that" do
    test "is happy when the experiment works as expected" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_that Agent.update(agent, fn s -> s + 1 end),
        changes: Agent.get(agent, fn s -> s end),
        from: 0,
        to: 1
    end

    test "accepts a zero-arity function as the command (first parameter)" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_that (fn -> Agent.update(agent, fn s -> s + 1 end) end).(),
        changes: Agent.get(agent, fn s -> s end),
        from: 0,
        to: 1
    end

    test "flunks when the precondition is not fulfilled" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_raise ExUnit.AssertionError,
                   """


                   Pre-condition failed
                   code:  assert Agent.get(agent, fn s -> s end) == 9
                   left:  0
                   right: 9
                   """,
                   fn ->
                     assert_that Agent.update(agent, fn s -> s + 1 end),
                       changes: Agent.get(agent, fn s -> s end),
                       from: 9,
                       to: 1
                   end
    end

    test "flunks when the postcondition is not fulfilled" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_raise ExUnit.AssertionError,
                   """


                   Post-condition failed
                   code:  assert Agent.get(agent, fn s -> s end) == 2
                   left:  1
                   right: 2
                   """,
                   fn ->
                     assert_that Agent.update(agent, fn s -> s + 1 end),
                       changes: Agent.get(agent, fn s -> s end),
                       from: 0,
                       to: 2
                   end
    end

    test "passes without :from if something changed" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_that Agent.update(agent, fn s -> s + 1 end),
        changes: Agent.get(agent, fn s -> s end),
        to: 1
    end

    test "flunks without :from when nothing changes" do
      assert_raise ExUnit.AssertionError,
                   """


                   Post-condition failed
                   code: assert post_condition != pre_condition
                   left: 1
                   """,
                   fn ->
                     assert_that :ok,
                       changes: 1,
                       to: 1
                   end
    end
  end

  describe "refute_that" do
    test "passes when the action does not change the test condition" do
      {:ok, agent} = Agent.start(fn -> 0 end)
      return_value = refute_that(Function.identity(1), changes: Agent.get(agent, fn s -> s end))
      assert return_value == 1
    end

    # ExUnit in Elixir 1.16 changes the whitespace in assert errors.
    @tag :only_latest
    test "fails when the action changes the test condition" do
      {:ok, agent} = Agent.start(fn -> 0 end)

      assert_raise ExUnit.AssertionError,
                   """


                   Post-condition failed
                        before: 0
                        after: 1

                   """,
                   fn ->
                     refute_that(Agent.update(agent, fn s -> s + 1 end), changes: Agent.get(agent, fn s -> s end))
                   end
    end
  end
end
