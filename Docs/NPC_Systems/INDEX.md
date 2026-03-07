# NPC Systems Documentation - Index

**Project:** DynamicTrading  
**Purpose:** Comprehensive NPC system reference based on Bandits mod analysis  
**Last Updated:** March 8, 2026  
**Status:** Living documentation - continuously expanded

---

## Quick Navigation

### Core Systems
1. **[Bandit Brain System](01_Bandit_Brain_System.md)** - NPC data structure and personality
   - Brain initialization
   - Stat mapping
   - Personality traits
   - Data persistence

2. **[Zombie Conversion Mechanics](02_Zombie_Conversion_Mechanics.md)** - Bidirectional NPC conversion
   - Banditize (zombie → NPC)
   - Zombify (NPC → zombie)
   - Safety measures
   - State transitions

3. **[Hostile vs Friendly State Transitions](03_Hostile_Friendly_State_Transitions.md)** - Relationship system
   - Dual hostility flags
   - Betrayal detection
   - State transitions
   - Clan dynamics

4. **[Enemy Detection & Targeting](04_Enemy_Detection_Targeting.md)** - Threat assessment system
   - Target validation
   - Priority-based detection
   - Line of sight
   - Combat initiation

5. **[Base & Barricading Management](05_Base_Barricading_Management.md)** - Territory control
   - Base definition
   - Barricading strategies
   - Defense mechanics
   - Resource management

---

## System Dependencies

```
Brain System
    ├─ Stores NPC personality and stats
    └─ Required by all other systems

    ↓

Zombie Conversion
    ├─ Applies brain to zombie (Banditize)
    ├─ Removes brain from zombie (Zombify)
    └─ Makes zombie NPC-compatible

    ↓

Hostile/Friendly States
    ├─ Applied during brain init
    ├─ Determines NPC behavior
    └─ Gates certain actions

    ↓

Detection & Targeting
    ├─ Uses hostile/friendly state
    ├─ Finds combat targets
    └─ Initiates combat

    ↓

Base Management
    ├─ Uses detection system
    ├─ Coordinates team defense
    └─ Manages territory
```

---

## Key Concepts Summary

### 1. Brain-Based Architecture

All NPC behavior stems from the **brain table** containing:
- Identity (name, ID, appearance)
- Capabilities (health, accuracy, endurance)
- Personality (traits, preferences)
- Current state (moving, fighting, idle)
- Persistent data (saved with zombie via ModData)

**Advantage:** One data structure controls everything

---

### 2. Task Queue System

```
Brain → Task Queue → Execute Tasks
              ↓
         onStart
              ↓
         onWorking (every tick)
              ↓
         onComplete
              ↓
         Remove & Next Task
```

All NPC actions are queued as tasks, not immediate commands

---

### 3. Dual Hostility

```lua
brain.hostile  = vs NPCs/zombies
brain.hostileP = vs Players

Combinations:
- true/true   = Aggressive to all
- true/false  = Attacks NPCs, helps players
- false/true  = Helps NPCs, attacks players  
- false/false = Fully peaceful
```

Allows nuanced relationships

---

### 4. Detection → Targeting → Behavior

```
Scan nearby characters
    ↓
Validate targets (alive, in range, visible)
    ↓
Prioritize by threat/relationship
    ↓
Set as current target
    ↓
Gate behaviors based on target type
```

Only performed when needed, not every tick

---

### 5. Version Compatibility

```lua
if getGameVersion() >= 42 then
    -- Build 42+ specific API
else
    -- Build 41 fallback
end
```

Bandits maintains support for multiple builds

---

## Implementation Priority for DynamicTrading

### Phase 1: Foundation (Essential)
- [ ] Brain system (data structure)
- [ ] Zombie conversion (Banditize/Zombify)
- [ ] Basic hostile/friendly state
- [ ] Distance-based detection

### Phase 2: Core Behavior (High Priority)
- [ ] Task queue system
- [ ] Movement/pathfinding
- [ ] Detection filtering (hostility-based)
- [ ] Target selection

### Phase 3: Advanced Features (Nice to Have)
- [ ] Betrayal detection
- [ ] Clan/faction system
- [ ] Base management
- [ ] Barricading
- [ ] Personality traits

### Phase 4: Polish (Optional)
- [ ] Alarm broadcasts
- [ ] Territory influence
- [ ] Resource management
- [ ] Durability/repairs

---

## Common Patterns to Steal

### 1. Compatibility Layer

```lua
-- Single point for version-specific code
BanditCompatibility = {}

-- All version checks go through this
function BanditCompatibility.SurpressZombieSounds(zombie)
    if getGameVersion() >= 42 then
        local desc = zombie:getDescriptor()
        desc:setVoicePrefix("NotAZombie")
    else
        zombie:getEmitter():stopSoundByName("MaleZombieCombined")
    end
end
```

**Benefit:** Main logic stays clean

---

### 2. Multi-Tier Caching

```lua
cache = {}                   -- Full references
cacheLight = {}             -- Just position/ID
cacheLightB = {}            -- Bandits only
cacheLightZ = {}            -- Zombies only
```

