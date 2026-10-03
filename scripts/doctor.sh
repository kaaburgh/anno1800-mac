#!/usr/bin/env bash
set -u

fail=0
warn=0

pass() { printf 'PASS  %s\n' "$*"; }
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
  IFS=. read -r major minor _patch <<< "$macos"
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

for tool in curl tar shasum plutil; do
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool available"
  else
    failure "$tool is required by the direct bootstrap"
  fi
done

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

printf '\nSummary: %d failure(s), %d warning(s).\n' "$fail" "$warn"
(( fail == 0 ))
