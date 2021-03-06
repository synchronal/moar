defmodule Moar.DurationTest do
  # @related [subject](/lib/duration.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Duration

  describe "ago" do
    test "returns the duration between a DateTime and now, in the largest possible unit" do
      earlier = Moar.DateTime.subtract(DateTime.utc_now(), {121, :minute})
      assert Moar.Duration.ago(earlier) |> Moar.Duration.shift(:minute) == {121, :minute}
    end

    test "works with NaiveDateTimes" do
      earlier = Moar.NaiveDateTime.subtract(NaiveDateTime.utc_now(), {121, :minute})
      assert Moar.Duration.ago(earlier) |> Moar.Duration.shift(:minute) == {121, :minute}
    end

    test "works with ISO 8601 strings" do
      earlier = Moar.DateTime.subtract(DateTime.utc_now(), {121, :minute}) |> DateTime.to_iso8601()
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

  describe "format" do
    test ":long formats a duration as a (non-localized) string" do
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

    test ":long supports negative times and plurals" do
      assert Moar.Duration.format({1, :second}, :long) == "1 second"
      assert Moar.Duration.format({-1, :minute}, :long) == "-1 minute"
      assert Moar.Duration.format({23, :hour}, :long) == "23 hours"
      assert Moar.Duration.format({-23, :hour}, :long) == "-23 hours"
    end

    test "defaults to :long" do
      assert Moar.Duration.format({25, :approx_year}) == "25 years"
    end

    test ":short converts a duration to a short (non-localized) string" do
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

    test ":short supports negative times and plurals" do
      assert Moar.Duration.format({1, :second}, :short) == "1s"
      assert Moar.Duration.format({-1, :minute}, :short) == "-1m"
      assert Moar.Duration.format({23, :hour}, :short) == "23h"
      assert Moar.Duration.format({-23, :hour}, :short) == "-23h"
    end

    test "accepts a suffix" do
      assert Moar.Duration.format({25, :minute}, "yonder") == "25 minutes yonder"
      assert Moar.Duration.format({25, :minute}, :long, "yonder") == "25 minutes yonder"
      assert Moar.Duration.format({25, :minute}, :short, "yonder") == "25m yonder"
    end

    test "accepts an ':ago' or ':from_now' transformation, which adds an 'ago' or 'from now' suffix" do
      assert Moar.Duration.format({25, :minute}, :ago) == "25 minutes ago"
      assert Moar.Duration.format({25, :minute}, :long, :ago) == "25 minutes ago"
      assert Moar.Duration.format({25, :minute}, :short, :ago) == "25m ago"
      assert Moar.Duration.format({25, :minute}, :from_now) == "25 minutes from now"
      assert Moar.Duration.format({25, :minute}, :long, :from_now) == "25 minutes from now"
      assert Moar.Duration.format({25, :minute}, :short, :from_now) == "25m from now"
    end

    test "accepts an ':ago' or ':from_now' transformation with a datetime" do
      earlier = DateTime.utc_now() |> Moar.DateTime.subtract({25, :minute})
      assert Moar.Duration.format(earlier, :long, [:ago, :approx]) == "25 minutes ago"
      assert Moar.Duration.format(earlier, :long, [:approx, :ago]) == "25 minutes ago"

      later = DateTime.utc_now() |> Moar.DateTime.add({25, :minute})
      assert Moar.Duration.format(later, :long, [:from_now, :approx]) == "24 minutes from now"
      assert Moar.Duration.format(later, :long, [:approx, :from_now]) == "24 minutes from now"
    end

    test "':ago' and ':from_now' transformation suffix can be overridden" do
      assert Moar.Duration.format({25, :minute}, :ago, "back") == "25 minutes back"
      assert Moar.Duration.format({25, :minute}, :long, :ago, "back") == "25 minutes back"
      assert Moar.Duration.format({25, :minute}, :short, :ago, "back") == "25m back"
      assert Moar.Duration.format({25, :minute}, :from_now, "henceforth") == "25 minutes henceforth"
      assert Moar.Duration.format({25, :minute}, :long, :from_now, "henceforth") == "25 minutes henceforth"
      assert Moar.Duration.format({25, :minute}, :short, :from_now, "henceforth") == "25m henceforth"
    end

    test "':ago' and ':from_now' transformation suffix can be removed with an empty suffix string, but not a nil" do
      assert Moar.Duration.format({25, :minute}, :ago, nil) == "25 minutes ago"
      assert Moar.Duration.format({25, :minute}, :ago, "") == "25 minutes"
      assert Moar.Duration.format({25, :minute}, :from_now, nil) == "25 minutes from now"
      assert Moar.Duration.format({25, :minute}, :from_now, "") == "25 minutes"
    end

    test "accepts a ':humanize' transformation" do
      assert Moar.Duration.format({60, :minute}, :humanize) == "1 hour"
      assert Moar.Duration.format({60, :minute}, :long, :humanize) == "1 hour"
      assert Moar.Duration.format({60, :minute}, :short, :humanize) == "1h"
    end

    test "accepts a combination of ':ago' or ':from_now' and ':humanize'" do
      assert Moar.Duration.format({60, :minute}, [:humanize, :ago]) == "1 hour ago"
      assert Moar.Duration.format({60, :minute}, [:ago, :humanize]) == "1 hour ago"
      assert Moar.Duration.format({60, :minute}, [:humanize, :ago], "yonder") == "1 hour yonder"
      assert Moar.Duration.format({60, :minute}, :long, [:humanize, :ago]) == "1 hour ago"
      assert Moar.Duration.format({60, :minute}, :short, [:humanize, :ago]) == "1h ago"
      assert Moar.Duration.format({60, :minute}, :short, [:humanize, :ago], "yonder") == "1h yonder"
      assert Moar.Duration.format({60, :minute}, [:humanize, :from_now]) == "1 hour from now"
      assert Moar.Duration.format({60, :minute}, [:from_now, :humanize]) == "1 hour from now"
      assert Moar.Duration.format({60, :minute}, [:humanize, :from_now], "henceforth") == "1 hour henceforth"
      assert Moar.Duration.format({60, :minute}, :long, [:humanize, :from_now]) == "1 hour from now"
      assert Moar.Duration.format({60, :minute}, :short, [:humanize, :from_now]) == "1h from now"
      assert Moar.Duration.format({60, :minute}, :short, [:humanize, :from_now], "henceforth") == "1h henceforth"
    end

    test "accepts ':approx' transformation" do
      assert Moar.Duration.format({300, :minute}, :approx) == "5 hours"
      assert Moar.Duration.format({300, :minute}, :approx, "from now") == "5 hours from now"
      assert Moar.Duration.format({300, :minute}, :long, :approx) == "5 hours"
      assert Moar.Duration.format({300, :minute}, :short, :approx) == "5h"
      assert Moar.Duration.format({300, :minute}, :short, :approx, "from now") == "5h from now"
    end

    test "accepts combination of ':ago' or ':from_now' and ':approx'" do
      assert Moar.Duration.format({300, :minute}, :long, [:approx, :ago]) == "5 hours ago"
      assert Moar.Duration.format({300, :minute}, :long, [:ago, :approx]) == "5 hours ago"
      assert Moar.Duration.format({300, :minute}, :long, [:approx, :from_now]) == "5 hours from now"
      assert Moar.Duration.format({300, :minute}, :long, [:from_now, :approx]) == "5 hours from now"
    end

    test "raises when an unknown transformation is requested" do
      assert_raise RuntimeError, "Unknown transformation: glorp", fn ->
        Moar.Duration.format({300, :minute}, :long, [:humanize, :glorp, :ago])
      end
    end
  end

  describe "from_now" do
    test "returns the duration between now and a DateTime now, in the largest possible unit" do
      later = Moar.DateTime.add(DateTime.utc_now(), {122, :minute})
      assert Moar.Duration.from_now(later) |> Moar.Duration.approx() == {2, :hour}
    end

    test "works with NaiveDateTimes" do
      later = Moar.NaiveDateTime.add(NaiveDateTime.utc_now(), {122, :minute})
      assert Moar.Duration.from_now(later) |> Moar.Duration.approx() == {2, :hour}
    end

    test "works with ISO 8601 strings" do
      later = Moar.DateTime.add(DateTime.utc_now(), {122, :minute}) |> DateTime.to_iso8601()
      assert Moar.Duration.from_now(later) |> Moar.Duration.approx() == {2, :hour}
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
    test "does nothing if the duration is already in the right unit" do
      assert Moar.Duration.shift({25, :second}, :second) == {25, :second}
    end

    test "can shift a duration to a smaller unit" do
      assert Moar.Duration.shift({1, :hour}, :minute) == {60, :minute}
      assert Moar.Duration.shift({1, :hour}, :second) == {3600, :second}
      assert Moar.Duration.shift({1, :hour}, :millisecond) == {3_600_000, :millisecond}
    end

    test "can shift a duration to a larger unit" do
      assert Moar.Duration.shift({60, :minute}, :hour) == {1, :hour}
      assert Moar.Duration.shift({1440, :minute}, :day) == {1, :day}
    end

    test "when shifting up, rounds towards zero" do
      assert Moar.Duration.shift({61, :minute}, :hour) == {1, :hour}
      assert Moar.Duration.shift({121, :minute}, :hour) == {2, :hour}
    end
  end

  describe "shift_down" do
    test "shifts a duration to the next lower unit" do
      assert Moar.Duration.shift_down({1, :hour}) == {60, :minute}
      assert Moar.Duration.shift_down({1, :second}) == {1000, :millisecond}
    end

    test "cannot shift below nanosecond" do
      assert_raise RuntimeError,
                   "Cannot shift {1, :nanosecond} to a smaller unit because nanosecond is the smallest supported unit.",
                   fn -> Moar.Duration.shift_down({1, :nanosecond}) end
    end
  end

  describe "shift_up" do
    test "shifts a duration to the next higher unit" do
      assert Moar.Duration.shift_up({60, :minute}) == {1, :hour}
      assert Moar.Duration.shift_up({24, :hour}) == {1, :day}
    end

    test "cannot shift above approx_year" do
      assert_raise RuntimeError,
                   "Cannot shift {1, :approx_year} to a larger unit because approx_year is the largest supported unit.",
                   fn -> Moar.Duration.shift_up({1, :approx_year}) end
    end

    test "rounds towards zero" do
      assert Moar.Duration.shift_up({1, :minute}) == {0, :hour}
      assert Moar.Duration.shift_up({61, :minute}) == {1, :hour}
    end
  end

  describe "to_string" do
    test "delegates to format(duration, :long)" do
      assert Moar.Duration.to_string({1, :second}) == "1 second"
      assert Moar.Duration.to_string({-23, :hour}) == "-23 hours"
    end
  end
end
