defmodule Moar.StringTest do
  # @related [subject](/lib/string.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.String

  describe "append_unless_blank" do
    test "appends when the string is not blank" do
      assert Moar.String.append_unless_blank("string", "-suffix") == "string-suffix"
    end

    test "does not append when the string is blank" do
      assert Moar.String.append_unless_blank("", "-suffix") == ""
      assert Moar.String.append_unless_blank(nil, "-suffix") == nil
    end

    test "accepts a nil suffix" do
      assert Moar.String.append_unless_blank("string", nil) == "string"
      assert Moar.String.append_unless_blank("", nil) == ""
      assert Moar.String.append_unless_blank(nil, nil) == nil
    end
  end

  describe "compare" do
    test "compares two strings using `==`" do
      assert Moar.String.compare("bat", "bat") == :eq
      assert Moar.String.compare("bat", "cat") == :lt
      assert Moar.String.compare("bat", "ant") == :gt

      assert Moar.String.compare("Bat", "bat") == :lt
      assert Moar.String.compare("bat", "Bat") == :gt
    end

    test "can transform the inputs with one or more transformer functions" do
      assert Moar.String.compare("foo", "FOO", &String.downcase/1) == :eq
      assert Moar.String.compare("foo bar", " foo   bar ", &Moar.String.squish/1) == :eq
      assert Moar.String.compare("foo", " foo ", &String.trim/1) == :eq
      assert Moar.String.compare("foo bar", " FOO   baR ", [&String.downcase/1, &Moar.String.squish/1]) == :eq
    end
  end

  describe "compare?" do
    test "like `compare/2` but returns `true` if the first value is less than or equal to the second value" do
      assert Moar.String.compare?("bat", "bat") == true
      assert Moar.String.compare?("bat", "cat") == true
      assert Moar.String.compare?("bat", "ant") == false

      assert Moar.String.compare?("foo bar", " FOO   baR ", [&String.downcase/1, &Moar.String.squish/1]) == true
    end
  end

  describe "count_leading_spaces" do
    test "returns the number of leading spaces" do
      assert Moar.String.count_leading_spaces("") == 0
      assert Moar.String.count_leading_spaces("foo") == 0
      assert Moar.String.count_leading_spaces("  foo") == 2
    end
  end

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

  describe "remove_marked_whitespace" do
    # Elixir 1.16 removes the trailing whitespace from heredocs. Older versions
    # do not, so we should skip them in CI.
    @tag :only_latest
    test "removes whitespace following backslash-v" do
      """
      ant bat\v cat dog\v
          eel fox\v  \t \r

        gnu
      """
      |> Moar.String.remove_marked_whitespace()
      |> assert_eq("ant batcat dogeel foxgnu")
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
      refute Moar.String.secure_compare(~c"", nil)
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

  describe "to_case" do
    test "changes lowerCamelCase to snake_case" do
      assert "textWithSomeThings" |> Moar.String.to_case(:snake_case) == "text_with_some_things"
    end

    test "changes CamelCase to snake_case" do
      assert "TextWithSomeThings" |> Moar.String.to_case(:snake_case) == "text_with_some_things"
    end

    test "changes multi-cased to snake_case" do
      assert "  text with SomeThings  " |> Moar.String.to_case(:snake_case) == "text_with_some_things"
    end

    test "changes lowerCamelCase to CamelCase" do
      assert "textWithSomeThings" |> Moar.String.to_case(:camel_case) == "TextWithSomeThings"
    end

    test "changes snake_case to CamelCase" do
      assert "text_with_some_things" |> Moar.String.to_case(:camel_case) == "TextWithSomeThings"
    end

    test "changes multi-cased to CamelCase" do
      assert "  text with SomeThings  " |> Moar.String.to_case(:camel_case) == "TextWithSomeThings"
    end

    test "changes CamelCase to lowerCamelCase" do
      assert "TextWithSomeThings" |> Moar.String.to_case(:lower_camel_case) == "textWithSomeThings"
    end

    test "changes snake_case to lowerCamelCase" do
      assert "text_with_some_things" |> Moar.String.to_case(:lower_camel_case) == "textWithSomeThings"
    end

    test "changes multi-cased to lowerCamelCase" do
      assert "  text with SomeThings  " |> Moar.String.to_case(:lower_camel_case) == "textWithSomeThings"
    end
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

    test "when given an integer, returns it" do
      assert Moar.String.to_integer(12_345) == 12_345
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

  describe "unindent/1" do
    test "removes leading spaces" do
      assert Moar.String.unindent("  foo") == "foo"
    end

    test "removes leading spaces from each line" do
      """
        foo
        bar
      """
      |> Moar.String.unindent()
      |> assert_eq("""
      foo
      bar
      """)
    end

    test "uses the smallest space count of non-blank lines to determine how much to unindent" do
      """

          foo
        bar
            baz
        fez
          quux
      """
      |> Moar.String.unindent()
      |> assert_eq("""

        foo
      bar
          baz
      fez
        quux
      """)
    end
  end

  describe "unindent/2" do
    test "removes at most the given number of spaces" do
      assert Moar.String.unindent(" foo", 2) == "foo"
      assert Moar.String.unindent("  foo", 2) == "foo"
      assert Moar.String.unindent("    foo", 2) == "  foo"
    end

    test "works on multiline strings" do
      """
          foo
        bar
            baz
      fez
      """
      |> Moar.String.unindent(2)
      |> assert_eq("""
        foo
      bar
          baz
      fez
      """)
    end
  end
end
