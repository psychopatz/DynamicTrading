# Hostile vs Friendly State Transitions - NPC Relationships

**Location:** `/mods/Bandits/42.13/media/lua/server/BanditServerSpawner.lua` (initialization)  
**Location:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` (transitions)  
**Purpose:** Manage NPC attitudes toward players and other NPCs

---

## State Overview

Each NPC has **two independent hostility flags**:

```lua
brain.hostile = true/false    -- Attitude toward zombies/NPCs
brain.hostileP = true/false   -- Attitude toward PLAYERS specifically
```

### Possible State Combinations

| hostile | hostileP | Behavior |
|---------|----------|----------|
| true | true | Aggressive to all (bandits, zombies, players) |
| true | false | Attacks NPCs/zombies but friendly to players |
| false | true | Friendly to NPCs but attacks all players |
| false | false | Fully friendly (traders, guards) |

---

## Initialization - Setting Default State

### From Clan Configuration

```lua
local spawn = clan.spawn
brain.hostile = not spawn.friendly  -- Global hostility default
brain.hostileP = brain.hostile      -- Initially mirrors
```

**Clan Definition:**
- `spawn.friendly = true` → Both flags false (peaceful)
- `spawn.friendly = false` → Both flags true (aggressive)

### Override via Arguments

```lua
if args.hostile ~= nil then 
    brain.hostile = args.hostile      -- Override global
end

if args.hostileP ~= nil then 
    brain.hostileP = args.hostileP    -- Override vs players
end
```

**Use Cases:**
- Make one trader friendly while tribe is hostile
- Create double agents (friendly to player, hostile to NPCs)
- Temporary peacetime negotiations

---

## State Transitions During Gameplay

### 1. Betrayal Detection

**Trigger:** Player attacks a friendly NPC

```lua
local attacker = zombie:getAttackedBy()

if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
    local isMaster = (master and attacker == master)
    
    if isMaster or not brain.isHostile then
        -- FRIENDLY NPC WAS ATTACKED
        brain.state = "AttackRange"
        brain.isHostile = true  -- Become hostile
        zombie:setTarget(attacker)
    end
end
```

**Key Logic:**
- Detect actual damage (not just pushes) via health delta
- Distinguish between master (can betray) and others
- Immediate state change to combat

### 2. Combat Initiation

```lua
if brain.state ~= "AttackRange" then
    brain.state = "AttackRange"
    brain.isHostile = true
    print("[DTNPC] Combat Initiated! " .. brain.name .. " attacking " .. attackerName)
end
```

**Point of No Return:** Once attacked friendly NPC enters combat state

### 3. Clan Dynamics

Bandits don't attack clan members:

```lua
if brainEnemy and brainEnemy.clan and 
   brainShooter.clan == brainEnemy.clan and 
   (not brainShooter.hostile or brainEnemy.hostile) then
    -- Same clan, don't shoot unless one is marked hostile
end
```

**Prevents:** Friendly fire within squads

### 4. Formal Transition (Not Implemented in Bandits)

Bandits doesn't have explicit "peace negotiation" but the pattern would be:

```lua
function TransitionToFriendly(bandit)
    brain.hostile = false
    brain.hostileP = false
    brain.state = "Stay" or "Trade"
    -- Clear targets
    bandit:setTarget(nil)
end

function TransitionToHostile(bandit)
    brain.hostile = true
    brain.hostileP = true
    brain.state = "AttackRange"
    -- Initiate combat search
end
```

---

## Detection & Targeting

### Finding Hostile Targets

```lua
function GetClosestTarget(zombie)
    local brain = DTNPC.GetBrain(zombie)
    
    -- 1. If hostile, search for enemies
    if brain.isHostile then
        local player = zombie:getTarget()
        if player and instanceof(player, "IsoPlayer") then
            return player, calculateDistance(zombie, player)
        end
    end
    
    -- 2. Track master/friendly target
    if brain.master then
        -- Search for master player
        -- Return for following/trading
    end
    
    return nil, 9999
end
```

### Hostility Checks

Before performing peaceful actions:

```lua
if brain.hostile or brain.hostileP then
    return  -- Skip peaceful behavior
