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
  sikarugir-wrapper.sh /path/to/Wrapper.app install /path/to/setup.exe
  sikarugir-wrapper.sh /path/to/Wrapper.app open
EOF
  exit 2
}

[[ $# -ge 2 ]] || usage
wrapper="$1"
action="$2"
launcher="$wrapper/Contents/MacOS/Sikarugir"
script_dir="$(cd "$(dirname "$0")" && pwd)"

[[ -d "$wrapper" ]] || { echo "Wrapper not found: $wrapper" >&2; exit 1; }

case "$action" in
  status)
    [[ $# -eq 2 ]] || usage
    exec bash "$script_dir/inspect-wrapper.sh" "$wrapper"
    ;;
  open)
    [[ $# -eq 2 ]] || usage
    exec open "$wrapper"
    ;;
esac

[[ -x "$launcher" ]] || {
  echo "Sikarugir launcher not found/executable: $launcher" >&2
  exit 1
}

case "$action" in
  debug)
    [[ $# -eq 2 ]] || usage
    exec "$launcher" debug
    ;;
  winecfg)
    [[ $# -eq 2 ]] || usage
    exec "$launcher" WSS-winecfg
    ;;
  kill)
    [[ $# -eq 2 ]] || usage
    exec "$launcher" WSS-wineserverkill
    ;;
  prefixcreate)
    [[ $# -eq 2 ]] || usage
    exec "$launcher" WSS-wineprefixcreate
    ;;
  install)
    [[ $# -eq 3 ]] || usage
    installer="$3"
    [[ -f "$installer" ]] || { echo "Installer not found: $installer" >&2; exit 1; }
    installer="$(cd "$(dirname "$installer")" && pwd)/$(basename "$installer")"
    exec "$launcher" WSS-installer "$installer"
    ;;
  *)
    usage
    ;;
esac
