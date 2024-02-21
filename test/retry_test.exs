defmodule Moar.RetryTest do
  # @related [subject](lib/retry.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Retry

  defmodule Counter do
    use Agent

    def start_link(_opts \\ []), do: Agent.start_link(fn -> 0 end)
    def value(pid), do: Agent.get(pid, & &1)
    def increment(pid), do: Agent.update(pid, &(&1 + 1))
    def tick(pid), do: increment(pid) && value(pid)
  end

  setup do
    {:ok, pid} = start_supervised(Counter)
    [counter: pid]
  end

  describe "rescue_for!" do
    test "calls the function repeatedly until it does not raise", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) < 3, do: raise("not 3 yet") end
      Moar.Retry.rescue_for!(100, fun, 10)
    end

    test "accepts a duration", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) < 3, do: raise("not 3 yet") end
      Moar.Retry.rescue_for!({100, :millisecond}, fun, 10)
    end

    test "raises if the function does not stop raising within the timeout period", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) < 10, do: raise("not 10 yet") end

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_for!(20, fun, 10)
      end
    end
  end

  describe "rescue_until!" do
    test "calls the function repeatedly until it does not raise", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) < 3, do: raise("not 3 yet") end
      later = DateTime.add(DateTime.utc_now(), 100, :millisecond)
      Moar.Retry.rescue_until!(later, fun, 10)
    end

    test "raises if the function does not stop raising before the timeout time", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) < 10, do: raise("not 10 yet") end
      later = DateTime.add(DateTime.utc_now(), 20, :millisecond)

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_until!(later, fun, 10)
      end
    end
  end

  describe "retry_for" do
    test "calls the function repeatedly until it returns a truthy value", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) > 3, do: Counter.value(counter) end
      assert {:ok, 4} = Moar.Retry.retry_for(100, fun, 10)
    end

    test "accepts a duration", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) > 3, do: Counter.value(counter) end
      assert {:ok, 4} = Moar.Retry.retry_for({100, :millisecond}, fun, 10)
    end

    test "fails if the function does not return a truthy value within the timeout period", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) > 10, do: Counter.value(counter) end
      assert {:error, :timeout} = Moar.Retry.retry_for(20, fun, 10)
    end
  end

  describe "retry_until" do
    test "calls the function repeatedly until it returns a truthy value", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) > 3, do: Counter.value(counter) end
      later = DateTime.add(DateTime.utc_now(), 100, :millisecond)
      assert {:ok, 4} = Moar.Retry.retry_until(later, fun, 10)
    end

    test "raises if the function does not stop raising before the timeout time", %{counter: counter} do
      fun = fn -> if Counter.tick(counter) > 10, do: Counter.value(counter) end
      later = DateTime.add(DateTime.utc_now(), 20, :millisecond)
      assert {:error, :timeout} = Moar.Retry.retry_until(later, fun, 10)
    end
  end
end
