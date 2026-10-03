# AGENTS.md

## Mission

Make Anno 1800 playable on Apple Silicon without a paid CrossOver dependency.

Read `PLAN.md` before making changes. The first target is an M3 Max Mac. The initial preferred stack is a direct Sikarugir wrapper + Wine + D3DMetal.

## Decision order

1. Reproduce and capture the current state.
2. Prefer existing free-stack functionality and configuration.
3. Change one meaningful variable at a time.
4. If the free stack works, make it reproducible and stop adding compatibility complexity.
5. Use CrossOver only as a known-good reference if the free stack fails.
6. Build or patch Wine only after evidence points at the Wine layer.

Do not create an artificial Wine bug to justify a Wine patch.

## Evidence rules

A compatibility claim needs an observed oracle plus a capture. Useful oracles progress from:

- launcher starts/authenticates;
- Anno process starts;
- game window appears;
- main menu renders;
- input/audio work;
- a real save loads;
- 30 minutes of normal gameplay remain stable;
- the same result reproduces from a clean wrapper.

Use `scripts/capture-baseline.sh` before and after important configuration changes. Record symptoms, not diagnoses, in notes.

## External dependencies

Reuse Sikarugir, Wine engines, D3DMetal and other established infrastructure rather than reimplementing a general-purpose wrapper here.

Do not pin or replace a Wine engine merely because another game's recipe uses it. A version becomes Anno-specific only after evidence from this project.

When an external recipe suggests a tweak, record why it is being tried and retain it only if it changes the observed result.

## Deliberate minimalism for reviews

This repository intentionally does **not** pre-harden hypothetical configurations or environments. Review findings should be tied to the current Anno 1800 experiment, an observed failure, or a cheap invariant on the main execution path.

In particular, do not reintroduce without evidence:

- generic wrapper CLI commands or bootstrap escape hatches such as skipping prefix creation, D3DMetal selection, or captures;
- Porting Kit / Sikarugir Creator / Homebrew as parallel Step A execution paths;
- D3D9, DirectDraw, or unrelated renderer settings such as D9VK/CNC_DDRAW into the Anno renderer strategy;
- generic renderer inventories beyond the D3DMetal / DXMT / DXVK paths relevant to Anno's DX11/DX12 modes;
- validation of an explicitly pinned Wine engine against the current upstream engine list;
- rare shell/environment compatibility guards for conditions not observed on the target machine.

Keep safeguards that protect data or verify a main-path invariant: do not overwrite wrappers/captures, validate downloaded archives before use, verify prefix creation, back up modified plist files, and avoid leaking credentials.

If a currently omitted case becomes a real failure, add the smallest fix together with the evidence that required it.

## Safety and legal boundaries

Do not:

- commit or redistribute Anno 1800 game files;
- commit complete Wine prefixes;
- commit D3DMetal or other vendor binaries;
- commit credentials, authentication tokens, browser profiles, or unreviewed launcher logs;
- bypass Ubisoft/Steam ownership checks, DRM, activation, anti-cheat, or account controls;
- import a CrossOver bottle as the target solution.

CrossOver may be installed temporarily only to establish a reference result when needed.

## macOS scripting

Target stock macOS userland first.

- Scripts must work with Apple's Bash 3.2 unless they explicitly declare and verify another shell.
- Do not assume GNU behavior for `find`, `sed`, `awk`, `xargs`, or similar tools.
- Quote paths; assume spaces and Unicode.
- Never overwrite an existing wrapper or prefix without an explicit destructive flag and a clear message.
- Prefer exact upstream release metadata over copied version strings from forum posts.

Before publishing script changes, run `make check`. It performs shell syntax checks and Python compile checks without adding project-specific CI infrastructure.

## Scope control

This repository owns Anno-1800-specific setup, measurement, diagnosis, automation, and any patches that prove necessary.

It is not a new generic Wine launcher.

If a failure is in a closed layer such as D3DMetal, preserve the minimal evidence and test an available alternate path (for example DX11 + DXMT) rather than assuming Wine can fix it.
