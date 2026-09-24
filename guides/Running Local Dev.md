# Running Local Dev

## Prerequisites

- **Ruby** (check your version with `ruby -v`). The repo has no `.ruby-version` file and
  doesn't declare a required version anywhere; these docs were verified against Ruby 3.3.0. If
  you hit gem-resolution errors on a different version, pinning one with a `.ruby-version` file
  is a reasonable fix to adopt.
- **Bundler** (`gem install bundler` if `bundle -v` doesn't work).

## Install dependencies

From the repository root:

```bash
bundle config set --local path 'vendor/bundle'
bundle install
```

The `--local path` step installs gems into `vendor/bundle` inside the repo rather than
system-wide, which keeps versions isolated per-project. `vendor/` is already git-ignored.

The root `Gemfile` pulls in this repo's own `jekyll-nagymaros.gemspec`, whose only runtime
dependency is the `github-pages` gem — this is the same gem GitHub itself uses to build Pages
sites, and it bundles Jekyll along with all the plugins listed in `demo/_config.yml`
(`jekyll-seo-tag`, `jekyll-sitemap`). Installing it locally means your local build matches what
GitHub Pages will actually produce.

## Serve the site

This repository is the **theme itself** — the root folder has no `index.md` or `_config.yml`
of its own. The actual site content lives in `demo/`, which comes with its own `_config.yml`
(setting `theme: jekyll-nagymaros`) and its own `Gemfile`. To preview it, tell Jekyll to build
from that folder instead of the root:

```bash
bundle exec jekyll serve --source demo --destination _site
```

Then open the URL Jekyll prints, typically:

```
http://localhost:4000/jekyll-nagymaros/
```

Note the `/jekyll-nagymaros/` path segment — `demo/_config.yml` sets `baseurl: /jekyll-nagymaros`
to match the theme's GitHub Pages project URL. If the URL 404s at `localhost:4000/`, check that
you're browsing under the `baseurl` path, or temporarily clear `baseurl` in your local copy of
`demo/_config.yml` if that's confusing (don't commit that change unless you're intentionally
changing the deployed URL structure — see `Deploying to GitHub.md`).

`jekyll serve` watches the filesystem and rebuilds automatically when you edit a page, layout,
data file, or Sass partial — just refresh the browser after a save. If you're editing `_sass`
files and don't see style changes, confirm the terminal shows a successful rebuild (Sass errors
will halt the watcher).

## Important: don't point local dev at `docs/`

The `docs/` folder in this repo is the **committed production build** that GitHub Pages serves
directly (see `Deploying to GitHub.md`). Always build local/dev output to the default `_site`
destination (already git-ignored) or another scratch folder — never run
`jekyll serve --destination docs` or `jekyll build --destination docs` while iterating, since
that would overwrite the live build with in-progress or draft content the moment you save a
file.

## Stopping the server

`Ctrl+C` in the terminal running `jekyll serve`.

## Troubleshooting

- **"Could not locate Gemfile" or theme not found**: make sure you're running commands from the
  repository root (where the root `Gemfile` lives), not from inside `demo/`.
- **Stale styles/scripts after a change**: delete the Sass cache and rebuild —
  `rm -rf .sass-cache .jekyll-cache _site && bundle exec jekyll serve --source demo --destination _site`.
- **Port already in use**: pass `--port 4001` (or any free port) to `jekyll serve`.
