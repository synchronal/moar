defmodule Moar.URI do
  # @related [test](/test/uri_test.exs)

  @moduledoc "URI/URL-related functions."

  @cdata_regex ~r|<!\[CDATA\[([^\]]*)\]\]>|

  @doc """
  Applies some fixes to a URI string if necessary. Returns `nil` when given `nil`.

  Adds a default path if one is not given:

  ```elixir
  iex> Moar.URI.fix("https://www.example.com")
  "https://www.example.com/"

  iex> Moar.URI.fix("https://www.example.com/")
  "https://www.example.com/"

  iex> Moar.URI.fix("https://www.example.com/index.html")
  "https://www.example.com/index.html"
  ```

  Adds an `https` scheme if no scheme is given:

  ```elixir
  iex> Moar.URI.fix("www.example.com/")
  "https://www.example.com/"

  iex> Moar.URI.fix("http://www.example.com/")
  "http://www.example.com/"
  ```

  Lowercases the scheme:

  ```elixir
  iex> Moar.URI.fix("HttpS://www.example.com/")
  "https://www.example.com/"
  ```

  Unwraps CDATA:

  ```elixir
  iex> Moar.URI.fix("<![CDATA[http://example.com/]]>")
  "http://example.com/"
  ```
  """
  @spec fix(binary() | nil) :: binary() | nil
  def fix(nil), do: nil
  def fix(""), do: ""

  def fix("<![CDATA[" <> _ = s) do
    case Regex.run(@cdata_regex, s) do
      nil -> s
      [_original, cdata_contents] -> cdata_contents
    end
  end

  def fix(s) when is_binary(s) do
    parsed = URI.parse(s)

    parsed =
      if parsed.path == nil,
        do: %URI{parsed | path: "/"},
        else: parsed

    parsed =
      if parsed.scheme == nil && parsed.host == nil do
        {host, path} = extract_host_from_path(parsed.path)
        %URI{parsed | host: host, scheme: "https", path: path}
      else
        parsed
      end

    parsed |> URI.to_string()
  end

  @doc """
  Formats a URI as a string with the given format. Format options:

  `scheme_host_port`: converts to `<scheme>://<host>[:<port>]` format, where the port is only rendered
  if the original URI includes the port.

  `scheme_host_port_path`: converts to `<scheme>://<host>[:<port>]/<path>` format, where the port is only rendered
  if the original URI included the port, and the path is rendered as `/` if the original URI does not include a path.

  `simple_string`: converts to a simplified string representation of a URI for display purposes. Scheme, port, params,
  and fragments are removed. `nil` is converted to an empty string. The return value is not a valid URI.

  ```elixir
  iex> url = "https://www.example.com:446/crackers/potato%20chips/fruit?a=1&b=2#something"
  iex> Moar.URI.format(url, :scheme_host_port)
  "https://www.example.com:446"

  iex> url = "https://www.example.com:446/crackers/potato%20chips/fruit?a=1&b=2#something"
  iex> Moar.URI.format(url, :scheme_host_port_path)
  "https://www.example.com:446/crackers/potato%20chips/fruit"

  iex> url = "https://www.example.com:446/crackers/potato%20chips/fruit?a=1&b=2#something"
  iex> Moar.URI.format(url, :simple_string)
  "www.example.com/crackers/potato chips/fruit"

  iex> Moar.URI.format(nil, :simple_string)
  ""
  ```
  """
  @spec format(URI.t() | binary(), atom()) :: binary()
  def format(string_or_uri, :scheme_host_port) do
    %{URI.parse(string_or_uri) | fragment: nil, path: nil, query: nil, userinfo: nil} |> URI.to_string()
  end

  def format(string_or_uri, :scheme_host_port_path) do
    parsed = URI.parse(string_or_uri)
    %{parsed | fragment: nil, path: parsed.path || "/", query: nil, userinfo: nil} |> URI.to_string()
  end

  def format(nil, :simple_string), do: ""
  def format("", :simple_string), do: ""

  def format(string_or_uri, :simple_string) do
    uri = URI.parse(string_or_uri)

    cond do
      uri.host == nil -> ""
      uri.path == "/" -> uri.host
      Moar.Term.blank?(uri.path) -> uri.host
      true -> (uri.host <> URI.decode_www_form(uri.path)) |> String.trim_trailing("/")
    end
  end

  @deprecated "Use `Moar.URI.format/2` with the `:simple_string` argument."
  @doc """
  Returns a simplified string representation of a URI for display purposes. Scheme, port, params, and fragments are
  removed. `nil` is converted to an empty string.
  """
  @spec to_simple_string(binary() | URI.t() | nil) :: binary()
  def to_simple_string(uri), do: format(uri, :simple_string)

  @doc """
  Returns `true` if the URI has a host and scheme, and if it has a path, the path does not contain spaces.

  ```elixir
  iex> Moar.URI.valid?(%URI{host: "example.com", path: "users/1", scheme: "https"})
  true

  iex> Moar.URI.valid?(%URI{host: "example.com", path: "users/1", scheme: nil})
  false

  iex> Moar.URI.valid?(%URI{host: "example.com", path: "spaces not allowed", scheme: "https"})
  false
  ```
  """
  @spec valid?(URI.t()) :: boolean()
  def valid?(%URI{host: host, path: path, scheme: scheme} = _uri),
    do: host != nil && scheme != nil && (path == nil || !String.contains?(path, " "))

  @doc """
  Returns `true` when given a valid URI string with an `http` or `https` scheme.

  ```elixir
  iex> Moar.URI.web_url?(nil)
  false

  iex> Moar.URI.web_url?("ftp://example.org")
  false

  iex> Moar.URI.web_url?("http://example.org")
  true
  ```
  """
  @spec web_url?(nil | binary() | URI.t()) :: boolean()
  def web_url?(nil), do: false
  def web_url?(s) when is_binary(s), do: s |> fix() |> URI.parse() |> web_url?()
  def web_url?(%URI{} = uri), do: valid?(uri) && uri.scheme in ["http", "https"]

  # # #

  defp extract_host_from_path(nil), do: nil
  defp extract_host_from_path(""), do: ""

  defp extract_host_from_path(path) when is_binary(path) do
    [beginning | rest] = String.split(path, "/")

    if beginning |> String.contains?("."),
      do: {beginning, "/" <> Enum.join(rest, "/")},
      else: {nil, path}
  end
end
