# Moar

[![CI](https://github.com/synchronal/moar/actions/workflows/tests.yml/badge.svg)](https://github.com/synchronal/moar/actions)
[![Hex pm](http://img.shields.io/hexpm/v/moar.svg?style=flat)](https://hex.pm/packages/moar)
[![License](http://img.shields.io/github/license/synchronal/moar.svg?style=flat)](https://github.com/synchronal/moar/blob/main/LICENSE.md)

An assortment of useful functions.

The docs can be found at <https://hexdocs.pm/moar>

## Installation

The package can be installed by adding `moar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:moar, "~> 1.13"}
  ]
end
```

## Similar libraries

* [Bunch](https://hexdocs.pm/bunch/readme.html)
* [Swiss](https://hexdocs.pm/swiss/readme.html)

## A quick tour

`Moar.Assertions`
* `assert_eq` is a pipeable equality assertion, with options such as the ability to ignore order when comparing
  lists, returning a different value than what was passed in, and asserting that a value is within some delta
  (which can be a number or time duration).
* `assert_recent` asserts that a datetime is pretty close to now.
* `assert_that` asserts that a pre-condition and post-condition are true after performing an action.
* `refute_that` asserts that a condition didn't change after performing an action.

`Moar.Atom`
* `from_string` and `to_string` convert between strings and atoms, and don't fail if you try to convert an
  atom to an atom or a string to a string.
  
`Moar.DateTime` and `Moar.NaiveDateTime`
* `add` can add a `Moar.Duration`, which is a tuple with a time unit, like `{27, :minute}`.
* `from_iso8601!` raises if the string is not in ISO 8601 format.
* `to_iso8601_rounded` converts to an ISO 8601 string, truncated to the second.

`Moar.Difference`
* a protocol that defines `diff(a, b)` along with implementations for datetimes.

`Moar.Duration`
* is a `{time, unit}` tuple (like `{27, :minute}`) and supports the regular `t:System.time_unit/0` values and also
  `:minute`, `:hour`, and `:day`.
* `ago` returns the duration between a given datetime and now.
* `approx` shifts the duration to a simple approximate value.
* `between` returns the duration between two datetimes.
* `convert` converts a duration to a new time unit, returning only the value.
* `format` formats a duration in long (`"3 seconds"`) or short (`"3s"`) format with optional transformers and suffix.
* `humanize` converts the duration to the highest possible time unit.
* `shift` converts a duration to a new time unit.
* `to_string` renders a duration into a string like `"27 minutes"`.

`Moar.Enum`
* `at` is like `Enum.at` but raises if the index is out of bounds.
* `compact` rejects nil values.
* `first!` returns the first item or raises if there isn't a first item.
* `isort` and `isort_by` sort case-insensitively.
* `tids` extracts `tid` fields. (`tid` is short for "test id" and the authors of Moar use tids extensively for testing.)

`Moar.File`
* `new_tempfile_path` returns a new path for a tempfile, without creating it.
* `write_tempfile` writes some data to a new tempfile.

`Moar.Map`
* `atomize_key`, `atomize_keys`, and `deep_atomize_keys` convert keys in a map from strings to atoms, and
  `stringify_keys` does the opposite.
* `merge` and `deep_merge` merge maps, and can also convert enumerables into maps before merging.
* `rename_key` and `rename_keys` rename keys in a map.
* `transform` transforms a key or multiple keys with a transformer function.

`Moar.Opts`
* is meant to be used with function options.
* `get` extracts a value from opts, falling back to a default if the value is blank (via `Moar.Term.blank?/1`)
* `take` extracts multiple values from opts, falling back to defaults if the value is blank (via `Moar.Term.blank?/1`)

`Moar.Protocol`
* `implements!` raises if a struct does not implement the given protocol.
* `implements?` returns true if a struct implements the given protocol.

`Moar.Random`
* `integer` returns a random integer.
* `string` returns random base64- or base32-encoded string.

`Moar.Retry`
* `rescue_until` and `rescue_for` run the given function repeatedly until it does not raise.
* `retry_until` and `retry_for` run the given function repeatedly until it returns a truthy value.

`Moar.String`
* `inner_truncate` removes the middle of a string to make it the desired length.
* `secure_compare` compares two strings in constant time.
* `slug` converts a string into a slug with a custom joiner character; `dasherize` and `underscore` are shortcuts for
  common slug formats.
* `squish` collapses consecutive whitespace characters.
* `surround` wraps a string with the given characters.
* `to_integer` converts a string to an integer with a few handy options.
* `trim` is like `String.trim/1` but handles `nil` values.
* `truncate_at` truncates a string at the last instance of a substring that results in the truncated string
  being shorter than a given length.
  
`Moar.Sugar`
* `error`, `noreply`, and `ok` create tuples (`"foo" |> error()` -> `{:error, "foo"}`).
* `error!` and `ok!` unwrap tuples (`{:error, "foo"} |> error!()` -> `"foo"`).
* `returning` takes two arguments and returns the second one.

`Moar.Term`
* `blank?` returns true if a term is `nil`, an empty string, a whitespace-only string, an empty list, or an empty map.
* `present?` is the opposite of `blank?`.
* `presence` returns a default if the argument is blank.

`Moar.Tuple`
* `from_list!` converts a list of tuples like `[{:ok, 1}, {:ok, 2}, {:ok, 3}]` to a tuple like `{:ok, [1, 2, 3]}`

