defmodule Moar.DurationTest do
  # @related [subject](/lib/duration.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Duration

  describe "ago" do
    test "returns the duration between a DateTime and now, in the largest possible unit" do
      earlier = Moar.DateTime.add(DateTime.utc_now(), {-121, :minute})
      assert Moar.Duration.ago(earlier) |> Moar.Duration.shift(:minute) == {121, :minute}
    end

    test "works with NaiveDateTimes" do
      earlier = Moar.NaiveDateTime.add(NaiveDateTime.utc_now(), {-121, :minute})
      assert Moar.Duration.ago(earlier) |> Moar.Duration.shift(:minute) == {121, :minute}
    end

    test "works with ISO 8601 strings" do
      earlier = Moar.DateTime.add(DateTime.utc_now(), {-121, :minute}) |> DateTime.to_iso8601()
      assert Moar.Duration.ago(earlier) |> Moar.Duration.shift(:minute) == {121, :minute}
    end
  end

  describe "approx" do
    test "when the time is exactly 1, the duration is unchanged" do
      assert Moar.Duration.approx({1, :second}) == {1, :second}
      assert Moar.Duration.approx({1, :hour}) == {1, :hour}
    end

    test "shifts to a higher unit when the higher unit's time value would be >= 2" do
      assert Moar.Duration.approx({10, :second}) == {10, :second}
      assert Moar.Duration.approx({119, :second}) == {119, :second}
      assert Moar.Duration.approx({120, :second}) == {2, :minute}
      assert Moar.Duration.approx({121, :second}) == {2, :minute}
      assert Moar.Duration.approx({2, :minute}) == {2, :minute}
      assert Moar.Duration.approx({119, :minute}) == {119, :minute}
      assert Moar.Duration.approx({120, :minute}) == {2, :hour}
      assert Moar.Duration.approx({2, :hour}) == {2, :hour}
      assert Moar.Duration.approx({47, :hour}) == {47, :hour}
      assert Moar.Duration.approx({48, :hour}) == {2, :day}
      assert Moar.Duration.approx({2, :day}) == {2, :day}
      assert Moar.Duration.approx({45, :day}) == {45, :day}
      assert Moar.Duration.approx({59, :day}) == {59, :day}
    end
  end

  describe "between" do
    test "returns the duration between two dates, in the largest possible unit" do
      earlier = ~U[2020-01-01T00:00:00.000000Z]
      later = ~U[2020-01-01T02:01:00.000000Z]

      assert Moar.Duration.between(earlier, later) == {121, :minute}
    end

    test "works with NaiveDateTimes" do
      earlier = ~N[2020-01-01T00:00:00.000000Z]
      later = ~N[2020-01-01T02:01:00.000000Z]

      assert Moar.Duration.between(earlier, later) == {121, :minute}
    end

    test "works with ISO 8601 strings" do
      earlier = "2020-01-01T00:00:00.000000Z"
      later = "2020-01-01T02:01:00.000000Z"

      assert Moar.Duration.between(earlier, later) == {121, :minute}
    end
  end

  describe "convert" do
    test "converts a duration to a value in a different time unit" do
      assert Moar.Duration.convert({1, :second}, :millisecond) == 1000
      assert Moar.Duration.convert({23, :second}, :millisecond) == 23_000
      assert Moar.Duration.convert({1001, :millisecond}, :second) == 1
      assert Moar.Duration.convert({121, :second}, :minute) == 2
      assert Moar.Duration.convert({121, :minute}, :hour) == 2
      assert Moar.Duration.convert({49, :hour}, :day) == 2
    end
  end

  describe "humanize" do
    test "increases the unit if possible" do
      assert Moar.Duration.humanize({1000, :nanosecond}) == {1, :microsecond}
      assert Moar.Duration.humanize({1000, :microsecond}) == {1, :millisecond}
      assert Moar.Duration.humanize({1000, :millisecond}) == {1, :second}
      assert Moar.Duration.humanize({60, :second}) == {1, :minute}
      assert Moar.Duration.humanize({60, :minute}) == {1, :hour}
      assert Moar.Duration.humanize({24, :hour}) == {1, :day}
    end

    test "can increase the unit more than one step" do
      ns_in_day = Moar.Duration.convert({1, :day}, :nanosecond)
      assert Moar.Duration.humanize({ns_in_day, :nanosecond}) == {1, :day}
    end

    test "doesn't increase the unit if it does not exactly match a higher unit" do
      assert Moar.Duration.humanize({1001, :nanosecond}) == {1001, :nanosecond}
      assert Moar.Duration.humanize({1001, :microsecond}) == {1001, :microsecond}
      assert Moar.Duration.humanize({1001, :millisecond}) == {1001, :millisecond}
      assert Moar.Duration.humanize({61, :second}) == {61, :second}
      assert Moar.Duration.humanize({61, :minute}) == {61, :minute}
      assert Moar.Duration.humanize({25, :hour}) == {25, :hour}
    end
  end

  describe "shift" do
    test "changes a duration to a different time unit" do
      assert Moar.Duration.shift({1, :second}, :millisecond) == {1000, :millisecond}
      assert Moar.Duration.shift({23, :second}, :millisecond) == {23_000, :millisecond}
      assert Moar.Duration.shift({1001, :millisecond}, :second) == {1, :second}
      assert Moar.Duration.shift({121, :second}, :minute) == {2, :minute}
      assert Moar.Duration.shift({121, :minute}, :hour) == {2, :hour}
      assert Moar.Duration.shift({49, :hour}, :day) == {2, :day}
    end
  end

  describe "to_short_string" do
    test "converts a duration to a short (non-localized) string" do
      assert Moar.Duration.to_short_string({25, :day}) == "25d"
      assert Moar.Duration.to_short_string({25, :hour}) == "25h"
      assert Moar.Duration.to_short_string({25, :minute}) == "25m"
      assert Moar.Duration.to_short_string({25, :second}) == "25s"
      assert Moar.Duration.to_short_string({25, :millisecond}) == "25ms"
      assert Moar.Duration.to_short_string({25, :microsecond}) == "25us"
      assert Moar.Duration.to_short_string({25, :nanosecond}) == "25ns"
    end
  end

  describe "to_string" do
    test "converts a duration to a (non-localized) string" do
      assert Moar.Duration.to_string({1, :second}) == "1 second"
      assert Moar.Duration.to_string({-1, :minute}) == "-1 minute"
      assert Moar.Duration.to_string({23, :hour}) == "23 hours"
    end
  end
end
