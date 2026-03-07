# Base & Barricading Management - NPC Territories

**Location:** `/mods/Bandits/42.13/media/lua/shared/BanditBases/`  
**Purpose:** Manage NPC territories, barricading strategies, and base defense

---

## Base System Overview

Bandits implements a sophisticated base/territory system allowing NPCs to:
- Claim and defend specific buildings/areas
- Barricade doors and windows strategically
- Manage base resources (food, supplies, ammo)
- Conduct base-related tasks in specific locations
- Set up patrol routes and defensive positions

---

## Base Architecture

### Base Definitions

Each base is defined in a **procedure file**:

```
/BanditBases/Procedures/
├─ ProcHouseSmall.lua       (2-3 room dwellings)
├─ ProcHouseMedium.lua      (4-6 room houses)
├─ ProcHouseBigLuxury.lua   (Large mansions)
├─ ProcMilitaryField.lua    (Tactical bases)
├─ ProcCabin.lua            (Isolated shelters)
├─ ProcCementary.lua        (Tombs)
├─ ProcDungeon.lua          (Underground)
└─ ProcMilitaryTent.lua     (Mobile camps)
```

### Base Structure Components

Each base typically contains:

```lua
local baseProcedure = {
    name = "Small House",
    type = "house",
    
    -- Territory definition
    bounds = {
        x1 = 1000, y1 = 2000,
        x2 = 1020, y2 = 2020
    },
    
    -- Rooms/zones
    rooms = {
        {name="Kitchen", entrances={...}},
        {name="Bedroom", entrances={...}},
        {name="Living Room", entrances={...}}
    },
    
    -- Barricading targets
    doors = {
        {x=1005, y=2005, primary=true},
        {x=1010, y=2010, primary=false}
    },
    
    windows = {
        {x=1002, y=2008, priority="high"},
        {x=1015, y=2012, priority="low"}
    },
    
    -- Defensive positions
    posts = {
        {x=1008, y=2018, direction=45},   -- Guard post angle
        {x=1012, y=2005, direction=270}
    },
    
    -- Resource locations
    storage = {
        food = {x=1005, y=2005},
        ammo = {x=1008, y=2008},
        supplies = {x=1010, y=2010}
    }
}
```

---

## Barricading System

### Barricade Priorities

```lua
-- Primary entrances (always barricade if hostile)
primary_doors = true

-- Secondary entrances (barricade if resources allow)
secondary_doors = false

-- Windows (variable priority)
window_priority = "high" | "medium" | "low" | "never"
```

### Barricading Decision Tree

```
Is NPC Hostile?
├─ YES: Barricade primary entrances
│   └─ Resources sufficient?
│       ├─ YES: Barricade secondary
│       └─ NO: Prioritize most-used entrances
└─ NO: Don't barricade
    (Barricading friendly = suspicious/defensive)
```

### Barricade Types

Bandits supports multiple barricade methods:

```lua
function ShouldBarricade(brain, door)
    if brain.hostile or brain.program.name == "Civilian" then
        -- Check door properties
        
        if not door.canBarricade then
            return false
        end
        
        if door.isFortified then
            return false  -- Already fortified
        end
        
        if door.isWindowLocked then
            return false  -- Can't barricade locked windows
        end
        
        -- Resource check
        if GetBarricadeMaterials() < MINIMUM_BOARDS then
            return false
        end
        
        return true
    end
    
    return false
end
```

### Barricade Execution

Queued as tasks in NPC's task queue:

```lua
local task = {
    action = "Barricade",
    target = door,
    time = 10,              -- Estimated task duration
    endurance = 0.3,        -- Stamina cost
    materials = "wooden_boards"
}

table.insert(brain.tasks, task)
```

---

## Territory Management

### Base Claims

```lua
brain.baseClaim = {
    baseId = "house_1234",
    clanId = "clan_bandits",
    claimType = "primary_base" | "outpost" | "temporary",
    ownership = "full" | "contested" | "shared"
}
```

### Multi-Clan Territories

```lua
-- Can track who owns what
territoryOwnership = {
    ["house_1234"] = {
        primary = "clan_a",
        secondary = {"clan_b", "clan_c"},
        contested_areas = {"kitchen", "basement"}
    }
}
```

### Territory Influence Radius

```lua
TERRITORY_CONTROL_RADIUS = 40  -- tiles from base center

function IsInOwnTerritory(npc, position)
    local baseCentroid = CalculateBaseCentroid(npc.baseClaim.baseId)
    local dist = calculateDistance(baseCentroid, position)
    
    if dist < TERRITORY_CONTROL_RADIUS then
        return true
    end
    
    return false
end
```

---

## Defense Strategies

### Guard Post Assignment

```lua
local guardPost = baseProcedure.posts[i]

task = {
    action = "Guard",
    position = guardPost,
    direction = guardPost.direction,
    time = 120,           -- Patrol for 2 minutes
    alertLevel = "high"   -- Watch for threats
}
```

### Reactive Defense

```lua
function OnEnemyInTerritory(npc, intruder)
    if threat.health > 0.5 then
        -- Well-armed threat
        brain.state = "AttackRange"
        npc:setTarget(intruder)
    elseif threat.hasWeapon then
        -- Armed civilian/weak NPC
        brain.state = "Alert"
        -- Sound alarm to clan
        BroadcastThreat(npc.clan, intruder)
    else
        -- Unarmed intruder
        brain.state = "Confront"
        -- Demand they leave
    end
end
```

### Alarm System

