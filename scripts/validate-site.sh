#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="${1:-public}"
ERRORS=0

if [[ ! -d "${SITE_DIR}" ]]; then
  echo "ERROR: ${SITE_DIR} does not exist. Run the Hugo build first." >&2
  exit 1
fi

check_pattern() {
  local label="$1"
  local pattern="$2"

  if grep -RInE "${pattern}" "${SITE_DIR}" \
    --include='*.html' \
    --include='*.css' \
    --include='*.js' \
    --include='*.xml' \
    --include='*.json' \
    --exclude-dir='.git'; then
    echo
    echo "ERROR: Found ${label}" >&2
    echo
    ERRORS=$((ERRORS + 1))
  fi
}

echo "Validating generated Hugo site in ${SITE_DIR}..."

# Old GitHub Pages/project-path mistakes from the earlier deployment target.
check_pattern "wrong personal GitHub Pages asset URLs" 'https://smbambling\.github\.io/(images|css|js|icons)/'
check_pattern "wrong org GitHub Pages project URLs" 'https://rt-nova\.github\.io/rt-nova-website/'

# Runtime dependencies that should be self-hosted for this site.
check_pattern "TeamLinkt CDN dependency" 'cdn-app\.teamlinkt\.com'
check_pattern "external Iconify dependency" 'api\.iconify\.design|code\.iconify\.design|cdn\.iconify\.design'

if [[ "${ERRORS}" -gt 0 ]]; then
  echo "Validation failed with ${ERRORS} issue group(s)." >&2
  exit 1
fi

echo "Validation passed."
