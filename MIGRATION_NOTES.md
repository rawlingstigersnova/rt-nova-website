# Migration Notes

## Current package status

This package uses Hugo templates and data files for the high-value pages that need to be maintained regularly:

- `/teams/` → `data/teams.yaml` + `layouts/partials/page-teams.html`
- `/coaches/` → `data/coaches.yaml` + `layouts/partials/page-coaches.html`
- `/tryouts/` → `data/tryouts.yaml` + `layouts/partials/page-tryouts.html`
- `/sponsors/` → `data/sponsors.yaml` + `layouts/partials/page-sponsors.html`
- `/accolades/` → `data/accolades.yaml` + `layouts/partials/page-accolades.html`

The main visual system now lives in `assets/css/main.css`, with shared page shell templates in `layouts/_default/` and `layouts/partials/`.

## Local asset approach

Team, coach, accolade, player-highlight, and age-chart images are stored locally under:

```text
static/images/teamlinkt/
```

Active pages should reference them with root-relative paths like:

```text
/images/teamlinkt/example-file.png
```

These paths work correctly with Cloudflare Pages and GitHub Pages when the site is deployed at the root of the custom domain.

## Validation

Run this before deploying:

```bash
./scripts/validate-local-assets.sh
```

Optional manual source check:

```bash
grep -R "cdn-app\.teamlinkt\.com" -n . --exclude-dir=.git --exclude-dir=public
```

No source file matches should be returned.
