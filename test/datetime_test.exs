defmodule Moar.DateTimeTest do
  # @related [subject](/lib/datetime.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.DateTime

  describe "add" do
    test "adds a duration to a time" do
      assert Moar.DateTime.add(~U[2022-01-01T00:00:00.000Z], {55, :second}) == ~U[2022-01-01T00:00:55.000Z]
    end
  end

  describe "at" do
    test "makes a datetime at a specific time" do
      assert Moar.DateTime.at(~T{13:00:00}) == DateTime.new!(Date.utc_today(), ~T[13:00:00])
    end

    test "can add a duration" do
      assert Moar.DateTime.at(~T{13:00:00}, shift: [hour: 1]) == DateTime.new!(Date.utc_today(), ~T[14:00:00])

      assert Moar.DateTime.at(~T{12:00:00}, shift: [day: 1]) ==
               DateTime.new!(Date.utc_today(), ~T[12:00:00]) |> DateTime.shift(day: 1)
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

  describe "between?" do
    test "returns true if the DateTime is between two datetimes (inclusive)" do
      one = ~U[2022-01-01T01:00:00Z]
      two = ~U[2022-01-01T02:00:00Z]
      three = ~U[2022-01-01T03:00:00Z]
      four = ~U[2022-01-01T04:00:00Z]

      assert Moar.DateTime.between?(two, {one, three})
      assert Moar.DateTime.between?(two, {two, three})
      assert Moar.DateTime.between?(two, {one, two})
      refute Moar.DateTime.between?(two, {three, four})
      refute Moar.DateTime.between?(four, {two, three})
    end
  end

  describe "recent?" do
    test "returns true if the DateTime is within the last minute" do
      fifty_nine_seconds_ago = Moar.DateTime.utc_now(minus: {59, :second})
      sixty_one_seconds_ago = Moar.DateTime.utc_now(minus: {61, :second})

      assert Moar.DateTime.recent?(fifty_nine_seconds_ago)
      refute Moar.DateTime.recent?(sixty_one_seconds_ago)
    end

    test "fails if the DateTime is in the future" do
      one_second_from_now = Moar.DateTime.utc_now(plus: {1, :second})
      refute Moar.DateTime.recent?(one_second_from_now)
    end

    test "accepts a duration" do
      sixty_one_seconds_ago = Moar.DateTime.utc_now(minus: {61, :second})

      refute Moar.DateTime.recent?(sixty_one_seconds_ago)
      assert Moar.DateTime.recent?(sixty_one_seconds_ago, {62, :second})
    end
  end

  describe "subtract" do
    test "subtracts a duration from a datetime" do
      assert Moar.DateTime.subtract(~U[2022-01-01T00:00:55.000Z], {55, :second}) == ~U[2022-01-01T00:00:00.000Z]
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

  describe "within?" do
    test "returns true if the DateTime is within the last minute" do
      fifty_nine_seconds_ago = Moar.DateTime.utc_now(minus: {59, :second})
      sixty_one_seconds_ago = Moar.DateTime.utc_now(minus: {61, :second})
      fifty_nine_seconds_from_now = Moar.DateTime.utc_now(plus: {59, :second})
      sixty_one_seconds_from_now = Moar.DateTime.utc_now(plus: {61, :second})

      assert Moar.DateTime.within?(fifty_nine_seconds_ago, {1, :minute})
      assert Moar.DateTime.within?(fifty_nine_seconds_from_now, {1, :minute})
      refute Moar.DateTime.within?(sixty_one_seconds_ago, {1, :minute})
      refute Moar.DateTime.within?(sixty_one_seconds_from_now, {1, :minute})
    end
  end
end
