from __future__ import annotations

import shutil
from pathlib import Path


def copy_tree(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.mkdir(parents=True, exist_ok=True)

    for path in src.rglob("*"):
        rel = path.relative_to(src)
        out_path = dst / rel
        if path.is_dir():
            out_path.mkdir(parents=True, exist_ok=True)
        else:
            out_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, out_path)


def generate_web_site(source_web_root: Path, output_web_root: Path) -> None:
    templates = source_web_root / "templates"
    assets = source_web_root / "assets"

    output_web_root.mkdir(parents=True, exist_ok=True)

    # Pages
    for page in templates.glob("*.html"):
        shutil.copy2(page, output_web_root / page.name)

    # Static assets
    copy_tree(assets, output_web_root / "assets")
