# Changelog

## Unreleased changes

- `Moar.Duration.to_short_string/1` converts duration to short strings like `"3s"`.

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
