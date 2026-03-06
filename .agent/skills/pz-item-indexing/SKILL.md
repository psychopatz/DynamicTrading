# Project Zomboid Item Management & Indexing

This skill provides the definitive, data-driven workflow for implementing and balancing items in Project Zomboid Build 42 (B42). It centralizes pricing formulas, stock-level logic, and "No-Collision" tagging standards.

## 1. Indexing Workflow (The "Turbo" Method)

### A. Extraction

1. **Priority**: Always process `UnsureItems` first to populate tags and refine the registry.
2. **Execution**: Run with `--llm` for ultra-clean stats:

   ```bash
   python3 Scripts/ItemID_Verify.py --chunk 10 --status UnsureItems --category [Optional] --llm
   ```

3. **Lookup**: Use `--getTags [Root|all]` on-demand to check for existing hierarchies.

### B. Implementation (Autonomous AI Role)

1. **Judgment**: Use your own judgment for pricing and tags. The script's `Potential Worth` is a baseline, not a rule.
2. **Ambiguity**: If an item's root is unclear, default to `Misc.[DisplayName]`.
3. **Maintenance**: When creating new subtags, manually update `Docs/Tags_Reference.md` so future indexing can detect them.

---

## 2. Economic Balancing Rules

### A. Pricing (Base Price)

Establish logical value based on utility:

- **Formula**: `basePrice = math.floor(StatValue * Multiplier)`.
- **Food**: `Hunger * 2.5` (Scaling with calories/freshness).
- **Opened Penalty**: Apply a **30% discount** (0.7x) to items with `Opened = true`.
- **Armor/Gear**: Scale based on protection stats (Bite/Scratch/Bullet).

### B. Stock Range (Min/Max)

Driven by **Weight** and **Category**:

| Weight | Base Max (BMS) | Multipliers |
| :--- | :--- | :--- |
| `<= 0.05` | 50 | Staples (Ammo/Material): `2.0x` |
| `<= 0.2` | 25 | Perishable/Fresh: `0.5x` |
| `<= 0.5` | 15 | Rare/Luxury: `0.4x` (Min 1) |
| `<= 1.5` | 10 | Quest Items: `1` |
| `<= 5.0` | 5 | |
| `> 5.0` | 2 | |

**Min Stock**: `Floor(Max * 0.2)` (Default) or `Floor(Max * 0.4)` (High Demand).

---

## 3. Build 42 Implementation Parity

- **ItemType**: Use `ItemType = base:normal` for standard items to prevent NPE crashes.
- **Properties**: Use floating-point numbers for `Weight` (e.g., `1.0`).
- **Registration**:

  ```lua
  { item="Base.X", tags={"Root.Sub", "Rarity.C"}, basePrice=10, stockRange={min=2, max=10} },
  ```

## 4. Tagging Standards (No-Collision)

1. **Format**: `Root.SubCategory.Detail` (e.g., `Food.Meat.Fresh`).
2. **Roots**: `Weapon`, `Tool`, `Medical`, `Food`, `Clothing`, `Container`, `Resource`, `Literature`, `Electronics`, `Appliance`, `Misc`, `Vehicle`.
3. **Descriptors**: `Rarity.*`, `Quality.*`, `Origin.*`, `Theme.*`.
4. **Collision Check**: A name cannot be both a Root and a Descriptor.
