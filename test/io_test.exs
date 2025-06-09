defmodule IOTest do
  # @related [subject](lib/io.ex)
  use Moar.SimpleCase, async: true

  describe "cformat" do
    test "returns a single-element iolist when given a string with no formatting" do
      assert Moar.IO.cformat("ant bat cat", true) == [[], "ant bat cat"]
    end

    test "returns an iolist with ansi formatting" do
      assert Moar.IO.cformat("ant {green: bat} cat", true) == [[[[[[], "ant "] | "\e[32m"], "bat"] | "\e[0m"], " cat"]
    end
  end

  describe "cstring" do
    test "returns a string with ANSI format" do
      assert Moar.IO.cstring("ant {green: bat} cat", true) == "ant \e[32mbat\e[0m cat"
    end
  end

  describe "ANSI.convert" do
    test "when not a formatting expression, returns the string as-is" do
      assert Moar.IO.ANSI.convert("I like pie") == "I like pie"
    end

    test "when a formatting expression, converts to ANSI formatting data" do
      assert Moar.IO.ANSI.convert("{cyan: I like pie}") == [:cyan, "I like pie", :reset]
      # more here
    end

    test "trims spaces" do
      assert Moar.IO.ANSI.convert("  {cyan: I like pie} ") == [:cyan, "I like pie", :reset]
    end
  end

  describe "ANSI.parse" do
    test "returns a single-element iolist when given a string with no formatting" do
      assert Moar.IO.ANSI.parse("A quick brown fox") == ["A quick brown fox"]
    end

    test "returns an iolist with ansi formatting" do
      assert Moar.IO.ANSI.parse("A {green underline: quick} {red: brown} fox") == [
               "A ",
               [[:green, :underline], "quick", :reset],
               " ",
               [:red, "brown", :reset],
               " fox"
             ]
    end
  end
end
