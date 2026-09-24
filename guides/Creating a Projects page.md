# Creating a Projects Page

The theme ships with four built-in pages (index, program, map, participants), but nothing for
a project gallery. This guide adds one from scratch using a **Jekyll collection**: each project
is its own Markdown file, and a gallery page displays them as clickable thumbnail cards that
lead to the fully rendered project.

## 1. Register the collection

In `demo/_config.yml`, add:

```yaml
collections:
  projects:
    output: true
    permalink: /projects/:name/
```

`output: true` tells Jekyll to actually build a page for each entry in the collection (instead
of only making the data available). `permalink` controls the URL each project gets — here, the
file's name becomes its slug.

## 2. Create the project files

Add a `_projects/` folder at the same level as `_data/` and `_layouts/`. Each project is one
Markdown file:

```
demo/
└── _projects/
    ├── community-broadband-audit.md
    └── open-data-portal.md
```

`demo/_projects/community-broadband-audit.md`:

```markdown
---
layout: project
title: "Community Broadband Audit"
thumbnail: /assets/img/projects/broadband-audit.jpg
summary: "Mapping ISP coverage gaps across the metro area."
date: 2026-02-10
---

Full write-up of the project goes here. This Markdown is what renders when someone
clicks the thumbnail on the Projects page.
```

**New `<project_name>.md` files always go in `_projects/`** — that's what makes Jekyll pick
them up as part of the `projects` collection. A file placed anywhere else (e.g. directly in
`demo/`) will not appear in the gallery.

Put thumbnail images in a new `assets/img/projects/` folder to keep them separate from the
theme's own icons and images.

## 3. Add a layout for individual projects

`_layouts/project.html` — reuses the same structure as the theme's other simple layouts
(compare with `_layouts/page.html`):

```liquid
---
layout: default
---

{% include metadata.liquid %}
{% include header.html %}

<main class="my-4">
    <div class="container">
        <h1 class="display-5">{{ title }}</h1>
        <hr class="my-4">
        {{ content }}
    </div>
</main>

{% include footer.html %}
```

Note this uses `{{ title }}`, not `{{ page.title }}` — `title` is the local variable set by
`{% include metadata.liquid %}`, which falls back to `site.title` when a project's front matter
doesn't set one. Every other layout in the theme (`_layouts/page.html`, `_layouts/map.html`)
follows this same convention; using `page.title` directly would silently render an empty
heading for any `_projects/*.md` file that omits `title`.

Each file in `_projects/` should set `layout: project` in its front matter so it uses this.

## 4. Build the gallery page

First, the page itself — `demo/projects.md`:

```markdown
---
layout: projects
title: Projects
description: Our current and past work
navorder: 4
---

A brief introduction to the projects program can go here.
```

Setting `navorder` adds it to the nav bar automatically, exactly like the built-in pages (see
`Editing, Adding, and Removing pages.md`). Before picking a number, check what's already taken
so you don't tie with an existing page:

```bash
grep navorder demo/*.md
```

In the stock demo content, `program.md` uses `1`, `map.md` uses `2`, and `participants.md`
uses `3` — so `4` places Projects last. Two pages sharing the same `navorder` won't error, but
which one wins the tie is left to Liquid's `sort` filter and isn't a documented guarantee, so
it's worth avoiding rather than relying on.

Then the layout that lists the thumbnails — `_layouts/projects.html`:

```liquid
---
layout: default
---

{% include metadata.liquid %}
{% include header.html %}

<main class="my-4">
    <div class="container">
        <h1 class="display-5">{{ title }}</h1>
        <hr class="my-4">
        {{ content }}

        <div class="row row-cols-1 row-cols-md-3 g-4 mt-2">
            {% assign sorted_projects = site.projects | sort: 'date' | reverse %}
            {% for project in sorted_projects %}
            <div class="col">
                <a href="{{ project.url | relative_url }}" class="text-decoration-none text-reset">
                    <div class="card h-100 project-card">
                        <img src="{{ project.thumbnail | relative_url }}" class="card-img-top project-thumbnail" alt="{{ project.title }}">
                        <div class="card-body">
                            <h5 class="card-title">{{ project.title }}</h5>
                            <p class="card-text text-muted">{{ project.summary }}</p>
                        </div>
                    </div>
                </a>
            </div>
            {% endfor %}
        </div>
    </div>
</main>

{% include footer.html %}
```

`site.projects` is populated automatically from every file in `_projects/` because of the
collection registered in step 1. Clicking a card's thumbnail or title follows `project.url`,
which Jekyll derives from the `permalink` pattern — that's what renders the full Markdown body
via the `project` layout from step 3.

## 5. Styling the page

Because the theme bundles Bootstrap 5, the card grid above (`row row-cols-md-3`, `card`,
`card-img-top`) already gets sensible responsive styling for free — no extra CSS is required to
get a working grid of thumbnails.

To fine-tune it (e.g. force all thumbnails to a consistent aspect ratio regardless of the
source image's dimensions), add rules to `_sass/_custom.scss`, which the theme automatically
compiles and which is the sanctioned place for site-specific CSS:

```scss
.project-thumbnail {
    height: 180px;
    object-fit: cover;
}

.project-card {
    transition: box-shadow 0.15s ease-in-out;
}

.project-card:hover {
    box-shadow: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.1);
}
```

If you want the card colors to follow the site's overall color scheme rather than hard-coded
values, use the theme's Open Color skin system instead of raw hex codes. This repo does not
currently have a `_data/skin.yml` file — the theme falls back to its built-in defaults until you
create one. To customize, create `_data/skin.yml` yourself and assign colors to the tokens it
supports (e.g. `card.border`, `card-header.bg`); see the "Usage" section of the theme's
`README.md` for the full token list and an example file.

## Summary

- Register the `projects` collection in `_config.yml`.
- Drop new project write-ups in `_projects/<project_name>.md` with `layout: project`.
- Thumbnails go in `assets/img/projects/`.
- The gallery lives at `demo/projects.md` + `_layouts/projects.html`, which loops over
  `site.projects` and renders a Bootstrap card grid.
- Custom styling goes in `_sass/_custom.scss`.
