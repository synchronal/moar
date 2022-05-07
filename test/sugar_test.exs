defmodule Moar.SugarTest do
  use ExUnit.Case, async: true
  doctest Moar.Sugar

  describe "error" do
    test "wraps the given term in an :error tuple" do
      assert Moar.Sugar.error(1) == {:error, 1}
    end
  end

  describe "error!" do
    test "unwraps an :error tuple" do
      assert Moar.Sugar.error!({:error, 1}) == 1
    end

    test "fails when it's not an :error tuple" do
      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.error!/1", fn ->
        Moar.Sugar.error!({:ok, :good})
      end

      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.error!/1", fn ->
        Moar.Sugar.error!(:good)
      end
    end
  end

  describe "noreply" do
    test "wraps the given term in a :noreply tuple" do
      assert Moar.Sugar.noreply(1) == {:noreply, 1}
    end
  end

  describe "ok" do
    test "wraps the given term in an :ok tuple" do
      assert Moar.Sugar.ok(1) == {:ok, 1}
    end
  end

  describe "ok!" do
    test "unwraps an :ok tuple" do
      assert Moar.Sugar.ok!({:ok, 1}) == 1
    end

    test "fails when it's not an :ok tuple" do
      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.ok!/1", fn ->
        Moar.Sugar.ok!({:error, :bad})
      end

      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.ok!/1", fn ->
        Moar.Sugar.ok!(:bad)
      end
    end
  end

  describe "returning" do
    test "accepts two values and returns the second" do
      assert Moar.Sugar.returning(1, 2) == 2
    end
  end
end
