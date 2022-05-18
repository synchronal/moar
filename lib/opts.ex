defmodule Moar.Opts do
  # @related [test](/test/opts_test.exs)

  @moduledoc """
  Extracts keys and values from enumerables, especially from function options.

  There are two main functions, each of which takes an opts enumerable as input. `get/2` and `get/3` each extract
  one value from the opts. `take/2` extracts multiple values from the opts. `get/3` and `take/2` allow the
  specification of default values.

  Example using `get/2` and `get/3`:

  ```elixir
  def build_url(path, opts \\\\ []) do
    %URI{
      path: path,
      host: Moar.Opts.get(opts, :host, "localhost"),
      port: Moar.Opts.get(opts, :port),
      scheme: "https"
    } |> URI.to_string()
  end
  ```

  Examples using `take/2`:

  ```elixir
  # example using pattern matching
  def build_url(path, opts \\ []) do
    %{host: h, port: p} = Moar.Opts.take(opts, [:port, host: "localhost"])
    %URI{path: path, host: h, port: p, scheme: "https"} |> URI.to_string()
  end

  #example rebinding `opts` to the parsed opts
  def build_url(path, opts \\ []) do
    opts = Moar.Opts.take(opts, [:port, host: "localhost"])
    %URI{path: path, host: opts.host, port: opts.port, scheme: "https"} |> URI.to_string()
  end
  ```
  """

  @doc """
  Get the value of `key` from `input`, falling back to optional `default` if the key does not exist.


  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.get(:a)
  1

  iex> [a: 1, b: 2] |> Moar.Opts.get(:c)
  nil

  iex> [a: 1, b: 2] |> Moar.Opts.get(:c, 300)
  300
  ```
  """
  @spec get(Enum.t(), binary() | atom(), any()) :: any()
  def get(input, key, default \\ nil),
    do: input |> Enum.into(%{}) |> Map.get(key) |> Moar.Term.presence(default)

  @doc """
  Get each key in `keys` from `input`.

  `keys` is a list of keys, a keyword list of keys and default values, or a hybrid list/keyword list.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.take([:a, :c])
  %{a: 1, c: nil}

  iex> [a: 1, b: 2] |> Moar.Opts.take([:a, b: 0, c: 3])
  %{a: 1, b: 2, c: 3}
  ```
  """
  @spec take(Enum.t(), list()) :: map()
  def take(input, keys) do
    input = Enum.into(input, %{})

    Enum.reduce(keys, %{}, fn
      {key, default}, acc -> Map.put(acc, key, get(input, key, default))
      key, acc -> Map.put(acc, key, get(input, key))
    end)
  end
end
