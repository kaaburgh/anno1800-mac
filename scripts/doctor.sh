#!/usr/bin/env bash
set -u

fail=0
warn=0

pass() { printf 'PASS  %s\n' "$*"; }
info() { printf 'INFO  %s\n' "$*"; }
warning() { printf 'WARN  %s\n' "$*"; warn=$((warn + 1)); }
failure() { printf 'FAIL  %s\n' "$*" >&2; fail=$((fail + 1)); }

if [[ "$(uname -s 2>/dev/null)" != "Darwin" ]]; then
  failure "macOS required (got $(uname -s 2>/dev/null || echo unknown))"
else
  pass "macOS host"
fi

arch="$(uname -m 2>/dev/null || echo unknown)"
if [[ "$arch" == "arm64" ]]; then
  pass "Apple Silicon architecture: $arch"
else
  failure "Apple Silicon required for this project (got $arch)"
fi

if command -v sw_vers >/dev/null 2>&1; then
  macos="$(sw_vers -productVersion)"
  IFS=. read -r major minor patch <<< "$macos"
  major="${major:-0}"
  minor="${minor:-0}"
  if (( major > 14 || (major == 14 && minor >= 6) )); then
    pass "macOS $macos (meets current Sikarugir 14.6+ baseline)"
  else
    failure "macOS $macos is older than current Sikarugir's documented 14.6+ baseline"
  fi
else
  failure "sw_vers not found"
fi

if [[ "$arch" == "arm64" ]]; then
  if /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
    pass "Rosetta x86_64 execution works"
  else
    failure "Rosetta 2 unavailable; install with: /usr/sbin/softwareupdate --install-rosetta --agree-to-license"
  fi
fi

if command -v brew >/dev/null 2>&1; then
  pass "Homebrew: $(brew --version 2>/dev/null | head -n 1)"
else
  failure "Homebrew not found"
fi

if [[ -d "/Applications/Sikarugir Creator.app" ]]; then
  version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "/Applications/Sikarugir Creator.app/Contents/Info.plist" 2>/dev/null || echo unknown)"
  pass "Sikarugir Creator installed: $version"
elif command -v brew >/dev/null 2>&1 && brew list --cask sikarugir >/dev/null 2>&1; then
  pass "Sikarugir Homebrew cask installed"
else
  warning "Sikarugir Creator not detected"
  info "Current upstream install:"
  info "  brew trust Sikarugir-App/sikarugir"
  info "  brew install --cask Sikarugir-App/sikarugir/sikarugir

fi

portingkit=""
for candidate in "/Applications/Porting Kit.app" "$HOME/Applications/Porting Kit.app"; do
  if [[ -d "$candidate" ]]; then
    portingkit="$candidate"
    break
  fi
done
if [[ -n "$portingkit" ]]; then
  version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$portingkit/Contents/Info.plist" 2>/dev/null || echo unknown)"
  pass "Porting Kit detected: $version"
else
  info "Porting Kit not detected (optional if using Sikarugir directly)"
fi

free_kb="$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')"
if [[ "$free_kb" =~ ^[0-9]+$ ]]; then
  free_gb=$((free_kb / 1024 / 1024))
  if (( free_gb >= 60 )); then
    pass "Free space under HOME filesystem: ~${free_gb} GiB"
  elif (( free_gb >= 30 )); then
    warning "Free space is ~${free_gb} GiB; workable but leave room for wrapper, launcher, game and captures"
  else
    failure "Only ~${free_gb} GiB free; make more room before installing Anno"
  fi
fi

if command -v git >/dev/null 2>&1; then
  pass "git: $(git --version)"
else
  warning "git not found; not required to play, but needed to work on this repository normally"
fi

printf '\nSummary: %d failure(s), %d warning(s).\n' "$fail" "$warn"
(( fail == 0 ))
