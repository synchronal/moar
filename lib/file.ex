defmodule Moar.File do
  # @related [test](/test/file_test.exs)

  @moduledoc "File-related functions."

  @doc "Generate a sha256 checksum of a file's contents"
  @spec checksum(Path.t()) :: binary()
  def checksum(path) do
    stream!(path, 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

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

  if Version.compare(System.version(), "1.16.0") in [:gt, :eq] do
    @doc "Delegates to `File.stream!/2` in a way that's compatible with older Elixir versions."
    @spec stream!(Path.t(), pos_integer()) :: File.Stream.t()
    def stream!(path, bytes), do: File.stream!(path, bytes)
  else
    @doc "Delegates to `File.stream!/2` in a way that's compatible with older Elixir versions."
    @spec stream!(Path.t(), pos_integer()) :: File.Stream.t()
    def stream!(path, bytes), do: File.stream!(path, [], bytes)
  end

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
