defmodule Moar.Opts do
  # @related [test](/test/opts_test.exs)

  @moduledoc """
  Extracts keys and values from enumerables. Meant to be used to handle function options.

  ```elixir
  iex> [a: 1, b: 2, c: 3]
  ...> |> Moar.Opts.new()
  ...> |> Moar.Opts.get(:a)
  ...> |> Moar.Opts.take([:b, :d])
  ...> |> Moar.Opts.get(:e, 100)
  ...> |> Moar.Opts.done!()
  %{a: 1, b: 2, d: nil, e: 100}
  ```
  """

  @type t() :: {map(), map()}

  @doc """
  Create a new Opts from `input`.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.new()
  {%{a: 1, b: 2}, %{}}
  ```
  """
  @spec new(Enum.t()) :: t()
  def new(input), do: {input |> Enum.into(%{}) |> Moar.Map.atomize_keys(), %{}}

  @doc """
  Get one item from the original input.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.get(:a)
  {%{a: 1, b: 2}, %{a: 1}}

  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.get(:a) |> Moar.Opts.get(:c, 300)
  {%{a: 1, b: 2}, %{a: 1, c: 300}}

  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.get(:a) |> Moar.Opts.get(:c, 300) |> Moar.Opts.done!()
  %{a: 1, c: 300}
  ```
  """
  @spec get(t(), atom(), any()) :: t()
  def get({input, output} = _opts, key, default \\ nil) do
    value = Map.get(input, key) |> Moar.Term.presence(default)
    output = Map.put(output, key, value)
    {input, output}
  end

  @doc """
  Take multiple items from the original input.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.take([:a, :c])
  {%{a: 1, b: 2}, %{a: 1, c: nil}}

  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.take([:a, :c]) |> Moar.Opts.done!()
  %{a: 1, c: nil}
  ```
  """
  @spec take(t(), keyword()) :: t()
  def take({input, output} = _opts, keys) do
    output =
      Enum.reduce(keys, output, fn key, acc ->
        value = Map.get(input, key) |> Moar.Term.presence(nil)
        Map.put(acc, key, value)
      end)

    {input, output}
  end

  @doc """
  Finalize the opts, returning the values obtained via `get/3` and `take/2` and discarding the original input.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.new() |> Moar.Opts.get(:a) |> Moar.Opts.done!()
  %{a: 1}
  ```
  """
  @spec done!(t()) :: map()
  def done!({_input, output} = _opts), do: output
end
