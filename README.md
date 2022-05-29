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
    {:moar, "~> 1.7"}
  ]
end
```

## A quick tour

`Moar.Assertions`
* `assert_eq` is a pipeable equality assertion, with options such as the ability to ignore order when comparing
  lists, returning a different value than what was passed in, asserting that a value is within some delta which
  can be a number or time duration.
* `assert_recent` asserts that a datetime is pretty close to now.
* `assert_that` asserts that a pre-condition and post-condition are true after performing an action.

`Moar.Atom`
* `from_string` and `to_string` convert between strings and atoms, and don't fail if you try to convert an
  atom to an atom or a string to a string.
  
`Moar.DateTime` and `Moar.NaiveDatetime`
* `add` can add a `Moar.Duration`, which is a tuple with a time unit, like `{27, :minute}`.
* `from_iso8601!` raises if the string is not in ISO 8601 format.

`Moar.Difference`
* a protocol that defines `diff(a, b)` along with implementations for datetimes.

`Moar.Duration`
* is a `{time, unit}` tuple, like `{27, :minute}`, and supports the regular `t:System.time_unit` values and also
  `:minute`, `:hour`, and `:day`.
* `convert` converts between various time units.
* `to_string` renders a time unit into a string like `"27 minutes"`.

`Moar.Enum`
* `at` is like `Enum.at` but raises if the index is out of bounds.
* `compact` rejects nil values.
* `first!` returns the first item or raises if there isn't a first item.
* `isort` and `isort_by` sort case-insensitively.
* `tids` extracts `tid` fields. (`tid` is short for "test id" and the authors of Moar use it extensively for testing.)

`Moar.File`
* `new_tempfile_path` returns a new path for a tempfile, without creating it.
* `write_tempfile` writes some data to a new tempfile.

`Moar.Map`
* `atomize_key`, `atomize_keys`, and `deep_atomize_keys` convert keys in a map from strings to atoms, and
  `stringify_keys` does the opposite.
* `merge` and `deep_merge` merge maps, and can also convert enumerables into maps before merging.
* `rename_key` and `rename_keys` rename keys in a map.
* `transform` transform a key or multiple keys with a transformer function.
