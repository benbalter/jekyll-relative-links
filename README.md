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

## Collection support

Jekyll Relative Links can optionally be enabled on a per-collection basis. To enable relative link support, add the following to your site's `_config.yml` (replacing the collections with your own collections):

```yml
jekyll_relative_links:
  collections:
    - posts
    - another-collection
```

*Note: Although you must enable support for rewriting links **within** collection documents (e.g., rewriting a relative link in a Post), you can always link **to** a collection document (e.g., rewriting a link in a Page that targets a Post).*
