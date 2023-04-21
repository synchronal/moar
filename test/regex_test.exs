defmodule Moar.RegexTest do
  # @related [subject](/lib/regex.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Regex

  describe "named_capture" do
    test "returns a single named capture" do
      assert Moar.Regex.named_capture("abcd", ~r/a(?<foo>b)c(?<bar>d)/, "bar") == "d"
    end

    test "returns `nil` if the name is not captured" do
      assert Moar.Regex.named_capture("abcd", ~r/a(?<foo>b)c(?<bar>d)/, "xyz") == nil
    end
  end

  describe "named_captures" do
    test "works like `Regex.named_captures/3` but can take the first two args in any order" do
      assert Regex.named_captures(~r/a(?<foo>b)c(?<bar>d)/, "abcd") == %{"bar" => "d", "foo" => "b"}
      assert Moar.Regex.named_captures(~r/a(?<foo>b)c(?<bar>d)/, "abcd") == %{"bar" => "d", "foo" => "b"}
      assert Moar.Regex.named_captures("abcd", ~r/a(?<foo>b)c(?<bar>d)/) == %{"bar" => "d", "foo" => "b"}
    end

    test "passes options to `Regex.named_captures/3`" do
      assert Moar.Regex.named_captures("abcd", ~r/a(?<foo>b)c(?<bar>d)/, return: :index) == %{
               "bar" => {3, 1},
               "foo" => {1, 1}
             }
    end
  end
end
