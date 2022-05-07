defmodule Moar.DateTimeTest do
  # @related [subject](/lib/datetime.ex)

  use Moar.SimpleCase, async: true

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
end
