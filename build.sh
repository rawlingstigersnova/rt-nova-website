#!/usr/bin/env bash
set -euo pipefail

# Hugo version used for Cloudflare builds.
# Cloudflare can also set HUGO_VERSION as an environment variable, but this
# script will verify the version and install the requested Linux binary when
# the build image provides an older Hugo.
HUGO_VERSION="${HUGO_VERSION:-0.163.0}"

PROJECT_NAME="rt-nova"

PRODUCTION_BASE_URL="${PRODUCTION_BASE_URL:-https://rawlingstigersnova.org/}"
PREVIEW_BASE_URL="${PREVIEW_BASE_URL:-https://rt-nova.workers.dev/}"

BRANCH="${WORKERS_CI_BRANCH:-${CF_PAGES_BRANCH:-${CF_BRANCH:-}}}"

ensure_hugo_version() {
  echo "Required Hugo version: ${HUGO_VERSION}"

  if command -v hugo >/dev/null 2>&1; then
    echo "Detected Hugo:"
    hugo version || true

    if hugo version 2>/dev/null | grep -q "hugo v${HUGO_VERSION}"; then
      return 0
    fi
  else
    echo "Hugo was not found in PATH."
  fi

  local os arch asset url install_dir
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "${arch}" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *)
      echo "ERROR: Unsupported architecture for automatic Hugo install: ${arch}"
      echo "Install Hugo ${HUGO_VERSION} locally or set Cloudflare HUGO_VERSION=${HUGO_VERSION}."
      exit 1
      ;;
  esac

  case "${os}" in
    linux)
      asset="hugo_extended_${HUGO_VERSION}_linux-${arch}.tar.gz"
      ;;
    darwin)
      echo "ERROR: Local Hugo does not match ${HUGO_VERSION}."
      echo "Install Hugo ${HUGO_VERSION} locally, for example: brew upgrade hugo"
      echo "Automatic install is only enabled for Cloudflare/Linux builds."
      exit 1
      ;;
    *)
      echo "ERROR: Unsupported OS for automatic Hugo install: ${os}"
      echo "Install Hugo ${HUGO_VERSION} manually or set Cloudflare HUGO_VERSION=${HUGO_VERSION}."
      exit 1
      ;;
  esac

  url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${asset}"
  install_dir="${PWD}/.hugo-bin"

  echo "Installing Hugo ${HUGO_VERSION} from:"
  echo "${url}"

  rm -rf "${install_dir}"
  mkdir -p "${install_dir}"

  curl -fsSL "${url}" -o /tmp/hugo.tar.gz
  tar -xzf /tmp/hugo.tar.gz -C "${install_dir}" hugo
  chmod +x "${install_dir}/hugo"
  export PATH="${install_dir}:${PATH}"

  echo "Using Hugo after install:"
  hugo version

  if ! hugo version 2>/dev/null | grep -q "hugo v${HUGO_VERSION}"; then
    echo "ERROR: Hugo install completed but version still does not match ${HUGO_VERSION}."
    exit 1
  fi
}

echo "Cloudflare branch: ${BRANCH:-unknown}"
echo "Cloudflare Pages URL: ${CF_PAGES_URL:-unknown}"

case "${BRANCH}" in
  main)
    HUGO_BASE_URL="${PRODUCTION_BASE_URL}"
    ;;

  preview)
    HUGO_BASE_URL="${PREVIEW_BASE_URL}"
    ;;

  *)
    HUGO_BASE_URL="${CF_PAGES_URL:-${PREVIEW_BASE_URL}}"
    ;;
esac

ensure_hugo_version

echo "Cleaning previous Hugo output..."
rm -rf public

echo "Building Hugo site with baseURL: ${HUGO_BASE_URL}"

hugo \
  --gc \
  --minify \
  --baseURL "${HUGO_BASE_URL}" \
  --destination public

if [[ -f scripts/validate-site.sh ]]; then
  bash scripts/validate-site.sh public
fi
