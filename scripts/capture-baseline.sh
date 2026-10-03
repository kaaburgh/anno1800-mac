#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  capture-baseline.sh --wrapper /path/to/Wrapper.app --label LABEL [--note TEXT]
EOF
  exit 2
}

wrapper=""
label=""
note=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wrapper)
      [[ $# -ge 2 ]] || usage
      wrapper="$2"; shift 2 ;;
    --label)
      [[ $# -ge 2 ]] || usage
      label="$2"; shift 2 ;;
    --note)
      [[ $# -ge 2 ]] || usage
      note="$2"; shift 2 ;;
    *)
      usage ;;
  esac
done

[[ -n "$wrapper" && -n "$label" ]] || usage
[[ -d "$wrapper" ]] || { echo "Wrapper not found: $wrapper" >&2; exit 1; }

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_dir="$(cd "$script_dir/.." && pwd)"
prefix="$wrapper/Contents/SharedSupport/prefix"
safe_label="$(printf '%s' "$label" | tr -cs 'A-Za-z0-9._-' '-')"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
out="$repo_dir/artifacts/${timestamp}-${safe_label}"
mkdir -p "$repo_dir/artifacts"
if ! mkdir "$out"; then
  echo "Capture already exists; refusing to overwrite: $out" >&2
  exit 1
fi

{
  echo "captured_utc=$timestamp"
  echo "label=$label"
  printf 'wrapper=%s\n' "$wrapper"
  [[ -n "$note" ]] && printf 'note=%s\n' "$note"
} > "$out/summary.txt"

{
  echo "[os]"
  sw_vers 2>/dev/null || true
  printf 'arch=%s\n' "$(uname -m 2>/dev/null || echo unknown)"
  printf 'kernel=%s\n' "$(uname -r 2>/dev/null || echo unknown)"
  printf 'model=%s\n' "$(sysctl -n hw.model 2>/dev/null || echo unknown)"
  printf 'memory_bytes=%s\n' "$(sysctl -n hw.memsize 2>/dev/null || echo unknown)"
  if /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
    echo "rosetta_x86_64=yes"
  else
    echo "rosetta_x86_64=no"
  fi
} > "$out/host.txt"

bash "$script_dir/inspect-wrapper.sh" "$wrapper" > "$out/wrapper.txt"

{
  echo "[relevant-processes]"
  ps -axo comm= 2>/dev/null |
    grep -Ei 'wine|wineserver|anno|ubisoft|steam|sikarugir' |
    awk -F/ '{print $NF}' |
    sort -fu || true
} > "$out/processes.txt"

hash_file() {
  local label="$1" path="$2"
  if [[ -f "$path" ]]; then
    printf '%s_sha256=' "$label"
    shasum -a 256 "$path" | awk '{print $1}'
  fi
}

{
  hash_file "Info.plist" "$wrapper/Contents/Info.plist"
  hash_file "prefix/user.reg" "$prefix/user.reg"
  hash_file "prefix/system.reg" "$prefix/system.reg"
  hash_file "prefix/userdef.reg" "$prefix/userdef.reg"
  hash_file "wine/version" "$wrapper/Contents/SharedSupport/wine/version"
} > "$out/hashes.txt"

cat > "$out/README.txt" <<'EOF'
This capture intentionally contains metadata, not complete logs or registry files.

Before sharing or committing any additional launcher logs, inspect them for:
- authentication tokens;
- account names;
- email addresses;
- personal filesystem paths;
- URLs with signed/query credentials.

The artifacts/ directory is gitignored by this repository.
EOF

echo "Capture written to:"
echo "  $out"
echo
echo "Review summary:"
cat "$out/summary.txt"
