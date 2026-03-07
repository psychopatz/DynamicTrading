# Enemy Detection & Targeting System - Threat Assessment

**Location:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` (lines 920-1050, targeting logic merged with combat)  
**Purpose:** Identify and prioritize threats for combat and behavior decisions

---

## Detection System Architecture

### Multi-Layer Detection Approach

Bandits uses situational targeting rather than global scan:

```
Current Target Check
    ↓
    └→ Is target still valid? (range, alive, visible)
        ├→ YES: Continue targeting
        └→ NO: Fall through to detection
    
Detection Phase
    ├→ Check for immediate threats (combat)
    ├→ Check for programmed targets (tasks)
    └→ Check for environmental threats (zombies attacking base)
```

---

## Core Targeting Function

### GetClosestTarget

```lua
function DTNPCLogic.GetClosestTarget(zombie)
    local brain = DTNPC.GetBrain(zombie)
    if not brain then return nil, 9999 end
    
    -- 1. HOSTILE TARGETING (Combat)
    if brain.isHostile then
        local player = zombie:getTarget()
        if player and instanceof(player, "IsoPlayer") then
            return player, calculateDistance(zombie, player)
        end
    end
    
    -- 2. MASTER/FACTION TARGETING (Following/Trading)
    if brain.masterID or brain.master then
        local onlinePlayers = getOnlinePlayers()
        for i = 0, onlinePlayers:size() - 1 do
            local p = onlinePlayers:get(i)
            if p and ((brain.masterID and p:getOnlineID() == brain.masterID) 
                   or (brain.master and p:getUsername() == brain.master)) then
                return p, calculateDistance(zombie, p)
            end
        end
    end
    
    return nil, 9999
end
```

**Return Values:**
- `master` - The target object (IsoPlayer)
- `dist` - Distance in tiles (999 = no target)

### Distance Calculation

```lua
local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end
```

**Simple 2D Euclidean distance** - ignores Z (floor level)

---

## Target Validation

### Before Using Target

```lua
local target = zombie:getTarget()

if target then
    -- Is target still alive?
    if not target:isAlive() then
        zombie:setTarget(nil)
        return
    end
    
    -- Is target in range? (varies by behavior)
    local dist = calculateDistance(zombie, target)
    if dist > MAX_BEHAVIOR_RANGE then
        zombie:setTarget(nil)
        return
    end
    
    -- Can we see/reach target?
    if not zombie:CanSee(target) then
        -- Line of sight blocked
        zombie:setTarget(nil)
        return
    end
end
```

---

## Threat Prioritization

### 1. Immediate Threats (Being Attacked)

```lua
local attacker = zombie:getAttackedBy()

if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
    -- HIGHEST PRIORITY: Someone is attacking us
    local isMaster = (master and attacker == master)
    
    if isMaster or not brain.isHostile then
        -- Respond with force
        brain.state = "AttackRange"
        brain.isHostile = true
        zombie:setTarget(attacker)
        return  -- Stop other behaviors
    end
end
```

**Priority:** Instant response to damage

### 2. Current Target Validation

```lua
local target = zombie:getTarget()

