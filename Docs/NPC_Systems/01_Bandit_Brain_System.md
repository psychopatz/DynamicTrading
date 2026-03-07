# Bandit Brain System - NPC Data Architecture

**Module:** `BanditBrain.lua`  
**Purpose:** Centralized NPC state and personality management

---

## Brain Overview

The "brain" is the data structure that holds all state for an individual NPC. It persists across updates via ModData and contains personality, capabilities, health, tasks, and behavior state.

### Brain Storage

Brains are stored in zombie ModData:

```lua
function BanditBrain.Get(zombie)
    local modData = zombie:getModData()
    return modData.brain
end

function BanditBrain.Update(zombie, brain)
    local modData = zombie:getModData()
    modData.brain = brain
end

function BanditBrain.Remove(zombie)
    local modData = zombie:getModData()
    modData.brain = nil
end
```

**Key Point:** Brain persists through save/load via ModData - survives game restarts

---

## Brain Initialization Structure

When an NPC is spawned, a new brain table is created with the following sections:

### 1. Identity & Metadata

```lua
brain.id = id                              -- Persistent outfit ID (unique per NPC)
brain.fullname = BanditNames.GenerateName(female)  -- Generated name
brain.female = general.female or false     -- Gender
brain.skin = general.skin or 1             -- Appearance
brain.hairType = general.hairType or 1
brain.hairColor = general.hairColor or 1
brain.beardType = general.beardType or 1

-- Birth/spawn information
brain.born = getGameTime():getWorldAgeHours()
brain.bornCoords = {x, y, z}               -- Starting position
```

### 2. Clan & Faction

```lua
brain.clan = general.cid                   -- Clan ID
brain.cid = general.cid                    -- Clan ID (duplicate for versatility)
brain.bid = general.bid                    -- Bandit ID within clan
```

**Purpose:** Enables squad coordination and faction-based interactions

### 3. Physical Attributes (Stats)

```lua
-- Direct stats (1-9 scale, then mapped to game multipliers)
brain.health = BanditUtils.Lerp(health, 1, 9, 1, 2.6)
    -- Mapped: 1→1.0x health, 5→1.8x, 9→2.6x

brain.accuracyBoost = BanditUtils.Lerp(sight, 1, 9, -8, 8)
    -- Mapping: 1→-8 (poor aim), 5→0 (normal), 9→+8 (sniper)

brain.enduranceBoost = BanditUtils.Lerp(endurance, 1, 9, 0.25, 1.75)
    -- Stamina multiplier: 1→0.25x stamina, 9→1.75x

brain.strengthBoost = BanditUtils.Lerp(strength, 1, 9, 0.25, 1.75)
    -- Damage/carrying capacity: weak to strong

-- Experience tracking (3 categories)
brain.exp = {exp1, exp2, exp3}             -- Skill progression
```

### 4. Weapon System

```lua
brain.weapons = {
    melee = "Base.BareHands",              -- Default melee weapon
    primary = {
        name = "weapon_id",
        bulletsLeft = 0,
        type = "mag" or "nomag",           -- Magazine-fed or not
        magCount = 5,
        ammoCount = 45
    },
    secondary = {                          -- Secondary weapon (knife, etc.)
        name = "weapon_id",
        bulletsLeft = 0,
        type = "mag" or "nomag",
        magCount = 0,
        ammoCount = 0
    }
}
```

**Weapon Types:**
- `"mag"` - Magazine-fed weapons (pistols, rifles)
- `"nomag"` - Direct ammo count (shotguns)
- Created via `BanditWeapons.Make(weaponConfig, ammoConfig)`

### 5. Appearance & Customization

```lua
brain.clothing = bandit.clothing or {}     -- Worn items
brain.tint = bandit.tint or {}            -- Color/visual tints
brain.bag = bandit.bag                    -- Backpack/outfit
```

### 6. Inventory & Loot

```lua
brain.loot = {}                           -- Dropped/stored items
brain.inventory = {}                      -- Carried items
```

### 7. Task Queue

```lua
brain.tasks = {}                          -- Array of action tasks
-- Tasks are added in order and processed sequentially
```

See: `Pathing System Architecture` for task structure

### 8. State Variables

```lua
brain.stationary = false                  -- Is staying put
brain.sleeping = false                    -- Resting/sleeping
brain.aiming = false                      -- Weapon aiming
brain.moving = false                      -- Currently moving
brain.inVehicle = false                   -- In a vehicle

-- Cooldowns/timers
brain.endurance = 1.00                    -- Stamina (0-1)
brain.speech = 0.00                       -- Speech cooldown (frames)
brain.sound = 0.00                        -- Sound cooldown (frames)
brain.infection = 0                       -- Zombie infection level
```

### 9. Health Status

