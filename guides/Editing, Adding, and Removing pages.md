# Editing, Adding, and Removing Pages

This site is built on the `jekyll-nagymaros` Jekyll theme. Every page is assembled from four
pieces that live in different folders. To change a page, you may need to touch more than one
of them.

## Where a page's specification lives

| Piece | Location | Purpose |
|---|---|---|
| Page file | `demo/*.md` (e.g. `demo/index.md`, `demo/map.md`) | Front matter (layout, title, nav order) + the page's Markdown body |
| Layout | `_layouts/*.html` (e.g. `_layouts/index.html`, `_layouts/map.html`) | The HTML skeleton the page's content is dropped into |
| Data | `_data/*.yml` (e.g. `_data/program.yml`, `_data/map.yml`) | Structured content (schedule, markers, participant list) consumed by the matching layout |
| Shared includes | `_includes/*.html` | Header, footer, `<head>`, and title/description fallback logic shared by every page |

Every page's front matter also determines its position in the navigation bar. Open
`_includes/header.html` and you'll see the nav is generated automatically:

```liquid
{% assign links = site.pages | sort: 'navorder' %}
{% for link in links %}
  {% if link.navorder %}
    ...
  {% endif %}
{% endfor %}
```

This means **you never hand-edit the nav bar**. A page appears in it only if its front matter
sets `navorder`, and its position is determined by that number. Leaving `navorder` unset hides
the page from the nav without deleting it (useful for a page you're still drafting).

## Example: editing an existing page

To change the welcome text on the home page, edit the Markdown body below the front matter in
`demo/index.md`:

```markdown
---
layout: index
description: A simple Jekyll theme for a conference or workshop website
---

Your new welcome copy goes here.
```

To change the schedule, you generally don't touch `demo/program.md` at all — its content is
mostly empty introductory text. Instead you edit `_data/program.yml`, which the `program`
layout reads via `site.data.program`:

```yaml
days:
  - name: Day 1
    events:
      - time: 9:00 to 10:00
        title: Opening remarks
        category: A category
```

The same pattern applies to `_data/map.yml` (markers/areas rendered by Leaflet) and
`_data/participants.yml` (the alphabetical list of people).

To reorder the nav, just change `navorder` in a page's front matter:

```yaml
---
layout: program
title: Program
navorder: 1   # lower numbers appear first
---
```

## Adding a new page

1. Create `demo/<name>.md` with front matter specifying at minimum a `layout` (usually `page`
   for a plain content page — see `_layouts/page.html`) and a `title`.
2. Set `navorder` if the page should appear in the nav bar.
3. If the page needs its own structured data (like `program` or `map` do), add a new file in
   `_data/` and reference it from a layout as `site.data.<name>`.
4. If the page needs a layout that doesn't already exist, add `_layouts/<name>.html`. Simple
   content pages can usually just reuse `layout: page`.

No other file needs to change — the nav bar will pick the page up automatically once
`navorder` is set.

## Removing a page

Deleting a page is not always as clean as it looks, because nothing in this theme automatically
prunes what the page depended on. Concretely:

- **Deleting `demo/map.md`** removes the page and its nav entry, but:
  - `_data/map.yml` becomes dead data — nothing reads it anymore.
  - `_layouts/map.html` becomes an orphaned layout file.
  - The Leaflet JS/CSS (`assets/js/leaflet.js`, `assets/js/leaflet-data.js`,
    `assets/css/leaflet.css`) is **not** scoped to the map page — it's loaded unconditionally by
    `_layouts/default.html` and `_includes/head.html` on *every* page. Removing the map page
    alone does not stop these files from being downloaded site-wide; you'd need to also edit
    `default.html`/`head.html` to drop those `<script>`/`<link>` tags if you want to actually
    shed the dependency.
  - The marker icon assets in `assets/img/` (`marker-icon.png`, `marker-shadow.png`, etc.)
    become unused, but Jekyll copies the entire `assets/` folder regardless of whether files are
    referenced, so they'll still ship in the built site.

- **Deleting `demo/program.md`** orphans `_data/program.yml` and `_layouts/program.html`.
  Watch for `paper:` links inside `program.yml` events pointing at files under
  `assets/files/` — those PDFs become unreferenced but, again, are not removed from the build.

- **Deleting `demo/participants.md`** orphans `_data/participants.yml` and
  `_layouts/participants.html`.

- **Broken internal links**: if any page's Markdown body, a button in `_data/index.yml`, or
  custom HTML links to a page you removed, that link will 404. Search the repo for the page's
  filename (minus `.md`) before deleting it.

- **Nav-active-state matching**: `header.html` decides whether a nav link is "active" by
  comparing `page.layout` to the linked page's filename (`{% if page.layout == current %}`). If
  you rename a page file without renaming its layout to match (or vice versa), the active-state
  highlight silently stops working — it won't throw an error, so it's easy to miss.

**Recommendation:** when removing a page, delete its `.md` file, its layout, and its data file
together, then grep the repo for the old filename to catch stray links. If you only want a page
temporarily hidden rather than gone, just unset `navorder` instead of deleting anything.
