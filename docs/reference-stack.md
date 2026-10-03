# Reference stack

Snapshot date: 2026-10-03.

This file records the external work we intentionally reuse so the repository does not reinvent it.

## Sikarugir

Upstream:

https://github.com/Sikarugir-App/Sikarugir

Sikarugir is a current Wineskin-successor wrapper project. Its upstream README documents:

- Apple Silicon support;
- Rosetta 2 requirement;
- D3DMetal as a toggle for 64-bit Direct3D 11/12 through Metal;
- DXMT and DXVK as alternative renderer paths;
- Homebrew installation through the Sikarugir-App tap.

Treat the upstream README as authoritative for installation commands because these have changed over time.

## Porting Kit

https://www.portingkit.com/

Porting Kit is useful as the higher-level workflow/UI. The project plan allows using it for Step A, but the evidence we capture should still identify the resulting wrapper, Wine engine, renderer, and prefix state.

## D3DMetal / Game Porting Toolkit

Apple's D3DMetal is the preferred initial renderer because it is already proven as a practical Direct3D 11/12 path on Apple Silicon.

It is **not open source**. Therefore:

- using it satisfies the initial no-CrossOver-license goal;
- it does not satisfy a hypothetical future 100%-FOSS goal;
- D3DMetal binaries must not be committed here.

## Free Sikarugir + D3DMetal prior art

https://github.com/mirpo/windows-steam-on-apple-silicon

This project is useful evidence for current Sikarugir wrapper internals and CLI behavior. In particular, it demonstrates a self-contained Windows Steam wrapper assembled without CrossOver and documents the standard layout:

- `Contents/MacOS/Sikarugir`
- `Contents/SharedSupport/wine`
- `Contents/drive_c`
- renderer settings in `Contents/Info.plist`

We deliberately do **not** copy its pinned Wine engine choice into the Anno plan. A working engine for one Steam game is not evidence that the same engine is optimal for Anno 1800.

## Per-game wrapper prior art

https://github.com/therealjkvalentine/mac-gaming-ports

This is a current example of the same architectural choice: keep Sikarugir/Wine/D3DMetal generic and put game-specific knowledge in a thin recipe layer. It has no Anno 1800 recipe today, but its verified games provide useful implementation patterns for self-contained wrappers and renderer selection.

We reuse only generally applicable wrapper/build lessons. This project keeps Ubisoft/Steam authentication and DRM intact and does not adopt unrelated DRM-bypass/offline tooling.

## Wine source / later phases

If Step A requires deeper work, candidates include:

- upstream Wine;
- CodeWeavers-published FOSS Wine sources;
- existing Apple-Silicon Wine build tooling.

Those belong to Phase C, not the first baseline.

## Rule for external recipes

A recipe is evidence, not configuration truth.

Whenever we reuse an external tweak:

1. record the source and date;
2. state the failure it is supposed to address;
3. capture before/after;
4. keep it only if it changes the observed oracle.
