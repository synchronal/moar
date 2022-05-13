defmodule Moar.Retry do
  # @related [test](/test/retry_test.exs)

  @moduledoc """
  Retryable functions.
  """

  @default_interval 100

  @doc """
  Run `fun` every `interval_ms` until it doesn't raise an exception.
  If `timeout` expires, the exception will be re-raised.

  * `timeout` can be an integer in milliseconds or a `Moar.Duration` tuple

  ```elixir
  iex> Moar.Retry.rescue_for!(20, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails

  iex> Moar.Retry.rescue_for!({20, :millisecond}, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_for!(pos_integer() | Moar.Duration.t(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_for!(timeout, fun, interval_ms \\ @default_interval) do
    expiry = Moar.DateTime.add(DateTime.utc_now(), duration(timeout))
    rescue_until!(expiry, fun, interval_ms)
  end

  @doc """
  Run `fun` every `interval_ms` until it doesn't raise an exception.
  If the current time reaches `expiry`, the exception will be re-raised.

  ```elixir
  iex> date_time = DateTime.add(DateTime.utc_now(), 20, :millisecond)
  iex> Moar.Retry.rescue_until!(date_time, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_until!(DateTime.t(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_until!(%DateTime{} = expiry, fun, interval_ms \\ @default_interval) do
    fun.()
  rescue
    e ->
      if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
        :timer.sleep(interval_ms)
        rescue_until!(expiry, fun)
      else
        reraise e, __STACKTRACE__
      end
  end

  @doc """
  Run `fun` every `interval_ms` until it returns a truthy value, returning `{:ok, <value>}`.
  If `timeout` expires, returns `{:error, :timeout}`.

  * `timeout` can be an integer in milliseconds or a `Moar.Duration` tuple

  ```elixir
  iex> Moar.Retry.retry_for(20, fn -> 10 end, 2)
  {:ok, 10}

  iex> Moar.Retry.retry_for(20, fn -> false end, 2)
  {:error, :timeout}
  ```
  """
  @spec retry_for(pos_integer() | Moar.Duration.t(), fun(), pos_integer()) :: {:ok, any()} | {:error, :timeout}
  def retry_for(timeout, fun, interval_ms \\ @default_interval) do
    expiry = Moar.DateTime.add(DateTime.utc_now(), duration(timeout))
    retry_until(expiry, fun, interval_ms)
  end

  @doc """
  Run `fun` every `interval_ms` until it returns a truthy value, returning `{:ok, <value>}`.
  If the current time reaches `expiry`, returns `{:error, :timeout}`.

  ```elixir
  iex> date_time = DateTime.add(DateTime.utc_now(), 20, :millisecond)
  iex> Moar.Retry.retry_until(date_time, fn -> false end, 2)
  {:error, :timeout}
  ```
  """
  @spec retry_until(DateTime.t(), fun(), pos_integer()) :: {:ok, any()} | {:error, :timeout}
  def retry_until(expiry, fun, interval_ms \\ @default_interval) do
    cond do
      result = fun.() ->
        {:ok, result}

      DateTime.compare(expiry, DateTime.utc_now()) == :gt ->
        :timer.sleep(interval_ms)
        retry_until(expiry, fun, interval_ms)

      true ->
        {:error, :timeout}
    end
  end

  # # #

  defp duration({_time, _unit} = duration), do: duration
  defp duration(time) when is_integer(time), do: {time, :millisecond}
end