```lua
function SoundAlarm(clanId, threatLocation)
    local clanMembers = GetClanMembers(clanId)
    
    for _, member in pairs(clanMembers) do
        if IsNearBase(member, threatLocation) then
            -- Priority alert
            member.brain.state = "AttackRange"
        elseif IsInTerritory(member, threatLocation) then
            -- Secondary alert
            member.brain.state = "Alert"
        end
    end
end
```

---

## Base Tasks

### Barricading Tasks

```lua
{
    action = "Barricade",
    door = door_object,
    boards = 5,
    time = barricade_difficulty,
    endurance = 0.4
}
```

### Looting/Supply Gathering

```lua
{
    action = "LootItems",
    location = room_coordinates,
    priority = "ammo" | "food" | "medical",
    time = 30,
    endurance = 0.2
}
```

### Fortification

```lua
{
    action = "Fortify",
    targetSquare = square,
    type = "sandbags" | "barricade_walls" | "spike_traps",
    time = 45,
    endurance = 0.6
}
```

### Cleanup/Maintenance

```lua
{
    action = "CleanBlood",
    location = room,
    time = 20,
    endurance = 0.1
},
{
    action = "RepairStructure",
    targetDoor = door,
    time = 30,
    endurance = 0.3
}
```

---

## Resource Management

### Base Inventory

```lua
baseInventory = {
    ammunition = {
        ammo_556 = 150,
        ammo_762 = 80,
        ammo_pistol = 400
    },
    
    supplies = {
        wooden_boards = 45,
        nails = 200,
        duct_tape = 15
    },
    
    food = {
        canned_soup = 12,
        crackers = 30,
        water = 8
    },
    
    medical = {
        bandages = 50,
        antibiotics = 5,
        painkillers = 20
    }
}
```

### Resource Allocation

```lua
function AllocateResources(brain)
    local resources = baseInventory
    
    -- Priority 1: Ammunition (for combat readiness)
    if resources.ammunition.ammo_primary < 100 then
        brain.task_priority = "gather_ammo"
    end
    
    -- Priority 2: Barricading materials
    if resources.supplies.wooden_boards < 20 then
        brain.task_priority = "gather_supplies"
    end
    
    -- Priority 3: Food (morale)
    if resources.food.total < needed_food then
        brain.task_priority = "gather_food"
    end
end
```

---

## Base Scenes

Each base can have **preset NPC placement** via scene definitions:

```
/BanditBases/Scenes/
├─ SceneRichman.lua        (Guard variation)
├─ ScenePervert.lua        (Guard variation)
├─ SceneCarpenter.lua      (Guard variation)
├─ SceneCannibal.lua       (Special occupation)
└─ ...etc
```

These define:
- Which NPCs spawn at the base
- Their equipment
- Their initial positions
- Their roles (guard, supplier, etc.)

---

## Barricading Materials

### What Can Be Barricaded

```lua
BARRICADEABLE_OBJECTS = {
    door = true,           -- Regular doors
    garage_door = true,    -- Garage doors
    window = true,         -- Windows (if property allows)
    fence_gate = true      -- Fence gates
}
```

### Material Requirements

```lua
BARRICADE_MATERIALS = {
    wooden_board = 1,      -- Per board placed
    nails = 10,           -- Per barricade
    hammer = 1,           -- Tool (not consumed)
}
```

### Barricade Degradation

```lua
-- Barricades degrade over time from use
barricade.durability = 100  -- Start at 100%
barricade.lastAppliedTime = currentTime

-- Every few hours
if timeSinceLastRepair > 6_hours then
    barricade.durability -= 10  -- 10% per 6 hours
end

-- Reinforce when it drops below threshold
if barricade.durability < 30 then
    queue_repair_task = true
end
```

---

## Implementation Checklist for DynamicTrading

### Base System
- [ ] Define base territory bounds
- [ ] Map out doors and windows
- [ ] Assign guard posts
- [ ] Resource storage locations

### Barricading
- [ ] Identify barricadeable objects
- [ ] Set primary vs secondary priorities
- [ ] Material requirement calculation
- [ ] Durability/repair system

### Defense
- [ ] Assign guard positions
- [ ] Implement threat detection
- [ ] Broadcast alarms to faction
- [ ] Escalate response based on threat

### Tasks
- [ ] Barricade task creation
- [ ] Supply gathering tasks
- [ ] Guard/patrol tasks
- [ ] Maintenance/repair tasks

### Optimization
- [ ] Cache base boundaries
- [ ] Only check nearby NPCs for territory
- [ ] Queue barricade tasks (don't spam)
- [ ] Limit alarm broadcasts (prevent spam)

---

## Performance Considerations

### Territory Checks

```lua
-- Expensive: Full scan of all characters
for i = 0, allCharacters:size() - 1 do
    if IsInTerritory(allCharacters:get(i)) then
        -- Respond
    end
end

-- Efficient: Grid-based nearby check
local nearby = GetNearbyCharacters(baseCenter, TERRITORY_RADIUS)
for _, char in pairs(nearby) do
    if IsEnemy(char) then
        -- Respond
    end
end
```

### Barricade Updates

- Only update barricade state when entering territory
- Cache barricade status (don't query every tick)
- Defer damage calculations to 10-tick intervals

---

## Files

- **Base Procedures:** `/mods/Bandits/42.13/media/lua/shared/BanditBases/Procedures/`
- **Base Placements:** `/mods/Bandits/42.13/media/lua/shared/BanditBases/BanditBaseGroupPlacements.lua`
- **Base Scenes:** `/mods/Bandits/42.13/media/lua/shared/BanditBases/Scenes/`
- **Barricading:** integrated in `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua`
