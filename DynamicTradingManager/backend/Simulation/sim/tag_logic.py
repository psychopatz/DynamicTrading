from __future__ import annotations

from typing import Iterable, Sequence


def matches_all_tags(item_tags: Sequence[str], required_tags: Sequence[str]) -> bool:
    if not required_tags:
        return False
    for req in required_tags:
        matched = False
        for item_tag in item_tags:
            if item_tag == req or item_tag.startswith(req + "."):
                matched = True
                break
        if not matched:
            return False
    return True


def has_forbidden_tag(item_tags: Sequence[str], forbidden_tags: Iterable[str]) -> bool:
    for forbid in forbidden_tags:
        for tag in item_tags:
            if tag == forbid or tag.startswith(forbid + "."):
                return True
    return False


def tag_price_mult(item_tags: Sequence[str], tag_price_map: dict[str, float]) -> float:
    max_mult = 1.0
    for tag in item_tags:
        mult = tag_price_map.get(tag)
        if mult is not None and mult > max_mult:
            max_mult = mult
    return max_mult


def find_first_want_bonus(item_tags: Sequence[str], wants: dict[str, float]) -> float:
    for item_tag in item_tags:
        for want_tag, bonus in wants.items():
            if item_tag == want_tag or item_tag.startswith(want_tag + "."):
                return float(bonus)
    return 1.0
