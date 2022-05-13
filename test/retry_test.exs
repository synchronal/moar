defmodule Moar.RetryTest do
  use Moar.SimpleCase, async: true

  doctest Moar.Retry

  defmodule Counter do
    use Agent

    def start_link do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    defp value do
      Agent.get(__MODULE__, & &1)
    end

    defp increment do
      Agent.update(__MODULE__, &(&1 + 1))
    end

    def tick do
      increment()
      value()
    end
  end

  describe "rescue_for!" do
    test "calls the function repeatedly until it does not raise" do
      {:ok, _pid} = Counter.start_link()

      fun = fn -> if Counter.tick() < 3, do: raise("not 3 yet") end
      Moar.Retry.rescue_for!(50, fun, 10)
    end

    test "raises if the function does not stop raising within the timeout period" do
      {:ok, _pid} = Counter.start_link()

      fun = fn -> if Counter.tick() < 10, do: raise("not 10 yet") end

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_for!(20, fun, 10)
      end
    end
  end

  describe "rescue_until!" do
    test "calls the function repeatedly until it does not raise" do
      {:ok, _pid} = Counter.start_link()

      fun = fn -> if Counter.tick() < 3, do: raise("not 3 yet") end
      later = DateTime.add(DateTime.utc_now(), 50, :millisecond)
      Moar.Retry.rescue_until!(later, fun, 10)
    end

    test "raises if the function does not stop raising before the timeout time" do
      {:ok, _pid} = Counter.start_link()

      fun = fn -> if Counter.tick() < 10, do: raise("not 10 yet") end
      later = DateTime.add(DateTime.utc_now(), 20, :millisecond)

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_until!(later, fun, 10)
      end
    end
  end
end
