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

The default Jekyll's configuration `permalink: pretty` in the `_config.yaml`
file removes the `.html` extensions from the generated links.

## Why

Because Markdown files rendered by GitHub Pages should behave similar to Markdown files rendered on GitHub.com

## Usage

1. Add the following to your site's Gemfile:

  ```ruby
  gem 'jekyll-relative-links'
  ```

2. Add the following to your site's config file:

  ```yml
  plugins:
    - jekyll-relative-links
  ```
  Note: If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

## Configuration

You can configure this plugin in `_config.yml` under the `relative_links` key. This is optional and defaults to:

```yml
relative_links:
  enabled:     true
  collections: false
```

### Excluding files

To exclude specific directories and/or files:

```yml
relative_links:
  exclude:
    - directory
    - file.md
```

### Processing Collections

Setting the `collections` option to `true` enables relative links from collection items (including posts).

Assuming this structure

~~~
├── _my_collection
│   ├── some_doc.md
│   └── some_subdir
│       └── another_doc.md
├── _config.yml
└── index.md
~~~

the following will work:

File | Link
-|-
`index.md` | `[Some Doc](_my_collection/some_doc.md)`
`index.md` | `[Another Doc](_my_collection/some_subdir/another_doc.md)`
`_my_collection/some_doc.md` | `[Index](../index.md)`
`_my_collection/some_doc.md` | `[Another Doc](some_subdir/another_doc.md)`
`_my_collection/some_subdir/another_doc.md` | `[Index](../../index.md)`
`_my_collection/some_subdir/another_doc.md` | `[Some Doc](../some_doc.md)`


### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `enabled` key to `false`.
