# Step A — free stack baseline

This is the first hands-on experiment. It deliberately avoids building Wine from source and keeps one execution path.

## 1. Preflight

From a clone of this repository:

    bash scripts/doctor.sh

The script does not install anything. It checks only requirements used by the direct bootstrap:

- Apple Silicon;
- macOS version;
- Rosetta execution;
- required stock tools;
- free disk space.

Current Sikarugir upstream documents macOS 14.6+ and Rosetta 2 for Apple Silicon.

## 2. Create a dedicated wrapper

Run the repository bootstrap:

    bash scripts/bootstrap-sikarugir-wrapper.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800.app"

The bootstrap is intentionally one fixed evidence-producing path:

1. select the current upstream engine/template unless explicitly pinned;
2. download and validate their archives;
3. assemble a fresh wrapper;
4. create and verify the 64-bit Wine prefix;
5. capture the upstream-default renderer state;
6. select D3DMetal;
7. capture the D3DMetal state.

Current Sikarugir documentation names DXMT as the default renderer before D3DMetal is selected. The capture records the actual D3DMetal/DXMT/DXVK state and bundled versions rather than treating that default as permanent.

The bootstrap prints and records SHA-256 hashes of the exact engine/template archives.

For a pinned rerun:

    bash scripts/bootstrap-sikarugir-wrapper.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800-pinned.app" \
      --engine WS12WineSikarugir11.0_1 \
      --template Template-1.0.21

An explicitly supplied engine/template is a reproduction pin. The engine does not have to remain present in the current upstream `EngineList.txt`; its release asset only has to remain available.

The example versions above were current on 2026-10-03. They are examples, not an Anno-specific recommendation. A future clean reproduction should pin whichever combination is actually proven to work.

The script refuses to overwrite an existing wrapper. It targets stock macOS/Bash 3.2 and does not depend on Homebrew, Sikarugir Creator, or Porting Kit.

## 3. Renderer baseline

The normal bootstrap already selects D3DMetal and captures state immediately before and after that change.

`scripts/enable-d3dmetal.sh` exists as the narrow implementation helper for that transition. It expects the current Sikarugir `D3DMETAL` key to exist; if the key disappears, the script fails instead of inventing an obsolete setting.

For Anno, the renderer hypothesis is deliberately limited to:

- DX12 or DX11 through D3DMetal first;
- DX11 through DXMT only as a fallback if evidence requires it.

Do not add unrelated renderer backends to the experiment merely because they exist in the generic Sikarugir template.

## 4. Install the launcher route you actually own

Do not install both routes into the same first baseline.

### Ubisoft-owned copy

Install Ubisoft Connect in this wrapper and sign in normally.

### Steam-owned copy

Install Windows Steam in this wrapper, sign in, then allow the owned Anno installation to install/use Ubisoft Connect as required.

A recent independent Sikarugir project demonstrates that a Windows Steam wrapper with D3DMetal can be assembled without CrossOver. We use that as implementation evidence, not as proof that its pinned engine is the right Anno engine.

After the launcher is working:

    bash scripts/capture-baseline.sh \
      --wrapper "/path/to/Anno1800.app" \
      --label launcher-working

## 5. Install / discover Anno

Once Anno is installed:

    bash scripts/capture-baseline.sh \
      --wrapper "/path/to/Anno1800.app" \
      --label anno-installed

The inspector searches the wrapper for common Steam, Ubisoft Connect, and Anno executables. It records paths and metadata, not file contents.

## 6. First game oracle

Record each result separately:

1. process starts;
2. game window appears;
3. main menu renders;
4. input works;
5. audio works;
6. a real save loads;
7. 30 minutes of normal play remain stable.

Try Anno's DX12 mode first with D3DMetal. Keep DX11 as an explicit second experiment if DX12 fails or exhibits defects.

Capture immediately after the first main-menu success and after the first stable gameplay session.

## 7. What not to do yet

Do not:

- build Wine from source;
- import CrossOver bottles;
- install random winetricks verbs;
- copy registry files from someone else's prefix;
- add multiple graphics translation layers;
- add generic wrapper controls or alternate setup paths without a demonstrated need;
- apply game-specific Wine patches without a demonstrated failure they address.

If Step A works, the next task is clean reproduction, not deeper reverse engineering.

If Step A fails, preserve the failing capture and exact symptom. That becomes the starting evidence for a narrow comparison.
