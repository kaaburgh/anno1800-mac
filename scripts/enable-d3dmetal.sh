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

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup="$plist.anno1800-mac.$timestamp.bak"
cp -p "$plist" "$backup"

has_key() {
  plutil -extract "$1" raw -o - "$plist" >/dev/null 2>&1
}

set_int() {
  local key="$1" value="$2"
  if has_key "$key"; then
    plutil -replace "$key" -integer "$value" "$plist"
  else
    plutil -insert "$key" -integer "$value" "$plist"
  fi
}

set_int "D3DMETAL" 1

# These renderer toggles are mutually exclusive in a useful baseline.
# Only touch them when the wrapper already defines the key, because templates
# may change names and we do not want to invent configuration.
for key in DXMT DXVK; do
  if has_key "$key"; then
    plutil -replace "$key" -integer 0 "$plist"
  fi
done

echo "Updated: $plist"
echo "Backup:  $backup"
echo
for key in D3DMETAL DXMT DXVK MOLTENVKCX WINEESYNC WINEMSYNC; do
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
