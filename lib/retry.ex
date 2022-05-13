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
  Run `fun` every `interval` ms until either it doesn't raise an exception or `timeout_ms` expires.

  ```elixir
  iex> Moar.Retry.rescue_for!(200, fn -> raise "always fails" end, 10)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_for!(pos_integer(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_for!(timeout_ms, fun, interval_ms \\ 100) do
    DateTime.utc_now()
    |> DateTime.add(timeout_ms, :millisecond)
    |> rescue_until!(fun, interval_ms)
  end

  @doc """
  Run `fun` every `interval` ms until either it doesn't raise an exception or the current time reaches `time`.

  ```elixir
  iex> date_time = DateTime.add(DateTime.utc_now(), 100, :millisecond)
  iex> Moar.Retry.rescue_until!(date_time, fn -> raise "always fails" end, 10)
  ** (RuntimeError) always fails
  ```
  """
  @spec rescue_until!(DateTime.t(), (() -> any()), pos_integer()) :: any() | no_return
  def rescue_until!(%DateTime{} = time, fun, interval_ms \\ 100) do
    fun.()
  rescue
    e ->
      if DateTime.compare(time, DateTime.utc_now()) == :gt do
        :timer.sleep(interval_ms)
        rescue_until!(time, fun)
      else
        reraise e, __STACKTRACE__
      end
  end
end
