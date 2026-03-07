# Bandits Mod Analysis - Tips & Tricks
## NPC System Reference Documentation

**Date:** March 8, 2026  
**Purpose:** Document learnings from analyzing the Bandits mod for NPC implementation techniques  
**Status:** Living document - continuously updated with new discoveries

---

## 📚 Detailed System Documentation

This file is an overview. For comprehensive documentation, see:

### **[NPC_Systems/ Directory](NPC_Systems/)**

Individual files for each major system:

1. **[Bandit Brain System](NPC_Systems/01_Bandit_Brain_System.md)** - NPC data structure (identity, stats, personality)
2. **[Zombie Conversion](NPC_Systems/02_Zombie_Conversion_Mechanics.md)** - Converting between zombie/NPC states  
3. **[Hostile/Friendly States](NPC_Systems/03_Hostile_Friendly_State_Transitions.md)** - Relationship management
4. **[Detection & Targeting](NPC_Systems/04_Enemy_Detection_Targeting.md)** - Threat assessment system
5. **[Base & Barricading](NPC_Systems/05_Base_Barricading_Management.md)** - Territory control

**👉 [START HERE: Comprehensive Index](NPC_Systems/INDEX.md)**

---

---

## Sound Suppression

### Key Discovery: Voice Prefix Method

The most effective way to prevent zombie sounds in Build 42+ is to set the voice prefix to `"NotAZombie"`:

```lua
local desc = zombie:getDescriptor()
if desc then
    desc:setVoicePrefix("NotAZombie")
end
```

**Why This Works:**
- Build 42 completely changed how zombie sounds are handled
- Setting voice prefix to `"NotAZombie"` tells the game engine NOT to play any zombie vocals
- This is more effective than trying to stop individual sounds via `stopSoundByName()`
- Must be called **every tick** to maintain silence

### Legacy Approach (Build 41 and earlier)

For older builds, Bandits falls back to stopping individual sounds:

```lua
bandit:getEmitter():stopSoundByName("MaleZombieCombined")
bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
```

### Build Version Detection Pattern

```lua
if getGameVersion() >= 42 then
    -- Build 42+ method
    local desc = bandit:getDescriptor()
    desc:setVoicePrefix("NotAZombie")
else
    -- Build 41 method
    bandit:getEmitter():stopSoundByName("MaleZombieCombined")
    bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
end
```

---

## Update Loop Structure

### Event Hooks

Bandits uses `OnZombieUpdate` event for their main update loop:

```lua
Events.OnZombieUpdate.Remove(OnBanditUpdate)
Events.OnZombieUpdate.Add(OnBanditUpdate)
```

**Key Pattern:**
- Remove before adding to avoid duplicate registrations
- Called automatically by the game for every zombie every tick

### Performance Optimization - Adaptive Updates

Bandits uses adaptive update frequency based on zombie count:

```lua
local zcnt = BanditZombie.GetAllCnt()
if zcnt > 600 then zcnt = 600 end
local skip = math.floor(zcnt / 50) + 1

if uTick % skip == 0 then
    UpdateZombies(zombie)
end
```

**Benefits:**
- Reduces CPU load when many NPCs are present
- Up to 100 zombies: update every tick
- 800+ zombies: update every 1/16th tick

---

## Caching Strategy

### Multi-Tier Cache System

Bandits maintains separate caches for:

1. **Cache (full)** - Raw zombie references by ID
2. **CacheLight** - Lightweight data (position, direction, etc.)
3. **CacheLightB** - Bandits only
4. **CacheLightZ** - Regular zombies only

```lua
local light = CacheLight[id]
if not light then
    light = {}
    CacheLight[id] = light
end

light.id = id
light.x = zombie:getX()
light.y = zombie:getY()
light.z = zombie:getZ()
light.d = zombie:getDirectionAngle()
light.isBandit = isBandit
```

**Advantages:**
- Avoids repeated expensive lookups
- Separates bandits from zombies for different update logic
- Reuses tables instead of allocating new ones each tick

