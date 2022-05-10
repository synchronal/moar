defmodule Moar.RandomTest do
  # @related [subject](/lib/random.ex)

  use Moar.SimpleCase, async: true

  describe "integer" do
    test "generates random integers" do
      0..10_000
      |> Enum.map(fn _ -> Moar.Random.integer(10) end)
      |> Enum.uniq()
      |> Enum.sort()
      |> assert_eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    end
  end

  describe "string" do
    test "defaults to 32 characters" do
      assert String.length(Moar.Random.string()) == 32
    end

    test "returns a string with the given length" do
      assert String.length(Moar.Random.string(5)) == 5
      assert String.length(Moar.Random.string(59)) == 59
    end

    test "returns strings that don't collide" do
      refute Moar.Random.string(59) == Moar.Random.string(59)
    end

    test "can be base64 encoded (the default)" do
      for _ <- 1..1000 do
        assert Moar.Random.string() =~ ~r|^[A-Za-z0-9+/]{32}$|
        assert Moar.Random.string(:base64) =~ ~r|^[A-Za-z0-9+/]{32}$|
        assert Moar.Random.string(20) =~ ~r|^[A-Za-z0-9+/]{20}$|
        assert Moar.Random.string(10, :base64) =~ ~r|^[A-Za-z0-9+/]{10}$|
      end
    end

    test "can be base32 encoded" do
      for _ <- 1..1000 do
        assert Moar.Random.string(:base32) =~ ~r|^[A-Z2-7]{32}$|
        assert Moar.Random.string(20, :base32) =~ ~r|^[A-Z2-7]{20}$|
      end
    end
  end
end
