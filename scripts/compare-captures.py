#!/usr/bin/env python3
import argparse
import difflib
from pathlib import Path

DEFAULT_FILES = ("host.txt", "wrapper.txt", "processes.txt", "hashes.txt")


def read_lines(path: Path):
    return path.read_text(errors="replace").splitlines(keepends=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare two anno1800-mac baseline captures")
    parser.add_argument("left", type=Path)
    parser.add_argument("right", type=Path)
    parser.add_argument(
        "--file",
        action="append",
        dest="files",
        help="Compare only this relative file; may be repeated",
    )
    args = parser.parse_args()

    if not args.left.is_dir() or not args.right.is_dir():
        parser.error("both arguments must be capture directories")

    files = tuple(args.files) if args.files else DEFAULT_FILES
    for rel in files:
        left = args.left / rel
        right = args.right / rel

        if not left.exists() and not right.exists():
            continue

        print(f"\n===== {rel} =====")
        if not left.exists():
            print(f"only on right: {right}")
            continue
        if not right.exists():
            print(f"only on left: {left}")
            continue

        a = read_lines(left)
        b = read_lines(right)
        if a == b:
            print("identical")
            continue

        diff = difflib.unified_diff(
            a,
            b,
            fromfile=str(left),
            tofile=str(right),
        )
        print("".join(diff), end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
