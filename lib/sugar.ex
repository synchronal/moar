defmodule Moar.Sugar do
  # @related [test](/test/sugar_test.exs)

  @moduledoc """
  Syntactic sugar functions.

  These functions are intended to be used by importing the functions or the whole module:

  ```
  import Moar.Sugar, only: [noreply: 1]

  def handle_event("foo", _params, socket) do
    socket |> assign(foo: "bar") |> noreply()
  end
  ```
  """
  @doc """
  Wraps a term in a :cont tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, "unknown") |> Moar.Sugar.cont()
  {:cont, %{count: "unknown"}}
  ```
  """
  @spec cont(term()) :: {:cont, term()}
  def cont(term), do: {:cont, term}

  @doc """
  Unwraps a :cont tuple, raising if the term is not an :cont tuple.

  ```elixir
  iex> {:cont, 1} |> Moar.Sugar.cont!()
  1
  ```
  """
  @spec cont!({:cont, term()}) :: term()
  def cont!({:cont, term}), do: term

  @doc """
  Wraps a term in an :error tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, "unknown") |> Moar.Sugar.error()
  {:error, %{count: "unknown"}}
  ```
  """
  @spec error(term()) :: {:error, term()}
  def error(term), do: {:error, term}

  @doc """
  Unwraps an :error tuple, raising if the term is not an :error tuple.

  ```elixir
  iex> {:error, 1} |> Moar.Sugar.error!()
  1
  ```
  """
  @spec error!({:error, term()}) :: term()
  def error!({:error, term}), do: term

  @doc """
  Wraps a term in a :halt tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, "unknown") |> Moar.Sugar.halt()
  {:halt, %{count: "unknown"}}
  ```
  """
  @spec halt(term()) :: {:halt, term()}
  def halt(term), do: {:halt, term}

  @doc """
  Unwraps a :halt tuple, raising if the term is not an :halt tuple.

  ```elixir
  iex> {:halt, 1} |> Moar.Sugar.halt!()
  1
  ```
  """
  @spec halt!({:halt, term()}) :: term()
  def halt!({:halt, term}), do: term

  @doc """
  Wraps a term in a :noreply tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, 0) |> Moar.Sugar.noreply()
  {:noreply, %{count: 0}}
  ```
  """
  @spec noreply(term()) :: {:noreply, term()}
  def noreply(term), do: {:noreply, term}

  @doc """
  Unwraps a :noreply tuple, raising if the term is not an :noreply tuple.

  ```elixir
  iex> {:noreply, 1} |> Moar.Sugar.noreply!()
  1
  ```
  """
  @spec noreply!({:noreply, term()}) :: term()
  def noreply!({:noreply, term}), do: term

  @doc """
  Wraps a term in an :ok tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, 10) |> Moar.Sugar.ok()
  {:ok, %{count: 10}}
  ```
  """
  @spec ok(term()) :: {:ok, term()}
  def ok(term), do: {:ok, term}

  @doc """
  Unwraps an :ok tuple, raising if the term is not an :ok tuple.

  ```elixir
  iex> {:ok, 1} |> Moar.Sugar.ok!()
  1
  ```
  """
  @spec ok!({:ok, term()}) :: term()
  def ok!({:ok, term}), do: term

  @doc """
  Wraps two terms in a :reply tuple, reversing the terms. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, 0) |> Moar.Sugar.reply(:ok)
  {:reply, :ok, %{count: 0}}
  ```
  """
  @spec reply(term(), term()) :: {:reply, term(), term()}
  def reply(term, message), do: {:reply, message, term}

  @doc """
  Accepts two arguments and returns the second.

  Useful at the end of the pipeline when you want to return a different value than the last result of the pipeline,
  such as when the pipeline has side effects.

  ```elixir
  iex> %{} |> Map.put(:count, 20) |> Moar.Sugar.returning(:count_updated)
  :count_updated
  ```
  """
  @spec returning(any(), any()) :: any()
  def returning(_first, second), do: second

  @doc """
  Accepts an argument and passes it into the given function if the condition is truthy.

  ``` elixir
  iex> 1 |> Moar.Sugar.then_if(nil, &(&1 + 1))
  1
  iex> 1 |> Moar.Sugar.then_if(false, &(&1 + 1))
  1

  iex> 1 |> Moar.Sugar.then_if("exists", &(&1 + 1))
  2
  ```
  """
  @spec then_if(term(), term(), (term() -> term())) :: term()
  def then_if(a, truthy, _fun) when truthy in [false, nil], do: a
  def then_if(a, _truthy, fun), do: fun.(a)
end
