# Changelog

## Unreleased changes

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
