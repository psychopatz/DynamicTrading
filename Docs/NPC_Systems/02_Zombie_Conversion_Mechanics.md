# Zombie Conversion Mechanics - Bidirectional NPC System

**Location:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` (line 158-250)  
**Purpose:** Convert between zombie and NPC states while preserving/resetting data

---

## Overview

Bandits implements a **bidirectional conversion system** where zombies can be upgraded to bandits and bandits can revert to zombies. This is critical for:

- Spawning new NPCs with full capabilities
- Handling NPC death (revert to zombie)
- Temporary zombie infection scenarios
- Removing NPC status

---

## Banditize: Zombie → NPC

### Function Signature

```lua
local function Banditize(zombie, brain)
    -- Load brain data
    -- Apply NPC visual markers
    -- Enable NPC-specific systems
    -- Prevent game conflicts
end
```

### Step 1: Brain Association

```lua
BanditBrain.Update(zombie, brain)
```

Stores the brain table in ModData so all subsequent updates can access NPC state

### Step 2: Appearance Preparation

```lua
zombie:setNoTeeth(true)
```

**Why?** Prevents gore effects that don't match NPC appearance

### Step 3: Variable Flags

```lua
zombie:setVariable("Bandit", true)           -- The key flag
zombie:setVariable("LimpSpeed", 0.80)        -- Limp speed override
zombie:setVariable("RunSpeed", 0.65 + ZombRandFloat(0, 0.15))  -- 65-80% speed
zombie:setVariable("WalkSpeed", 1.04)        -- Standard walk
zombie:setVariable("BanditPrimary", "")      -- Weapon slot tracking
zombie:setVariable("BanditSecondary", "")
zombie:setVariable("BanditWalkType", "Walk") -- Animation type
```

**Critical Flag:** `"Bandit"` variable controls all NPC-specific behavior gates

### Step 4: Combat Crash Prevention

```lua
zombie:setVariable("ZombieHitReaction", "Chainsaw")
```

**Issue Fixed:** Without this, bandits crash when hit because game calls `testDefense()` which references moodles (health system) that zombies don't have

**Solution:** Setting reaction type prevents crash-causing code path

### Step 5: Anti-Lunge Protection

```lua
zombie:setVariable("NoLungeTarget", true)
```

**Purpose:** Prevents players from lunging at NPCs with knockdown animations

### Step 6: Silence System

```lua
zombie:getEmitter():stopAll()
```

Stops all currently playing sounds immediately (preparation for "NotAZombie" prefix)

### Step 7: Equipment Reset

```lua
zombie:setPrimaryHandItem(nil)
zombie:setSecondaryHandItem(nil)
zombie:resetEquippedHandsModels()
zombie:clearAttachedItems()
```

**Purpose:** Clear any zombie-related items before equipping NPC gear

### Step 8: Unstuck Mechanics

```lua
zombie:setTurnAlertedValues(-5, 5)
```

**What this does:** Allows NPC to turn more freely after spawn, prevents stuck animations

### Step 9: MetaData Linking

```lua
zombie:getModData().brainId = brain.id
```

Stores brain ID for future lookups/syncing

### Step 10: Voice Setup

```lua
local desc = zombie:getDescriptor()
desc:setVoicePrefix("Bandit")
```

**Alternative:** Custom prefix for dialogue, "NotAZombie" to suppress zombie sounds

---

## Zombify: NPC → Zombie

### Function Signature

```lua
local function Zombify(bandit)
    -- Reverse all Banditize changes
    -- Clear NPC-specific data
    -- Restore zombie defaults
end
```

### Reverse Process (Line by Line)

```lua
bandit:setNoTeeth(false)                      -- Restore zombie teeth for gore
bandit:setUseless(false)                      -- Re-enable game engine AI
bandit:setVariable("Bandit", false)          -- Disable NPC checks
bandit:setVariable("BanditPrimary", "")      -- Clear NPC variables
bandit:setVariable("BanditSecondary", "")
bandit:setWalkType("2")                      -- Restore zombie walk
bandit:setVariable("BanditWalkType", "")

