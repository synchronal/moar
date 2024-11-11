# Changelog

## Unreleased changes

## 1.61.2

- `Moar.Map.deep_atomize_keys/1` handles struct values without raising.

## 1.61.1

- `Moar.Map.deep_stringify_keys/1` skips stringifying structs.

## 1.61.0

- Add `Moar.Map.deep_stringify_keys/1`.

## 1.60.0

- Add `Moar.String.lorem/1` which generates a "lorem ipsum" string of the given length.

## 1.59.2

- `Moar.UUID.valid?/1` requires the first segment to be 8 hexadecimal characters.

## 1.59.1

- `Moar.UUID.valid?/1` now fails if the input is too long

## 1.59.0

- add `Moar.Random.dom_id/1`

## 1.58.0

- require Elixir 1.15 or greater

## 1.57.0

- test against the latest version of Erlang and Elixir

## 1.56.2

- more doc fixes

## 1.56.1

- doc updates

## 1.56.0

- add `Moar.Code.fetch_docs_as_markdown` to fetch a module's or function's docs as markdown.

## 1.55.0

- add `Moar.Random.fuzz/2` which increases or decreases a number by a random percent.

## 1.54.0

- add `Moar.UUID.regex/0` which returns a regex that matches valid UUIDs
- add `Moar.UUID.valid?/1` which returns true if the given string is a valid UUID

## 1.53.0

- add `Moar.File.checksum/1` which returns a sha256 checksum of a file.
- add `Moar.File.stream!` which delegates to `File.stream!` in a way that's compatible with older Elixir versions.

## 1.52.1

- fix typespecs for `Moar.Assertions.assert_eq/3`

## 1.52.0

- `assert_eq` now raises when an invalid option is provided.
- Add `:apply` and `:map` options to `assert_eq/3` to run one or more functions on `left` or `right` (`:apply`) or run one
  or more functions on each value in `left` or `right` (`:map`).
- The following `assert_eq` transformations are now supported: `:downcase`, `:sort`, `:squish`, `:trim`
- The following `assert_eq` are soft-deprecated: `ignore_order: <boolean>`, `ignore_whitespace: :leading_and_trailing`,
  `whitespace: :squish`, `whitespace: :trim`.
- `Moar.Opts.get/3` and `Moar.Opts.take/2` accept keyword lists with a mix of "valueless" keys and regular keys, like
  `[:a, b: 2]`, where the default value for a "valueless" key is `true`.
- Add `Moar.Opts.pop/3` which pops an opt out of an opts enum.
- Add `Moar.Opts.delete/2` and `Moar.Opts.delete/3` which deletes values from opts.
- Add `Moar.Opts.replace/3` which replaces values in opts.

## 1.51.0

- Add `Moar.Term.when_present` which returns one value when the term is present, and another value when missing

## 1.50.0

- Deprecated `is_map_or_keyword` in favor of `map_or_keyword?`.
- Deprecated `is_map_or_nonempty_keyword` in favor of `map_or_nonempty_keyword?`.

## 1.49.0

- Add `Moar.List.unwrap!` which returns the argument if it's not a list, or returns the only item in the list, or raises
  if the list has 0 or more than 1 item.
- Add `Moar.Random.float` which returns a random float.
- Add `Moar.String.remove_marked_whitespace` which - `remove_marked_whitespace` removes whitespacing following a special
  `\v` marker.
- Add `Moar.URI.format` with `scheme_host_port`, `scheme_host_port_path`, and `simple_string` formats.
- Deprecate `Moar.URI.to_simple_string` in favor of `Moar.URI.format(uri, :simple_string)`.

## 1.48.0

- Add `Moar.Enum.test_ids` which is just like `Moar.Enum.tids` but with a slightly different name.

## 1.47.0

- Add `Moar.Enum.lists_to_maps` which converts a list of lists to a list of maps using the provided list of keys.

## 1.46.0

- `Moar.Enum.tids` accepts a `:sorted` option

## 1.45.1

- `Moar.Version.compare/2` truncates `1.2.3.4` to `1.2.3`.

## 1.45.0

