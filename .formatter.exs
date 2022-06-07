# Used by "mix format"
[
  export: [
    locals_without_parens: [
      assert_recent: :*,
      assert_that: :*,
      refute_that: :*
    ]
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  locals_without_parens: [
    assert_recent: :*,
    assert_that: :*,
    refute_that: :*
  ]
]
