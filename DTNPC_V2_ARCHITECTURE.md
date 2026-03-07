# DynamicTrading V2 NPC System Architecture

## Overview
DynamicTrading V2 implements a dual-layer NPC management system with:
1. **Persistent Layer**: DTSoul/DynamicTrading_Roster (tracks all NPC state, even when unloaded)
2. **Active Layer**: DTNPCManager (tracks NPC instances currently in the world)
3. **Network Layer**: Server-Client synchronization via sendServerCommand

---

## 1. NPC SPAWNING/LOADING SYSTEM

### Architecture Files

| File | Purpose |
|------|---------|
| [DTNPC_Spawn.lua](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua) | Main spawning, sync, and network functions |
| [DTNPC_ManagerRespawn.lua](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_ManagerRespawn.lua) | Proximity-based respawn checks |
| [DTNPC_ServerCore_Spawn.lua](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/ServerCore/DTNPC_ServerCore_Spawn.lua) | Core spawn implementation |
| [DTNPC_Manager_Tick.lua](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Tick.lua) | Main game loop that drives respawn/broadcast |

### Spawning Process Flow

```
1. DTNPCSpawn.SpawnNPC(player, existingBrain, options)
   ├─ Find safe grid square near player
   ├─ Use addZombiesInOutfit() to create zombie
   ├─ Attach brain data via DTNPC.AttachBrain()
   ├─ Apply visuals via DTNPC.ApplyVisuals()
   ├─ DTNPCManager.Register(zombie, brain)
   │  ├─ Generate/assign UUID if needed
   │  ├─ Store in DTNPCManager.Data[uuid]
   │  ├─ Update DTNPCManager.OutfitIDToUUID mapping
   │  └─ Save to ModData("DTNPC_GlobalList")
   └─ DTNPCSpawn.SyncToAllClients(zombie, brain)
      └─ Send "SyncNPC" command to all clients via sendServerCommand()
```

### Key Data Structures

**DTNPCManager.Data (Runtime Database):**
```lua
DTNPCManager.Data = {
    [uuid] = {
        uuid = "abc123...",
        name = "NPC Name",
        currentOutfitID = 12345,        -- Zombie's persistent outfit ID
        lastX, lastY, lastZ = ...,      -- Last known position
        health = 100,
        state = "Stay" | "Guard" | "Trading" | "Follow",
        isFemale = true/false,
        visualID = random(1000000),     -- Forces visual refresh on respawn
        status = "Resting" | "Trading" | "Away" | "Dead",
        brain = { ... }                 -- Full behavioral data
    }
}

DTNPCManager.OutfitIDToUUID = {
    [outfitID_number] = "uuid-string"  -- Maps current outfit ID to persistent UUID
}
```

**Roster Soul (Persistent Storage):**
```lua
DynamicTrading_Roster.Souls = {
    [uuid] = {
        name = "NPC Name",
        factionID = "faction_id",
        homeCoords = {x, y, z},
        lastX, lastY, lastZ = ...,
        status = "Resting" | "Trading" | "Away" | "Dead",
        returnTime = world_age_hours,   -- When to trigger transition
        returnStatus = next_status,     -- What to transition to
        spawnRetryTime = hours,         -- Backoff timer for failed spawns
    }
}
```

---

## 2. PROXIMITY-BASED LOADING

### Respawn Range
```lua
-- File: DTNPC_ManagerRespawn.lua, Line 12
local RESPAWN_RANGE = 100  -- Distance in tiles at which NPCs hydrate/spawn near players
```

### Proximity Check System

**Function: `DTNPCManager.CheckForRespawn(brain, uuid)`**
- **When**: Every 3 seconds (RESPAWN_CHECK_RATE = 60 ticks @ 20 ticks/sec)
- **Logic**:
  1. For each active player
  2. Calculate distance to NPC's last known position (brain.lastX, brain.lastY)
  3. If player Z == NPC Z AND distance < 100 tiles:
     - Spawn NPC near player using `DTNPCServerCore.RespawnNPC()`