---

## Sound Management

### SoundStopList Pattern

Bandits maintains a list of action sounds to suppress (prevents animation sounds):

```lua
Bandit.SoundStopList = Bandit.SoundStopList or {}
table.insert(Bandit.SoundStopList, "BeginRemoveBarricadePlank")
table.insert(Bandit.SoundStopList, "BlowTorch")
table.insert(Bandit.SoundStopList, "GeneratorAddFuel")
-- etc...
```

Then suppress them in the update loop:

```lua
local emitter = zombie:getEmitter()
local stopList = Bandit.SoundStopList

for _, stopSound in pairs(stopList) do
    if emitter:isPlaying(stopSound) then
        emitter:stopSoundByName(stopSound)
    end
end
```

**Use Case:** Prevents action-related environmental sounds when NPCs shouldn't be making them

---

## Voice/Speech System

### Custom Voice Prefix Assignment

Bandits assigns custom voice prefixes for actual speech:

```lua
function Bandit.PickVoice(zombie)
    local maleOptions = {"1", "2", "3", "4"}
    local femaleOptions = {"1", "2", "4"}
    
    if zombie:isFemale() then
        return BanditUtils.Choice(femaleOptions)
    else
        return BanditUtils.Choice(maleOptions)
    end
end
```

### Playing Custom Vocals

```lua
local sound = config.prefix .. sex .. "_" .. voice .. "_" .. tostring(1 + ZombRand(config.randMax))
zombie:getEmitter():playVocals(sound)
```

**Pattern:**
- Construct sound name dynamically: `"prefix_Male_1_3"`
- Use `playVocals()` instead of `playSound()` for speech
- Only play if sandbox option enabled

---

## Distance Optimization

### Useless Flag for Distant NPCs

Bandits sets distant NPCs as "useless" to reduce game engine updates:

```lua
if BanditZombie.CacheLightB[id] then 
    zombie:setUseless(false)  -- In range, enable updates
else
    zombie:setUseless(true)   -- Out of range, disable
    return
end
```

**Benefits:**
- Game engine skips pathfinding/AI for "useless" zombies
- Significant performance improvement with many NPCs
- Only update NPCs the player can interact with

---

## Compatibility Layer Pattern

### Centralized Version Handling

Bandits uses a `BanditCompatibility` module to abstract version differences:

```lua
BanditCompatibility.SurpressZombieSounds = function(bandit)
    if getGameVersion() >= 42 then
        local desc = bandit:getDescriptor()
        desc:setVoicePrefix("NotAZombie")
    else
        bandit:getEmitter():stopSoundByName("MaleZombieCombined")
        bandit:getEmitter():stopSoundByName("FemaleZombieCombined")
    end
end
```

**Benefits:**
- Single point of maintenance for version-specific code
- Main logic stays clean and readable
- Easy to update when game versions change

---

## Pathing System Architecture

### Task-Based Movement

Bandits uses a **task queue system** rather than direct pathfinding. Movement is just another action task:

```lua
local task = {
    action = "Move",      -- or "GoTo"
    time = 20,            -- Duration in seconds
    endurance = 0.5,      -- Stamina cost
    x = targetX,
    y = targetY,
    z = targetZ,
    walkType = "Walk",    -- Walk, Run, SneakWalk, WalkAim
    closeSlow = false
}
```

### Move vs GoTo Strategy

**Move Action** - Continuous proportional navigation:
- Uses `getPathFindBehavior2():pathToLocation()`
- Continuously updates path every tick
- Better for dynamic combat scenarios
- Causes multiplayer desync in large distances

**GoTo Action** - One-time pathfinding:
- Uses `pathToLocationF()` only once
- Fire-and-forget navigation
- Better for multiplayer (synchronized)
- Not optimal for longer distances

**Selection Logic** (in multiplayer):
```lua
if dist > 30 then
    -- Long distance: use continuous Move
    action = "Move"
else
    -- Short distance: use one-time GoTo
    action = "GoTo"
end
```

