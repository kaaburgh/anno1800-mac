# Experiment protocol

The purpose of this protocol is to keep Wine/macOS debugging from turning into a pile of unrepeatable GUI state.

## Naming

Use short labels that describe state, not conclusions:

- `pre-launcher`
- `d3dmetal-base`
- `ubisoft-login`
- `anno-installed`
- `main-menu-dx12`
- `gameplay-dx12-30m`
- `main-menu-dx11`
- `failure-black-window`

`scripts/capture-baseline.sh` adds a UTC timestamp.

## One-variable rule

Between two captures, prefer changing one of:

- Wine engine;
- renderer;
- DX11 vs DX12;
- launcher route;
- wrapper plist setting;
- one registry change;
- one DLL override.

If several changes are unavoidable, state them in `--note`.

## What capture-baseline records

By default:

- macOS / kernel / architecture / model / memory;
- Homebrew and wrapper-tool versions where discoverable;
- Sikarugir wrapper engine identity;
- selected renderer-related plist keys;
- canonical Sikarugir prefix (`Contents/SharedSupport/prefix`) existence and registry hashes;
- common Steam / Ubisoft / Anno executable locations;
- relevant running process names;
- hashes of small configuration files.

It intentionally does **not** copy:

- launcher logs;
- registry contents;
- browser profiles;
- Ubisoft/Steam credentials;
- game files;
- complete process command lines.

These omissions are deliberate because launchers can place authentication material in logs or command-line arguments.

## Notes

Use the note field for the outcome you personally observed:

    bash scripts/capture-baseline.sh \
      --wrapper "/path/to/Anno1800.app" \
      --label main-menu-dx12 \
      --note "Main menu renders; mouse works; no audio tested yet."

Do not encode interpretation as if it were measured fact. "D3DMetal broken" is a poor note; "black window after splash; process remains alive for 5 min" is useful.

## Comparing captures

    python3 scripts/compare-captures.py artifacts/<A> artifacts/<B>

The comparator shows unified diffs for matching text snapshots and reports files present on only one side.

The most useful comparisons are adjacent states or a failing free stack against a known-good reference on the same machine.

## Clean reproduction

Once gameplay appears stable, create a fresh wrapper and reproduce without copying the old prefix.

Only after that should the project claim A4.
