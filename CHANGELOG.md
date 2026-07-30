# Changelog

## 0.8.0

### Features

- Add a `rellinks` Liquid filter that rewrites relative links in already-
  markdownified content — usable as `{{ content | markdownify | rellinks }}`,
  so links inside included fragments get converted (#98)

### Bug fixes

- Convert relative links in Jekyll includes that were previously skipped (#104)
- Handle hex-encoded (`%20`) spaces in relative link paths (#106)
- Correctly handle images nested inside Markdown links (#107)
- Fix an error when a page's YAML front matter has an `excerpt:` field (#97)

### Performance

- Use an O(1) hash lookup in `url_for_path`, speeding up link resolution on
  large sites (#110)

### Documentation

- Document that line-wrapped links are not processed, per the CommonMark spec
  (#105)

### Infrastructure

- Modernize CI — Ruby 3.3 & 4.0 against Jekyll 3.x & 4.x — and bump
  rubocop-rspec to `~> 3.0` (#115)
- Enable Dependabot for GitHub Actions; bump `actions/checkout`,
  `github/codeql-action`, and `rubocop-factory_bot` (#111, #112, #113, #114)
