defmodule Moar.VersionTest do
  # @related [subject](/lib/version.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.Version

  describe "compare" do
    test "works just like `Version.compare`" do
      assert Moar.Version.compare("1.2.3", "1.2.4") == :lt
    end

    test "unlike `Version.compare`, will normalize versions" do
      assert Moar.Version.compare("1.2", "1.2.4") == :lt
    end

    test "matches 4-number versions to 3-number versions" do
      assert Moar.Version.compare("1.2.3.4", "1.2.3") == :eq
      assert Moar.Version.compare("1.2.3.4", "1.2.2") == :gt
      assert Moar.Version.compare("1.2.3.4", "1.2.4") == :lt
    end
  end

  describe "normalize" do
    test "returns major.minor.patch.bug unchanged" do
      assert Moar.Version.normalize("1.2.3.4") == "1.2.3"
    end

    test "returns major.minor.patch unchanged" do
      assert Moar.Version.normalize("1.2.3") == "1.2.3"
    end

    test "adds patch value if needed" do
      assert Moar.Version.normalize("1.2") == "1.2.0"
    end

    test "adds minor value if needed" do
      assert Moar.Version.normalize("1") == "1.0.0"
    end

    test "adds major value if needed" do
      assert Moar.Version.normalize("") == "0.0.0"
      assert Moar.Version.normalize(nil) == "0.0.0"
    end
  end
end
