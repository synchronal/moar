defmodule Moar.Retry do
  # @related [test](/test/retry_test.exs)

  # TODO:
  # - implement: retry_until(DateTime.t(), fun()) :: {:ok, any()} | {:error, :timeout}
  # - implement: retry_for(pos_integer(), fun()) :: {:ok, any()} | {:error, :timeout}
  #
  # see: https://github.com/RatioPBC/euclid/blob/main/test/support/helpers/retry.ex

  @spec rescue_for!(pos_integer(), (() -> any())) :: any() | no_return
  def rescue_for!(timeout_ms \\ 5000, fun) when is_function(fun) and is_number(timeout_ms) do
    DateTime.utc_now()
    |> DateTime.add(timeout_ms, :millisecond)
    |> rescue_until!(fun)
  end

  @spec rescue_until!(DateTime.t(), (() -> any())) :: any() | no_return
  def rescue_until!(%DateTime{} = time, fun) when is_function(fun) do
    fun.()
  rescue
    e ->
      if DateTime.compare(time, DateTime.utc_now()) == :gt do
        :timer.sleep(100)
        rescue_until!(time, fun)
      else
        reraise e, __STACKTRACE__
      end
  end
end
