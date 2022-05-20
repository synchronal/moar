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
  Wraps a term in a :noreply tuple. Useful in pipelines.

  ```elixir
  iex> %{} |> Map.put(:count, 0) |> Moar.Sugar.noreply()
  {:noreply, %{count: 0}}
  ```
  """
  @spec noreply(term()) :: {:noreply, term()}
  def noreply(term), do: {:noreply, term}

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
end
