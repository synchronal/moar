defmodule Moar.FileTest do
  # @related [subject](/lib/file.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.File

  describe "checksum" do
    test "generates a sha256 checksum of a file" do
      {shasum, 0} = System.cmd("sha256sum", ["test/support/fixtures/test.jpg"])
      [sha256, _path, _] = String.split(shasum, ~r[\s+])
      assert Moar.File.checksum("test/support/fixtures/test.jpg") == sha256
    end
  end

  describe "new_tempfile_path" do
    test "generates a tempfile path" do
      ".txt"
      |> Moar.File.new_tempfile_path()
      |> Path.split()
      |> List.last()
      |> assert_eq(~r|^[A-Z2-7]{10}.txt$|)
    end
  end

  describe "write_tempfile" do
    test "writes text to a tempfile with the given extension" do
      path = Moar.File.write_tempfile("the contents", ".txt")
      assert path =~ ~r/.txt$/
      assert File.read!(path) == "the contents"
    end
  end
end