- `Moar.String.count_leading_spaces/1` returns the number of leading spaces in a string.
- `Moar.String.unindent/1` un-indents a multiline string by the smallest indentation size
- `Moar.String.unindent/2` un-indents a multiline string by the given amount

## 1.44.0

- `Moar.List.to_sentence` takes a mapper function, which defaults to `Kernel.to_string/1`.

## 1.43.0

- Add `Moar.List.to_sentence` converts a list into a string, with items separated by commas, and an "and" before the last
  item.

## 1.42.0

- Add `Moar.Integer.compare/2`.

## 1.41.0

- Created `Moar.List` and added `to_keyword` which converts a list to a keyword list, allowing a default value.

## 1.40.0

- `assert_contains` returns consistently-ordered map keys when using OTP 26.0 or greater.

## 1.39.0

- Add `Moar.String.compare` and `Moar.String.compare?` which can transform strings before comparing.

## 1.38.0

- Fix `Moar.DateTime.recent?` to return false when the given datetime is in the future.
- Add `Moar.DateTime.within?` which returns `true` if the given datetime is within the given duration.

## 1.37.0

- Add `Moar.Enum.find_indices!` which raises when a member of the expected elements is not found in the given enumerable.

## 1.36.0

- Add `Moar.Regex` with `named_capture/3` and `named_captures/3` functions.
- Add `Moar.Version` with `compare/2` and `normalize/1` functions.

## 1.35.0

- Add `Moar.Map.compact/1`.

## 1.34.0

- Add `Moar.Map.merge_if_blank/2`.

## 1.33.0

- Add `Moar.Enum.index_by/2` and `Moar.Map.index_by/2` which return a new map indexed by a function or key. Inspired by
  code in: http://johnelmlabs.com/posts/anti-patterns-in-liveview/
- Add `Moar.Map.put_new!/3` which is like `Map.put_new/3` but raises if the key already exists.

## 1.32.0