**Function: `DTNPCManager.CheckRosterSpawns()`**
- **When**: Every 3 seconds (alongside CheckForRespawn)
- **Logic**:
  1. Scan all Souls in DynamicTrading_Roster
  2. For Souls with status: "Resting", "Working", or "Trading"
  3. Check if any player is within 100 tiles
  4. If player nearby and soul not tracked in DTNPCManager.Data:
     - Fetch full brain via `DynamicTrading_Roster.GetSoul(uuid)`
     - Call `DTNPCServerCore.RespawnNPC(fullBrain, uuid)`
  5. Show progress: `"Player [name] is near Soul: [name] (Dist: [distance]m, Status: [status])"`

**Proximity Check Code:**
```lua
local dx = player:getX() - targetX
local dy = player:getY() - targetY
local dz = player:getZ() - targetZ
local dist = math.sqrt(dx*dx + dy*dy)

-- Relaxed Z-check: Allow +/- 1 floor
if math.abs(dz) <= 1 and dist < RESPAWN_RANGE then
    -- Respawn NPC
end
```

### Spawn Location Search (Fallback System)

When respawning, if target square is not immediately free:
- **Pass 1 (15-tile radius)**: Search for perfect square (Free, Not Solid, Not SolidTrans)
- **Pass 2 (15-tile radius)**: Search for tolerable square (Not Solid, Not SolidTrans, but may have objects)
- **Failure**: Log "Chunk likely UNLOADED or area is blocked"

```lua
-- File: DTNPC_Spawn.lua, Lines 230-280
for radius = 1, 15 do
    for _x = -radius, radius do
        for _y = -radius, radius do
            local tSq = cell:getGridSquare(x + _x, y + _y, z)
            if tSq and tSq:isFree(false) and not tSq:isSolid() then
                foundSq = tSq
                break
            end
        end
        if foundSq then break end
    end
    if foundSq then break end
end
```

---

## 3. NPC DATA TRANSMISSION TO CLIENTS

### Network Protocol

**Server-to-Client Messages** (via `sendServerCommand()`):

| Command | Payload | Purpose |
|---------|---------|---------|
| `SyncNPC` | uuid, outfitID, x, y, z, brain | Spawn/update NPC on client |
| `UpdatePosition` | uuid, outfitID, x, y, z, health, state | Position/state broadcast every 6 seconds |
| `RemoveNPC` | uuid, outfitID, name | Remove NPC from client world |
| `SyncAllNPCs` | {uuid → brain, ...} | Full database dump on initial sync |

**Client-to-Server Messages** (via `sendClientCommand()`):

| Command | Payload | Purpose |
|---------|---------|---------|
| `RequestFullSync` | {} | Client requests all NPC data |
| `RequestSync` | {} | Client requests nearby NPCs |
| `UpdateNPC` | uuid, updates {state, tasks, ...}, broadcastPosition | Client sends behavioral changes |
| `Order` | x, y, z, state, [targetX, targetY, targetZ] | Player issues order (Follow, Flee, GoTo) |
| `RemoveNPC` | uuid, status, returnTime, returnStatus | Request removal with Roster update |

### Sync Functions (Server-Side)

**1. SyncToAllClients() - Broadcast to all players**
```lua
-- File: DTNPC_Spawn.lua, Lines 18-45
function DTNPCSpawn.SyncToAllClients(zombie, brain)
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain  -- Full brain object
    }
    
    if isServer() then
        sendServerCommand("DTNPC", "SyncNPC", syncData)  -- All players
    else
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)  -- SP fallback
    end
end
```

**2. SyncToPlayer() - Send to specific player**
```lua
-- File: DTNPC_Spawn.lua, Lines 48-75
sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
```

**3. BroadcastPosition() - Update positions periodically**
```lua
-- File: DTNPC_Spawn.lua, Lines 78-98
-- Called every 6 seconds (POSITION_BROADCAST_RATE = 120 ticks)
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        state = brain.state
    }
    
    sendServerCommand("DTNPC", "UpdatePosition", posData)
end
```

### Client-Side Sync Reception

**File: [DTNPC_ClientNetwork.lua](Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua)**

