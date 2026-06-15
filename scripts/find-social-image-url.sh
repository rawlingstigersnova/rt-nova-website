#!/usr/bin/env bash
set -euo pipefail

POST_URL="${1:-}"
MODE="${2:-main}"
SLUG="${3:-social-image}"

if [[ -z "$POST_URL" ]]; then
  cat <<'USAGE'
Usage:
  ./scripts/find-social-image-url.sh <instagram-or-facebook-post-url> [main|all|download] [slug]

Examples:
  ./scripts/find-social-image-url.sh "https://www.facebook.com/photo?fbid=122128820241194215&set=a.122108161857194215"
  ./scripts/find-social-image-url.sh "https://www.facebook.com/photo?fbid=122128820241194215&set=a.122108161857194215" download 11u-facebook-photo

Notes:
  - Facebook photo pages often expose a usable og:image value to curl.
  - Instagram often returns only app/static assets to curl. If this script cannot find the post image,
    open the Instagram post in your browser and use scripts/browser-social-image-snippet.js in DevTools.
USAGE
  exit 1
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

curl -LfsS \
  -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125 Safari/537.36" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" \
  -H "Accept-Language: en-US,en;q=0.9" \
  "$POST_URL" \
  -o "$TMP_FILE"

# Decode common escaped HTML/JSON forms.
extract_urls() {
  python3 - "$TMP_FILE" <<'PY'
import html, re, sys
text = open(sys.argv[1], 'r', encoding='utf-8', errors='ignore').read()
text = html.unescape(text)
text = text.replace('\\/', '/')
text = text.replace('\\u0026', '&')
patterns = [
    r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)["\']',
    r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image["\']',
    r'<meta[^>]+name=["\']twitter:image["\'][^>]+content=["\']([^"\']+)["\']',
    r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+name=["\']twitter:image["\']',
    r'"display_url"\s*:\s*"([^"]+)"',
    r'"thumbnail_src"\s*:\s*"([^"]+)"',
    r'"src"\s*:\s*"(https?://[^"]+\.(?:jpg|jpeg|png|webp)[^"]*)"',
    r'(https?://[^"\s<>]+\.(?:jpg|jpeg|png|webp)[^"\s<>]*)',
]
seen = set()
for pat in patterns:
    for m in re.finditer(pat, text, re.I):
        url = html.unescape(m.group(1)).replace('\\/', '/').replace('\\u0026', '&')
        if url not in seen:
            seen.add(url)
            print(url)
PY
}

score_url() {
  local url="$1"
  local score=0

  # Penalize static app chrome/assets.
  [[ "$url" == *"static.cdninstagram.com/rsrc"* ]] && score=$((score-1000))
  [[ "$url" == *"static.xx.fbcdn.net"* ]] && score=$((score-1000))
  [[ "$url" == *"/rsrc.php/"* ]] && score=$((score-1000))
  [[ "$url" == *"emoji"* ]] && score=$((score-200))
  [[ "$url" == *"favicon"* ]] && score=$((score-200))
  [[ "$url" == *"profile_pic"* ]] && score=$((score-100))

  # Reward post-media hosts and common post-media markers.
  [[ "$url" == *"scontent"* ]] && score=$((score+100))
  [[ "$url" == *"fbcdn.net"* ]] && score=$((score+100))
  [[ "$url" == *"cdninstagram.com"* ]] && score=$((score+100))
  [[ "$url" == *"t39.30808-6"* ]] && score=$((score+80))
  [[ "$url" == *"t51.82787-15"* ]] && score=$((score+80))
  [[ "$url" == *"regular_photo"* ]] && score=$((score+70))
  [[ "$url" == *"video_cover"* ]] && score=$((score+70))
  [[ "$url" == *"e35"* ]] && score=$((score+15))
  [[ "$url" == *"p1080x1080"* ]] && score=$((score+30))
  [[ "$url" == *"s1339x1004"* ]] && score=$((score+30))
  [[ "$url" == *"mx1339x1004"* ]] && score=$((score+30))

  echo "$score"
}

mapfile -t candidates < <(extract_urls | sort -u)

ranked="$(mktemp)"
trap 'rm -f "$TMP_FILE" "$ranked"' EXIT
for url in "${candidates[@]}"; do
  score="$(score_url "$url")"
  if (( score > 0 )); then
    printf '%s\t%s\n' "$score" "$url" >> "$ranked"
  fi
done

if [[ ! -s "$ranked" ]]; then
  cat >&2 <<'ERR'
No likely post image was found from the fetched HTML.

For Instagram, this usually means Instagram returned only the app shell/static assets to curl.
Open the post in your browser, then paste scripts/browser-social-image-snippet.js into DevTools Console.
That browser method can inspect the already-rendered images and pick the largest post image.
ERR
  exit 2
fi

if [[ "$MODE" == "all" ]]; then
  sort -rn "$ranked" | cut -f2-
  exit 0
fi

IMAGE_URL="$(sort -rn "$ranked" | head -1 | cut -f2-)"

if [[ "$MODE" == "download" ]]; then
  mkdir -p static/images/social
  OUT="static/images/social/${SLUG}.jpg"
  curl -LfsS \
    -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125 Safari/537.36" \
    -H "Referer: $POST_URL" \
    "$IMAGE_URL" \
    -o "$OUT"
  echo "Downloaded: $OUT"
  echo
  echo "Markdown example:"
  echo "image: \"images/social/${SLUG}.jpg\""
  echo "image_fit: \"contain\""
  exit 0
fi

echo "$IMAGE_URL"
echo
echo "Markdown example:"
echo "image: \"$IMAGE_URL\""
echo "image_fit: \"contain\""
