#!/usr/bin/env python3
"""
Scans icons/ directories and builds icons/index.json —
a lookup table mapping service names to icon file paths.
Run after download_icons.sh or whenever icons change.
"""
import json
import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
ICONS_ROOT = REPO_ROOT / "icons"
OUTPUT = ICONS_ROOT / "index.json"

# Normalise a filename into searchable keywords
def keywords(name: str) -> list[str]:
    name = re.sub(r"\.(svg|png)$", "", name, flags=re.IGNORECASE)
    name = re.sub(r"[-_]", " ", name).lower()
    return [w for w in name.split() if len(w) > 1]

index: dict[str, dict] = {}

for provider_dir in sorted(ICONS_ROOT.iterdir()):
    if not provider_dir.is_dir():
        continue
    provider = provider_dir.name
    for icon_file in sorted(provider_dir.glob("*.svg")):
        rel_path = str(icon_file.relative_to(REPO_ROOT))
        kws = keywords(icon_file.name)
        entry_key = f"{provider}/{icon_file.stem}".lower()
        index[entry_key] = {
            "path": rel_path,
            "provider": provider,
            "keywords": kws,
        }

with open(OUTPUT, "w") as f:
    json.dump(index, f, indent=2, sort_keys=True)

print(f"Icon index built: {len(index)} entries → {OUTPUT}")