```lua
function DTNPCClient.OnServerCommand(module, command, args)
    -- SyncNPC: Receive new/updated NPC
    if command == "SyncNPC" then
        DTNPCClient.CacheBrain(uuid, outfitID, args.brain)
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
    end
    
    -- UpdatePosition: Update position + state
    if command == "UpdatePosition" then
        local cached = DTNPCClient.NPCCache[uuid]
        if cached then
            cached.brain.lastX = args.x
            cached.brain.lastY = args.y
            cached.brain.state = args.state
            -- Reconcile position with in-world zombie
        end
    end
    
    -- RemoveNPC: Delete from client
    if command == "RemoveNPC" then
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
        end
        DTNPCClient.RemoveFromCache(uuid, outfitID)
    end
end
```

### Initial Sync on Join
```lua
-- File: DTNPC_ClientVisuals.lua, Line 158
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)

-- File: DTNPC_ClientNetwork.lua, Lines 147-156
function DTNPCClient.RequestInitialSync(playerNum)
    local player = getSpecificPlayer(playerNum)
    sendClientCommand(player, "DTNPC", "RequestFullSync", {})
end

-- Server handler: DTNPC_Spawn.lua, Lines 519-524
if command == "RequestFullSync" then
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
end
```

---

## 4. UNLOADING/DELETION MECHANISM

### Unloading Scenarios

**A. Player Moves Away (Passive Removal)**
- When player distance > 100 tiles, NPC is NOT actively unloaded
- Instead: NPC stays in world until chunk unloads naturally
- When re-approached, respawn is triggered again

**B. NPC Dies (Active Removal)**
```lua
-- File: DTNPC_Manager_Registration.lua, Lines 118-135
Events.OnZombieDead.Add(DTNPCManager.Unregister)

function DTNPCManager.Unregister(zombie)
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    if uuid and DTNPCManager.Data[uuid] then
        DTNPCManager.RemoveData(uuid, "Dead")
    end
end
```

**C. Status Change to Away/Dead (Active Removal)**
```lua
-- File: DTNPC_Manager_Registration.lua, Lines 103-117
function DTNPCManager.SetNPCStatus(uuid, status, returnTime, returnStatus)
    if status == "Away" or status == "Dead" then
        if DTNPCManager.Data[uuid] then
            DTNPCManager.RemoveData(uuid)
        end
        
        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if zombie then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
        end
    end
end
```

**D. Manual Removal (RemoveNPC Command)**
```lua
-- File: DTNPC_Spawn.lua, Lines 564-596
if command == "RemoveNPC" then
    if DTNPCManager then
        local name = DTNPCManager.Data[args.uuid].name
        DTNPCManager.RemoveData(args.uuid, args.status, args.returnTime, args.returnStatus)
        
        local zombie = DTNPCSpawn.FindZombieByUUID(args.uuid)
        if zombie then
            zombie:removeFromWorld()
            zombie:removeFromSquare()
        end
    end
end
```

### Removal Process Flow

```
DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
├─ Remove from outfit ID mapping: DTNPCManager.OutfitIDToUUID[outfit] = nil
├─ Update Roster (persistent): DynamicTrading_Roster.UpdateSoulStatus(...)
├─ Remove from Manager data: DTNPCManager.Data[uuid] = nil
├─ Save to disk: DTNPCManager.Save()
└─ Notify all clients: DTNPCServerCore.NotifyRemoval(uuid, outfitID, name)
   └─ Server sends "RemoveNPC" command
      └─ Client receives: zombie:removeFromWorld() + zombie:removeFromSquare()
         └─ DTNPCClient.RemoveFromCache(uuid, outfitID)
```

### Persistence Across Unloads

Even when NPC is unloaded/removed from the active world:
1. **Roster stores** all state in `DynamicTrading_Roster` ModData
2. **Status transitions** are tracked with timers (returnTime, returnStatus)
3. **When player re-approaches**: `CheckRosterSpawns()` re-hydrates the NPC

Example: "Away" Transition
```lua
-- NPC status set to "Away" with returnTime = currentHours + 4
-- Every 30 seconds, ProcessAwayTransitions() checks:
if currentHours >= registry.returnTime then
    -- Trigger next status (e.g., "Resting" or "Trading")
    DTNPCManager.SetNPCStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
end
```

