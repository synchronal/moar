defmodule TestModule do
  defmodule ModuleWithDocs do
    @moduledoc "This is the *module doc*"

    @doc "This is the *fun doc*"
    def fun_with_docs, do: nil

    def fun_without_docs, do: nil
  end

  defmodule ModuleWithoutDocs do
  end
end
