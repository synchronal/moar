defmodule Moar.String do
  # @related [test](/test/string_test.exs)

  @moduledoc "String-related functions."

  import Bitwise

  @type string_case() :: :camel_case | :lower_camel_case | :snake_case

  @doc """
  Appends `suffix` to `string` unless `string` is blank according to `Moar.Term.blank?/1`.

  ```elixir
  iex> Moar.String.append_unless_blank("foo", "-bar")
  "foo-bar"

  iex> Moar.String.append_unless_blank("", "-bar")
  ""

  iex> Moar.String.append_unless_blank(nil, "-bar")
  nil
  ```
  """
  @spec append_unless_blank(binary() | nil, binary() | nil) :: binary()
  def append_unless_blank(string, suffix) do
    if Moar.Term.present?(string) && Moar.Term.present?(suffix),
      do: string <> suffix,
      else: string
  end

  @doc """
  Compares two strings, returning `:lt`, `:eq`, or `:gt` depending on whether the first arg is less than, equal to, or
  greater than the second arg. Accepts one or more functions that transform the inputs before comparison.

  See `Moar.String.compare?/2` for a version that returns `true` or `false`.

  ```
  iex> Moar.String.compare("foo", "FOO")
  :gt

  iex> Moar.String.compare("foo", "FOO", &String.downcase/1)
  :eq

  iex> Moar.String.compare("foo bar", " FOO    bar ", [&String.downcase/1, &Moar.String.squish/1])
  :eq
  ```
  """
  @spec compare(binary(), binary(), (binary() -> binary()) | [(binary() -> binary())]) :: :lt | :eq | :gt
  def compare(left, right, transformer_fns \\ []) do
    List.wrap(transformer_fns)
    |> Enum.reduce({left, right}, fn
      transformer_fn, {left, right} -> {transformer_fn.(left), transformer_fn.(right)}
    end)
    |> case do
      {left, right} when left < right -> :lt
      {left, right} when left > right -> :gt
      _ -> :eq
    end
  end

  @doc """
  Compares two strings, returning `true` if the first arg is less than or equal to the second arg, or `false` if the
  first arg is greater than the second arg. Accepts one or more functions that transform the inputs before comparison.
  Useful for sorter functions like what is passed into `Enum.sort/2`.

  See `Moar.String.compare/2` for a version that returns `:lt`, `:eq`, or `:gt`.

  ```
  iex> Moar.String.compare?("foo", "FOO")
  false

  iex> Moar.String.compare?("foo", "FOO", &String.downcase/1)
  true

  iex> Moar.String.compare?("foo bar", " FOO    bar ", [&String.downcase/1, &Moar.String.squish/1])
  true
  ```
  """
  @spec compare?(binary(), binary(), (binary() -> binary()) | [(binary() -> binary())]) :: boolean()
  def compare?(left, right, transformer_fns \\ []),
    do: compare(left, right, transformer_fns) in [:lt, :eq]

  @doc """
  Returns the number of leading spaces. Only considers "plain" spaces, not all unicode whitespace.

  ```elixir
  iex> Moar.String.count_leading_spaces("  foo")
  2
  ```
  """
  @spec count_leading_spaces(binary()) :: non_neg_integer()
  def count_leading_spaces(<<" ", rest::binary>>), do: 1 + count_leading_spaces(rest)
  def count_leading_spaces(_), do: 0

  @doc """
  Dasherizes `term`. A shortcut to `slug(term, "-")`.

  See docs for `slug/2`.

  ```elixir
  iex> Moar.String.dasherize("foo bar")
  "foo-bar"
  ```
  """
  @spec dasherize(String.Chars.t() | [String.Chars.t()]) :: binary()
  def dasherize(term),
    do: slug(term, "-")

  @doc """
  Truncate `s` to `max_length` by replacing the middle of the string with `replacement`, which defaults to
  the single unicode character `…`.

  Note that the final length of the string will be `max_length` plus the length of `replacement`.

  ```elixir
  iex> Moar.String.inner_truncate("abcdefghijklmnopqrstuvwxyz", 10)
  "abcde…vwxyz"

  iex> Moar.String.inner_truncate("abcdefghijklmnopqrstuvwxyz", 10, "<==>")
  "abcde<==>vwxyz"
  ```
  """
  @spec inner_truncate(binary(), integer(), binary()) :: binary()
  def inner_truncate(s, max_length, replacement \\ "…")

  def inner_truncate(nil, _, _),
    do: nil

  def inner_truncate(s, max_length, replacement) do
    case String.length(s) <= max_length do
      true ->
        s

      false ->
        left_length = (max_length / 2) |> Float.ceil() |> round()
        right_length = (max_length / 2) |> Float.floor() |> round()
        [String.slice(s, 0, left_length), replacement, String.slice(s, -right_length, right_length)] |> to_string()
    end
  end

  @doc """
  Pluralizes a string.

  When `count` is -1 or 1, returns the second argument (the singular string).

  Otherwise, returns the third argument (the pluralized string), or if the third argument is a function,
  calls the function with the singular string as an argument.

  ```elixir
  iex> Moar.String.pluralize(1, "fish", "fishies")
  "fish"

  iex> Moar.String.pluralize(2, "fish", "fishies")
  "fishies"

  iex> Moar.String.pluralize(2, "fish", fn singular -> singular <> "ies" end)
  "fishies"

  iex> Moar.String.pluralize(2, "fish", &(&1 <> "ies"))
  "fishies"
  ```
  """
  @spec pluralize(number(), binary(), binary() | function()) :: binary()
  def pluralize(count, singular, _plural) when count in [-1, 1], do: singular
  def pluralize(_count, _singular, plural) when is_binary(plural), do: plural
  def pluralize(_count, string, pluralizer) when is_function(pluralizer), do: pluralizer.(string)

  @doc """
  Removes all whitespace following a backspace+v escape code.

  Especially useful in test assertions where only some of the whitespace matters.
  ```
  iex> Moar.String.remove_marked_whitespace("one two three\v\t   four five")
  "one two threefour five"
  ```
  """
  @spec remove_marked_whitespace(binary()) :: binary()
  def remove_marked_whitespace(s),
    do: s |> String.replace(~r|\v\s*|, "")

  @doc """
  Compares the two binaries in constant-time to avoid timing attacks.
  See: <http://codahale.com/a-lesson-in-timing-attacks/>.

  ```elixir
  iex> Moar.String.secure_compare("foo", "bar")
  false
  ```
  """
  @spec secure_compare(binary(), binary()) :: boolean()
  def secure_compare(left, right) when is_nil(left) or is_nil(right),
    do: false

  def secure_compare(left, right) when is_binary(left) and is_binary(right),
    do: byte_size(left) == byte_size(right) and secure_compare(left, right, 0)

  defp secure_compare(<<x, left::binary>>, <<y, right::binary>>, acc) do
    xorred = Bitwise.bxor(x, y)
    secure_compare(left, right, acc ||| xorred)
  end

  defp secure_compare(<<>>, <<>>, acc),
    do: acc === 0

  @doc """
  Creates slugs like `foo-bar-123` or `foo_bar` from various input types.

  Converts strings, atoms, and anything else that implements `String.Chars`, plus lists of those things,
  to a single string after removing non-alphanumeric characters, and then joins them with `joiner`.
  Existing occurrences of `joiner` are kept, including leading and trailing ones.

  `dasherize/1` and `underscore/1` are shortcuts that specify a joiner.

  ```elixir
  iex> Moar.String.slug("foo bar", "_")
  "foo_bar"

  iex> Moar.String.slug("foo bar", "+")
  "foo+bar"

  iex> Moar.String.slug(["foo", "bar"], "+")
  "foo+bar"

  iex> Moar.String.slug("_foo bar", "_")
  "_foo_bar"

  iex> ["foo", "FOO", :foo] |> Enum.map(&Moar.String.slug(&1, "-"))
  ["foo", "foo", "foo"]

  iex> ["foo-bar", "foo_bar", :foo_bar, " fooBar ", "  ?foo ! bar  "] |> Enum.map(&Moar.String.slug(&1, "-"))
  ["foo-bar", "foo-bar", "foo-bar", "foo-bar", "foo-bar"]
  ```
  """
  @spec slug(String.Chars.t() | [String.Chars.t()], binary()) :: binary()
  def slug(term, joiner) when is_list(term) do
    Enum.map_join(term, joiner, fn t ->
      t
      |> to_string()
      |> String.replace(~r/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
      |> String.replace(~r/([a-z\d])([A-Z])/, "\\1_\\2")
      |> String.replace(~r{^[^a-z0-9#{joiner}]+}i, "", global: false)
      |> String.replace(~r{[^a-z0-9#{joiner}]+$}i, "", global: false)
      |> String.replace(~r{[^a-z0-9#{joiner}]+}i, joiner)
      |> String.downcase()
    end)
  end

  def slug(term, joiner),
    do: slug([term], joiner)

  @doc """
  Trims spaces from the beginning and end of a string, and replaces consecutive whitespace characters with a single
  space.

  ```elixir
  iex> Moar.String.squish("  foo   bar  \tbaz ")
  "foo bar baz"
  ```
  """
  @spec squish(binary()) :: binary()
  def squish(nil),
    do: nil

  def squish(s),
    do: s |> trim() |> Elixir.String.replace(~r/\s+/, " ")

  @doc """
  Adds `surrounder` to the beginning and end of `s`.

  ```elixir
  iex> Moar.String.surround("Hello", "**")
  "**Hello**"
  ```
  """
  @spec surround(binary(), binary()) :: binary()
  def surround(s, surrounder),
    do: surrounder <> s <> surrounder

  @doc """
  Adds `prefix` to the beginning of `s` and `suffix` to the end.

  ```elixir
  iex> Moar.String.surround("Hello", "“", "”")
  "“Hello”"
  ```
  """
  @spec surround(binary(), binary(), binary()) :: binary()
  def surround(s, prefix, suffix),
    do: prefix <> s <> suffix

  @doc """
  Change the case of a string.

  ```elixir
  iex> Moar.String.to_case("text_with_case", :camel_case)
  "TextWithCase"
  iex> Moar.String.to_case("textWithCase", :camel_case)
  "TextWithCase"
  iex> Moar.String.to_case("some random text", :camel_case)
  "SomeRandomText"

  iex> Moar.String.to_case("text_with_case", :lower_camel_case)
  "textWithCase"
  iex> Moar.String.to_case("textWithCase", :lower_camel_case)
  "textWithCase"
  iex> Moar.String.to_case("some random text", :lower_camel_case)
  "someRandomText"

  iex> Moar.String.to_case("text_with_case", :snake_case)
  "text_with_case"
  iex> Moar.String.to_case("textWithCase", :snake_case)
  "text_with_case"
  iex> Moar.String.to_case("some random text", :snake_case)
  "some_random_text"
  ```
  """
  @spec to_case(binary(), string_case()) :: binary()
  def to_case(s, :camel_case),
    do:
      s
      |> to_case(:lower_camel_case)
      |> String.replace(~r[^(\w)], fn char -> String.upcase(char) end)

  def to_case(s, :lower_camel_case),
    do:
      s
      |> to_case(:snake_case)
      |> String.replace(~r[_(\w)], fn "_" <> char -> String.upcase(char) end)

  def to_case(s, :snake_case),
    do:
      s
      |> underscore()
      |> String.trim()
      |> String.replace_leading("_", "")

  @doc """
  Converts a string to an integer. Returns `nil` if the argument is `nil` or empty string.
  Returns the argument without complaint if it is already an integer.

  ```elixir
  iex> Moar.String.to_integer("12,345")
  12_345

  iex> Moar.String.to_integer("")
  nil

  iex> Moar.String.to_integer(12_345)
  12_345
  ```
  """
  @spec to_integer(nil | binary()) :: integer()
  def to_integer(nil),
    do: nil

  def to_integer(""),
    do: nil

  def to_integer(integer) when is_integer(integer),
    do: integer

  def to_integer(s) when is_binary(s),
    do: s |> trim() |> Elixir.String.replace(",", "") |> Elixir.String.to_integer()

  @doc """
  Like `to_integer/1` but with options:
  * `:lenient` option removes non-digit characters first
  * `default:` option specifies a default in case `s` is nil

  ```elixir
  iex> Moar.String.to_integer("USD$25", :lenient)
  25

  iex> Moar.String.to_integer(nil, default: 0)
  0
  ```
  """
  @spec to_integer(binary(), :lenient | [default: binary()]) :: integer()
  def to_integer(s, :lenient) when is_binary(s),
    do: s |> String.replace(~r|\D|, "") |> Elixir.String.to_integer()

  def to_integer(s, default: default),
    do: s |> to_integer() |> Moar.Term.presence(default)

  @doc "Like `String.trim/1` but returns `nil` if the argument is nil."
  @spec trim(nil | binary()) :: nil | binary()
  def trim(nil), do: nil
  def trim(s) when is_binary(s), do: Elixir.String.trim(s)

  @doc """
  Truncates `s` at the last instance of `at`, causing the string to be at most `limit` characters.

  ```elixir
  iex> Moar.String.truncate_at("I like apples. I like bananas. I like cherries.", ".", 35)
  "I like apples. I like bananas."
  ```
  """
  def truncate_at(s, at, limit) do
    s
    |> String.graphemes()
    |> Enum.take(limit)
    |> Enum.reverse()
    |> Enum.split_while(fn c -> c != at end)
    |> case do
      {a, []} -> a
      {[], b} -> b
      {_a, b} -> b
    end
    |> Enum.reverse()
    |> Enum.join("")
  end

  @doc """
  Underscores `term`. A shortcut to `slug(term, "_")`.

  See docs for `slug/2`.

  ```elixir
  iex> Moar.String.underscore("foo bar")
  "foo_bar"
  ```
  """
  @spec underscore(String.Chars.t() | [String.Chars.t()]) :: binary()
  def underscore(term),
    do: slug(term, "_")

  @doc """
  Unindents a string by finding the smallest indentation of the string, and removing that many spaces from each line.
  Only considers "plain" spaces, not all unicode whitespace.

  ```elixir
  iex> \"""
  ...>      ant
  ...>    bat
  ...>      cat
  ...>        dog
  ...> \""" |> Moar.String.unindent()
  "  ant\nbat\n  cat\n    dog\n"
  ```
  """
  @spec unindent(binary()) :: binary()
  def unindent(s) do
    lines = String.split(s, "\n")
    min_spaces = lines |> Enum.filter(&Moar.Term.present?/1) |> Enum.map(&count_leading_spaces(&1)) |> Enum.min()
    unindent(s, min_spaces)
  end

  @doc """
  Unindents a string by `count` spaces. Only considers "plain" spaces, not all unicode whitespace.

  ```elixir
  iex> \"""
  ...> foo
  ...>   bar
  ...>     baz
  ...> \""" |> Moar.String.unindent(2)
  "foo\nbar\n  baz\n"
  ```
  """
  @spec unindent(binary(), non_neg_integer()) :: binary()
  def unindent(s, count) do
    s
    |> String.split("\n")
    |> Enum.map_join("\n", &String.slice(&1, min(count, count_leading_spaces(&1))..-1))
  end
end
