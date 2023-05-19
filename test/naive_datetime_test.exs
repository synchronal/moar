defmodule Moar.NaiveDateTimeTest do
  # @related [subject](/lib/naive_datetime.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.NaiveDateTime

  describe "add" do
    test "adds a duration to a time" do
      assert Moar.NaiveDateTime.add(~N[2022-01-01T00:00:00.000], {55, :second}) == ~N[2022-01-01T00:00:55.000]
    end
  end

  describe "from_iso8601!" do
    test "parses a valid ISO8601 string" do
      assert Moar.NaiveDateTime.from_iso8601!("2020-01-01T00:00:00.000") == ~N[2020-01-01T00:00:00.000]
    end

    test "ignores any time zone information" do
      assert Moar.NaiveDateTime.from_iso8601!("2020-01-01T00:00:00.000+0800") == ~N[2020-01-01T00:00:00.000]
    end

    test "raises if the string is not in ISO 8601 format" do
      assert_raise ArgumentError,
                   ~S|Invalid ISO8601 format: "three and a half days from tomorrow night"|,
                   fn -> Moar.NaiveDateTime.from_iso8601!("three and a half days from tomorrow night") end
    end
  end

  describe "subtract" do
    test "subtracts a duration from a naivedatetime" do
      assert Moar.NaiveDateTime.subtract(~N[2022-01-01T00:00:55.000Z], {55, :second}) == ~N[2022-01-01T00:00:00.000Z]
    end
  end

  describe "to_iso8601_rounded" do
    test "formats with no partial seconds" do
      date = %NaiveDateTime{
        year: 2000,
        month: 2,
        day: 29,
        hour: 23,
        minute: 0,
        second: 7,
        microsecond: {111, 5}
      }

      assert date |> Moar.NaiveDateTime.to_iso8601_rounded() == "2000-02-29T23:00:07"
    end
  end

  describe "utc_now" do
    test "accepts `:plus` option which returns utc_now plus the given duration" do
      one_minute_hence = NaiveDateTime.utc_now() |> NaiveDateTime.add(60, :second)
      Moar.NaiveDateTime.utc_now(plus: {1, :minute}) |> assert_eq(one_minute_hence, within: {1, :second})
    end

    test "accepts `:minus` option which returns utc_now minus the given duration" do
      one_minute_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-60, :second)
      Moar.NaiveDateTime.utc_now(minus: {1, :minute}) |> assert_eq(one_minute_ago, within: {1, :second})
    end
  end
end
