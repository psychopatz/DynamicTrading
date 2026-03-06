# Quick Reference: Using the Modular System

## File Locations

```
Scripts/
├── ItemID_Verify.py                          ← Run this (main entry point)
│
└── ItemGenerator/src/
    ├── verify/                               ← Verification modules
    │   ├── helpers.py
    │   ├── vanilla_loader.py
    │   ├── mod_loader.py
    │   ├── tag_validator.py
    │   ├── item_analyzer.py
    │   ├── confidence.py                     ← Confidence scoring (NEW)
    │   ├── reporters.py
    │   └── README.md                         ← Full documentation
    │
    └── pricing/                              ← Pricing modules
        ├── config.json                       ← Configuration (EDIT THIS)
        ├── calculator.py
        ├── stock_manager.py
        └── README.md                         ← Full documentation
```

---

## Common Commands

### Generate Confidence Report

```bash
cd ~/Zomboid/Workshop/DynamicTrading/Scripts
python ItemID_Verify.py --confidence --threshold 0.65
```

**Output:** `Output/confidence.txt`
- Shows items scoring below 0.65 confidence
- Lists why they're suspicious
- Suggests fixes

### Get Tag Information

```bash
python ItemID_Verify.py --getTags Food
python ItemID_Verify.py --getTags all
```

### Generate Standard Verification Reports

```bash
python ItemID_Verify.py --output ./Output
```

**Generates:**
- `Output/VanillaOnly/` - Items not in mod
- `Output/AlreadyHas/` - Items already registered
- `Output/Invalid/` - Bad mod references
- `Output/Duplicates/` - Duplicate registrations

### Run with Chunk Output

```bash
python ItemID_Verify.py --chunk 50 --status VanillaOnly
```

Outputs 50 items in Lua format for review.

---

## Modifying Configuration

### Edit Pricing Config

File: `ItemGenerator/src/pricing/config.json`

**Change weapon prices:**
```json
"rarity_multipliers": {
  "Legendary": 6.0   ← Increase from 4.0
}
```

**Change category prices:**
```json
"category_multipliers": {
  "Weapon": 3.0      ← Increase from 2.5
}
```

**Save and reload** - no code compilation needed!

### Adjust Confidence Threshold

To catch more items:
```python
# In Items D_Verify.py, modify:
parser.add_argument("--threshold", type=float, default=0.60)
                                                       # Change from 0.65 to 0.60
```

Or from command line:
```bash
python ItemID_Verify.py --confidence --threshold 0.50
```

---

## Python Usage Examples

### Import Individual Modules

```python
from Scripts.ItemGenerator.Utils.verify import (
    get_vanilla_data,
    calculate_worth,
    score_item_confidence
)

# Load items
items, fluids = get_vanilla_data("/path/to/vanilla")

# Analyze single item
props = items['Katana']['props']
worth = calculate_worth('Katana', props, 'Weapon', 'Blade')

# Check confidence
score = score_item_confidence(
    'Katana', 
    props, 
    'Weapon',
    ['Weapon.Melee.Blade', 'Rarity.Rare']
)
print(f"Score: {score['overall_score']}")
```

### Load Pricing Config

```python
from Scripts.ItemGenerator.Utils.pricing import (
    load_pricing_config,
    PriceCalculator
)

config = load_pricing_config()
calc = PriceCalculator(config)

price = calc.calculate(
    base_worth=20.0,
    item_data={
        'category': 'Weapon',
        'rarity': 'Rare',
        'weight': 2.5
    }
)
print(f"Price: ${price}")
```

### Find Problem Items

```python
from Scripts.ItemGenerator.Utils.verify import (
    find_below_threshold,
    generate_confidence_report,
    write_confidence_report
)

# Find low-scoring items
below_threshold = find_below_threshold(
    items_data,
    threshold=0.65
)

# Generate report
report = generate_confidence_report(below_threshold)

# Write to file
write_confidence_report("./output", report)
```

---

## Output Interpretation

### confidence.txt Format

```
⚠ 42 ITEMS BELOW CONFIDENCE THRESHOLD
═══════════════════════════════════════════════════════════════

[ItemID]
  Overall Score: 0.52 (Threshold: 0.65)            ← Main indicator
  Confidence Level: LOW                             ← Text label
  Category: Food
  Tags: Food.General, Rarity.Common

  Score Breakdown:
    category_confidence      ██░░░░░░░░░░░░░░░░░░ 0.4  ← Component scores
    tag_confidence           ████░░░░░░░░░░░░░░░░ 0.5
    property_coverage        ████████░░░░░░░░░░░░ 0.6
    clarity_score            ███████░░░░░░░░░░░░░░ 0.5

  Recommendations:                                 ← How to fix
    - Review category detection - unclear item type
    - Assign more specific tags to clarify purpose
```

### Interpreting Scores

| Component | What It Measures | Target |
|-----------|---|---|
| category_confidence | How certain we are about item type | 0.7+ |
| tag_confidence | How specific the tags are | 0.7+ |
| property_coverage | How many properties are defined | 0.5+ |
| clarity_score | How clear the item ID and purpose are | 0.5+ |

**Rule of Thumb:**
- If all components ≥ 0.6 → Item is probably fine
- If any component < 0.4 → Item needs review
- If multiple < 0.5 → Item needs significant work

---

## Troubleshooting

### "ImportError: No module named 'Utils.verify'"

**Solution:** Make sure you're running from `Scripts/` directory:
```bash
cd ~/Zomboid/Workshop/DynamicTrading/Scripts
python ItemID_Verify.py
```

### Confidence scores too low/high?

**Solution:** Adjust thresholds in `confidence.py`:
```python
# Line in ConfidenceScorer.__init__
self.config = {
    'default_threshold': 0.65  ← Change this value
}
```

### Want different pricing?

**Solution:** Edit `src/pricing/config.json` directly - no code changes needed!

### Want more verbose output?

**Solution:** Add to ItemID_Verify.py:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

---

## Performance Tips

### Processing Speed

| Task | Duration |
|------|----------|
| Load 3000 items | ~1-2s |
| Calculate worth (all) | ~1s |
| Score confidence (all) | ~2-3s |
| Generate reports | ~0.5s |

### For Large Datasets

Use chunking:
```bash
python ItemID_Verify.py --chunk 100 --status VanillaOnly
```

Process in smaller batches rather than all at once.

---

## Integration Checklist

- [ ] Review `Output/confidence.txt` for problem items
- [ ] Fix low-confidence items (see recommendations)
- [ ] Validate pricing ranges with `PriceCalculator`
- [ ] Adjust `config.json` multipliers as needed
- [ ] Test with `--getTags Food` to verify tags
- [ ] Generate final reports for reference

---

## Documentation Links

- **Full Verify Module Docs:** `ItemGenerator/src/verify/README.md`
- **Full Pricing Docs:** `ItemGenerator/src/pricing/README.md`
- **System Architecture:** `ItemGenerator/SYSTEM_SUMMARY.md` (this file)

---

## Key Concepts

### Property-Agnostic
The system doesn't rely on vanilla discovery - it analyzes **any** item's properties to score and price it.

### Modular
Each component (verify, price, stock) is independent and can be used separately.

### Configurable
Most behavior can be changed via `config.json` without touching code.

### Scalable  
Processes 3000+ items in ~5-7 seconds with room to optimize further.

---

## Getting Help

1. **Check README files** in `verify/` and `pricing/` directories
2. **Review confidence report** for specific problem items
3. **Examine config.json** for pricing questions
4. **Look at test output** to debug issues
