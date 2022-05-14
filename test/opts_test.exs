defmodule Moar.OptsTest do
  use Moar.SimpleCase, async: true

  doctest Moar.Opts

  describe "done!" do
    test "returns the output, discarding the input" do
      input = %{a: 1, b: 2, c: 3, d: 4}

      assert %{a: 1, b: 2, c: 3, e: 100} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.get(:a)
               |> Moar.Opts.take([:b, :c])
               |> Moar.Opts.get(:e, 100)
               |> Moar.Opts.done!()
    end
  end

  describe "get" do
    test "adds one item from input into output" do
      input = %{a: 1, b: 2, c: 3}

      assert {^input, %{a: 1}} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.get(:a)
    end

    test "if the item is missing or blank, its value is set to nil" do
      input = %{a: 1, b: 2, c: nil, d: "", e: [], f: %{}}

      assert {^input, %{a: 1, b: 2, c: nil, d: nil, e: nil, f: nil, g: nil}} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.get(:a)
               |> Moar.Opts.get(:b)
               |> Moar.Opts.get(:c)
               |> Moar.Opts.get(:d)
               |> Moar.Opts.get(:e)
               |> Moar.Opts.get(:f)
               |> Moar.Opts.get(:g)
    end

    test "if the item is missing or blank, it can be set to a default value" do
      input = %{a: 1, b: 2, c: nil, d: "", e: [], f: %{}}

      assert {^input, %{a: 1, b: 2, c: 300, d: 400, e: 500, f: 600, g: 700}} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.get(:a, 100)
               |> Moar.Opts.get(:b, 200)
               |> Moar.Opts.get(:c, 300)
               |> Moar.Opts.get(:d, 400)
               |> Moar.Opts.get(:e, 500)
               |> Moar.Opts.get(:f, 600)
               |> Moar.Opts.get(:g, 700)
    end
  end

  describe "new" do
    test "creates a new Opts by converting input into an atomized map, and creating an empty output" do
      assert {%{a: 1, b: 2, c: 3}, %{}} = Moar.Opts.new(a: 1, b: 2, c: 3)
      assert {%{a: 1, b: 2, c: 3}, %{}} = Moar.Opts.new(%{a: 1, b: 2, c: 3})
      assert {%{a: 1, b: 2, c: 3}, %{}} = Moar.Opts.new(%{"a" => 1, "b" => 2, "c" => 3})
    end
  end

  describe "take" do
    test "takes opts from input and puts into output" do
      input = %{a: 1, b: 2, c: 3}

      assert {^input, %{a: 1, b: 2}} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.take([:a, :b])
    end

    test "unlike Enum.take, requested keys are taken even if not in the input" do
      input = %{a: 1, b: 2, c: nil, d: "", e: [], f: %{}}

      assert {^input, %{a: 1, b: 2, c: nil, d: nil, e: nil, f: nil}} =
               input
               |> Moar.Opts.new()
               |> Moar.Opts.take([:a, :b, :c, :d, :e, :f])
    end
  end
end
