#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  sikarugir-wrapper.sh /path/to/Wrapper.app status
  sikarugir-wrapper.sh /path/to/Wrapper.app debug
  sikarugir-wrapper.sh /path/to/Wrapper.app winecfg
  sikarugir-wrapper.sh /path/to/Wrapper.app kill
  sikarugir-wrapper.sh /path/to/Wrapper.app prefixcreate
  sikarugir-wrapper.sh /path/to/Wrapper.app open
EOF
  exit 2
}

[[ $# -eq 2 ]] || usage
wrapper="$1"
action="$2"
launcher="$wrapper/Contents/MacOS/Sikarugir"
script_dir="$(cd "$(dirname "$0")" && pwd)"

[[ -d "$wrapper" ]] || { echo "Wrapper not found: $wrapper" >&2; exit 1; }

case "$action" in
  status)
    exec bash "$script_dir/inspect-wrapper.sh" "$wrapper"
    ;;
  open)
    exec open "$wrapper"
    ;;
esac

[[ -x "$launcher" ]] || {
  echo "Sikarugir launcher not found/executable: $launcher" >&2
  exit 1
}

case "$action" in
  debug)
    exec "$launcher" debug
    ;;
  winecfg)
    exec "$launcher" WSS-winecfg
    ;;
  kill)
    exec "$launcher" WSS-wineserverkill
    ;;
  prefixcreate)
    exec "$launcher" WSS-wineprefixcreate
    ;;
  *)
    usage
    ;;
esac
