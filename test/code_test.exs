defmodule Moar.CodeTest do
  # @related [subject](/lib/code.ex)

  use Moar.SimpleCase, async: true

  describe "fetch_docs_as_markdown" do
    test "fetches a module's docs as markdown" do
      assert Moar.Code.fetch_docs_as_markdown(TestModule.ModuleWithDocs) == "This is the *module doc*"
    end

    test "fetches a function's docs as markdown" do
      assert Moar.Code.fetch_docs_as_markdown(TestModule.ModuleWithDocs, :fun_with_docs) == "This is the *fun doc*"
    end

    test "returns nil if the module has no markdown docs" do
      assert Moar.Code.fetch_docs_as_markdown(TestModule.ModuleWithoutDocs) == nil
    end

    test "returns nil if the function has no markdown docs" do
      assert Moar.Code.fetch_docs_as_markdown(TestModule.ModuleWithoutDocs, :fun_without_docs) == nil
    end
  end
end
