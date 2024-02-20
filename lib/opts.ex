defmodule Moar.Opts do
  # @related [test](/test/opts_test.exs)

  @moduledoc """
  Extracts keys and values from enumerables, especially from function options.

  There are three main functions, each of which takes an opts enumerable as input. `get/3` extracts
  one value from the opts with an optional default value. `pop/3` is like `get/3` but removes the opt from opts
  and returns the opt and the remaining opts as a tuple. `take/2` extracts multiple values from the opts
  with optional default values for some or all keys.

  `get/3`, `pop/3`, and `take/2` differ from their `Map` and `Keyword` counterparts in the following ways:
  * `get/3`, `pop/3`, and `take/2` accept any enumerable, including maps, keyword lists, and mixed lists like
    `[:a, :b, c: 3, d: 4]`.
  * `get/3`, `pop/3`, and `take/2` will fall back to the default value if the given key's value is blank
    as defined by `Moar.Term.blank?/1` (`nil`, empty strings, strings made up only of whitespace,
    empty lists, and empty maps), and will default valueless keys (e.g., `:a` in `[:a, b: 2]`) to `true` unless a
    different default is specified. The corresponding `Map` and `Keyword` functions only fall back to
    the default value if the value is exactly `nil`, and `Keyword` functions don't support valueless keys.
  * `get/3`, `pop/3`, and `take/2` allow default values to be specified.
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
  Deletes an opt given a key, a {key, value}, or a function that accepts opts and a map, list, or term.

  ```elixir
  iex> Moar.Opts.delete(%{a: 1, b: 2}, :a)
  %{b: 2}

  iex> Moar.Opts.delete([a: 1, b: 2], :a)
  [b: 2]

  iex> Moar.Opts.delete([:a, b: 2], :a)
  [b: 2]

  iex> Moar.Opts.delete([a: 1, b: 2], :a, 1)
  [b: 2]

  iex> Moar.Opts.delete([a: 1, b: 2], :a, 99)
  [a: 1, b: 2]

  iex> Moar.Opts.delete([:a, b: 2], :a, 1)
  [:a, b: 2]

  iex> Moar.Opts.delete([:trim, :downcase, :reverse], fn k -> k == :downcase end)
  [:trim, :reverse]

  iex> Moar.Opts.delete([a: 1, b: 2, c: 3, d: 4], fn {_k, v} -> Integer.mod(v, 2) == 0 end)
  [a: 1, c: 3]
  ```
  """
  @spec delete(map() | list(), any()) :: map() | list()
  @spec delete(map() | list(), any(), any()) :: map() | list()

  def delete(input, fun) when is_function(fun) and is_map(input) do
    Enum.reduce(input, %{}, fn
      {k, v}, acc -> if fun.({k, v}), do: acc, else: Map.put(acc, k, v)
    end)
  end

  def delete(input, fun) when is_function(fun) and is_list(input) do
    List.foldr(input, [], fn
      {k, v}, acc -> if fun.({k, v}), do: acc, else: [{k, v} | acc]
      k, acc -> if fun.(k), do: acc, else: [k | acc]
    end)
  end

  def delete(input, fun) when is_function(fun) do
    if fun.(input),
      do: input,
      else: nil
  end

  def delete(input, key) do
    delete(input, fn
      {k, _v} -> k == key
      k -> k == key
    end)
  end

  def delete(input, key, value) do
    delete(input, fn
      {k, v} -> k == key && v == value
      _ -> false
    end)
  end

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
  Removes an opt from the opts (via `get/3`), returning `{opt, remaining_opts}`.

  ```elixir
  iex> [a: 1, b: 2] |> Moar.Opts.pop(:a)
  {1, [b: 2]}

  iex> [:a, b: 2] |> Moar.Opts.pop(:a)
  {true, [b: 2]}
  ```
  """
  @spec pop(Enum.t(), binary() | atom(), any()) :: {any(), Enum.t()}
  def pop(input, key, default \\ nil)

  def pop(input, key, default) when is_list(input) do
    value = get(input, key, default)

    list =
      cond do
        key in input -> List.delete(input, key)
        Keyword.has_key?(input, key) -> Keyword.delete(input, key)
        :else -> input
      end

    {value, list}
  end

  def pop(input, key, default) when is_map(input),
    do: {get(input, key, default), Map.delete(input, key)}

  @doc """
  Replace an opt.

  ```elixir
  iex> Moar.Opts.replace(%{a: 1, b: 2}, {:a, 1}, {:a, 100})
  %{a: 100, b: 2}

  iex> Moar.Opts.replace([a: 1, b: 2], {:a, 1}, {:a, 100})
  [a: 100, b: 2]

  iex> Moar.Opts.replace([:a, b: 2], :a, :aa)
  [:aa, b: 2]
  ```
  """
  @spec replace(map(), {any(), any()}, {any(), any()}) :: map()
  @spec replace(list(), {any(), any()} | any(), any()) :: list()

  def replace(opts, {key, value}, {replacement_key, replacement_value}) when is_map(opts) do
    Enum.reduce(opts, %{}, fn {k, v}, acc ->
      if key == k && value == v,
        do: Map.put(acc, replacement_key, replacement_value),
        else: Map.put(acc, k, v)
    end)
  end

  def replace(opts, {key, value}, replacement) when is_list(opts) do
    List.foldr(opts, [], fn {k, v}, acc ->
      if key == k && value == v,
        do: [replacement | acc],
        else: [{k, v} | acc]
    end)
  end

  def replace(opts, key, replacement) when is_list(opts) do
    List.foldr(opts, [], fn k, acc ->
      if key == k,
        do: [replacement | acc],
        else: [k | acc]
    end)
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
