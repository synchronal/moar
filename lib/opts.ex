defmodule Moar.Opts do
  # @related [test](/test/opts_test.exs)

  @moduledoc """
  Extracts keys and values from enumerables, especially from function options.

  There are two main functions, each of which takes an opts enumerable as input. `get/3` extracts
  one value from the opts with an optional default value. `take/2` extracts multiple values from the opts
  with optional default values for some or all keys.

  `get/3` and `take/2` differ from their `Map` and `Keyword` counterparts in the following ways:
  * `get/3` and `take/2` accept any enumerable, including maps, keyword lists, and mixed lists like
    `[:a, :b, c: 3, d: 4]`.
  * `get/3` and `take/2` will fall back to the default value if the given key's value is blank
    as defined by `Moar.Term.blank?/1` (`nil`, empty strings, strings made up only of whitespace,
    empty lists, and empty maps), and will default valueless keys (e.g., `:a` in `[:a, b: 2]`) to `true` unless a
    different default is specified. The corresponding `Map` and `Keyword` functions only fall back to
    the default value if the value is exactly `nil`, and `Keyword` functions don't support valueless keys.
  * `get/3` and take/2` allow default values to be specified.
  * `take/2` will return the value for a requested key even if the key is not in the input enumerable.

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

  # example rebinding `opts` to the parsed opts
  def build_url(path, opts \\ []) do
    opts = Moar.Opts.take(opts, [:port, host: "localhost"])
    %URI{path: path, host: opts.host, port: opts.port, scheme: "https"} |> URI.to_string()
  end
  ```
  """

  @doc """
  Get the value of `key` from `input`, falling back to optional `default` if the key does not exist,
  or if its value is blank (via `Moar.Term.blank?/1`).

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.get(:a)
  1

  iex> [:a, b: 2] |> Moar.Opts.get(:a)
  true

  iex> [a: 1, b: 2] |> Moar.Opts.get(:c)
  nil

  iex> [a: 1, b: 2, c: ""] |> Moar.Opts.get(:c)
  nil

  iex> [a: 1, b: 2, c: %{}] |> Moar.Opts.get(:c)
  nil

  iex> [a: 1, b: 2, c: "   "] |> Moar.Opts.get(:c, 300)
  300
  ```
  """
  @spec get(Enum.t(), binary() | atom(), any()) :: any()
  def get(input, key, default \\ nil) do
    Enum.find_value(input, fn
      {k, v} -> k == key && Moar.Term.presence(v)
      k -> k == key && Moar.Term.presence(default, true)
    end) || default
  end

  @doc """
  Get the value each key in `keys` from `input`, falling back to optional default values for keys that
  do not exist, or for values that are blank (via `Moar.Term.blank?/1`).

  If `key` does not exist in `keys`, returns `nil`, or returns the default value if provided.

  `keys` is a list of keys (e.g., `[:a, :b]`),
  a keyword list of keys and default values (e.g., `[a: 1, b: 2]`),
  or a hybrid list/keyword list (e.g., `[:a, b: 2]`)

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.take([:a, :c])
  %{a: 1, c: nil}

  iex> [:a, b: 2] |> Moar.Opts.take([:a, :c])
  %{a: true, c: nil}

  iex> [a: 1, b: 2] |> Moar.Opts.take([:a, b: 0, c: 3])
  %{a: 1, b: 2, c: 3}
  ```
  """
  @spec take(Enum.t(), list()) :: map()
  def take(input, keys) do
    Enum.reduce(keys, %{}, fn
      {key, default}, acc -> Map.put(acc, key, get(input, key, default))
      key, acc -> Map.put(acc, key, get(input, key))
    end)
  end
end
