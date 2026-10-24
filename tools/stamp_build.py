#!/usr/bin/env python3
"""Stamp the iOS CFBundleVersion and Android versionCode before export."""

import re
import sys
from pathlib import Path

path = Path(sys.argv[1] if len(sys.argv) > 1 else "3d_game/export_presets.cfg")
build = sys.argv[2] if len(sys.argv) > 2 else "1"
if not re.fullmatch(r"\d+", build):
    raise SystemExit(f"build number must be numeric, got {build!r}")
text = path.read_text()
text = re.sub(r'(?m)^application/version="[^"]*"', f'application/version="{build}"', text)
text = re.sub(r"(?m)^version/code=\d+", f"version/code={build}", text)
path.write_text(text)
print(f"stamped build {build} in {path}")
