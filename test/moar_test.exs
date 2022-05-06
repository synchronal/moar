defmodule MoarTest do
  use ExUnit.Case
  doctest Moar

  test "greets the world" do
    assert Moar.hello() == :world
  end
end
