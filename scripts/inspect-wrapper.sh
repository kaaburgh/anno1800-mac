#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 /path/to/Wrapper.app" >&2; exit 2; }
wrapper="$1"
[[ -d "$wrapper" ]] || { echo "Wrapper not found: $wrapper" >&2; exit 1; }

plist="$wrapper/Contents/Info.plist"
wine_dir="$wrapper/Contents/SharedSupport/wine"
prefix="$wrapper/Contents/SharedSupport/prefix"
drive_c="$prefix/drive_c"
renderer_dir="$wrapper/Contents/Frameworks/renderer"

echo "[wrapper]"
printf 'path=%s\n' "$wrapper"
printf 'name=%s\n' "$(basename "$wrapper")"

if [[ -f "$plist" ]]; then
  echo
  echo "[plist]"
  for key in "D3DMETAL" "DXMT" "DXVK" "FASTMATH" "METAL_HUD" "WINEESYNC" "WINEMSYNC" "Program Name and Path" "Program Flags" "CFBundleShortVersionString" "CFBundleVersion"; do
    if value="$(plutil -extract "$key" raw -o - "$plist" 2>/dev/null)"; then
      printf '%s=%s\n' "$key" "$value"
    fi
  done
else
  echo "plist=missing"
fi

echo
echo "[renderer]"
for renderer_name in d3dmetal dxmt dxvk; do
  version_file="$renderer_dir/$renderer_name/version"
  if [[ -f "$version_file" ]]; then
    printf '%s=%s\n' "$renderer_name" "$(paste -sd ' ' "$version_file")"
  fi
done

d3dmetal_plist="$renderer_dir/d3dmetal/external/D3DMetal.framework/Versions/A/Resources/Info.plist"
if [[ -f "$d3dmetal_plist" ]]; then
  for key in CFBundleShortVersionString CFBundleVersion; do
    if value="$(plutil -extract "$key" raw -o - "$d3dmetal_plist" 2>/dev/null)"; then
      printf 'd3dmetal_%s=%s\n' "$key" "$value"
    fi
  done
fi

echo
echo "[engine]"
if [[ -f "$wine_dir/version" ]]; then
  printf 'version=%s\n' "$(cat "$wine_dir/version")"
else
  echo "version=unknown"
fi
for wine_bin in "$wine_dir/bin/wine64" "$wine_dir/bin/wine"; do
  if [[ -e "$wine_bin" ]]; then
    file "$wine_bin" 2>/dev/null || true
  fi
done

echo
echo "[prefix]"
if [[ -d "$drive_c" ]]; then
  echo "drive_c=present"
else
  echo "drive_c=missing"
fi
for reg in user.reg system.reg userdef.reg; do
  path="$prefix/$reg"
  if [[ -f "$path" ]]; then
    printf '%s_sha256=' "$reg"
    shasum -a 256 "$path" | awk '{print $1}'
  fi
done

echo
echo "[known-executables]"
candidates=(
  "$drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/UbisoftConnect.exe"
  "$drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/upc.exe"
  "$drive_c/Program Files (x86)/Steam/steam.exe"
  "$drive_c/Program Files/Steam/steam.exe"
)
for path in "${candidates[@]}"; do
  [[ -f "$path" ]] && printf 'found=%s\n' "$path"
done

if [[ -d "$drive_c" ]]; then
  while IFS= read -r path; do
    printf 'found=%s\n' "$path"
  done < <(find "$drive_c" -type f \( -iname 'Anno1800.exe' -o -iname 'UbisoftConnect.exe' -o -iname 'steam.exe' \) -print 2>/dev/null || true)
fi

echo
echo "[wrapper-cli]"
launcher="$wrapper/Contents/MacOS/Sikarugir"
if [[ -x "$launcher" ]]; then
  printf 'launcher=%s\n' "$launcher"
else
  echo "launcher=missing"
fi
