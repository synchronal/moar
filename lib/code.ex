defmodule Moar.Code do
  # @related [test](test/code_test.exs)

  @moduledoc "Code-related functions"

  @doc "Fetches `module`'s @moduledoc as a markdown string"
  @spec fetch_docs_as_markdown(module()) :: nil | binary()
  def fetch_docs_as_markdown(module) do
    case Code.fetch_docs(module) do
      {:error, :module_not_found} ->
        nil

      {_, _, _, "text/markdown", %{"en" => doc}, _, _} ->
        doc

      _ ->
        nil
    end
  end

  @doc "Fetches `module`.`function`'s @doc as a markdown string"
  @spec fetch_docs_as_markdown(module(), fun()) :: nil | binary()
  def fetch_docs_as_markdown(module, function) do
    case Code.fetch_docs(module) do
      {:error, :module_not_found} ->
        nil

      {_, _, _, "text/markdown", _, _, docs} ->
        Enum.find_value(docs, fn
          {{:function, ^function, _}, _, _, %{"en" => markdown}, %{}} -> markdown
          _ -> nil
        end)
    end
  end
end
