defmodule Moar.DurationTest do
  # @related [subject](/lib/duration.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Duration

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