### Movement Execution Flow

**State Machine (3 phases):**

1. **onStart** - Initialize movement
   - Set walk type/animation
   - Start pathfinding
   - Calculate animation bump (IdleToWalk, IdleToRun)

2. **onWorking** - Update movement every tick
   - Update pathfinder state: `getPathFindBehavior2():update()`
   - Returns `BehaviorResult.Failed` or `BehaviorResult.Succeeded` when done
   - Decrement timer by frame delta

3. **onComplete** - Cleanup after movement
   - Cancel pathfinder: `getPathFindBehavior2():cancel()`
   - Reset state: `getPathFindBehavior2():reset()`

### Controller Requirement

Only the **controller** (owner) can issue movement:

```lua
if BanditUtils.IsController(zombie) then
    zombie:getPathFindBehavior2():pathToLocation(task.x, task.y, task.z)
end
```

**Key Insight:** In multiplayer, only the server or owner controls pathfinding - prevents conflicts and desync.

### Free Tile Finding

Bandits handles blocked starting positions:

```lua
if not zombie:getSquare():isFree(false) then
    local asquare = AdjacentFreeTileFinder.Find(zombie:getSquare(), zombie)
    if asquare then
        zombie:setX(asquare:getX() + 0.5)
        zombie:setY(asquare:getY() + 0.5)
    end
end
```

**Purpose:** If NPC spawns in blocked square, find adjacent free space and teleport

### Walk Type Variations

Bandits supports multiple movement styles via WalkType variable:
- `"Walk"` - Standard walking speed
- `"Run"` - Faster, action-oriented
- `"SneakWalk"` - Slow, stealth movement
- `"WalkAim"` - Aiming while walking (combat)

Applied to animation system:
```lua
zombie:setVariable("BanditWalkType", task.walkType)
```

### Direction Handling

For long turns during movement:

```lua
local faceDir = zombie:getDirectionAngle()
local targetDir = BanditUtils.CalcAngle(zombie:getX(), zombie:getY(), task.x, task.y)
local angleDifference = faceDir - targetDir

if math.abs(angleDifference) > 130 then
    -- Large turn needed
    zombie:faceLocation(task.x, task.y)
    zombie:setBumpType("IdleToRun")
end
```

**Pattern:** Detect 180° turns and apply transition animations

### Performance Considerations

- **No expensive setPath() calls** - Uses PathFindBehavior2 API
- **Adaptive distance handling** - Different strategies for short vs long distances
- **Controller-only updates** - Reduces network traffic in multiplayer
- **Cleanup on completion** - Prevents pathfinder memory leaks

---

## 1. Key Takeaways

1. **"NotAZombie" is the magic word** - Use this voice prefix for Build 42+ to completely suppress zombie sounds
2. **Call every tick** - Sound suppression must be applied continuously
3. **Use compatibility layers** - Abstract version-specific code into separate modules
4. **Cache aggressively** - Store frequently accessed data to avoid repeated lookups
5. **Adaptive updates** - Scale update frequency based on zombie count for performance
6. **Distance culling** - Use `setUseless()` for NPCs far from players
7. **Separate concerns** - Different cache layers for different purposes (light vs full, bandits vs zombies)

---

## Files Analyzed

- `/mods/Bandits/42.13/media/lua/shared/Bandit.lua` - Main bandit logic
- `/mods/Bandits/42.13/media/lua/shared/BanditCompatibility.lua` - Version abstraction
- `/mods/Bandits/42.13/media/lua/shared/BanditUtils.lua` - Utility functions (GetMoveTask, etc.)
- `/mods/Bandits/42.13/media/lua/shared/ZombieActions/ZAMove.lua` - Move action implementation
- `/mods/Bandits/42.13/media/lua/shared/ZombieActions/ZAGoTo.lua` - GoTo action implementation
- `/mods/Bandits/42.13/media/lua/client/BanditUpdate.lua` - Update loop (line 1851+) & task state machine (line 1710+)
- `/mods/Bandits/42.13/media/lua/client/BanditZombie.lua` - Caching system

