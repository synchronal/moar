defmodule Moar.AtomTest do
  # @related [subject](/lib/atom.ex)

  use Moar.SimpleCase, async: true

  describe "from_string" do
    test "string", do: assert(Moar.Atom.from_string("banana") == :banana)
    test "already an atom", do: assert(Moar.Atom.from_string(:banana) == :banana)
    test "nil", do: assert_raise(ArgumentError, fn -> Moar.Atom.from_string(nil) end)
  end

  describe "to_string" do
    test "atom", do: assert(Moar.Atom.to_string(:banana) == "banana")
    test "already a string", do: assert(Moar.Atom.to_string("banana") == "banana")
    test "nil", do: assert_raise(ArgumentError, fn -> Moar.Atom.to_string(nil) end)
  end
end
