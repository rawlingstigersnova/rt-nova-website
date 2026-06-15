#!/usr/bin/env bash
set -euo pipefail

# Source-level check. This intentionally does not remove public/ or resources/;
# generated-file cleanup belongs in build.sh or .gitignore, not validation.

if grep -RInE "cdn-app\.teamlinkt\.com|api\.iconify\.design|code\.iconify\.design|cdn\.iconify\.design" \
  . \
  --exclude-dir=.git \
  --exclude-dir=public \
  --exclude-dir=resources; then
  echo "ERROR: Found external CDN references that should be self-hosted." >&2
  exit 1
fi

python3 - <<'PY'
import pathlib
import re
import sys

missing=[]
files = []
for root, patterns in [('data', ('*.yaml', '*.yml')), ('content', ('*.md',)), ('layouts', ('*.html',))]:
    base = pathlib.Path(root)
    if not base.exists():
        continue
    for pattern in patterns:
        files.extend(base.rglob(pattern))

for p in files:
    text = p.read_text(errors='ignore')
    for ref in re.findall(r'(?<!https:)//?images/teamlinkt/[^\s"\'<>)]+' , text):
        clean = '/' + ref.lstrip('/')
        if not pathlib.Path('static' + clean).exists():
            missing.append((str(p), clean))

if missing:
    for p, ref in missing:
        print(f'MISSING: {p}: {ref}')
    sys.exit(1)

print('OK: no old CDN references and all local /images/teamlinkt/ assets exist.')
PY
