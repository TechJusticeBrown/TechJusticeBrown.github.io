# Deploying to GitHub

## How this repo is currently set up

This repository does not (yet) have a `.github/workflows/` folder, so there is no GitHub
Actions build. Instead, the built site is **committed directly to the `docs/` folder** on the
default branch — you can see this in the git history (`git log` shows commits like "Rebuild
demo website" / "Rebuild demo site"). GitHub Pages is configured (Settings → Pages) to serve
from that branch's `/docs` folder rather than building anything itself.

This means deploying is a two-step manual process: build, then commit + push.

### 1. Build the production site

From the repository root, with dependencies installed (see `Running Local Dev.md`):

```bash
bundle exec jekyll build --source demo --destination docs
```

This regenerates everything under `docs/` (HTML pages, `docs/assets/`, `sitemap.xml`,
`robots.txt`) from the current contents of `demo/`, `_layouts/`, `_includes/`, `_data/`,
`_sass/`, and `assets/`.

### 2. Review and commit

```bash
git status
git add docs
git commit -m "Rebuild site"
git push
```

Always review `git status`/`git diff` on the `docs/` folder before committing — a stray local
config change (like a temporarily cleared `baseurl`, see `Running Local Dev.md`) will otherwise
get baked into the live build and pushed.

GitHub Pages republishes automatically a short while after the push lands on the branch it's
configured to serve from. No further action is needed on GitHub's side for this workflow.

## Verifying/changing the Pages source

In the GitHub web UI: **Settings → Pages → Build and deployment → Source**. For the setup
described above, this should be set to "Deploy from a branch," with the branch set to the
default branch and the folder set to `/docs`. If you ever change the build destination (e.g.
build to `_site` and want Pages to serve that instead), update this setting to match — a
mismatch here is the most common cause of "I pushed but the site didn't change."

## Alternative: GitHub Actions

GitHub Actions can build and deploy the site automatically on every push, removing the need to
build locally and commit the output at all. This repo doesn't use this approach today, but it's
worth considering if multiple people will be editing content and you want to stop tracking
generated HTML in git.

**What Actions gives you:**
- The build runs on GitHub's infrastructure, not your laptop — no risk of an out-of-date local
  Ruby/gem environment producing a different result than what ships.
- `docs/` (or `_site/`) no longer needs to be committed at all, which keeps the git history to
  source changes only.
- Every push (or only pushes to certain branches/paths, if configured) can trigger a rebuild,
  so contributors don't need to remember the manual build step.

**Trade-offs to weigh:**
- Adds a small delay (the Actions run itself) between pushing and the site updating, versus the
  current approach where the built files are already in the push.
- Requires switching the Pages source setting from "Deploy from a branch" to "GitHub Actions."
- One more file (the workflow YAML) to maintain, and Actions minutes count against the repo's
  (or org's) usage if it's private.

**Example workflow**, if you decide to adopt it — save as `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: ["master"]  # replace with your repo's actual default branch
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true
      - name: Build site
        run: bundle exec jekyll build --source demo --destination _site
      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

Things to adjust to taste when configuring this for real use:
- `branches: ["master"]` — this repo's actual default branch (confirmed via
  `git branch --show-current`); change it to match whatever branch should trigger a deploy in
  your own fork, or add a `paths:`
  filter (e.g. only `demo/**`, `_layouts/**`, `_data/**`, `_sass/**`, `assets/**`) so unrelated
  commits (like updates to this `guides/` folder) don't trigger a rebuild.
- `ruby-version` — pin to whatever Ruby version you've standardized on locally.
- If you keep committing `docs/` as a fallback/manual option, decide on one source of truth —
  running both the manual process and an Actions-based deploy simultaneously risks the two
  overwriting each other's output.
