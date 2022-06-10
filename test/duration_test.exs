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
      assert Moar.Duration.approx({7, :day}) == {7, :day}
      assert Moar.Duration.approx({60, :day}) == {2, :approx_month}
      assert Moar.Duration.approx({12, :approx_month}) == {12, :approx_month}
      assert Moar.Duration.approx({23, :approx_month}) == {23, :approx_month}
      assert Moar.Duration.approx({24, :approx_month}) == {2, :approx_year}
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
      assert Moar.Duration.convert({60, :day}, :approx_month) == 2
      assert Moar.Duration.convert({360, :day}, :approx_year) == 1
      assert Moar.Duration.convert({12, :approx_month}, :approx_year) == 1
    end
  end

  describe "format(:long)" do
    test "formats a duration as a (non-localized) string" do
      assert Moar.Duration.format({25, :approx_year}, :long) == "25 years"
      assert Moar.Duration.format({25, :approx_month}, :long) == "25 months"
      assert Moar.Duration.format({25, :day}, :long) == "25 days"
      assert Moar.Duration.format({25, :hour}, :long) == "25 hours"
      assert Moar.Duration.format({25, :minute}, :long) == "25 minutes"
      assert Moar.Duration.format({25, :second}, :long) == "25 seconds"
      assert Moar.Duration.format({25, :millisecond}, :long) == "25 milliseconds"
      assert Moar.Duration.format({25, :microsecond}, :long) == "25 microseconds"
      assert Moar.Duration.format({25, :nanosecond}, :long) == "25 nanoseconds"
    end

    test "supports negative times and plurals" do
      assert Moar.Duration.format({1, :second}, :long) == "1 second"
      assert Moar.Duration.format({-1, :minute}, :long) == "-1 minute"
      assert Moar.Duration.format({23, :hour}, :long) == "23 hours"
      assert Moar.Duration.format({-23, :hour}, :long) == "-23 hours"
    end
  end

  describe "format(:short)" do
    test "converts a duration to a short (non-localized) string" do
      assert Moar.Duration.format({25, :approx_year}, :short) == "25yr"
      assert Moar.Duration.format({25, :approx_month}, :short) == "25mo"
      assert Moar.Duration.format({25, :day}, :short) == "25d"
      assert Moar.Duration.format({25, :hour}, :short) == "25h"
      assert Moar.Duration.format({25, :minute}, :short) == "25m"
      assert Moar.Duration.format({25, :second}, :short) == "25s"
      assert Moar.Duration.format({25, :millisecond}, :short) == "25ms"
      assert Moar.Duration.format({25, :microsecond}, :short) == "25us"
      assert Moar.Duration.format({25, :nanosecond}, :short) == "25ns"
    end

    test "supports negative times and plurals" do
      assert Moar.Duration.format({1, :second}, :short) == "1s"
      assert Moar.Duration.format({-1, :minute}, :short) == "-1m"
      assert Moar.Duration.format({23, :hour}, :short) == "23h"
      assert Moar.Duration.format({-23, :hour}, :short) == "-23h"
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
      assert Moar.Duration.humanize({30, :day}) == {1, :approx_month}
      assert Moar.Duration.humanize({12, :approx_month}) == {1, :approx_year}
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

  describe "to_string" do
    test "delegates to format(duration, :long)" do
      assert Moar.Duration.to_string({1, :second}) == "1 second"
      assert Moar.Duration.to_string({-23, :hour}) == "-23 hours"
    end
  end
end
