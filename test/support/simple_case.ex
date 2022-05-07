defmodule Moar.SimpleCase do
  @moduledoc "A basic test case"

  use ExUnit.CaseTemplate

  using do
    quote do
      import Moar.Assertions
      import ExUnit.Assertions
    end
  end
end