---

## 5. SERVER-CLIENT SYNCHRONIZATION

### Synchronization Flows

**1. Spawn/Update Flow**
```
Server World Event
  ↓
DTNPCSpawn.SyncToAllClients(zombie, brain)
  ↓
sendServerCommand("DTNPC", "SyncNPC", syncData)
  ↓
All Clients receive OnServerCommand
  ↓
DTNPCClient.CacheBrain(uuid, outfitID, brain)
DTNPCClient.ApplyVisualsToNPC(zombie, brain)
DTNPCClient.ReconcilePosition(zombie, x, y, z)
```

**2. Position Broadcast (Every 6 seconds)**
```
DTNPCManager.OnTick()
  ├─ Every 3 sec: CheckForRespawn() + CheckRosterSpawns()
  ├─ Every 6 sec: BroadcastPosition() for all in-world NPCs
  └─ Every 30 sec: ProcessAwayTransitions() + ProcessTradeCycles()
    ↓
DTNPCSpawn.BroadcastPosition(zombie, brain)
  ↓
sendServerCommand("DTNPC", "UpdatePosition", posData)
```

**3. Behavioral Update Flow (Client → Server)**
```
Player issues command (e.g., "Follow me")
  ↓
Client sends: sendClientCommand(player, "DTNPC", "UpdateNPC", {
    uuid = "...",
    updates = {state = "Follow", broadcastPosition = true}
})
  ↓
Server receives: onClientCommand(module, command, args)
  ↓
Updates DTNPCManager.Data[uuid].state = "Follow"
Syncs to all clients: DTNPCSpawn.SyncToAllClients(zombie, brain)
```

**4. Critical Sync Points**
- **On Spawn**: Full brain object sent
- **During Movement**: Position updates every 6 seconds
- **On State Change**: Full brain object resent (with new visualID)
- **On Respawn**: New visualID forces client visual refresh
- **On Death/Removal**: RemoveNPC command cleans up client-side

### Death Handling

```lua
Events.OnZombieDead.Add(DTNPCManager.Unregister)

function DTNPCManager.Unregister(zombie)
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    DTNPCManager.RemoveData(uuid, "Dead")
    -- Calls NotifyRemoval → Server sends RemoveNPC to all clients
end

-- Client side (DTNPC_ClientNetwork.lua):
if command == "RemoveNPC" then
    zombie:removeFromWorld()
    zombie:removeFromSquare()
    DTNPCClient.RemoveFromCache(uuid, outfitID)
end
```

---

## 6. DATA FLOW: DTSoul AND DTNPC_ROSTER BRIDGE

### Two-Layer Architecture

```
┌─────────────────────────────────────────────────┐
│ DynamicTrading_Roster (Common Module)           │
│ ├─ ModData("DynamicTrading_Roster")             │
│ ├─ Souls: {uuid → soul_registry}                │
│ └─ Methods: GetSoul(), SaveSoul(), GetSoulRegistry() │
└─────────────────────────────────────────────────┘
           ↑                      ↑
           │                      │
    GetSoul()          UpdateSoulStatus(),
  (full brain)          SaveSoul()
           │                      │
┌──────────────────────┐   ┌──────────────────────┐
│ DTNPCManager         │   │ DTNPCManager         │
│ (Active Tracking)    │   │ (Status Changes)     │
│ ├─ Data by UUID      │   │ ├─ Death             │
│ ├─ OutfitIDToUUID    │   │ ├─ Away Transitions  │
│ └─ Position Updates  │   │ └─ Trade Cycles      │
└──────────────────────┘   └──────────────────────┘
```

### Roster Functions Used

**`DynamicTrading_Roster.GetSoul(uuid)`**
- Returns full NPC brain object
- Used when hydrating from Roster into world
- Location: DynamicTrading_Roster (from Common)

**`DynamicTrading_Roster.SaveSoul(uuid, fullBrain)`**
- Persists brain state back to Roster
- Called when NPC transitions (Resting → Trading → Away → Resting)
- Updates position coordinates before saving