-- Clear equipment
bandit:setPrimaryHandItem(nil)
bandit:setSecondaryHandItem(nil)
bandit:resetEquippedHandsModels()
bandit:clearAttachedItems()

-- Remove brain association
bandit:getModData().brainId = nil
BanditBrain.Remove(bandit)                   -- Clear brain from ModData
```

---

## Conversion Gates

### When Does Banditize Happen?

```lua
if not zombie:getVariableBoolean("Bandit") then
    brain = gmd[id]  -- From game mode data
    Banditize(zombie, brain)
end
```

**Trigger:** When server detects bandit data for a non-bandit zombie

### When Does Zombify Happen?

```lua
if zombie:getVariableBoolean("Bandit") then
    Zombify(zombie)
end
```

**Trigger:** When bandit data is removed or NPC is killed

---

## State Machine Impact

### Before Banditize

```
Regular Zombie
├─ Game engine pathfinding
├─ Zombie behaviors (eating, attacking)
├─ Zombie sounds
├─ Gore system enabled
└─ No persistent brain
```

### After Banditize

```
NPC Bandit
├─ Custom task-based pathfinding
├─ NPC behaviors (jobs, combat strategy)
├─ Silent (or custom dialogue)
├─ No gore/teeth
└─ Persistent brain with personality
```

### After Zombify

```
Zombie Again
├─ Game engine takes over
├─ Back to regular zombie AI
├─ Zombie sounds
├─ Normal corpse mechanics
└─ No brain
```

---

## Critical Safety Measures

### 1. Variable Checks (Everywhere)

Before using NPC-specific code, always check:

```lua
if not zombie:getVariableBoolean("Bandit") then return end
```

Prevents accessing brain when in zombie state

### 2. ModData Null Checks

```lua
local brain = BanditBrain.Get(zombie)
if not brain then return end
```

Brain might not be synced yet from server

### 3. Descriptor Nullability

```lua
local desc = zombie:getDescriptor()
if desc then
    desc:setVoicePrefix("Bandit")
end
```

Descriptor might be null in certain conditions

---

## Technical Considerations

### Network Sync

In multiplayer:
- Banditize happens **client-side** when brain data arrives from server
- Server has authoritative brain data
- Client applies Banditize to make zombie visually match brain state

### Persistence

The "Bandit" variable persists in save files via:
- Zombie's variable storage (automatically saved)
- Brain table in ModData (automatically saved if zombie exists)

If zombie is deleted, brain is lost

### Performance

Converting a single zombie is cheap (~5 variable sets + function calls)

But converting 100+ zombies at once would cause frame stutter

### Animation Complications

Banditize must happen **before** task queuing because tasks reference walk types

If done in wrong order:
- Walk type set to zombie walk (setWalkType("2"))
- Then NPC walk type can't override (animation mismatch)

---

## Conversion Validation

After conversion, the zombie should have:

**Banditize Validation:**
- ✓ `zombie:getVariable("Bandit") == true`
- ✓ `BanditBrain.Get(zombie) ~= nil`
- ✓ Voice prefix changed
- ✓ No hand items
- ✓ Can execute tasks

**Zombify Validation:**
- ✓ `zombie:getVariable("Bandit") == false`
- ✓ `BanditBrain.Get(zombie) == nil`
- ✓ `zombie:getUseless() == false`
- ✓ Normal walk type
- ✓ Game engine controls movement again

---

## Application to DynamicTrading

DynamicTrading should consider:

1. **Clear Identification** - Use persistent variable to mark NPCs
2. **Clean Reversal** - Have explicit function to remove NPC state
3. **Safety Checks** - Always verify NPC status before accessing NPC-specific data
4. **Sync Consideration** - If multiplayer, coordinate bandit conversion across clients
5. **Task Queue Setup** - Initialize after Banditize, before behavior updates
6. **Audio System** - Set voice prefix FIRST before any sound attempts

---

## Files

- **Banditize:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` line 158
- **Zombify:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` line 208
- **Brain Storage:** `/mods/Bandits/42.13/media/lua/shared/BanditBrain.lua`
