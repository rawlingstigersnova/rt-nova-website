# Social Hub Updates

The home page Social Hub is powered by Markdown files in:

```text
content/social-hub/
```

Each Markdown file becomes one Social Hub card. The home page shows the **3 newest posts first**. If there are more than 3 posts, visitors can click **Load more**.

Posts are ordered by the `date:` field in the Markdown front matter, newest first. The filename does not control the order, but using a date in the filename makes files easier to manage.

## Simple post template

```markdown
---
title: "Short title for the card"
date: 2026-06-15
platform: "Facebook"
account: "Rawlings Tigers NOVA"
link: "https://www.facebook.com/..."
button: "View on Facebook"
image: "images/social/example.jpg"
caption: "Short text shown on the card."
build:
  render: never
  list: always
---
```

## Fields

| Field | Required? | What it does |
|---|---:|---|
| `title` | Yes | Card title and internal Hugo title. |
| `date` | Yes | Controls sort order. Newest dates show first. |
| `platform` | Yes | Free-form label. Recommended: `Instagram`, `Facebook`, `Team News`, or `Program Update`. Also controls the small upper-right platform icon. |
| `account` | Yes | Account/team name shown at the top of the card. |
| `link` | Yes | Where the card/button sends visitors. Can be Facebook, Instagram, a news article, or an internal page. |
| `button` | Yes | Button/action text, such as `View on Facebook`, `View on Instagram`, `Read article`, or `Learn more`. |
| `image` | Yes | Preview image. Best: local image under `static/images/social/`. Direct external image URLs are supported but may expire. |
| `caption` | Yes | Short text shown on the card. |
| `image_alt` | No | Accessibility text for the image. If omitted, the template uses `title`. |
| `image_fit` | No | Use `contain` to show the full image or `cover` to fill/crop. Default is `contain`. |
| `build` | Yes | Hugo setting. Keep this exactly as shown so the item appears on the homepage but does not generate its own page. |

## Recommended image workflow

Best long-term approach:

1. Save the image or screenshot into:

```text
static/images/social/
```

2. Reference it like this:

```yaml
image: "images/social/my-post-image.jpg"
```

Direct Facebook/Instagram CDN image URLs can work for testing, but they can expire or stop hotlinking. Local images are more reliable for the public website.

## Examples

### Facebook

```markdown
---
title: "11U Team Update"
date: 2026-06-15
platform: "Facebook"
account: "Rawlings Tigers NOVA 11U"
link: "https://www.facebook.com/photo?fbid=122128820241194215&set=a.122108161857194215"
button: "View on Facebook"
image: "images/social/11u-facebook-photo.jpg"
caption: "11U team update from Facebook."
build:
  render: never
  list: always
---
```

### Instagram

```markdown
---
title: "Instagram Player Highlight"
date: 2026-06-14
platform: "Instagram"
account: "@rawlingstigersnova"
link: "https://www.instagram.com/p/DZGMdrojkoZ/"
button: "View on Instagram"
image: "images/social/player-highlight.jpg"
caption: "Player highlight from Rawlings Tigers NOVA."
build:
  render: never
  list: always
---
```

### Team News / article

```markdown
---
title: "11U Black Brings Home Championship"
date: 2025-09-07
platform: "Team News"
account: "Rawlings Tigers NOVA"
link: "https://rawlingstigersnova.com/leagues/NewsItem/28092/35799"
button: "Read article"
image: "images/social/11u-black-champions.jpeg"
caption: "11U Black battled through the weekend and brought home another championship."
build:
  render: never
  list: always
---
```