**`DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)`**
- Sets status: "Resting", "Trading", "Away", "Dead"
- Sets transition timers for auto-progression
- Used by Manager when removing/changing NPC state
- File usage:
  - [DTNPC_Manager_Registration.lua:85](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Registration.lua)
  - [DTNPC_Spawn.lua:582](Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua)

### Trade Cycle Automation

```lua
-- File: DTNPC_ManagerRespawn.lua, Lines 235-290
function DTNPCManager.ProcessTradeCycles()
    -- Called every 30 seconds
    -- For each Resting NPC:
    --   if faction_trading_percent < 40% (default):
    --     1 in 2000 chance (~1/min) to start trade mission
    --       → SetStatus("Away") + set return time
    
    -- When returnTime expires:
    -- ProcessAwayTransitions() triggers:
    --   Away → Pick random trading building in faction town
    --       → Set status "Trading" + stay duration
    --   Trading → After stay duration → Set status "Away"
    --   Away → After walk duration → Set status "Resting" (back home)
end
```

---

## 7. KEY CONFIGURATION CONSTANTS

| Constant | Value | Purpose | File |
|----------|-------|---------|------|
| `RESPAWN_RANGE` | 100 tiles | Proximity trigger for NPC spawning | ManagerRespawn.lua:12 |
| `TICK_RATE` | 20 ticks | Update frequency for position tracking | Manager_Tick.lua:6 |
| `POSITION_BROADCAST_RATE` | 120 ticks | Position update frequency (~6 sec) | Manager_Tick.lua:8 |
| `RESPAWN_CHECK_RATE` | 60 ticks | Proximity check frequency (~3 sec) | Manager_Tick.lua:10 |
| `TRANSITION_CHECK_RATE` | 600 ticks | Away/Trading cycle check (~30 sec) | Manager_Tick.lua:12 |
| `SPAWN_SEARCH_RADIUS` | 15 tiles | Max distance to search for safe spawn square | Spawn.lua:240 |
| `NPCTradingStayHours` | 4.0 (default) | How long NPC stays at trading location | Sandbox vars |
| `NPCTradingWalkHours` | 1.0 (default) | How long walk-home takes | Sandbox vars |
| `NPCTradePopPercent` | 40% (default) | % of faction that can trade simultaneously | ManagerRespawn.lua:245 |

---

## 8. FILE STRUCTURE SUMMARY

### Server Side (lua/server/)
```
DT/V2/NPC/
├── Manager/
│   ├── DTNPC_Manager.lua              # Bootstrap, Tables, Helpers
│   ├── DTNPC_Manager_Registration.lua # NPC Registration/Removal
│   ├── DTNPC_ManagerRespawn.lua      # Proximity checks, transitions
│   ├── DTNPC_Manager_Tick.lua         # Main tick loop
│   ├── DTNPC_Manager_SaveLoad.lua     # Persistence
│   └── DTNPC_Manager_UUID.lua         # UUID helpers
├── ServerCore/
│   ├── DTNPC_ServerCore.lua           # Bootstrap
│   ├── DTNPC_ServerCore_Spawn.lua     # Core spawn logic
│   ├── DTNPC_ServerCore_Respawn.lua   # Core respawn logic
│   ├── DTNPC_ServerCore_Sync.lua      # Sync functions
│   ├── DTNPC_ServerCore_Commands.lua  # Client command handlers
│   ├── DTNPC_ServerCore_Summon.lua    # Teleport logic
│   └── DTNPC_ServerCore_Utilities.lua # Helpers
└── DTNPC_Spawn.lua                    # Legacy interface (delegates to ServerCore)
```

### Client Side (lua/client/)
```
DT/V2/NPC/
├── DTNPC_ClientNetwork.lua   # Network command receivers
├── DTNPC_ClientCache.lua     # NPC cache/brain storage
├── DTNPC_ClientSync.lua      # Sync coordination
├── DTNPC_ClientVisuals.lua   # Appearance/outfit application
├── DTNPC_ClientEvents.lua    # Event handlers
├── DTNPC_ChatMenu.lua        # Dialog system
├── DTNPC_TradingHandler.lua  # Trading interaction
└── UI/
    └── DTNPC_TraderDialogue_Hub.lua
```

