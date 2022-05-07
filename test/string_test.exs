defmodule Moar.StringTest do
  use Moar.SimpleCase, async: true

  doctest Moar.String

  describe "inner_truncate" do
    test "works with nil" do
      assert Moar.String.inner_truncate(nil, 10) == nil
    end

    test "doesn't change short strings" do
      assert Moar.String.inner_truncate("12345", 10) == "12345"
      assert Moar.String.inner_truncate("12345", 5) == "12345"
    end

    test "removes the middle of long strings" do
      assert Moar.String.inner_truncate("1234567890", 4) == "12…90"
      assert Moar.String.inner_truncate("1234567890", 5) == "123…90"
      assert Moar.String.inner_truncate("1234567890", 6) == "123…890"
    end
  end

  describe "secure_compare/2" do
    test "compares binaries securely" do
      assert Moar.String.secure_compare(<<>>, <<>>)
      assert Moar.String.secure_compare(<<0>>, <<0>>)

      refute Moar.String.secure_compare(<<>>, <<1>>)
      refute Moar.String.secure_compare(<<1>>, <<>>)
      refute Moar.String.secure_compare(<<0>>, <<1>>)

      assert Moar.String.secure_compare("test", "test")
      assert Moar.String.secure_compare("無", "無")
      refute Moar.String.secure_compare(nil, nil)
      refute Moar.String.secure_compare(nil, "")
      refute Moar.String.secure_compare("", nil)
      refute Moar.String.secure_compare('', nil)
    end
  end

  describe "squish" do
    test "removes whitespace" do
      assert " foo  BAR  \t baz \n FEz    " |> Moar.String.squish() == "foo BAR baz FEz"
    end

    test "allows nil", do: nil |> Moar.String.squish() |> assert_eq(nil)
  end

  describe "to_integer" do
    test "doesn't blow up on nil" do
      assert Moar.String.to_integer(nil) == nil
    end

    test "converts to integer" do
      assert Moar.String.to_integer("12345") == 12_345
    end

    test "allows commas and spaces" do
      assert Moar.String.to_integer(" 12,345  ") == 12_345
    end

    test "can be very lenient" do
      assert Moar.String.to_integer("  12,3m 456,,@789   ", :lenient) == 123_456_789
    end

    test "can default" do
      assert Moar.String.to_integer(nil, default: 4) == 4
      assert Moar.String.to_integer("", default: 4) == 4
      assert Moar.String.to_integer("100", default: 4) == 100
    end
  end

  describe "trim" do
    test "doesn't blow up on nil" do
      assert Moar.String.trim(nil) == nil
    end

    test "trims from left and right" do
      assert Moar.String.trim("  foo  ") == "foo"
    end
  end

  describe "truncate_at" do
    test "truncates at the last instance of 'at' that doesn't exceed the limit" do
      "12345. 12345. 12345."
      |> Moar.String.truncate_at(".", 16)
      |> assert_eq("12345. 12345.")
    end

    test "doesn't truncate if it does not exceed the limit" do
      "12345. 12345."
      |> Moar.String.truncate_at(".", 999)
      |> assert_eq("12345. 12345.")
    end

    test "truncates at the limit if 'at' is not in the string" do
      "1234567890"
      |> Moar.String.truncate_at(".", 5)
      |> assert_eq("12345")
    end

    test "truncates at the limit if 'at' is not in within the limit" do
      "12345678.90"
      |> Moar.String.truncate_at(".", 5)
      |> assert_eq("12345")
    end

    test "doesn't mess with the content" do
      "aaaaaaaaaaaaa"
      |> Moar.String.truncate_at("a", 3)
      |> assert_eq("aaa")
    end
  end
end
