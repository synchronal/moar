# Moar

[![CI](https://github.com/synchronal/moar/actions/workflows/tests.yml/badge.svg)](https://github.com/synchronal/moar/actions)
[![Hex pm](http://img.shields.io/hexpm/v/moar.svg?style=flat)](https://hex.pm/packages/moar) [![License](http://img.shields.io/github/license/synchronal/moar.svg?style=flat)](https://github.com/synchronal/moar/blob/main/LICENSE.md)

A dependency-free utility library containing 100+ useful functions. Part of the [Synchronal suite of
libraries](https://github.com/synchronal) and sponsored by [Reflective Software](https://reflective.dev).

The docs can be found at https://hexdocs.pm/moar.

This library is tested against the most recent 3 versions of Elixir and Erlang.

## Installation

The package can be installed by adding `moar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:moar, "~> 1.58"}
  ]
end
```

Moar's test suite runs successfully against Elixir versions 1.13 and newer.

If you'd rather not install the whole library, you can just copy some of its functions to your project.

## Similar libraries

- [Bunch](https://hexdocs.pm/bunch/readme.html)
- [Swiss](https://hexdocs.pm/swiss/readme.html)
- [WuunderUtils](https://hexdocs.pm/wuunder_utils/api-reference.html)

## A quick tour

`Moar.Assertions`

- `assert_contains` asserts that a list or map contains one or more elements.
- `assert_eq` is a pipeable equality assertion, with options such as the ability to ignore order when comparing lists,
  ignore space when comparing strings, consider only certain keys of a map, returning a different value than what was
  passed in, and asserting that a value is within some delta (which can be a number or time duration).
- `assert_recent` asserts that a datetime is pretty close to now.
- `assert_that` asserts that a pre-condition and post-condition are true after performing an action.
- `refute_that` asserts that a condition didn't change after performing an action.

`Moar.Atom`

- `atomize` when given an atom, returns it; when given a string, converts it to an atom, replacing non-alphanumeric
  characters with underscores.
- `from_string` and `to_string` convert between strings and atoms, and don't fail if you try to convert an atom to an atom
  or a string to a string.
- `to_existing_atom` is like `String.to_existing_atom/1` but can accept an atom as a param.

`Moar.Code`

- `fetch_docs_as_markdown` returns a module's or function's docs as a markdown string

`Moar.DateTime` and `Moar.NaiveDateTime`

- `add` and `subtract` can add and subtract a `Moar.Duration`, which is a tuple with a time unit, like `{27, :minute}`.
- `between?` determines whether a datetime is between two other datetimes.
- `from_iso8601!` raises if the string is not in ISO 8601 format.
- `recent?` returns true if the given datetime was at most one minute ago.
- `to_iso8601_rounded` converts to an ISO 8601 string, truncated to the second.
- `utc_now` takes `plus` and `minus` options to get the current time plus or minus some duration.
- `within?` determines whether a given datetime is within the given duration.

`Moar.Difference`

- a protocol that defines `diff(a, b)` along with implementations for datetimes.

`Moar.Duration`

- is a `{time, unit}` tuple (like `{27, :minute}`) and supports the regular `t:System.time_unit/0` values and also
  `:minute`, `:hour`, and `:day`.
- `ago` returns the duration between a given datetime and now.
- `approx` shifts the duration to a simple approximate value.
- `between` returns the duration between two datetimes.
- `convert` converts a duration to a new time unit, returning only the value.
- `format` formats a duration in long (`"3 seconds"`) or short (`"3s"`) format with optional transformers and suffix.
- `from_now` returns a duration between now and a given datetime.
- `humanize` converts the duration to the highest possible time unit.
- `shift`, `shift_up`, and `shift_down` convert a duration to a new time unit.
- `to_string` renders a duration into a string like `"27 minutes"`.

`Moar.Enum`

- `at!` is like `Enum.at` but raises if the index is out of bounds.
- `compact` rejects nil values.
- `find_indices` returns the indices of matching elements
- `find_indices!` returns the indices of matching elements and raises if any element is not found.
- `first!` returns the first item or raises if there isn't a first item.
- `index_by` converts an enum into a list of maps indexed by the given function.
- `into!` is like `Enum.into` but allows `nil` as its first argument.
- `is_map_or_keyword` returns true if the value is a map or a keyword list (unfortunately cannot be used as a guard).
- `isort` and `isort_by` sort case-insensitively.
- `lists_to_maps` converts a list of lists to a lists of maps using the provided list of keys.
- `take_at` returns a list of elements at the given indices.
- `test_ids` is like `tids` (see below) with a slightly different spelling.
- `tids` extracts `tid` fields. (`tid` is short for "test id" and the authors of Moar use tids extensively for testing.)

`Moar.File`

- `checksum` returns a sha256 checksum of a file.
- `new_tempfile_path` returns a new path for a tempfile, without creating it.
- `stream!` delegates to `File.stream!` in a way that's compatible with older Elixir versions.
- `write_tempfile` writes some data to a new tempfile.

`Moar.Integer`

- `compare` returning `:eq`, `:lt`, `:gt`.

`Moar.List`

- `to_keyword` converts a list into a keyword list, using a default value or function to generate the values
- `to_sentence` converts a list into a string, with items separated by commas, and an "and" before the last item
- `unwrap` returns the argument if it's not a list, or returns the only item in the list, or raises.

`Moar.Map`

- `atomize_key`, `atomize_keys`, and `deep_atomize_keys` convert keys in a map from strings to atoms, and `stringify_keys`
  does the opposite.
- `deep_take` takes a list of keys and `{key, nested_key}` tuples to take from nested maps.
- `index_by` converts a list of maps into a map of maps indexed by the values of one of the keys.
- `merge` and `deep_merge` merge maps, converting enumerables into maps before merging. `deep_merge` also accepts a
  function to resolve value conflicts.
- `merge_if_blank` merge maps, retaining existing non-blank values.
- `put_if_blank` puts a key/value pair into a map if the key is missing or its value is blank (via `Moar.Term.blank?/1`)
- `put_new!` is like `Map.put_new/3` but raises if the key already exists in the map.
- `rename_key` and `rename_keys` rename keys in a map.
- `transform` transforms a key or multiple keys with a transformer function.
- `validate_keys!` validates that the keys in the map are equal to or a subset of a list of valid keys.

`Moar.Opts`

- is meant to be used with function options.
- `delete` deletes a value from opts.
- `get` extracts a value from opts, falling back to a default if the value is blank (via `Moar.Term.blank?/1`)
- `pop` removes a value from opts, falling back to a default if the value is blank (via `Moar.Term.blank?/1`)
- `take` extracts multiple values from opts, falling back to defaults if the value is blank (via `Moar.Term.blank?/1`)

`Moar.Protocol`

- `implements!` raises if a struct does not implement the given protocol.
- `implements?` returns true if a struct implements the given protocol.

`Moar.Random`

- `dom_id` returns a random string that is a valid DOM ID, with an optional prefix.
- `float` returns a random float.
- `fuzz` increases or decreases a number by a random percent.
- `integer` returns a random integer.
- `string` returns random base64- or base32-encoded string.

`Moar.Regex`

- `named_capture` gets a single named capture.
- `named_captures` is like `Regex.named_captures/3` but can take the first two args in any order.

`Moar.Retry`

- `rescue_until` and `rescue_for` run the given function repeatedly until it does not raise.
- `retry_until` and `retry_for` run the given function repeatedly until it returns a truthy value.

`Moar.String`

- `append_unless_blank` appends a suffix to a string, unless the string is blank.
- `compare` and `compare?` compare two strings, optionally transforming the strings before comparison.
- `count_leading_spaces/1` returns the number of leading spaces in a string.
- `inner_truncate` removes the middle of a string to make it the desired length.
- `remove_marked_whitespace` removes whitespacing following a special `\v` marker.
- `secure_compare` compares two strings in constant time.
- `slug` converts a string into a slug with a custom joiner character; `dasherize` and `underscore` are shortcuts for
  common slug formats.
- `squish` collapses consecutive whitespace characters.
- `surround` wraps a string with the given characters.
- `to_case` converts text to `:camel_case`, `:lower_camel_case`, or `:snake_case`.
- `to_integer` converts a string to an integer with a few handy options.
- `trim` is like `String.trim/1` but handles `nil` values.
- `truncate_at` truncates a string at the last instance of a substring that results in the truncated string being shorter
  than a given length.
- `unindent/1` un-indents a multiline string by the smallest indentation size.
- `unindent/2` un-indents a multiline string by the given amount.

`Moar.Sugar`

- `error`, `noreply`, and `ok` create tuples (`"foo" |> error()` -> `{:error, "foo"}`).
- `error!` and `ok!` unwrap tuples (`{:error, "foo"} |> error!()` -> `"foo"`).
- `returning` takes two arguments and returns the second one.

`Moar.Term`

- `blank?` returns true if a term is `nil`, an empty string, a whitespace-only string, an empty list, or an empty map.
- `present?` is the opposite of `blank?`.
- `presence` returns a default if the argument is blank.

`Moar.Tuple`

- `from_list!` converts a list of tuples like `[{:ok, 1}, {:ok, 2}, {:ok, 3}]` to a tuple like `{:ok, [1, 2, 3]}`
- `reduce` converts a list of tuples like `[{:ok, 1}, {:error, 2}]` to a map like `%{ok: [1], error: [2]}`

`Moar.URI`

- `fix` applies some fixes to a URI string.
- `format` formats a URI in various ways.
- `valid?` returns true if the URI has a host and scheme, and if it has a path, the path does not contain spaces.
- `web_url?` returns true if the scheme is `http` or `https`.

`Moar.UUID`

- `regex` returns a Regex that matches valid UUIDs.
- `valid?` returns true if the given string is a valid UUID.

`Moar.Version`

- `compare` is like `Version.compare/2` but normalizes the versions first.
- `normalize` appends as many ".0" strings as necessary to create a string with major, minor, and patch numbers.
