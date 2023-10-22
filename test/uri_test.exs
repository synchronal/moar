defmodule Moar.URITest do
  # @related [subject](/lib/uri.ex)

  use Moar.SimpleCase, async: true

  doctest Moar.URI

  describe "fix" do
    test "does not change a valid URI" do
      "https://www.example.com/path?a=b#thing" |> Moar.URI.fix() |> assert_eq("https://www.example.com/path?a=b#thing")
    end

    test "adds 'https' scheme if there is no scheme" do
      "www.example.com/path?a=b#thing" |> Moar.URI.fix() |> assert_eq("https://www.example.com/path?a=b#thing")
    end

    test "can handle an empty path" do
      "www.example.com" |> Moar.URI.fix() |> assert_eq("https://www.example.com/")
    end

    test "adds a default path if there's a scheme and host but no path" do
      "https://www.example.com" |> Moar.URI.fix() |> assert_eq("https://www.example.com/")
    end

    test "handles mis-cased schemes" do
      "HtTpS://www.example.com/foo" |> Moar.URI.fix() |> assert_eq("https://www.example.com/foo")
    end

    test "unwraps cdata" do
      "<![CDATA[http://example.com/foo/bar-1.mp4]]>" |> Moar.URI.fix() |> assert_eq("http://example.com/foo/bar-1.mp4")
    end

    test "returns empty string for empty string" do
      "" |> Moar.URI.fix() |> assert_eq("")
    end

    test "returns nil for nil" do
      nil |> Moar.URI.fix() |> assert_eq(nil)
    end
  end

  describe "format/2" do
    test "with :scheme_host_port, returns scheme://host:port" do
      URI.parse("https://example.com:1234/path?query=string#fragment")
      |> Moar.URI.format(:scheme_host_port)
      |> assert_eq("https://example.com:1234")
    end

    test "with :scheme_host_port and no port, returns scheme://host" do
      URI.parse("https://example.com/path?query=string#fragment")
      |> Moar.URI.format(:scheme_host_port)
      |> assert_eq("https://example.com")
    end

    test "with :scheme_host_port_path, returns scheme://host:port/path" do
      URI.parse("https://example.com:1234/path?query=string#fragment")
      |> Moar.URI.format(:scheme_host_port_path)
      |> assert_eq("https://example.com:1234/path")
    end

    test "with :scheme_host_port_path and no path, returns scheme://host:port/" do
      URI.parse("https://example.com:1234")
      |> Moar.URI.format(:scheme_host_port_path)
      |> assert_eq("https://example.com:1234/")
    end

    test "with :scheme_host_port_path and no port, returns scheme://host/path" do
      URI.parse("https://example.com/path?query=string#fragment")
      |> Moar.URI.format(:scheme_host_port_path)
      |> assert_eq("https://example.com/path")
    end

    test "with :scheme_host_port_path and no port or path, returns scheme://host/" do
      URI.parse("https://example.com")
      |> Moar.URI.format(:scheme_host_port_path)
      |> assert_eq("https://example.com/")
    end

    test "with :simple_string, returns an empty string when given empty or nil" do
      assert Moar.URI.format(nil, :simple_string) == ""
      assert Moar.URI.format("", :simple_string) == ""
    end

    test "with :simple_string, just shows the host and path; no scheme, params, port, or fragment" do
      "https://www.example.com:446/crackers/potato%20chips/fruit?a=1&b=2#something"
      |> Moar.URI.format(:simple_string)
      |> assert_eq("www.example.com/crackers/potato chips/fruit")
    end

    test "with :simple_string, accepts a URI" do
      %URI{
        fragment: "something",
        host: "www.example.com",
        path: "/crackers/potato%20chips/fruit",
        port: 446,
        query: "a=1&b=2",
        scheme: "https"
      }
      |> Moar.URI.format(:simple_string)
      |> assert_eq("www.example.com/crackers/potato chips/fruit")
    end

    test "with :simple_string, when there is no path, just shows the host" do
      "https://www.example.com/"
      |> Moar.URI.format(:simple_string)
      |> assert_eq("www.example.com")
    end

    test "with :simple_string, when there is no scheme or path, shows the host, as long as it was fixed first" do
      "www.example.com"
      |> Moar.URI.fix()
      |> Moar.URI.format(:simple_string)
      |> assert_eq("www.example.com")
    end

    test "with :simple_string, trims off the trailing slash" do
      "https://www.example.com/foo/bar/" |> Moar.URI.format(:simple_string) |> assert_eq("www.example.com/foo/bar")
    end

    test "with :simple_string, ignores urls without hosts" do
      "/foo/bar" |> Moar.URI.format(:simple_string) |> assert_eq("")
      "../" |> Moar.URI.format(:simple_string) |> assert_eq("")
    end
  end

  describe "valid?" do
    setup do
      [uri: %URI{host: "example.com", path: "users/1", scheme: "https"}]
    end

    test "valid", %{uri: uri} do
      assert Moar.URI.valid?(uri)
      assert Moar.URI.valid?(%{uri | path: nil})
      assert Moar.URI.valid?(%{uri | scheme: "http"})
      assert Moar.URI.valid?(%{uri | scheme: "ftp"})
    end

    test "invalid", %{uri: uri} do
      refute Moar.URI.valid?(%{uri | host: nil})
      refute Moar.URI.valid?(%{uri | path: "spaces in path are invalid"})
      refute Moar.URI.valid?(%{uri | scheme: nil})
    end
  end

  describe "web_url?" do
    test "true for http" do
      assert Moar.URI.web_url?("http://example.com")
    end

    test "true for https" do
      assert Moar.URI.web_url?("https://example.com")
    end

    test "false for other schemes" do
      refute Moar.URI.web_url?("ftp://example.com")
      refute Moar.URI.web_url?("ig: @foobar Snap Chat: foobar_123")
    end

    test "false for junk" do
      refute Moar.URI.web_url?("i want to buy some cheese")
    end

    test "false for nil" do
      refute Moar.URI.web_url?(nil)
    end

    test "accepts a URI" do
      assert Moar.URI.web_url?(%URI{host: "www.example.com", scheme: "https"})
    end
  end
end
