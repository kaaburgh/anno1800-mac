# Plan

## Goal

Run Anno 1800 on the first target machine (M3 Max Apple Silicon Mac) without requiring a CrossOver license.

A successful initial solution may use:

- Sikarugir;
- a freely available Wine engine;
- Rosetta 2;
- Apple's D3DMetal / Game Porting Toolkit components;
- local scripts and Anno-specific configuration from this repository.

The initial goal is **free as in no paid CrossOver dependency**, not necessarily 100% open source.

## Non-goals for the first success

- upstreaming a Wine patch;
- supporting every Apple Silicon generation;
- supporting Intel Macs;
- making a general-purpose Wine launcher;
- removing Ubisoft Connect / game DRM;
- redistributing Wine prefixes, game files, D3DMetal, or vendor installers;
- forcing a Wine patch to exist if configuration alone already works.

## Success ladder

Each rung is independently useful and should be recorded.

### A0 — free runtime exists

A Sikarugir wrapper can be created on the target Mac with D3DMetal selected and a 64-bit Wine prefix available.

### A1 — launcher works

The store/launcher route used by the owned copy of Anno works far enough to authenticate and install or discover Anno 1800.

Two routes are allowed:

- Ubisoft route: Ubisoft Connect directly in the wrapper.
- Steam route: Windows Steam in the wrapper, then Ubisoft Connect as required by Anno.

Do not choose one globally until the actual owned edition is known.

### A2 — game boots

Anno1800.exe reaches the main menu with usable graphics, input, and audio.

### A3 — gameplay is viable

A real save loads and remains playable for at least 30 minutes. Record:

- renderer and DirectX mode;
- rough resolution / quality settings;
- obvious rendering defects;
- hangs/crashes;
- launcher problems;
- material performance degradation over time.

This is not a benchmark project; numbers are only needed when they distinguish configurations.

### A4 — clean reproduction

The working result can be recreated from a clean wrapper using documented steps and scripts in this repository.

This is the main project completion criterion.

### B — differential diagnosis, only if needed

If free stack fails but current CrossOver succeeds on the same Mac/game build:

1. capture both configurations;
2. compare renderer, Wine engine, prefix registry hashes, wrapper settings, launcher route, and environment;
3. change one layer at a time;
4. keep the smallest change that advances the oracle.

### C — self-built Wine, only if needed or useful

Replace the prebuilt Wine engine with a self-built CodeWeavers/upstream Wine while holding the rest of the known-good stack fixed.

Do not start here. A custom Wine build is a diagnostic/tooling milestone, not the project's definition of success.

## Experiment order

1. Run `scripts/doctor.sh`.
2. Create one dedicated Anno wrapper with the repository bootstrap.
4. Capture `pre-launcher`.
5. Select D3DMetal; capture `d3dmetal-base`.
6. Install the relevant Windows launcher; capture `launcher-installed`.
7. Install/discover Anno; capture `anno-installed`.
8. Try DX12 first when using D3DMetal, but keep DX11 as an explicit comparison rather than an assumption.
9. Capture `main-menu` and first stable `gameplay` state.
10. If successful, repeat from a clean wrapper before debugging anything deeper.
11. Only if free path fails, create a CrossOver reference run.

## Experimental discipline

The unit of evidence is a **capture + observed outcome**, not a remembered GUI setting.

Prefer:

- one wrapper per major route;
- one renderer per run;
- explicit labels;
- immutable captures;
- exact game/launcher versions where visible.

Avoid:

- changing Wine engine, renderer, launcher settings, and prefix tweaks in one attempt;
- copying an old prefix into a supposedly clean baseline;
- interpreting "launcher window appeared" as "game compatibility works";
- editing registry/plist without recording before/after state.

## Stopping rules

Stop adding complexity when A4 is reached.

If a simple Sikarugir configuration already survives a clean rebuild and real gameplay, the correct result is documentation and automation, not an artificial compatibility patch.

If a failure is proven to be inside a closed component such as D3DMetal, preserve the minimal reproducer and consider the DX11/DXMT alternative rather than pretending the Wine layer can necessarily fix it.
