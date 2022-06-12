defmodule Moar.StringTest do
  # @related [subject](/lib/string.ex)

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

    test "accepts a replacement" do
      assert Moar.String.inner_truncate("1234567890", 4) == "12…90"
      assert Moar.String.inner_truncate("1234567890", 4, "#-#") == "12#-#90"
    end
  end

  describe "pluralize" do
    test "returns the string when the count is 1 or -1" do
      assert Moar.String.pluralize(1, "fish", "fishies") == "fish"
      assert Moar.String.pluralize(-1, "fish", "fishies") == "fish"
    end

    test "returns the pluralized string when the count is not 1 or -1" do
      assert Moar.String.pluralize(2, "fish", "fishies") == "fishies"
      assert Moar.String.pluralize(0, "fish", "fishies") == "fishies"
      assert Moar.String.pluralize(-2, "fish", "fishies") == "fishies"
    end

    test "accepts a pluralizer function" do
      pluralizer = fn s -> s <> "ies" end

      assert Moar.String.pluralize(2, "fish", pluralizer) == "fishies"
      assert Moar.String.pluralize(1, "fish", pluralizer) == "fish"
      assert Moar.String.pluralize(0, "fish", pluralizer) == "fishies"
      assert Moar.String.pluralize(-1, "fish", pluralizer) == "fish"
      assert Moar.String.pluralize(-2, "fish", pluralizer) == "fishies"
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

  describe "slug" do
    test "replaces non-string characters with a string" do
      assert Moar.String.slug(" A brown cow.", "-") == "a-brown-cow"
      assert Moar.String.slug("SomeModule.Name", "-") == "some-module-name"
      assert Moar.String.slug("foo", "-") == "foo"
      assert Moar.String.slug("FOO", "-") == "foo"
      assert Moar.String.slug(:foo, "-") == "foo"
      assert Moar.String.slug("foo_bar", "-") == "foo-bar"
      assert Moar.String.slug("FOO_BAR", "-") == "foo-bar"
      assert Moar.String.slug(:foo_bar, "-") == "foo-bar"
      assert Moar.String.slug("fooBar", "-") == "foo-bar"
      assert Moar.String.slug(" fooBar ", "-") == "foo-bar"
      assert Moar.String.slug(" [fooBar) ", "-") == "foo-bar"
      assert Moar.String.slug(" foo bar ", "-") == "foo-bar"
      assert Moar.String.slug(" ?foo! bar ) ", "-") == "foo-bar"
      assert Moar.String.slug(" ?foo! bar ) ", "_") == "foo_bar"
      assert Moar.String.slug(" ?foo! bar ) ", "?") == "?foo?bar"
    end

    test "preserves leading and trailing joiners" do
      assert Moar.String.slug("foo-bar", "_") == "foo_bar"
      assert Moar.String.slug("_foo_", "_") == "_foo_"
      assert Moar.String.slug("_foo-bar_", "_") == "_foo_bar_"
      assert Moar.String.slug(" \t _foo-bar_ _ ", "_") == "_foo_bar___"
    end

    test "accepts anything that implements `String.Chars`" do
      assert Moar.String.slug(:foo, "_") == "foo"
      assert Moar.String.slug(:foo_bar, "_") == "foo_bar"
      assert Moar.String.slug(123, "_") == "123"
    end

    test "accepts lists" do
      assert Moar.String.slug(["foo", "bar", 123], "-") == "foo-bar-123"
      assert Moar.String.slug([" foo ", :bar, " baz fez ", 123], "-") == "foo-bar-baz-fez-123"
    end

    test "has a dasherize/1 shortcut" do
      assert Moar.String.dasherize(" foo bar ") == "foo-bar"
    end

    test "has an underscore/1 shortcut" do
      assert Moar.String.underscore(" foo bar ") == "foo_bar"
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