---

## Applied to DynamicTrading

**File Modified:** `Contents/mods/DynamicTradingV2/42.13/media/lua/shared/DT/V2/NPC/Sys/DTNPC_Logic.lua`

**Change:** Updated `suppressSound()` function to use `"NotAZombie"` voice prefix instead of `"None"`

```lua
local function suppressSound(zombie)
    if not zombie then return end
    
    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("NotAZombie")
    end
end
```

**Result:** NPCs are now completely silent (no moaning, shouting, or other zombie sounds)

---

## Ongoing Discoveries & Implementation Notes

### NPC Dialogue System Notes
- Bandits uses custom voice prefixes for dialogue: `"prefix_Male_1_3"`pattern
- Controlled via `playVocals()` instead of `playSound()`
- Sandbox variables control whether speech plays (`SandboxVars.Bandits.General_Speak`)
- Text captions system available for accessibility (`addLineChatElement()`)

### Animation & Movement Synchronization
- Walk type propagated via variable: `zombie:setVariable("BanditWalkType", task.walkType)`
- Animation bumps (transitions) applied to match movement intent:
  - `IdleToWalk` - Standing to walking
  - `IdleToRun` - Standing to running
  - Applied via `zombie:setBumpType()`
- Build 42+ has separate `setAnimatingBackwards()` for reverse movement

### Distance-Based Optimization Patterns
- **setUseless()** flag crucial for performance with many NPCs
- Distance checks before expensive operations (sound playback, complex AI)
- Culling zones prevent updates to distant NPCs
- Example: Only play sounds within 14 units of player

### Multiplayer Considerations
- Game mode detection: `getWorld():getGameMode() == "Multiplayer"`
- Controller-only pathfinding prevents desync
- Different task configurations for MP vs SP
- Fallback chains for missing online players

### Brain/Data Structure Pattern
- Separate brain table for each zombie: `local brain = BanditBrain.Get(zombie)`
- Brain persists across updates via ModData or persistent table
- Contains state, tasks, voice preferences, health tracking, etc.
- Useful for stateful NPC behavior

### Endurance/Stamina System
- Tracked at task level: `task.endurance = 0.5`
- Applied on task completion in `onComplete` phase
- Can gate behaviors (tired NPCs move slower, etc.)

### Health & Bleeding Integration
- NPCs track last known health: `brain.lastHealth`
- Differentiate between damage and non-damaging hits (pushes)
- Visual damage list contains 70+ different wound animations
- Automatic detection of betrayal (friendly player attacks)

### FPS-Aware Delta Time
Bandits properly handles variable framerates:
```lua
local decrement = 1 / ((getAverageFPS() + 0.5) * 0.01666667)
task.time = task.time - decrement
```
**Lesson:** Don't hardcode tick counts, use FPS-aware deltas for smooth gameplay

---

### To Document Next
- [ ] Bandit brain initialization system
- [ ] Expertise/skill system implementation
- [ ] Loot and item management patterns
- [ ] Combat behavior prioritization
- [ ] Barricading and base management
- [ ] Zombie conversion mechanics (how they make bandits)
- [ ] Hostile vs Friendly state transitions
- [ ] Damage calculation and health management
- [ ] Visual damage system (70+ wound animations)
- [ ] Corpse handling and burial
- [ ] Vehicle systems interaction
- [ ] Squad coordination patterns
- [ ] Enemy detection and targeting
- [ ] Sound event synchronization in multiplayer

---

## Documentation Methodology

This document focuses on **reusable patterns** rather than direct code copying. When analyzing external mods:

1. **Identify core systems:** Sound, movement, animation, etc.
2. **Extract architecture:** How are they organized? Task-based? Event-driven?
3. **Document patterns:** What's the general approach that could apply elsewhere?
4. **Note version differences:** Build 42 API changes are critical
5. **Performance insights:** What optimizations matter at scale?

Apply learnings to DynamicTrading incrementally, adapting to our architecture.
