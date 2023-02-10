# Changelog

## Unreleased changes

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

- Add `Moar.Atom.to_existing_atom/1` which acts like `String.to_existing_atom` but can take an
  atom (or string) as an argument.

## 1.24.1

- Bug fix: `Moar.Map.deep_merge/3` used to try to convert any enumerable into a map before merging, but this caused
  problems when a value was some other kind of enumerable that wasn't meant to be a nested map-like structure.
  Now, it only automatically converts keyword lists to maps.
  
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

- Add `Moar.Duration.humanize/1` which can turn `{120, :second}` into `{2, :minute}`,
  and `Moar.Duration.shift/1` which is like `Moar.Duration.convert/1` but returns a duration tuple.
- Add `Moar.Duration.ago/1` which returns the duration between a given datetime and now.
- Add `Moar.Duration.between/2` which returns the duration between two datetimes.
- Add `Moar.Duration.approx/1` which shifts a duration to a simpler approximate value.
- `Moar.Duration` supports more time units: `:approx_month` (30 days), and `approx_year` (12 approx_months).
- Add `Moar.Duration.format/2` which formats a duration in either long (`"3 seconds"`) or short (`"3s"`) format,
  with optional transformers and suffix.

## 1.11.0

- `Moar.Assertions.refute_that/2` macro.
- Add exports to formatter.

## 1.10.0

- `Moar.Map.atomize_key/3` converts dashes in keys to underscores before atomizing. Because
  the other "atomize" functions in this module use this function, they have the same behavior.
- `Moar.String.slug/2` retains any leading or trailing joiners (so `slug("_foo-bar", "_")` now
  returns `"_foo_bar"` instead of `"foo_bar"`).
  
## 1.9.0

- Add `Moar.String.slug/2` and `Moar.String.underscore/1`.

## 1.8.0

- Add `atomize_key` to `Moar.Map`, which atomizes a map key and raises if atomizing a key would conflict
  with an exsiting atom key. `atomize_keys` and `deep_atomize_keys` now use this function so they can also
  raise in the same situation.
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
