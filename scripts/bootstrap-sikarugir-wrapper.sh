#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  bootstrap-sikarugir-wrapper.sh --wrapper /path/to/Anno1800.app [options]

Options:
  --engine NAME       Sikarugir engine from the official EngineList.txt.
                      Default: first (current) entry from upstream.
  --template NAME     Sikarugir template version.
                      Default: upstream NewestVersion.txt.
  --no-prefix         Assemble wrapper but do not initialize the Wine prefix.
  --no-d3dmetal       Do not select D3DMetal after assembly.
  --no-capture        Do not create an anno1800-mac baseline capture.
  -h, --help          Show this help.

The target wrapper must not already exist. The script downloads only from the
Sikarugir-App GitHub organization and reuses Sikarugir's normal cache directory.
USAGE
  exit "${1:-2}"
}

wrapper=""
engine=""
template=""
create_prefix=1
enable_d3dmetal=1
capture=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wrapper)
      [[ $# -ge 2 ]] || usage
      wrapper="$2"; shift 2 ;;
    --engine)
      [[ $# -ge 2 ]] || usage
      engine="$2"; shift 2 ;;
    --template)
      [[ $# -ge 2 ]] || usage
      template="$2"; shift 2 ;;
    --no-prefix)
      create_prefix=0; shift ;;
    --no-d3dmetal)
      enable_d3dmetal=0; shift ;;
    --no-capture)
      capture=0; shift ;;
    -h|--help)
      usage 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage ;;
  esac
done

[[ -n "$wrapper" ]] || usage
[[ "$(uname -s 2>/dev/null)" == "Darwin" ]] || { echo "macOS required" >&2; exit 1; }
[[ "$(uname -m 2>/dev/null)" == "arm64" ]] || { echo "Apple Silicon required" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "tar is required" >&2; exit 1; }

if ! /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
  echo "Rosetta 2 is required. Install it with:" >&2
  echo "  /usr/sbin/softwareupdate --install-rosetta --agree-to-license" >&2
  exit 1
fi

if [[ -e "$wrapper" ]]; then
  echo "Refusing to overwrite existing path: $wrapper" >&2
  exit 1
fi

ENGINE_LIST_URL="https://raw.githubusercontent.com/Sikarugir-App/Engines/main/EngineList.txt"
TEMPLATE_VERSION_URL="https://raw.githubusercontent.com/Sikarugir-App/Template/main/NewestVersion.txt"
ENGINE_RELEASE_BASE="https://github.com/Sikarugir-App/Engines/releases/download/v1.0"
TEMPLATE_RELEASE_BASE="https://github.com/Sikarugir-App/Template/releases/download/v1.0"

engine_list="$(curl -fsSL "$ENGINE_LIST_URL")"
[[ -n "$engine_list" ]] || { echo "Official Sikarugir engine list is empty" >&2; exit 1; }

if [[ -z "$engine" ]]; then
  engine="$(printf '%s\n' "$engine_list" | sed -n '1{/^[[:space:]]*$/!p;}')"
fi
if ! printf '%s\n' "$engine_list" | grep -Fqx -- "$engine"; then
  echo "Engine is not present in current official EngineList.txt: $engine" >&2
  echo "Available engines:" >&2
  printf '  %s\n' $engine_list >&2
  exit 1
fi

if [[ -z "$template" ]]; then
  template="$(curl -fsSL "$TEMPLATE_VERSION_URL" | tr -d '\r\n')"
fi
[[ "$template" == Template-* ]] || { echo "Unexpected template name: $template" >&2; exit 1; }

cache="$HOME/Library/Application Support/Sikarugir"
engine_archive="$cache/Engines/${engine}.tar.xz"
template_archive="$cache/Template/${template}.tar.xz"
engine_url="$ENGINE_RELEASE_BASE/${engine}.tar.xz"
template_url="$TEMPLATE_RELEASE_BASE/${template}.tar.xz"

fetch() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -s "$dest" ]]; then
    echo "Using cached: $dest"
    return
  fi

  local tmp="${dest}.part.$$"
  echo "Downloading: $url"
  if ! curl -fL --retry 3 --retry-delay 2 --progress-bar -o "$tmp" "$url"; then
    rm -f "$tmp"
    return 1
  fi
  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    echo "Downloaded file is empty: $url" >&2
    return 1
  fi
  mv "$tmp" "$dest"
}

echo "Selected engine:   $engine"
echo "Selected template: $template"
echo "Target wrapper:    $wrapper"

fetch "$engine_url" "$engine_archive"
fetch "$template_url" "$template_archive"

engine_sha256="$(shasum -a 256 "$engine_archive" | awk '{print $1}')"
template_sha256="$(shasum -a 256 "$template_archive" | awk '{print $1}')"
echo "Engine SHA256:     $engine_sha256"
echo "Template SHA256:   $template_sha256"

parent="$(dirname "$wrapper")"
mkdir -p "$parent"
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/anno1800-sikarugir.XXXXXX")"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

mkdir -p "$tmpdir/template"
tar -xf "$template_archive" -C "$tmpdir/template"
template_apps=()
while IFS= read -r item; do
  template_apps[${#template_apps[@]}]="$item"
done < <(find "$tmpdir/template" -type d -name '*.app' -prune -print)
if (( ${#template_apps[@]} != 1 )); then
  echo "Expected exactly one .app in template archive; found ${#template_apps[@]}" >&2
  printf '  %s\n' "${template_apps[@]:-}" >&2
  exit 1
fi
cp -R "${template_apps[0]}" "$wrapper"

shared="$wrapper/Contents/SharedSupport"
mkdir -p "$shared"
mkdir -p "$tmpdir/engine"
tar -xf "$engine_archive" -C "$tmpdir/engine"
bundles=()
while IFS= read -r item; do
  bundles[${#bundles[@]}]="$item"
done < <(find "$tmpdir/engine" -type d -name 'wswine.bundle' -prune -print)
if (( ${#bundles[@]} != 1 )); then
  echo "Expected exactly one wswine.bundle in engine archive; found ${#bundles[@]}" >&2
  printf '  %s\n' "${bundles[@]:-}" >&2
  exit 1
fi
cp -R "${bundles[0]}" "$shared/wine"

launcher="$wrapper/Contents/MacOS/Sikarugir"
[[ -x "$launcher" ]] || { echo "Assembled wrapper has no executable Sikarugir launcher" >&2; exit 1; }

script_dir="$(cd "$(dirname "$0")" && pwd)"

if (( create_prefix )); then
  echo "Creating Wine prefix..."
  "$launcher" WSS-wineprefixcreate
fi

if (( enable_d3dmetal )); then
  bash "$script_dir/enable-d3dmetal.sh" "$wrapper"
fi

if (( capture )); then
  bash "$script_dir/capture-baseline.sh" \
    --wrapper "$wrapper" \
    --label fresh-sikarugir-d3dmetal \
    --note "Fresh wrapper assembled from official Sikarugir engine=$engine engine_sha256=$engine_sha256 template=$template template_sha256=$template_sha256"
fi

cat <<EOF

Wrapper ready:
  $wrapper

Engine:
  $engine
  sha256=$engine_sha256
Template:
  $template
  sha256=$template_sha256

Inspect:
  bash "$script_dir/inspect-wrapper.sh" "$wrapper"
Open:
  open "$wrapper"
EOF
