defmodule Moar.TermTest do
  # @related [subject](/lib/term.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Term

  describe "blank?" do
    test "booleans: true is not blank, false is blank" do
      refute Moar.Term.blank?(true)
      assert Moar.Term.blank?(false)
    end

    test "lists: blank if empty" do
      assert Moar.Term.blank?([])
      refute Moar.Term.blank?([nil])
      refute Moar.Term.blank?([1])
    end

    test "maps: blank if empty" do
      assert Moar.Term.blank?(%{})
      refute Moar.Term.blank?(%{a: nil})
      refute Moar.Term.blank?(%{a: 1})
    end

    test "nil: is blank" do
      assert Moar.Term.blank?(nil)
    end

    test "numbers: never blank" do
      refute Moar.Term.blank?(0)
      refute Moar.Term.blank?(1000)
    end

    test "strings: blank if empty or just whitespace" do
      assert Moar.Term.blank?("")
      assert Moar.Term.blank?("    ")
      refute Moar.Term.blank?("hi")
    end

    test "bitstrings: blank only empty" do
      assert Moar.Term.blank?(<<>>)

      refute Moar.Term.blank?(
               <<224, 35, 248, 72, 154, 36, 174, 49, 191, 174, 37, 241, 82, 164, 214, 228, 31, 35, 81, 32, 53, 195, 39,
                 204, 16, 128, 150, 109, 242, 251, 91, 144, 33>>
             )
    end
  end

  describe "present?" do
    test "returns the opposite of `blank?`" do
      assert Moar.Term.blank?("")
      refute Moar.Term.present?("")

      refute Moar.Term.blank?("something")
      assert Moar.Term.present?("something")
    end
  end

  describe "presence" do
    test "if the value is present (via `present?`), returns the value" do
      assert Moar.Term.presence("foo") == "foo"
      assert Moar.Term.presence("foo", "default") == "foo"
    end

    test "if the value is not present (via `present?`), returns the default value" do
      assert Moar.Term.presence(" ") == nil
      assert Moar.Term.presence(" ", "default") == "default"
    end
  end

  describe "when_present" do
    test "if the value is present (via `present?`), returns the `present` value" do
      assert Moar.Term.when_present("foo", "it's there", "it's not there") == "it's there"
    end

    test "if the value is not present (via `present?`), returns the `blank` value" do
      assert Moar.Term.when_present(" ", "it's there", "it's not there") == "it's not there"
    end

    test "if the value is a function, it is applied" do
      assert Moar.Term.when_present(5, &(&1 * 2), 0) == 10
      assert Moar.Term.when_present(nil, &(&1 * 2), 0) == 0
    end
  end
end
