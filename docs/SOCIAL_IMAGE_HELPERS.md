# Finding Social Hub Image URLs

The Social Hub cards can use either a local image or a direct external image URL.

Recommended/stable:

```yaml
external_url: "https://www.instagram.com/p/POST_ID/"
image: "images/social/my-post-image.jpg"
image_fit: "contain"
```

Allowed for testing, but less stable:

```yaml
external_url: "https://www.instagram.com/p/POST_ID/"
image: "https://scontent...cdninstagram.com/...jpg?..."
image_fit: "contain"
```

## Helper script

For Facebook photo posts, this often finds the main image:

```bash
./scripts/find-social-image-url.sh "https://www.facebook.com/photo?fbid=122128820241194215&set=a.122108161857194215"
```

To download the image locally:

```bash
./scripts/find-social-image-url.sh "https://www.facebook.com/photo?fbid=122128820241194215&set=a.122108161857194215" download 11u-facebook-photo
```

This produces:

```yaml
image: "images/social/11u-facebook-photo.jpg"
image_fit: "contain"
```

## Instagram limitation

Instagram often returns only app/static assets to command-line tools like `curl`. When that happens, use the browser snippet instead.

1. Open the Instagram post in your browser.
2. Open DevTools Console.
3. Paste the contents of:

```text
scripts/browser-social-image-snippet.js
```

The snippet picks the largest rendered post image and prints Markdown fields.
