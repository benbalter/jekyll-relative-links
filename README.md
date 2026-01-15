# Jekyll Relative Links

[![CI](https://github.com/benbalter/jekyll-relative-links/actions/workflows/ci.yml/badge.svg)](https://github.com/benbalter/jekyll-relative-links/actions/workflows/ci.yml)

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


### Using the `rellinks` filter

In addition to automatically converting relative links in your Markdown files, this plugin also provides a Liquid filter called `rellinks` that can be used to convert relative links in content that has already been processed by Jekyll's `markdownify` filter.

This is especially useful when you have Markdown content in your front matter that you want to display with properly converted links.

For example, if you have a page with a sidebar defined in the front matter:

```yaml
---
title: My Page
sidebar: |
  My page's sidebar **content**.
  
  Might have [a link somewhere](./other.md)
---
```

You can use the `rellinks` filter in your template like this:

```liquid
<aside class="sidebar">
  {{ page.sidebar | markdownify | rellinks }}
</aside>
```

The `rellinks` filter will transform any relative links to Markdown files in the HTML output from the `markdownify` filter, converting them to their rendered equivalents.

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `enabled` key to `false`.

## Limitations

### Line-Wrapped Links

This plugin does not process links that contain hard line breaks (newlines) within the link syntax. According to the [CommonMark specification](https://spec.commonmark.org/) and [GitHub Flavored Markdown](https://github.github.com/gfm/), newlines are not permitted within link text or URLs.

For example, this is **not valid Markdown**:

```markdown
[my link
text](page.md)
```

Nor is this:

```markdown
[my link](page
.md)
```

#### Recommended Solution: Reference-Style Links

If you need to manage long links while keeping your Markdown source lines at a reasonable length, use **reference-style links**:

```markdown
Check out the [comprehensive guide to Jekyll plugins][plugin-guide]
for more information.

[plugin-guide]: path/to/very-long-documentation-filename.md
```

This approach:
- Keeps your prose readable with appropriate line wrapping
- Works with this plugin (reference links are fully supported)
- Is valid Markdown that works across all parsers
- Separates link definitions from the text, making them easier to maintain
