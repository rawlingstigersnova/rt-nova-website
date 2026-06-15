# News Articles

News articles live in `content/news/` and each Markdown file creates an article page under `/news/`.

## Add a news article

Create a file like:

```text
content/news/2026-05-11-13u-orange-runner-up.md
```

Example front matter:

```yaml
---
title: "Rawlings Tigers NOVA Orange 13U Takes Runner-Up at TCS NOVA Bat Wars"
date: 2026-05-11
badge: "Runner-Up"
team: "13U Orange"
image: "/images/social/example.jpg"
image_alt: "Rawlings Tigers NOVA team photo"
excerpt: "Short summary used on the news listing and homepage cards."
show_on_home_social: true
---
```

The body of the Markdown file becomes the full article content.

## Homepage Social Hub integration

Set this when a news article should also appear in the homepage Social Hub:

```yaml
show_on_home_social: true
```

Do not create a duplicate `content/social-hub/` card for the same article.

## News listing behavior

The `/news/` page sorts articles by `date`, newest first.

- The newest article appears as the large featured article.
- The next 3 articles appear under **Recent News**.
- Older articles are hidden behind **Load More**.

## Article page navigation

Each article page includes:

- `← Back to News` near the top.
- Plain `← Previous Article` and `Next Article →` links at both the top and bottom of the article.

The individual article page does not show a separate **More News** card grid. Use `/news/` for browsing all articles.