```lua
brain.health = STAT_VALUE                 -- Current health multiplier
brain.lastHealth = CURRENT_HEALTH          -- Track damage detection
-- Differentiate between pushes and actual damage via health delta
```

### 10. Personality & Traits

```lua
-- Random differentiators
brain.rnd = {ZombRand(2), ZombRand(10), ZombRand(100), ZombRand(1000), ZombRand(10000)}

-- Personality traits (randomized on spawn)
brain.personality = {
    alcoholic = (ZombRand(50) == 0),       -- 1 in 50 chance
    smoker = (ZombRand(4) == 0),           -- 1 in 4 chance
    compulsiveCleaner = (ZombRand(90) == 0),
    
    -- Collectors
    comicsCollector = (ZombRand(80) == 0),
    gameCollector = (ZombRand(220) == 0),
    hottieCollector = (ZombRand(100) == 0),
    toyCollector = (ZombRand(220) == 0),
    videoCollector = (ZombRand(220) == 0),
    underwearCollector = (ZombRand(150) == 0),
    
    -- Heritage (Easter eggs)
    fromPoland = (ZombRand(120) == 0)      -- "ku chwale ojczyzny!"
}
```

**Purpose:** These affect NPC behavior and item preferences - creates uniqueness

### 11. Behavioral Configuration

```lua
-- Hostile/Friendly state
brain.hostile = not spawn.friendly         -- Toward NPCs/zombies
brain.hostileP = brain.hostile             -- Toward players (can differ)

-- Program/occupation
brain.program = {
    name = "Patrol" or "Guard" or "Trade", -- Current task
    stage = "Prepare" or "Execute"         -- Program phase
}
brain.programFallback = args.program       -- Fallback if primary fails

brain.occupation = args.occupation         -- Role assignment
brain.loyal = false                        -- Loyalty to master
brain.master = args.pid                    -- Master player ID
```

### 12. Persistence

```lua
brain.permanent = false                    -- Survives world reset
brain.key = "custom_key"                   -- Unique identifier
brain.voice = "1" or "2" ...               -- Voice selection (Male/Female options)
```

---

## Brain Query Helpers

BanditBrain provides utility functions to check state:

```lua
-- Weapon status
BanditBrain.IsOutOfAmmo(brain)             -- Both weapons empty?
BanditBrain.NeedResupplySlot(brain, slot)  -- Specific weapon needs ammo
BanditBrain.IsBareHands(brain)             -- Only has fists?

-- Task queries
BanditBrain.HasTask(brain)                 -- Any tasks queued?
BanditBrain.HasActionTask(brain)           -- Non-movement tasks?
BanditBrain.HasMoveTask(brain)             -- Movement tasks?
BanditBrain.HasTaskType(brain, "Shoot")    -- Specific action type?
BanditBrain.HasTaskTypes(brain, {"Hit", "Shoot"})  -- Multiple types
```

---

## Brain Lifecycle

1. **Creation** - Brain table initialized in `banditize()` (server-side)
2. **Transfer** - Brain synced to client via network commands
3. **Updates** - Brain modified during OnZombieUpdate ticks
4. **Persistence** - Brain saved in ModData with zombie
5. **Removal** - Brain deleted when zombie dies or Zombify'd

---

## Key Design Patterns

### 1. Stat Mapping with Lerp

Raw 1-9 values mapped to gameplay multipliers:

```lua
BanditUtils.Lerp(inputValue, 1, 9, minOutput, maxOutput)
```

**Example:** Health stat of 7 maps to ~2.2x multiplier

### 2. Randomized Traits

Using `ZombRand()` enables unique NPCs from same spawn data

### 3. Separation of Concerns

- **Identity:** Who is this NPC?
- **Stats:** What are they capable of?
- **State:** What are they doing right now?
- **Persistence:** What survives restarts?

### 4. Dual Hostility

`brain.hostile` and `brain.hostileP` allow NPCs to be:
- Hostile to zombies but friendly to players
- Friendly to NPCs but hostile to specific player
- Globally configured but individually overridable

---

## Comparison with DynamicTrading

DynamicTrading's `DTNPC` brain structure should consider:
- ✓ Persistent ID (UUID or outfit ID)
- ✓ Stat-based capabilities (health, speed, etc.)
- ✓ Task queue for coordinated actions
- ✓ State tracking (moving, idle, combat, etc.)
- ✓ Personality/uniqueness factors
- ✓ Relationship tracking (hostile/friendly)
- ? Weapon proficiency
- ? Faction/team affiliation
- ? Voice/dialogue personality

---

## File Location

- **Definition:** `/mods/Bandits/42.13/media/lua/shared/BanditBrain.lua` (interface only)
- **Initialization:** `/mods/Bandits/42.13/media/lua/server/BanditServerSpawner.lua` (line 290+)
- **Usage:** Throughout client update loop and server logic
