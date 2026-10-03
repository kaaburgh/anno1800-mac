# Step A — free stack baseline

This is the first hands-on experiment. It deliberately avoids building Wine from source.

## 1. Preflight

From a clone of this repository:

    bash scripts/doctor.sh

The script does not install anything. It checks:

- Apple Silicon;
- macOS version;
- Rosetta execution;
- Homebrew (optional for the direct bootstrap; useful for the Creator GUI path);
- Sikarugir / Porting Kit presence;
- free disk space.

Current Sikarugir upstream documents macOS 14.6+ and Rosetta 2 for Apple Silicon.

The direct bootstrap in the next section does **not** require Homebrew or Sikarugir Creator. If you prefer the Creator GUI, use the current upstream Homebrew instructions rather than copying an old command from a forum:

    brew upgrade
    brew trust Sikarugir-App/sikarugir
    brew install --cask Sikarugir-App/sikarugir/sikarugir

## 2. Create a dedicated wrapper

The shortest reproducible path is the repository bootstrap:

    bash scripts/bootstrap-sikarugir-wrapper.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800.app"

By default it reads the **current official** Sikarugir `EngineList.txt` and `NewestVersion.txt` at execution time, downloads the selected release assets into Sikarugir's normal cache, assembles a fresh wrapper, creates and verifies the 64-bit prefix, captures the upstream-default renderer state, enables D3DMetal, and captures the D3DMetal state. Current Sikarugir documentation names DXMT as the default renderer; the capture records the actual renderer keys and bundled renderer versions rather than assuming that default will never change. It records SHA-256 hashes of the exact engine and template archives in those captures.

It always prints the exact engine/template selected. For a pinned rerun use, for example:

    bash scripts/bootstrap-sikarugir-wrapper.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800-pinned.app" \
      --engine WS12WineSikarugir11.0_1 \
      --template Template-1.0.21

Those example versions are the current upstream entries as of 2026-10-03; they are examples, **not** an Anno-specific recommendation. A future clean reproduction should pin whatever combination is actually proven to work.

The script refuses to overwrite an existing wrapper. It also uses only portable macOS/Bash 3.2-compatible shell constructs; no GNU `find`/Homebrew coreutils are assumed.

### GUI alternative

Use either:

- Porting Kit's custom-port flow backed by Sikarugir; or
- Sikarugir Creator directly.

Keep this wrapper dedicated to Anno experiments. Do not reuse a wrapper containing unrelated games.

Suggested name:

    ~/Applications/Sikarugir/Anno1800.app

At this point, before installing a launcher:

    bash scripts/capture-baseline.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800.app" \
      --label pre-launcher

If Porting Kit chooses a different path, pass that actual `.app` path.

## 3. Select D3DMetal

In the GUI, select D3DMetal and avoid simultaneously enabling an alternate D3D10/D3D11 renderer. The repository script disables DXMT/DXVK when those keys exist, but deliberately leaves the template's D9VK/CNC_DDRAW defaults unchanged until an observed launcher/game symptom justifies changing older-API paths.

Or, for a Sikarugir wrapper with the standard plist layout:

    bash scripts/enable-d3dmetal.sh "$HOME/Applications/Sikarugir/Anno1800.app"

The script creates a timestamped `Info.plist` backup before modifying renderer keys.

Then capture:

    bash scripts/capture-baseline.sh \
      --wrapper "$HOME/Applications/Sikarugir/Anno1800.app" \
      --label d3dmetal-base

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

For the first renderer test, use D3DMetal. Try Anno's DX12 mode first because that is the most direct fit for D3DMetal, but keep DX11 as an explicit second experiment if DX12 fails or exhibits defects.

Capture immediately after the first main-menu success and after the first stable gameplay session.

## 7. What not to do yet

Do not:

- build Wine from source;
- import CrossOver bottles;
- install random winetricks verbs;
- copy registry files from someone else's prefix;
- add multiple graphics translation layers;
- apply game-specific Wine patches without a demonstrated failure they address.

If Step A works, the next task is clean reproduction, not deeper reverse engineering.

If Step A fails, preserve the failing capture and exact symptom. That becomes the starting evidence for a narrow comparison.
