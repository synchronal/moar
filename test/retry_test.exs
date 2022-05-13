defmodule Moar.RetryTest do
  use Moar.SimpleCase, async: true

  doctest Moar.Retry

  defmodule Counter do
    use Agent

    def start_link do
      Agent.start_link(fn -> 0 end, name: __MODULE__)
    end

    def value do
      Agent.get(__MODULE__, & &1)
    end

    def increment do
      Agent.update(__MODULE__, &(&1 + 1))
    end

    def tick do
      increment()
      value()
    end
  end

  setup do
    {:ok, _pid} = Counter.start_link()
    :ok
  end

  describe "rescue_for!" do
    test "calls the function repeatedly until it does not raise" do
      fun = fn -> if Counter.tick() < 3, do: raise("not 3 yet") end
      Moar.Retry.rescue_for!(50, fun, 10)
    end

    test "accepts a duration" do
      fun = fn -> if Counter.tick() < 3, do: raise("not 3 yet") end
      Moar.Retry.rescue_for!({50, :millisecond}, fun, 10)
    end

    test "raises if the function does not stop raising within the timeout period" do
      fun = fn -> if Counter.tick() < 10, do: raise("not 10 yet") end

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_for!(20, fun, 10)
      end
    end
  end

  describe "rescue_until!" do
    test "calls the function repeatedly until it does not raise" do
      fun = fn -> if Counter.tick() < 3, do: raise("not 3 yet") end
      later = DateTime.add(DateTime.utc_now(), 50, :millisecond)
      Moar.Retry.rescue_until!(later, fun, 10)
    end

    test "raises if the function does not stop raising before the timeout time" do
      fun = fn -> if Counter.tick() < 10, do: raise("not 10 yet") end
      later = DateTime.add(DateTime.utc_now(), 20, :millisecond)

      assert_raise RuntimeError, "not 10 yet", fn ->
        Moar.Retry.rescue_until!(later, fun, 10)
      end
    end
  end

  describe "retry_for" do
    test "calls the function repeatedly until it returns a truthy value" do
      fun = fn -> if Counter.tick() > 3, do: Counter.value() end
      assert {:ok, 4} = Moar.Retry.retry_for(50, fun, 10)
    end

    test "accepts a duration" do
      fun = fn -> if Counter.tick() > 3, do: Counter.value() end
      assert {:ok, 4} = Moar.Retry.retry_for({50, :millisecond}, fun, 10)
    end

    test "fails if the function does not return a truthy value within the timeout period" do
      fun = fn -> if Counter.tick() > 10, do: Counter.value() end
      assert {:error, :timeout} = Moar.Retry.retry_for(20, fun, 10)
    end
  end

  describe "retry_until" do
    test "calls the function repeatedly until it returns a truthy value" do
      fun = fn -> if Counter.tick() > 3, do: Counter.value() end
      later = DateTime.add(DateTime.utc_now(), 50, :millisecond)
      assert {:ok, 4} = Moar.Retry.retry_until(later, fun, 10)
    end

    test "raises if the function does not stop raising before the timeout time" do
      fun = fn -> if Counter.tick() > 10, do: Counter.value() end
      later = DateTime.add(DateTime.utc_now(), 20, :millisecond)
      assert {:error, :timeout} = Moar.Retry.retry_until(later, fun, 10)
    end
  end
end
