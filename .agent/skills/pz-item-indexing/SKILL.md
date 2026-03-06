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

## 2. Advanced Economic Analysis & Balancing

### Potential Worth Calculation

The `ItemID_Verify.py` script extracts deep mechanical stats to provide a robust "Potential Worth" anchor for any item. This is the foundation for intelligent pricing.

#### Mechanical Factors

**1. Drainable Logic (Uses)**
Items consumed over multiple uses (Thread, Duct Tape, Meds) calculate usage density:
- **Formula**: `Total Uses = 1 / UseDelta`
- **Impact**: Thread (20 uses) valued 16× higher than single-use items of same weight

**2. Literature & Knowledge**
Books/magazines teaching recipes valued by `LearnedRecipes` count:
- **Impact**: CookingMag1 (1 recipe) = baseline, complex manuals scale higher

**3. Fuel Efficiency**
Items with `FireFuelRatio` recognized as fuel sources:
- **Impact**: Efficiency directly factored into Potential Worth

**4. Psychological Impact**
Negative `UnhappyChange` factored as price penalties:
- **Impact**: DogFood (high Unhappiness) = significantly reduced worth

**5. Perishability & Shelf Life (Food)**
Value scales with nutrition AND preservation:
- **Formula**: Shelf life bonus capped to prevent inflation for extremely long-lasting items
- **Result**: Acorn worth ~160 (not ~1000)

**6. Pricing Floor & Rounding**
- **Floor**: Mandatory `basePrice ≥ 1` for all LUA output
- **Rounding**: Improved to ensure items like Pan (Worth 0.74) aren't priced at 0

#### Multi-Stat Display Format
```
[ItemID] | Potential Worth: [Value] | Weight: [W] | Uses: [U] | Recipes: [R] | Fuel: [F] | Unhappy: [H]
```

**Examples:**
- Thread: Potential Worth: 80.0 | Weight: 0.1 | Uses: 20
- DogFoodBag: Potential Worth: 6.45 | Weight: 2.0 | Unhappy: 20.0
- CookingMag1: Potential Worth: 50.0 | Weight: 0.5 | Recipes: 1

---

### Harmonized Pricing and Stock Logic

Use the data-driven Potential Worth + vanilla stats to establish `basePrice` and `stockRange`.

#### 1. Pricing (Base Price)

Sync `basePrice` with the stats, always using **math.floor**:

- **General**: `basePrice = math.floor(PotentialWorth * CategoryMultiplier)`
- **Food**: `basePrice = math.floor(Hunger * 2.5)` (Primary basis, shell life scaled)
- **Opened Items**: Apply a **30% discount** (0.7x multiplier) for items with `Opened = true` or `_Open` suffix
- **Drainables**: Scale by Total Uses (higher uses = higher value)
- **Literature**: Scale by LearnedRecipes count + knowledge premium

#### 2. Stock Range Logic (Min/Max)

Stock levels are primarily driven by **Weight**, then modified by **Category**.

#### Step A: Determine Base Max Stock (BMS)

| Item Weight | Base Max Stock |
| :---------- | :------------- |
| `<= 0.05` | 50             |
| `<= 0.2`  | 25             |
| `<= 0.5`  | 15             |
| `<= 1.5`  | 10             |
| `<= 5.0`  | 5              |
| `> 5.0`   | 2              |

#### Step B: Apply Multipliers

- **Perishable / Fresh Food**: `0.5x`
- **Staples (Ammo, Material, Currency)**: `2.0x`
- **Rare / Luxury**: `0.4x` (Min 1)
- **Quest Items**: `1` (Manual Override)

#### Step C: Determine Min Stock

- **Default**: `Floor(Max * 0.2)`
- **High Demand (Material, Ammo)**: `Floor(Max * 0.4)`
- **Currency**: `Floor(Max * 0.8)`
- **Rare / Fresh**: `0`
- **Clothing**:
  - Heavy Armor (Bullet > 70): 1000 - 2000
  - Tactical/Riot (Bite/Scratch > 50): 500 - 1000
  - Winter/Hazard (Ins/Wind > 0.5): 250 - 500
  - Specialized Gear: 100 - 300

### Standardized Property Tagging (The "No-Collision" System)

To ensure consistency and prevent confusion between **what an item is** and **what it relates to**, follow the distinct Root vs. Descriptor naming convention.

#### **1. Core Rules**

1. **Format**: `RootCategory.SubCategory.Detail` (e.g., `Food.Meat.Fresh`).
2. **Casing**: Always use `PascalCase`.
3. **Naming**: Use singular nouns (e.g., `Tool`, not `Tools`).
4. **No Collisions**: Never use the same name for a Primary Root and a Secondary Descriptor.

#### **2. Primary Taxonomy Roots (The "Identity")**

*Defines the core nature of the item.*

- `Weapon`, `Tool`, `Medical`, `Food`, `Clothing`, `Container`, `Resource`, `Literature`, `Electronics`, `Appliance`, `Misc`.

#### **3. Global Descriptors (The "Properties")**

*Contextual terms that provide properties or affiliation.*

| Concept               | Descriptor Root | Permitted Values                                                                          |
| :-------------------- | :-------------- | :---------------------------------------------------------------------------------------- |
| **Scarcity**    | `Rarity.*`    | `Common`, `Uncommon`, `Rare`, `Legendary`                                         |
| **Tier/Value**  | `Quality.*`   | `Luxury`, `Sterile`, `Basic`, `Heavy`, `Waste`                                  |
| **Affiliation** | `Origin.*`    | `Corps`, `Police`, `Militia`, `Civ`, `Nomad`                                    |
| **Context**     | `Theme.*`     | `Combat`, `Utility`, `Clinical`, `Digital`, `Survival`, `Camping`, `Winter` |

### **Standardized Execution Guidelines**

1. **Descriptor Inference**:
   - **Infer from Name/Context**: "Canteen" -> `Origin.Militia`, "Propane Tank" -> `Origin.Industrial` (Now sub of Resource.Fuel).
   - **Safe Defaults**: If an item is common gear, use `Theme.Survival`. If it's ordinary waste, use `Rarity.Common` and `Quality.Waste`.
2. **Rarity Flagging**:
   - **Manual Calibration**: Use game knowledge to elevate rare items. (e.g., Caviar or Spices -> `Rarity.Rare`).
3. **Pricing (Weapon & Material)**:
   - Use `Potential Worth` as the base stat for the Category Multiplier.
4. **Scaling Pricing (Medical & Clothing)**:
   - **Logic**: Do not use "fixed" prices for a whole tier. SCALE the item within its assigned range (e.g., 200-500) based on its `Potential Worth` or `Weight`. A heavier or more durable armor piece should be at the top of the range.

### **Archetype Compatibility (Dual-Tagging)**

Use **Dual Tagging** to satisfy both generic and specific trader requirements:

1. **Taxonomy Tag**: `Weapon.Firearm.Rifle` (Generic stock targeting).
2. **Origin/Quality Tag**: `Origin.Mod.Brita` or `Quality.Luxury` (Specific targeting).
3. **Theme Tag**: `Theme.Combat` (For accessories like rifle cases that are technically containers).

```lua
-- Example: Canned Beans Registration
{ item="Base.TinnedBeans", basePrice=10, tags={"Food.Canned.Vegetable", "Rarity.Common"}, stockRange={min=5, max=20} }
```
