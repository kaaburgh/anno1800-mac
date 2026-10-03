# anno1800-mac

Make **Anno 1800 playable on Apple Silicon without a CrossOver license** using a free macOS Wine stack, while keeping every experiment observable and reproducible.

The first target is an M3 Max MacBook. CrossOver may be used later as a known-good reference, but the target runtime must not require a paid CrossOver installation or license.

## Current strategy

1. Try the shortest free path first: **direct Sikarugir wrapper + D3DMetal**.
2. Capture host, wrapper, Wine-prefix, launcher, and renderer metadata before changing layers.
3. If the free stack works, turn that configuration into a reproducible recipe rather than inventing patches.
4. If it fails while CrossOver works, reduce the delta systematically and patch only the layer shown to be responsible.
5. Only after that consider replacing the prebuilt Wine engine with a self-built CodeWeavers/upstream Wine.

D3DMetal is an Apple closed-source component with its own restrictive license. Using the Sikarugir D3DMetal path does not introduce a paid CrossOver dependency; redistribution and other uses remain governed by Apple's license. A later fully-FOSS renderer path (for example Anno's DX11 path through DXMT) is optional and is **not** part of the initial success criterion.

## Start here

- [PLAN.md](PLAN.md) — project goal, phases, success criteria, and stopping rules.
- [AGENTS.md](AGENTS.md) — repository contract for coding agents and future investigations.
- [docs/step-a-free-stack.md](docs/step-a-free-stack.md) — first hands-on experiment.
- [docs/experiment-protocol.md](docs/experiment-protocol.md) — how to make runs comparable.
- [docs/reference-stack.md](docs/reference-stack.md) — external projects we intentionally reuse.
- [scripts/doctor.sh](scripts/doctor.sh) — non-destructive host preflight.
- [scripts/bootstrap-sikarugir-wrapper.sh](scripts/bootstrap-sikarugir-wrapper.sh) — assemble a clean wrapper from the current official Sikarugir engine/template catalog, initialize its prefix, enable D3DMetal, and capture A0.
- [scripts/capture-baseline.sh](scripts/capture-baseline.sh) — capture a wrapper/runtime snapshot.
- [scripts/enable-d3dmetal.sh](scripts/enable-d3dmetal.sh) — make D3DMetal the selected Sikarugir renderer.
- [scripts/compare-captures.py](scripts/compare-captures.py) — compare two captures.

## Safety / repository hygiene

Do not commit game files, Ubisoft credentials/tokens, complete Wine prefixes, Apple D3DMetal binaries, or launcher logs before reviewing them for secrets and personal paths.

Generated captures live under `artifacts/` and are ignored by Git.

This repository owns **Anno-1800-specific setup, measurement, diagnosis, and patches**. It should reuse existing Wine/macOS infrastructure instead of becoming another general-purpose Wine wrapper.
