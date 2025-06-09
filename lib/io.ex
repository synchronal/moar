defmodule Moar.IO do
  # @related [test](test/io_test.exs)
  @moduledoc "IO-related functions"

  defmodule ANSI do
    @doc "Parses a string as described in `Moar.IO.cformat/2`"
    @spec parse(String.t()) :: iolist()
    def parse(string),
      do: Regex.split(pattern(), string, include_captures: true) |> Enum.map(&convert/1)

    @doc "Converts one formatting expression to an iolist"
    @spec convert(String.t()) :: iolist()
    def convert(string) do
      trimmed_string = String.trim(string)

      if String.first(trimmed_string) == "{" && String.last(trimmed_string) == "}" do
        [_, formats, text] = Regex.run(pattern(), trimmed_string)
        formats = formats |> String.split(~r/\W+/) |> Enum.map(&String.to_atom/1) |> maybe_unwrap_list()
        [formats, text, :reset]
      else
        string
      end
    end

    defp maybe_unwrap_list([item]), do: item
    defp maybe_unwrap_list(list) when is_list(list), do: list

    defp pattern, do: ~r/\{([^:]+):\s?([^\}]*)}/
  end

  @doc "Formats a string and prints it to stdout. See `cformat/2` for details."
  @spec cputs(String.t(), boolean()) :: :ok
  def cputs(string, emit? \\ IO.ANSI.enabled?()),
    do: string |> cformat(emit?) |> IO.puts()

  @doc """
  Accepts a string with special formatting syntax and converts it into an `iolist` that contains
  ANSI color and formatting codes. The second parameter, `emit?` can be used to enable or disable
  formatting; it defaults to the value of `IO.ANSI.enabled?/0`.

  The formatting syntax looks like:

      "My {green: hovercraft} is {red italic: full of eels}!"

  The formatting options are the ANSI codes that are allowed to be sent to `IO.ANSI.format/2`.
  There doesn't seem to be a list of valid codes, but the names of most of the zero-arity functions
  in `IO.ANSI` can be used. The order of the formatting options is not important.

  The resulting iolist can be used anywhere that iodata is expected. This module's `cstring/2` function
  will take the same input and return a string, and `cputs/2` will take the same input and print it to
  stdout.
  """
  @spec cformat(String.t(), boolean()) :: iolist()
  def cformat(string, emit? \\ IO.ANSI.enabled?()),
    do: string |> Moar.IO.ANSI.parse() |> IO.ANSI.format_fragment(emit?)

  @doc "Formats a string and returns the formatted string. See `cformat/2` for details."
  @spec cstring(String.t(), boolean()) :: String.t()
  def cstring(string, emit? \\ IO.ANSI.enabled?()),
    do: string |> cformat(emit?) |> to_string()
end
