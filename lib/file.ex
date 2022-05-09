defmodule Moar.File do
  # @related [test](/test/file_test.exs)

  @moduledoc "File-related functions."

  @doc "Returns a path to a new temp file in a new temp directory."
  @spec new_tempfile_path(file_extension :: binary()) :: binary()
  def new_tempfile_path(file_extension),
    do: System.tmp_dir!() |> Path.join(Moar.Random.string(10, :base32) <> file_extension)

  @doc "Writes `contents` to a new temp file with extension `file_extension`, and returns the path to the file."
  @spec write_tempfile(contents :: iodata(), file_extension :: binary()) :: binary()
  def write_tempfile(contents, file_extension),
    do: file_extension |> new_tempfile_path() |> tap(&File.write!(&1, contents, [:append]))
end