---

## 9. KEY IMPLEMENTATION PATTERNS

### Pattern 1: UUID-Based Tracking
```lua
-- Every zombie has unique UUID in modData.DTNPC_UUID
-- Maps to outfit ID via DTNPCManager.OutfitIDToUUID[outfitID]
-- Allows respawn with same NPC (new outfit ID, same UUID)

local uuid = brain.uuid
DTNPCManager.Data[uuid] = brain            -- Add to tracker
DTNPCManager.OutfitIDToUUID[outfitID] = uuid -- For reverse lookup
```

### Pattern 2: Proximity Hydration
```lua
-- NPCs not in proximity are stored only in Roster
-- No physical zombie exists
-- When player approaches within 100 tiles:
--   CheckRosterSpawns() detects
--   Fetches from Roster via GetSoul()
--   Spawns physical zombie via RespawnNPC()
--   Registers in DTNPCManager.Data
```

### Pattern 3: Dual Persistence
```lua
-- Server memory: DTNPCManager.Data[uuid] (runtime list)
-- Disk storage: ModData("DTNPC_GlobalList").NPCs[uuid] (saved)
-- Roster: ModData("DynamicTrading_Roster").Souls[uuid] (cross-mod reference)

-- On save: DTNPCManager.Data → DTNPC_GlobalList
-- On load: DTNPC_GlobalList → DTNPCManager.Data
-- Roster always has override/backup
```

### Pattern 4: Visual ID Refresh
```lua
-- Respawn generates new visualID: brain.visualID = ZombRand(1000000)
-- Sent to client in SyncNPC
-- Client detects change and forces visual reapplication
-- Ensures cosmetics persist across respawns
```

### Pattern 5: Async State Transitions
```lua
-- Status changes (Resting → Trading → Away → Resting) happen over time
-- Not instant teleport; uses game-time timers
-- Transitions can be observed/interrupted if player is nearby

-- Example: NPC goes "Away" for 4 hours, then "Trading" for 2 hours
-- If player approaches during "Trading": NPC spawns at trading location
```

---

## 10. NETWORK MESSAGE EXAMPLES

### SyncNPC (Spawn/Update)
```lua
{
    uuid = "550e8400-e29b-41d4-a716-446655440000",
    outfitID = 12345,
    x = 100, y = 200, z = 0,
    brain = {
        uuid = "550e8400-e29b-41d4-a716-446655440000",
        name = "Bob",
        isFemale = false,
        state = "Guard",
        tasks = {},
        lastX = 100, lastY = 200, lastZ = 0,
        visualID = 654321,
        health = 100,
        status = "Resting",
        ...
    }
}
```

### UpdatePosition (Broadcast)
```lua
{
    uuid = "550e8400-e29b-41d4-a716-446655440000",
    outfitID = 12345,
    x = 101, y = 201, z = 0,
    health = 95,
    state = "Guard"
}
```

### RemoveNPC (Cleanup)
```lua
{
    uuid = "550e8400-e29b-41d4-a716-446655440000",
    outfitID = 12345,
    name = "Bob"
}
```

### SyncAllNPCs (Initial Sync)
```lua
{
    npcs = {
        ["uuid1"] = {brain object},
        ["uuid2"] = {brain object},
        ...
    }
}
```

---

## Summary

**DynamicTrading V2 Architecture:**
1. **Persistent**: NPCs stored in DynamicTrading_Roster (Souls) across saves
2. **Proximity-Based**: NPCs spawn when players come within 100 tiles
3. **Resource-Efficient**: Unloaded NPCs exist only in data, not in-world
4. **Event-Driven**: Status changes trigger transitions (Resting → Trading → Away)
5. **Network-Safe**: All state changes synced to all clients via sendServerCommand
6. **Resilient**: UUID-based tracking survives respawns and outfit changes

**Key Systems**:
- `DTNPCManager`: Active world tracking (runtime)
- `DynamicTrading_Roster`: Persistent NPC registry (disk)
- `DTNPCSpawn`: Public API for spawning
- `DTNPCServerCore`: Core implementations
- `DTNPCClient`: Client-side receivers and cache
