# Used by "mix format"
[
  export: [
    locals_without_parens: [
      assert_contains: :*,
      assert_recent: :*,
      assert_that: :*,
      refute_that: :*
    ]
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "*.md"],
  line_length: 120,
  locals_without_parens: [
    assert_contains: :*,
    assert_recent: :*,
    assert_that: :*,
    refute_that: :*
  ],
  markdown: [
    line_length: 120
  ],
  plugins: [MarkdownFormatter]
]