**Benefit:** Trade memory for speed

---

### 3. Lerp for Stat Mapping

```lua
function Lerp(input, inMin, inMax, outMin, outMax)
    local normalized = (input - inMin) / (inMax - inMin)
    return outMin + (normalized * (outMax - outMin))
end

-- 1-9 scale maps to game multipliers
health_multiplier = Lerp(brain.health, 1, 9, 1.0, 2.6)
```

**Benefit:** Flexible stat scaling

---

### 4. Randomized Traits

```lua
brain.rnd = {
    ZombRand(2), ZombRand(10), ZombRand(100),
    ZombRand(1000), ZombRand(10000)
}

-- Use random values to create unique NPCs
local behavior = brain.rnd[1]  -- 0 or 1 for binary choice
```

**Benefit:** NPCs feel unique despite same code

---

### 5. Event-Driven Updates

```lua
-- Remove before adding (prevents duplicates)
Events.OnZombieUpdate.Remove(OnBanditUpdate)
Events.OnZombieUpdate.Add(OnBanditUpdate)

-- Game calls automatically for every zombie
```

**Benefit:** Automatic, no manual iteration needed

---

## Testing Checklist

### Unit Tests
- [ ] Brain initialization with all stat ranges
- [ ] Banditize/Zombify reversibility
- [ ] Hostile/friendly state gates
- [ ] Distance calculations
- [ ] Task queue ordering

### Integration Tests
- [ ] NPC spawns and behaves correctly
- [ ] Player attacking triggers combat
- [ ] Targeting finds closest threat
- [ ] Barricading blocks movement
- [ ] Clan members don't attack each other

### Performance Tests
- [ ] 10 NPCs - no lag
- [ ] 50 NPCs - acceptable lag
- [ ] 100+ NPCs - graceful degradation
- [ ] Profiling shows no hotspots

### Edge Cases
- [ ] NPC spawns in blocked square
- [ ] NPC dies during task
- [ ] Player joins multiplayer (sync)
- [ ] Save/load game with NPCs
- [ ] Base area out of bounds

---

## Debugging Tips

### Enable Debug Printing

```lua
-- Add to top of key files
DTNPC_DEBUG = true
DTNPC_DEBUG_PATHFINDING = true
DTNPC_DEBUG_COMBAT = true

-- Wrap critical logs
if DTNPC_DEBUG then
    print("[DTNPC] State: " .. brain.state)
end
```

### Check Brain Integrity

```lua
function DebugBrain(zombie)
    local brain = DTNPC.GetBrain(zombie)
    if not brain then
        print("[ERROR] Zombie has no brain!")
        return false
    end
    
    if not brain.id then
        print("[ERROR] Brain has no ID")
    end
    
    if not brain.tasks then
        print("[WARNING] Brain has no task queue")
    end
    
    return true
end
```

### Monitor Hostility

```lua
print(string.format(
    "[%s] hostile:%s hostileP:%s state:%s",
    brain.name,
    tostring(brain.hostile),
    tostring(brain.hostileP),
    brain.state
))
```

---

## Performance Optimization Priorities

1. **Cache aggressively** - Store expensive calculations
2. **Reduce scan radius** - Don't check all zombies
3. **Lazy evaluation** - Skip checks when not needed
4. **Spatial hashing** - Grid-based nearby lookups
5. **Adaptive updates** - Less frequent for distant NPCs

---

## Future Expansion Ideas

- [ ] Fully randomized NPC names with preferences
- [ ] Relationship tracking system (rep per NPC)
- [ ] Skill progression from experience
- [ ] Equipment degradation and replacement
- [ ] Squad coordination with complex tactics
- [ ] Dynamic base expansion
- [ ] NPC recruitment and defection
- [ ] Trade routes between bases
-[ ] Zombie seige mechanics
- [ ] Dialogue trees with NPCs

---

## File Organization

```
Docs/
├─ Bandits_Mod_Analysis_Tips.md           (Original overview)
└─ NPC_Systems/
   ├─ INDEX.md                            (This file)
   ├─ 01_Bandit_Brain_System.md
   ├─ 02_Zombie_Conversion_Mechanics.md
   ├─ 03_Hostile_Friendly_State_Transitions.md
   ├─ 04_Enemy_Detection_Targeting.md
   └─ 05_Base_Barricading_Management.md
```

---

## How to Contribute to This Documentation

1. **Discover Pattern** - Analyze new system in Bandits mod
2. **Document** - Create comprehensive markdown file
3. **Structure** - Follow template: Overview → Details → Example → Checklist
4. **Link** - Add to this index
5. **Update Priority** - List in implementation checkl if relevant

---

## Related Resources

- **Source Mod:** `/mods/Bandits/42.13/media/lua/`
- **Main Project:** DynamicTrading
- **Key Files:** 
  - `BanditBrain.lua`
  - `BanditUpdate.lua`
  - `BanditServerSpawner.lua`
  - `BanditCompatibility.lua`

---

**Last Updated:** March 8, 2026  
**Documentation Status:** Active - Regular additions planned  
**Next Topics to Document:** Expedition system, reputation algorithms, NPC economies
