from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Paths:
    root: Path
    mod_common: Path
    output_root: Path
    output_web: Path
    output_data: Path


@dataclass(frozen=True)
class BuildConfig:
    seed: int = 1337
    stock_mult: float = 1.0
    rarity_bonus: float = 0.0
    buy_mult: float = 1.0
    sell_mult: float = 0.5
    event_frequency_days: int = 5
    event_chance_percent: int = 50
    max_flash_events: int = 3
    flash_duration_days: int = 3


def default_paths(project_root: Path) -> Paths:
    mod_common = project_root / "Contents/mods/DynamicTradingCommon/42.13/media/lua/shared/DT/Common"
    output_root = project_root / "Scripts/SimulateGame/Output"
    output_web = output_root / "web"
    output_data = output_web / "assets/data"
    return Paths(
        root=project_root,
        mod_common=mod_common,
        output_root=output_root,
        output_web=output_web,
        output_data=output_data,
    )
