#!/usr/bin/env python3
"""Check relative markdown links in core docs (no network).

Usage:
  python3 scripts/check_md_links.py [repo_root]
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Reuse policy helper
sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_config_policy import check_md_links, repo_root_from  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("repo_root", nargs="?", default=None)
    args = p.parse_args(argv)
    repo = repo_root_from(Path(args.repo_root) if args.repo_root else None)
    roots = [
        repo / "README.md",
        repo / "CHANGELOG.md",
        repo / "CONTRIBUTING.md",
        repo / "AGENTS.md",
        repo / "docs" / "FAQ.md",
        repo / "docs" / "STATUS.md",
        repo / "docs" / "MIGRATION.md",
        repo / "docs" / "SECURITY.md",
        repo / "docs" / "TRACKS.md",
        repo / "config" / "README.md",
        repo / "slicer" / "README.md",
        repo / "slicer" / "orca" / "README.md",
    ]
    errs = check_md_links(repo, roots)
    if errs:
        print("FAILURES:")
        for e in errs:
            print(f"  FAIL  {e}")
        return 1
    print(f"OK: relative markdown links ({len(roots)} roots)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
