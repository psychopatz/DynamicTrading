#!/usr/bin/env python3
import argparse
import sys
import os

MODS_PATH = "/home/psychopatz/Zomboid/Workshop/DynamicTrading/Contents/mods"

MOD_INFO = {
    "Common": {
        "id": "DynamicTradingCommon",
        "path": os.path.join(MODS_PATH, "DynamicTradingCommon"),
        "role": "Core infrastructure, shared assets, item registers, and common Lua logic.",
        "notes": "Required by both V1 and V2."
    },
    "V1": {
        "id": "DynamicTrading",
        "path": os.path.join(MODS_PATH, "DynamicTradingV1"),
        "role": "Legacy Radio-only economy system (Market fluctuations, Merchant archetypes).",
        "notes": "Incompatible with V2. Uses Radio interface."
    },
    "V2": {
        "id": "DynamicTradingV2",
        "path": os.path.join(MODS_PATH, "DynamicTradingV2"),
        "role": "Alpha NPC/Faction overhaul (Physical NPCs, Faction bases, 3D world interactions).",
        "notes": "Incompatible with V1. Modern overhaul."
    }
}

def print_summary():
    print("# Dynamic Trading Project Summary")
    print("This project is a modular trading system for Project Zomboid B42.")
    print(f"It consists of three main components located in: {MODS_PATH}\n")
    for key, info in MOD_INFO.items():
        print(f"- {key} ({info['id']}): {info['role']}")

def print_paths():
    print("# Mod Paths")
    for key, info in MOD_INFO.items():
        print(f"{key}_PATH=\"{info['path']}\"")
        print(f"{key}_ID=\"{info['id']}\"")

def print_details():
    print("# In-Depth Mod Details")
    for key, info in MOD_INFO.items():
        print(f"## {key} [{info['id']}]")
        print(f"- **Path:** {info['path']}")
        print(f"- **Role:** {info['role']}")
        print(f"- **Notes:** {info['notes']}")
        print("-" * 20)

def main():
    parser = argparse.ArgumentParser(description="Dynamic Trading Mod Architecture Helper")
    parser.add_argument("--summary", action="store_true", help="Print project summary")
    parser.add_argument("--paths", action="store_true", help="Print mod paths")
    parser.add_argument("--details", action="store_true", help="Print in-depth mod details")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    if args.summary:
        print_summary()
    if args.paths:
        print_paths()
    if args.details:
        print_details()

if __name__ == "__main__":
    main()
