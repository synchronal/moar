defmodule Moar.DateTimeTest do
  # @related [subject](/lib/datetime.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.DateTime

  describe "add" do
    test "adds a duration to a time" do
      assert Moar.DateTime.add(~U[2022-01-01T00:00:00Z], {55, :second}) == ~U[2022-01-01T00:00:55Z]
    end
  end

  describe "from_iso8601!" do
    test "parses a valid ISO8601 string" do
      assert Moar.DateTime.from_iso8601!("2020-01-01T00:00:00.000Z") == ~U[2020-01-01T00:00:00.000Z]
    end

    test "raises if the string is not UTC" do
      assert_raise ArgumentError,
                   ~S|Expected "2020-01-01T00:00:00.000+0800" to have a UTC offset of 0, but was: 28800|,
                   fn -> Moar.DateTime.from_iso8601!("2020-01-01T00:00:00.000+0800") end
    end

    test "raises if the string is not in ISO 8601 format" do
      assert_raise ArgumentError,
                   ~S|Invalid ISO8601 format: "three and a half days from tomorrow night"|,
                   fn -> Moar.DateTime.from_iso8601!("three and a half days from tomorrow night") end
    end
  end

  describe "subtract" do
    test "subtracts a duration from a datetime" do
      assert Moar.DateTime.subtract(~U[2022-01-01T00:00:55Z], {55, :second}) == ~U[2022-01-01T00:00:00Z]
    end
  end

  describe "to_iso8601_rounded" do
    test "formats with no partial seconds" do
      date = %DateTime{
        year: 2000,
        month: 2,
        day: 29,
        zone_abbr: "AMT",
        hour: 23,
        minute: 0,
        second: 7,
        microsecond: {111, 5},
        utc_offset: -14_400,
        std_offset: 0,
        time_zone: "America/Manaus"
      }

      assert date |> Moar.DateTime.to_iso8601_rounded() == "2000-02-29T23:00:07-04:00"
    end
  end

  describe "utc_now" do
    test "accepts `:plus` option which returns utc_now plus the given duration" do
      one_minute_hence = DateTime.utc_now() |> DateTime.add(60, :second)
      Moar.DateTime.utc_now(plus: {1, :minute}) |> assert_eq(one_minute_hence, within: {1, :second})
    end

    test "accepts `:minus` option which returns utc_now minus the given duration" do
      one_minute_ago = DateTime.utc_now() |> DateTime.add(-60, :second)
      Moar.DateTime.utc_now(minus: {1, :minute}) |> assert_eq(one_minute_ago, within: {1, :second})
    end
  end
end
