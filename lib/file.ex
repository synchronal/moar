defmodule Moar.File do
  # @related [test](/test/file_test.exs)

  @moduledoc "File-related functions."

  @doc """
  Returns a randomly-named path in the system temp directory. Does not actually create the file at the path.

  For example, `Moar.File.new_tempfile_path(".txt")` would return something like
  `"/var/folders/3r/n09zyyy16yddj9m2d1ppzvt40000gn/T/XY7V5E26DV.txt"`.

  ```elixir
  iex> Moar.File.new_tempfile_path(".txt") |> File.exists?()
  false
  ```
  """
  @spec new_tempfile_path(file_extension :: binary()) :: binary()
  def new_tempfile_path(file_extension),
    do: System.tmp_dir!() |> Path.join(Moar.Random.string(10, :base32) <> file_extension)

  @doc """
  Writes `contents` to a new temp file with extension `file_extension`, and returns the path to the file.

  For example, `Moar.File.write_tempfile("hello", ".txt")` would create a file in a path something like
  `/var/folders/3r/n09zyyy16yddj9m2d1ppzvt40000gn/T/RHUEJCCH22.txt` with the contents `hello`.

  ```elixir
  iex> Moar.File.write_tempfile("hello", ".txt") |> File.read!()
  "hello"
  ```
  """
  @spec write_tempfile(contents :: iodata(), file_extension :: binary()) :: binary()
  def write_tempfile(contents, file_extension),
    do: file_extension |> new_tempfile_path() |> tap(&File.write!(&1, contents, [:append]))
end
