import os
import argparse
import shutil
from Utils.config import VANILLA_DIR, MOD_ITEMS_DIR, OUTPUT_DIR
from Utils.parser import get_vanilla_data, get_mod_data
from Utils.reporter import write_mod_duplicates, write_hierarchical_files

def main():
    parser = argparse.ArgumentParser(description="Process Vanilla PZ Items/Fluids vs Mod Registries (Modular)")
    parser.add_argument("--vanilla", default=VANILLA_DIR, help="Path to vanilla scripts")
    parser.add_argument("--mod", default=MOD_ITEMS_DIR, help="Path to mod item Lua files")
    parser.add_argument("--output", default=OUTPUT_DIR, help="Path for output")
    parser.add_argument("--simple", action="store_true", help="Split output into smaller AI-friendly files")
    parser.add_argument("--limit", type=int, default=50, help="Items per file in simple mode")
    args = parser.parse_args()

    # Clean output directory
    if os.path.exists(args.output):
        shutil.rmtree(args.output)
    os.makedirs(args.output, exist_ok=True)

    # 1. Load Data
    v_items, v_fluids = get_vanilla_data(args.vanilla)
    m_data, m_dupes = get_mod_data(args.mod)
    v_combined = {**v_items, **v_fluids}
    
    # 2. Compare
    vanilla_only = sorted(list(set(v_combined.keys()) - set(m_data.keys())))
    already_has = sorted(list(set(v_combined.keys()) & set(m_data.keys())))
    mod_invalid = sorted(list(set(m_data.keys()) - set(v_combined.keys())))
    
    # 3. Write Reports
    write_hierarchical_files(args.output, "VanillaOnly", vanilla_only, v_combined, m_data, simple=args.simple, items_per_file=args.limit)
    write_hierarchical_files(args.output, "AlreadyHas", already_has, v_combined, m_data, simple=args.simple, items_per_file=args.limit)
    write_hierarchical_files(args.output, "Invalid", mod_invalid, v_combined, m_data, simple=args.simple, items_per_file=args.limit)
    write_mod_duplicates(args.output, m_dupes)
    
    # 4. Summary Output
    print("\n" + "="*20)
    print("   PROCESS SUMMARY")
    print("="*20)
    print(f"Total Vanilla Assets:   {len(v_combined)}")
    print(f"Total Mod Registered:   {len(m_data)}")
    print(f"Missing (Vanilla Only): {len(vanilla_only)}")
    print(f"Correctly Registered:   {len(already_has)}")
    print(f"Invalid Mod IDs:        {len(mod_invalid)}")
    print(f"Mod Duplicates:         {len(m_dupes)}")
    print("="*20)
    print(f"Reports available in: {args.output}")

if __name__ == "__main__":
    main()
