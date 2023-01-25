defmodule Moar.AtomTest do
  # @related [subject](/lib/atom.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Atom

  describe "atomize" do
    test "returns atoms unchanged" do
      assert Moar.Atom.atomize(:atom) == :atom
      assert Moar.Atom.atomize(:my_atom) == :my_atom
    end

    test "converts strings to atoms, converting non-alphanumeric characters to underscores" do
      assert Moar.Atom.atomize("atom") == :atom
      assert Moar.Atom.atomize("my_atom") == :my_atom
      assert Moar.Atom.atomize("my-atom") == :my_atom
      assert Moar.Atom.atomize("my atom") == :my_atom
    end
  end

  describe "existing_atom?" do
    test "returns true when given an atom" do
      assert Moar.Atom.existing_atom?(:existing_atom)
    end

    test "returns true when given a string with a corresponding atom" do
      _existing_atom = :atom1

      assert Moar.Atom.existing_atom?("atom1")
    end

    test "returns false when given a string without a corresponding atom" do
      refute Moar.Atom.existing_atom?("nonexisting_atom")
    end
  end

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

  describe "to_existing_atom" do
    test "string when atom exists", do: assert(Moar.Atom.to_existing_atom("banana") == :banana)

    test "string when atom is not existing" do
      assert_raise ArgumentError, ~r/1st argument: not an already existing atom/, fn ->
        Moar.Atom.to_existing_atom("qwertyuiop")
      end
    end

    test "already an atom", do: assert(Moar.Atom.to_existing_atom(:banana) == :banana)
    test "nil", do: assert(Moar.Atom.to_existing_atom(nil) == nil)
  end
end
