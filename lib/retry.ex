defmodule Moar.Retry do
  # @related [test](/test/retry_test.exs)

  @moduledoc """
  Retryable functions.
  """

  # TODO:
  # - implement: retry_until(DateTime.t(), fun()) :: {:ok, any()} | {:error, :timeout}
  # - implement: retry_for(pos_integer(), fun()) :: {:ok, any()} | {:error, :timeout}
  #
  # see: https://github.com/RatioPBC/euclid/blob/main/test/support/helpers/retry.ex

  @doc """
  Run `fun` every `interval` ms until it doesn't raise an exception.
  If `timeout` expires, the exception will be re-raised.

  * `timeout` can be an integer (milliseconds) or a `Moar.Duration` tuple

  ```elixir
  iex> Moar.Retry.rescue_for!(20, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails

  iex> Moar.Retry.rescue_for!({20, :millisecond}, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_for!(pos_integer() | Moar.Duration.t(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_for!(timeout, fun, interval_ms \\ 100) do
    timeout = if is_tuple(timeout), do: timeout, else: {timeout, :millisecond}
    expiry = Moar.DateTime.add(DateTime.utc_now(), timeout)
    rescue_until!(expiry, fun, interval_ms)
  end

  @doc """
  Run `fun` every `interval` ms until either it doesn't raise an exception.
  If the current time reaches `expiry`, the exception will be re-raised.

  ```elixir
  iex> date_time = DateTime.add(DateTime.utc_now(), 20, :millisecond)
  iex> Moar.Retry.rescue_until!(date_time, fn -> raise "always fails" end, 2)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_until!(DateTime.t(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_until!(%DateTime{} = expiry, fun, interval_ms \\ 100) do
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
end
