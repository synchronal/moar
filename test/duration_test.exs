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

  describe "to_string" do
    test "converts a duration to a (non-localized) string" do
      assert Moar.Duration.to_string({1, :second}) == "1 second"
      assert Moar.Duration.to_string({-1, :minute}) == "-1 minute"
      assert Moar.Duration.to_string({23, :hour}) == "23 hours"
    end
  end
end