if target and instanceof(target, "IsoPlayer") then
    if target:isAlive() and zombie:CanSee(target) then
        -- Continue with current target (don't constantly search)
        local dist = calculateDistance(zombie, target)
        DTNPCLogic.CheckForCombatInitiation(zombie, brain, target, wasDamaged)
        return
    else
        -- Target invalid, clear it
        zombie:setTarget(nil)
    end
end
```

**Benefit:** Reduces re-targeting calculations

### 3. Nearby Scanning

For each category (hostile, friendly, neutral):

```lua
local cell = getCell()
local characterList = cell:getCharacters()

for i = 0, characterList:size() - 1 do
    local character = characterList:get(i)
    
    if character and character:isAlive() then
        local dist = calculateDistance(zombie, character)
        
        -- Filter by behavior type
        if ShouldTarget(zombie, character, dist) then
            if closestDist > dist then
                closest = character
                closestDist = dist
            end
        end
    end
end
```

---

## Behavior-Specific Detection

### Combat Detection (Hostile Mode)

```lua
if brain.hostile or brain.hostileP then
    -- Scan for hostile targets
    local closestEnemy = nil
    local closestDist = math.huge
    
    local cell = getCell()
    local characterList = cell:getCharacters()
    
    for i = 0, characterList:size() - 1 do
        local character = characterList:get(i)
        
        if character and instanceof(character, "IsoPlayer") then
            local dist = calculateDistance(zombie, character)
            
            if dist < closestDist and dist < COMBAT_RANGE then
                closestEnemy = character
                closestDist = dist
            end
        end
    end
    
    if closestEnemy then
        zombie:setTarget(closestEnemy)
        brain.state = "AttackRange"
    end
end
```

**Range:** Varies by weapon (melee ~2 tiles, ranged ~15+ tiles)

### Master Following (Friendly Mode)

```lua
if brain.master and not brain.isHostile then
    -- Look for master in current cell
    local players = getOnlinePlayers()
    
    for i = 0, players:size() - 1 do
        local p = players:get(i)
        
        if p and p:getUsername() == brain.master then
            local dist = calculateDistance(zombie, p)
            
            if dist < FOLLOWING_RANGE then
                zombie:setTarget(p)
                brain.state = "Follow"
            end
            
            return
        end
    end
end
```

**Range:** ~20 tiles to maintain following

### Clan Dynamics Detection

```lua
-- Don't target clan members
if brainTarget and brainTarget.clan == brain.clan then
    if not brainTarget.hostile and not brain.hostile then
        return false  -- Skip this target
    end
end
```

---

## Line of Sight (LoS)

### Game Physics Check

```lua
if zombie:CanSee(target) then
    -- Direct line of sight
    return true
else
    -- Blocked by walls/obstacles
    return false
end
```

**What it checks:**
- Wall blocks between positions
- Window occupancy
- Object occlusion

### Enhanced LoS with Walls

```lua
local targetSquare = target:getSquare()
local zombieSquare = zombie:getSquare()

if not targetSquare or not zombieSquare then return false end

-- Check for wall between squares
if zombieSquare:isSomethingTo(targetSquare) then
    return false  -- Wall blocks view
end

-- Check visibility
return zombie:CanSee(target)
```

---

## Range-Based Behavior

### Detection Ranges by Behavior

```lua
RANGE_IMMEDIATE = 2     -- Melee combat, point blank
RANGE_COMBAT = 15       -- Ranged weapon range
RANGE_ALERT = 25        -- Perceive threats
RANGE_TRACK = 50        -- Hearing range / last known position
RANGE_FOLLOWING = 20    -- Master following
RANGE_COORDINATION = 30  -- Clan member coordination
```

### Progressive Detection

```lua
if dist < RANGE_IMMEDIATE then
    -- Engage melee
    brain.state = "Attack"
elseif dist < RANGE_COMBAT then
    -- Ranged combat
    brain.state = "AttackRange"
elseif dist < RANGE_ALERT then
    -- Alert state, prepare
    brain.state = "Alerted"
elseif dist < RANGE_TRACK then
    -- Last known position chase
    brain.state = "GoTo"
else
    -- Out of all ranges
    brain.state = "Idle"
end
```

---

## Noise Detection

**Not fully implemented in Bandits**, but pattern would be:

```lua
function DetectNoise(zombie, noiseLocation, noiseMagnitude)
    local dist = calculateDistance(zombie, noiseLocation)
    
    -- Magnitude-based detection
    if dist < noiseMagnitude * HEARING_MULTIPLIER then
        -- Turn toward noise
        zombie:faceLocation(noiseLocation:getX(), noiseLocation:getY())
        
        -- Enter alert state
        if brain.state == "Stay" then
            brain.state = "Alert"
        end
    end
end
```

**Examples:** Gunshots, explosions, NPC shouts

---

## Targeting Optimization

### Spatial Hashing (Proposed)

Instead of linear scan of all characters:

```lua
-- Group characters into grid cells
local GRID_SIZE = 20  -- 20x20 tile cells

function GetNearbyCharacters(zombie)
    local x, y = math.floor(zombie:getX() / GRID_SIZE), 
                 math.floor(zombie:getY() / GRID_SIZE)
    
    -- Check only adjacent grid cells
    local nearby = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            local cellChars = grid[x + dx][y + dy]
            if cellChars then
                for _, char in pairs(cellChars) do
                    table.insert(nearby, char)
                end
            end
        end
    end
    return nearby
end
```

**Benefit:** Targets per NPC: 8-15 instead of potentially 200+

---

## Combat Initiation

### Check for Combat

```lua
function DTNPCLogic.CheckForCombatInitiation(zombie, brain, master, wasDamaged)
    local attacker = zombie:getAttackedBy()
    
    if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
        local isMaster = (master and attacker == master)
        
        if isMaster or not brain.isHostile then
            brain.state = "AttackRange"
            brain.isHostile = true
            brain.tasks = {}
            
            local attackerName = attacker:getUsername() or "Unknown Player"
            print("[DTNPC] Combat Initiated! " .. brain.name .. " is attacking " .. attackerName)
            
            zombie:setTarget(attacker)
            zombie:setAttackedBy(nil)
        end
    end
end
```

**Broadcast:** Print message alerts player of attack

---

## Implementation Checklist for DynamicTrading

### Detection System
- [ ] Calculate distance function (2D or 3D)
- [ ] Target validation (alive, in range, visible)
- [ ] Current target persistence (don't re-scan constantly)
- [ ] Line of sight check (walls, windows)

### Threat Assessment
- [ ] Immediate threat detection (being attacked)
- [ ] Priority-based targeting (closest enemy)
- [ ] Range-based behavior gates
- [ ] Faction/clan-based filtering

### Combat Initiation
- [ ] Detect when NPC is attacked
- [ ] Differentiate damage from pushes
- [ ] Set combat state immediately
- [ ] Log combat events

### Optimization
- [ ] Limit scan range to nearby area
- [ ] Cache target while valid
- [ ] Update detection every Nth tick (not every frame)
- [ ] Skip detection for distant NPCs

---

## Files

- **GetClosestTarget:** `/mods/Bandits/42.13/media/lua/shared/DT/V2/NPC/Sys/DTNPC_Logic.lua`
- **CheckForCombatInitiation:** Same file
- **Behavior Logic:** `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` (many functions)