end
```

Examples:
- Barricading doors (won't barricade around enemies)
- Trading (won't trade with hostile)
- Guarding (will attack, not guard)

---

## State Details

### brain.isHostile vs brain.hostile

**Note:** Code sometimes uses `brain.isHostile` (dynamic combat state) vs `brain.hostile` (base attitude)

```lua
brain.hostile = true/false           -- Base clan/faction attitude
brain.isHostile = true/false         -- Current combat engagement
```

**Important:** These can be different during transitions

### Anti-Ally Dynamics

Bandits prevents friendly fire WITHIN clans:

```lua
local isMaster = (master and attacker == master)

if isMaster or not brain.isHostile then
    -- Become hostile only if:
    -- 1. Player IS the master (special betrayal)
    -- 2. We're not already in combat
end
```

---

## Behavior Gating by Hostility

### Peaceful Actions (Require Not Hostile)

```lua
if not (brain.hostile or brain.hostileP) then
    -- Can trade
    -- Can guard peacefully
    -- Can help with tasks
    -- Can follow player
end
```

### Combat Actions (Require Hostile)

```lua
if brain.hostile or brain.hostileP then
    -- Can attack
    -- Can barricade against enemies
    -- Won't help players
    -- Will smash windows/destroy property
end
```

### Clan-Specific Actions

```lua
if SandboxVars.Bandits.General_SmashWindow and 
   (brain.hostile or brain.program.name == "Civilian") then
    -- Aggressive clan members break windows
    -- Civilians break windows (program-based)
end
```

---

## Real-World Scenarios

### Scenario 1: Trader Ambush

1. NPC spawns as trader (hostile=false, hostileP=false)
2. Player attacks trader → Betrayal detection fires
3. Trader enters combat (brain.state="AttackRange", isHostile=true)
4. Trader fights until killed or player leaves

**Code Path:**
```lua
wasDamaged and attacker and not brain.isHostile 
→ brain.isHostile = true
→ brain.state = "AttackRange"
```

### Scenario 2: Clan War

1. Bandit A (clan X, hostile=true) encounters Bandit B (clan Y, hostile=true)
2. Different clans + both hostile → Conflict
3. A shoots B, B retreats or fights back

**Code Path:**
```lua
if brainA.clan ~= brainB.clan and 
   (brainA.hostile or brainB.hostile) then
    -- Combat engagement
end
```

### Scenario 3: Defector

1. NPC spawns loyal to player (hostileP=false)
2. NPC's clan is hostile (hostile=true)
3. NPC ignores zombies, helps player, avoids clan violence

### Scenario 4: Sneak Attack

1. Player character is friendly (initial)
2. Player attacks NPC from behind (ambush)
3. `wasDamaged` detects damage
4. NPC becomes hostile immediately

---

## Potential Improvements

### 1. Gradual Relationship System

Instead of binary hostile/friendly, implement:

```lua
brain.reputation = {}
brain.reputation.player = 50              -- 0-100 scale
brain.reputation["clan_x"] = -30
brain.reputation["clan_y"] = 80

-- Threshold-based hostility
if brain.reputation.player < 30 then
    brain.hostileP = true
end
```

### 2. Forgiveness/Cooldown

Currently, betrayal is permanent. Could add:

```lua
brain.combatCooldown = 0
brain.lastAttackTime = 0

-- After 5 minutes without attacks, cool down
if getGameTime() - brain.lastAttackTime > 300 then
    brain.isHostile = false
    brain.canTrade = true
end
```

### 3. Faction Diplomacy

Track inter-faction relations:

```lua
factionRelations = {
    ["clan_a"] = {
        ["clan_b"] = -50,  -- At war
        ["clan_c"] = 80    -- Allied
    }
}
```

---

## Implementation Checklist for DynamicTrading

- [ ] Two-flag system (`hostile`, `hostileP`)
- [ ] Betrayal detection (damage delta, attacker check)
- [ ] State transition on attack
- [ ] Clan/faction tracking
- [ ] Peaceful action gating
- [ ] Combat action gating
- [ ] Prevent friendly fire (same group)
- [ ] Initial state from profile/arguments
- [ ] Allow override per NPC
- [ ] Combat cooldown tracking

---

## Files

- **Initialization:** `/mods/Bandits/42.13/media/lua/server/BanditServerSpawner.lua` line 410-421
- **Betrayal Detection:** `/mods/Bandits/42.13/media/lua/shared/DT/V2/NPC/Sys/DTNPC_Logic.lua` (equivalent)
- **Behavior Gating:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` (search `brain.hostile`)
