defmodule Moar.SugarTest do
  # @related [subject](/lib/sugar.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Sugar

  describe "cont" do
    test "wraps the given term in a :cont tuple" do
      assert Moar.Sugar.cont(1) == {:cont, 1}
    end
  end

  describe "cont!" do
    test "unwraps a :cont tuple" do
      assert Moar.Sugar.cont!({:cont, 1}) == 1
    end

    test "fails when it's not a :cont tuple" do
      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.cont!/1", fn ->
        Moar.Sugar.cont!({:ok, :good})
      end

      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.cont!/1", fn ->
        Moar.Sugar.cont!(:good)
      end
    end
  end

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

  describe "halt" do
    test "wraps the given term in a :halt tuple" do
      assert Moar.Sugar.halt(1) == {:halt, 1}
    end
  end

  describe "halt!" do
    test "unwraps a :halt tuple" do
      assert Moar.Sugar.halt!({:halt, 1}) == 1
    end

    test "fails when it's not a :halt tuple" do
      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.halt!/1", fn ->
        Moar.Sugar.halt!({:ok, :good})
      end

      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.halt!/1", fn ->
        Moar.Sugar.halt!(:good)
      end
    end
  end

  describe "noreply" do
    test "wraps the given term in a :noreply tuple" do
      assert Moar.Sugar.noreply(1) == {:noreply, 1}
    end
  end

  describe "noreply!" do
    test "unwraps a :noreply tuple" do
      assert Moar.Sugar.noreply!({:noreply, 1}) == 1
    end

    test "fails when it's not a :noreply tuple" do
      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.noreply!/1", fn ->
        Moar.Sugar.noreply!({:ok, :good})
      end

      assert_raise FunctionClauseError, "no function clause matching in Moar.Sugar.noreply!/1", fn ->
        Moar.Sugar.noreply!(:good)
      end
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
