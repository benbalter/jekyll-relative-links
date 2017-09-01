# Jekyll Relative Links

[![Build Status](https://travis-ci.org/benbalter/jekyll-relative-links.svg?branch=master)](https://travis-ci.org/benbalter/jekyll-relative-links)

A Jekyll plugin to convert relative links to Markdown files to their rendered equivalents.

## What it does

Let's say you have a link like this in a Markdown file:

```
[foo](bar.md)
```

While that would render as a valid link on GitHub.com, it would not be a valid link on Pages. Instead, this plugin converts that link to:

```
[foo](bar.html)
```

It even work with pages with custom permalinks. If you have `bar.md` with the following:

```
---
permalink: /bar/
---

# bar
```

Then `[foo](bar.md)` will render as `[foo](/bar/)`.

## Why

Because Markdown files rendered by GitHub Pages should behave similar to Markdown files rendered on GitHub.com

## Usage

1. Add the following to your site's Gemfile:

  ```ruby
  gem 'jekyll-relative-links'
  ```

2. Add the following to your site's config file:

  ```yml
  gems:
    - jekyll-relative-links
  ```

## Configuration

You can configure this plugin in `_config.yml` under the `relative_links` key. This is optional and defaults to:

```yml
relative_links:
  collections: false
  disabled:    false
```

### Processing Collections

Setting the `collections` option to a truthy value enables relative links to and from collection items (including posts).

Assuming this structure:

~~~
├── _posts
│   └── 2016-01-01-test.md
├── _config.yml
├── index.md
└── some-category
    └── _posts
        └── 2016-01-01-test.md
~~~

The following will work:

Link | Within file
-|-
`[Index](../index.md)` | `_posts/2016-01-01-test.md`
`[Index](../../index.md)` | `some-category/_posts/2016-01-01-test.md`
`[Post 1](_posts/2016-01-01-test.md)` | `index.md`
`[Post 2](some_category/_posts/2016-01-01-test.md)` | `index.md`

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `disabled` key.