- Add `Moar.Assertions.assert_contains/2`
- Soft-deprecate `Moar.Assertions.assert_eq`'s `ignore_whitespace: :leading_and_trailing` option in favor of `whitespace:
  :squish` and `whitespace: :trim`

## 1.31.0

- Add `Moar.URI`

## 1.30.0

- Fixed a bug in `Moar.Map.deep_merge/3`, which would incorrectly convert empty lists to maps when they were map or
  keyword list values.
- Add `Moar.Enum.is_map_or_nonempty_keyword/1` which is like `Moar.Enum.is_map_or_keyword/1` but returns false if given an
  empty list.

## 1.29.0

- Add `Moar.Enum.find_indices/3` which returns the indices of elements in an enum.

## 1.28.0

- Add `Moar.Atom.ensure_existing_atoms/2` to check for a list of previously defined atoms.
- Add `Moar.Atom.existing_atom?/1` to check if a string has previously been defined as an atom.
- Add `Moar.Enum.into!/2` which is like `Enum.into/2` but accepts `nil` as its first argument.
- `Moar.Map.merge/2` now accepts `nil` values.
- Add `Moar.Map.validate_keys!/2` which raises if the given map has keys that are not in the given list.

## 1.27.0

- Add `Moar.Map.deep_take/2` to take from nested maps.

## 1.26.0

- Add `Moar.Enum.take_at/2` which returns a list of elements at the given indices.

## 1.25.0

- Add `Moar.Atom.to_existing_atom/1` which acts like `String.to_existing_atom` but can take an atom (or string) as an
  argument.

## 1.24.1

- Bug fix: `Moar.Map.deep_merge/3` used to try to convert any enumerable into a map before merging, but this caused
  problems when a value was some other kind of enumerable that wasn't meant to be a nested map-like structure. Now, it
  only automatically converts keyword lists to maps.
- Add `Moar.Enum.is_map_or_keyword` (which unforuntately cannot be used as a guard).

## 1.24.0

- `Moar.Map.deep_merge/3` accepts a function to resolve merge conflicts.

## 1.23.0

- Add `between?/2` and `recent?/2` to `Moar.DateTime`

## 1.22.0

- `assert_that` and `refute_that` return the result of the action
- Add `:only` and `:except` to documentation for `assert_eq`.

## 1.21.0

- Add `Moar.Atom.atomize/1`

## 1.20.0

- Add `Moar.Map.put_if_blank/3`

## 1.19.3

- Add link to related library "siiibo/assert_match"

## 1.19.2

- `Moar.String.to_integer/1` will return the argument without complaint when it is already an integer.

## 1.19.1

- Add `:crypto` to declared extra applications.
- Clarify documentation for `Moar.String.append_unless_blank/2`.

## 1.19.0

- Add `Moar.String.append_unless_blank/2`.

## 1.18.1

- Fix `Moar.Assertions.refute_that` to work with checks that do not implement `String.Chars`.

## 1.18.0

- Add `Moar.Tuple.reduce/1`.

## 1.17.0

- Add `ignore_whitespace: :leading_and_trailing` option to `Moar.Assertions.assert_eq`.

## 1.16.0

- Add `Moar.Duration.shift_down/1` and `Moar.Duration.shift_up/1`.

## 1.15.0

- Add `Moar.DateTime.subtract/2` and `Moar.NaiveDateTime.subtract/2`.
- Add `Moar.DateTime.utc_now/1` and `Moar.NaiveDateTime.utc_now/1` which allow adding and subtracting from "now".
- Add `Moar.Duration.from_now/1` and a `:from_now` transformer to `Moar.Duration.format/4`.

## 1.14.0

- Add `Moar.Assertions.assert_that/2` without the `:from` assertion.
- Add `Moar.String.to_case/2`.

## 1.13.1

- Doc updates

## 1.13.0

- Add `Moar.String.pluralize/3` to pluralize strings.

## 1.12.0

- Add `Moar.Duration.humanize/1` which can turn `{120, :second}` into `{2, :minute}`, and `Moar.Duration.shift/1` which is
  like `Moar.Duration.convert/1` but returns a duration tuple.
- Add `Moar.Duration.ago/1` which returns the duration between a given datetime and now.
- Add `Moar.Duration.between/2` which returns the duration between two datetimes.
- Add `Moar.Duration.approx/1` which shifts a duration to a simpler approximate value.
- `Moar.Duration` supports more time units: `:approx_month` (30 days), and `approx_year` (12 approx_months).
- Add `Moar.Duration.format/2` which formats a duration in either long (`"3 seconds"`) or short (`"3s"`) format, with
  optional transformers and suffix.

## 1.11.0

- `Moar.Assertions.refute_that/2` macro.
- Add exports to formatter.

## 1.10.0

- `Moar.Map.atomize_key/3` converts dashes in keys to underscores before atomizing. Because the other "atomize" functions
  in this module use this function, they have the same behavior.
- `Moar.String.slug/2` retains any leading or trailing joiners (so `slug("_foo-bar", "_")` now returns `"_foo_bar"`
  instead of `"foo_bar"`).

## 1.9.0

- Add `Moar.String.slug/2` and `Moar.String.underscore/1`.

## 1.8.0

- Add `atomize_key` to `Moar.Map`, which atomizes a map key and raises if atomizing a key would conflict with an exsiting
  atom key. `atomize_keys` and `deep_atomize_keys` now use this function so they can also raise in the same situation.
- Add "!" versions of some functions in `Moar.Map` that raise when a key is not found.
- Add an overview of the library to the readme.

## 1.7.0

- Add `assert_recent` to `Moar.Assertions`

## 1.6.0

- Add `Moar.NaiveDateTime`

## 1.5.0

- Add `Moar.Opts`

## 1.4.0

- Add `Moar.Protocol.implements?/2`
- Add `Moar.Map.deep_merge/2`

## 1.3.0

- `Moar.DateTime.add` can add a `Moar.Duration` to a `DateTime`
- `Moar.Retry.rescue_for!/2` can take a `Moar.Duration`
- Add `Moar.Retry.retry_for` and `Moar.Retry.retry_until`

## 1.2.0

- `Moar.Retry.rescue_for!/2` and `.rescue_until!/2`

## 1.1.0

- Add `Moar.Tuple.from_list!/1`

## 1.0.0

- Update documentation
- Minor formatting fixes
- Remove `Moar.Term.or_default/2` since it is the same as `Moar.Term.presence/2`.

## 0.1.0

- Initial release
