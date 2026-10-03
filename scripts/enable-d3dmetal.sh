#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 /path/to/Wrapper.app" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage
wrapper="$1"
plist="$wrapper/Contents/Info.plist"

[[ -d "$wrapper" ]] || { echo "Wrapper not found: $wrapper" >&2; exit 1; }
[[ -f "$plist" ]] || { echo "Info.plist not found: $plist" >&2; exit 1; }
command -v plutil >/dev/null 2>&1 || { echo "plutil is required" >&2; exit 1; }

has_key() {
  plutil -extract "$1" raw -o - "$plist" >/dev/null 2>&1
}

if ! has_key "D3DMETAL"; then
  echo "Expected D3DMETAL key is missing; the Sikarugir template layout may have changed." >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup="$plist.anno1800-mac.$timestamp.bak"
cp -p "$plist" "$backup"

plutil -replace "D3DMETAL" -integer 1 "$plist"

# For Anno's D3D11/D3D12 baseline, disable alternate D3D10/D3D11 renderer
# toggles. Only touch keys the wrapper already defines.
for key in DXMT DXVK; do
  if has_key "$key"; then
    plutil -replace "$key" -integer 0 "$plist"
  fi
done

echo "Updated: $plist"
echo "Backup:  $backup"
echo
for key in D3DMETAL DXMT DXVK WINEESYNC WINEMSYNC; do
  if has_key "$key"; then
    value="$(plutil -extract "$key" raw -o - "$plist" 2>/dev/null || true)"
    printf '%-12s %s\n' "$key" "$value"
  fi
done

launcher="$wrapper/Contents/MacOS/Sikarugir"
if [[ -x "$launcher" ]]; then
  echo
  echo "If this wrapper currently has Wine processes running, apply the new"
  echo "configuration after closing them, or run:"
  printf '  %q %s\n' "$launcher" "WSS-wineserverkill"
fi
