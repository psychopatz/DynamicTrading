# DynamicTrading V2 - Optimization Implementation Guide

**Detailed Code Examples & Implementation Steps**

---

## QUICK START CHECKLIST

**Before Starting:**
- [ ] Backup current mod files
- [ ] Create branch: `optimization/tier1-distance-aware`
- [ ] Set up test server with 10 NPCs, 5 players
- [ ] Install bandwidth monitoring tool (or use manual logging)

---

## TIER 1: DISTANCE-AWARE BROADCASTING

### Step 1.1.1: Create Helper Function

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Broadcast.lua` (NEW)

```lua
-- ============================================
-- Distance-Aware Broadcasting Utilities
-- ============================================

if not DTNPCManager then DTNPCManager = {} end

-- Configuration
DTNPCManager.BROADCAST_RANGES = {
    CLOSE = 150,      -- Send to all clients within 150 tiles
    MEDIUM = 300,     -- 300 tiles for full state updates
    FAR = 500,        -- 500 tiles for sparse updates
}

-- ============================================
-- Function: Get players in range of NPC
-- ============================================
function DTNPCManager.GetPlayersInRange(x, y, z, maxDist, ignoreZ)
    local nearbyPlayers = {}
    
    for i = 0, getNumPlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local dx = x - px
            local dy = y - py
            local dz = z - pz
            
            local horizontalDist = math.sqrt(dx*dx + dy*dy)
            
            -- Check Z-axis (allow player 1 floor different)
            if ignoreZ or math.abs(dz) <= 1 then
                if horizontalDist <= maxDist then
                    table.insert(nearbyPlayers, {
                        player = player,
                        playerNum = i,
                        distance = horizontalDist
                    })
                end
            end
        end
    end
    
    return nearbyPlayers
end

-- ============================================
-- Function: Send to specific players only
-- ============================================
function DTNPCManager.SendToNearbyPlayers(module, command, data, x, y, z, maxDist)
    local nearbyPlayers = DTNPCManager.GetPlayersInRange(x, y, z, maxDist, false)
    
    for _, nearby in ipairs(nearbyPlayers) do
        sendServerCommand(nearby.player, module, command, data)
    end
    
    return #nearbyPlayers  -- Return count for monitoring
end

-- ============================================
-- Function: Send to all players (fallback)
-- ============================================
function DTNPCManager.SendToAllPlayers(module, command, data)
    sendServerCommand("DTNPC", module, command, data)
end

-- ============================================
-- Function: Smart broadcast with telemetry
-- ============================================
function DTNPCManager.BroadcastCommandWithTelemetry(module, command, data, x, y, z)
    local numPlayers = getNumPlayers()
    local broadcastRange = DTNPCManager.BROADCAST_RANGES.CLOSE
    local playersSent = 0
    
    if numPlayers == 0 then return end
    
    -- For position updates, use smart range; for state changes, use wider range
    if command == "UpdatePosition" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.CLOSE
    elseif command == "SyncNPC" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.MEDIUM
    elseif command == "UpdateNPC" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.MEDIUM
    end
    
    playersSent = DTNPCManager.SendToNearbyPlayers(module, command, data, x, y, z, broadcastRange)
    
    -- Telemetry (optional - can be logged)
    if DTNPC_BANDWIDTH_TRACKING then
        DTNPC_Stats = DTNPC_Stats or {}
        DTNPC_Stats.lastBroadcast = {
            command = command,
            playersInRange = playersSent,
            totalPlayers = numPlayers,
            range = broadcastRange,
            timestamp = getGameTime()
        }
    end
    
    return playersSent
end

```

### Step 1.1.2: Update SyncToAllClients

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Find** (around line 18-45):
```lua
function DTNPCSpawn.SyncToAllClients(zombie, brain)
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    if isServer() then
        sendServerCommand("DTNPC", "SyncNPC", syncData)
    else
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
end
```

**Replace with**:
```lua
function DTNPCSpawn.SyncToAllClients(zombie, brain)
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    if isServer() then
        -- OPTIMIZATION: Send only to nearby players
        local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
        local playersNotified = DTNPCManager.SendToNearbyPlayers(
            "DTNPC", "SyncNPC", syncData, x, y, z,
            DTNPCManager.BROADCAST_RANGES.MEDIUM
        )
        
        -- Debug logging (disable in production)
        if DTNPC_DEBUG_BROADCASTS then
            print("[DTNPC] SyncNPC: Notified " .. playersNotified .. "/" .. getNumPlayers() .. " players")
        end
    else
        -- Single player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
end
```

### Step 1.1.3: Update BroadcastPosition

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Find** (around line 78-98):
```lua
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

**Replace with**:
```lua
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
    
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = x,
        y = y,
        z = z,
        health = zombie:getHealth(),
        state = brain.state
    }
    
    if isServer() then
        -- OPTIMIZATION: Send only to nearby players
        local playersNotified = DTNPCManager.SendToNearbyPlayers(
            "DTNPC", "UpdatePosition", posData, x, y, z,
            DTNPCManager.BROADCAST_RANGES.CLOSE  -- Tighter range for frequent updates
        )
        
        if DTNPC_DEBUG_BROADCASTS then
            print("[DTNPC] UpdatePosition(" .. brain.name .. "): " .. playersNotified .. " players")
        end
    else
        sendServerCommand("DTNPC", "UpdatePosition", posData)
    end
end
```

### Step 1.1.4: Update SyncToPlayer

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Find** (around line 48-75):
```lua
function DTNPCSpawn.SyncToPlayer(player, zombie, brain)
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain
    }
    
    sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
end
```

**Add new function after it**:
```lua
-- New helper function
function DTNPCSpawn.SyncToNearbyPlayers(zombie, brain)
    return DTNPCManager.BroadcastCommandWithTelemetry(
        "DTNPC", "SyncNPC",
        {
            uuid = brain.uuid,
            outfitID = zombie:getPersistentOutfitID(),
            x = zombie:getX(),
            y = zombie:getY(),
            z = zombie:getZ(),
            brain = brain
        },
        zombie:getX(), zombie:getY(), zombie:getZ()
    )
end
```

### Step 1.1.5: Test Distance-Aware Broadcasting

**Test Steps:**
1. Create 10 NPCs across map (spread 500+ tiles apart)
2. Have Player A stand near NPC #1, Player B stand near NPC #10
3. Spawn both NPCs
4. Enable debug logging: `DTNPC_DEBUG_BROADCASTS = true`
5. Check console output:
   - Both syncs should show "Notified 1/2 players" (each player gets only relevant NPC)
   - Without optimization: Would show "Notified 2/2 players"

**Expected Result**: ~50% reduction in SyncNPC messages

---

## TIER 1.2: DELTA/PARTIAL SYNCHRONIZATION

### Step 1.2.1: Create Sync Variants

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Add new functions** (before existing SyncToAllClients):

```lua
-- ============================================
-- SYNC VARIANTS: Optimized message payloads
-- ============================================

-- Light sync: For initial spawn, only essential fields
function DTNPCSpawn.SyncSimpleNPC(zombie, brain)
    local syncData = {
        syncType = "SIMPLE",  -- Flag to indicate message format
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        name = brain.name,
        isFemale = brain.isFemale,
        visualID = brain.visualID,
        state = brain.state,
        -- Don't include: full brain, tasks[], trading history, etc.
    }
    return syncData
end

-- Full sync: For state changes or complete updates
function DTNPCSpawn.SyncFullBrain(zombie, brain)
    local syncData = {
        syncType = "FULL",  -- Flag to indicate message format
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain  -- Full object
    }
    return syncData
end

-- Delta sync: For incremental updates
function DTNPCSpawn.SyncDeltaBrain(uuid, outfitID, changedFields)
    local syncData = {
        syncType = "DELTA",  -- Flag to indicate message format
        uuid = uuid,
        outfitID = outfitID,
        changes = changedFields  -- Only: {state = "Guard", health = 95}
    }
    return syncData
end
```

### Step 1.2.2: Update Spawn to Use SyncSimple

**Find in DTNPC_Spawn.lua**, the call to `DTNPCSpawn.SyncToAllClients(zombie, brain)` in spawn logic (typically in `DTNPCServerCore_Spawn.lua`):

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/ServerCore/DTNPC_ServerCore_Spawn.lua`

Look for lines spawning the NPC and syncing to clients, then modify:

```lua
-- OLD (if used):
-- DTNPCSpawn.SyncToAllClients(zombie, brain)

-- NEW: Use simple sync for initial spawn
local syncData = DTNPCSpawn.SyncSimpleNPC(zombie, brain)
DTNPCManager.SendToNearbyPlayers(
    "DTNPC", "SyncNPC", syncData,
    zombie:getX(), zombie:getY(), zombie:getZ(),
    DTNPCManager.BROADCAST_RANGES.MEDIUM
)
```

### Step 1.2.3: Create Client Handler for Sync Variants

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Find** (around the OnServerCommand handler):
```lua
if command == "SyncNPC" then
    DTNPCClient.CacheBrain(uuid, outfitID, args.brain)
    local zombie = DTNPCClient.FindZombieByUUID(uuid)
    -- ... apply visuals, reconcile position
end
```

**Replace with**:
```lua
if command == "SyncNPC" then
    local syncType = args.syncType or "FULL"  -- Default to full for backwards compatibility
    
    if syncType == "SIMPLE" then
        -- Lightweight sync: Create basic cache entry
        local cacheEntry = {
            uuid = args.uuid,
            outfitID = args.outfitID,
            name = args.name,
            isFemale = args.isFemale,
            visualID = args.visualID,
            state = args.state,
            x = args.x,
            y = args.y,
            z = args.z,
            syncType = "SIMPLE"
        }
        DTNPCClient.CacheBrain(args.uuid, args.outfitID, cacheEntry)
        
        local zombie = DTNPCClient.FindZombieByUUID(args.uuid)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, cacheEntry)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
        
    elseif syncType == "DELTA" then
        -- Incremental update: Merge changes
        local cached = DTNPCClient.NPCCache[args.uuid]
        if cached then
            for k, v in pairs(args.changes) do
                cached[k] = v
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(args.uuid)
            if zombie then
                DTNPCClient.ApplyVisualsToNPC(zombie, cached)
            end
        end
        
    else  -- syncType == "FULL"
        -- Full sync: Replace entire entry
        DTNPCClient.CacheBrain(args.uuid, args.outfitID, args.brain)
        local zombie = DTNPCClient.FindZombieByUUID(args.uuid)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
    end
end
```

### Step 1.2.4: Measure Bandwidth Savings

**Create bandwidth logging** in `DTNPC_Manager_Tick.lua`:

```lua
-- Add at top of file
DTNPC_BANDWIDTH_LOG = {}

-- Add to main tick function (every 60 seconds)
function DTNPCManager.LogBandwidth()
    if DTNPCManager.tickCount % 1200 == 0 then  -- Every 60 seconds (20 ticks/sec × 60)
        local stats = {
            timestamp = getGameTime(),
            activeNPCs = 0,
            playerCount = getNumPlayers(),
            estimatedBandwidthPerMin = "TBD"  -- Calculate based on message counts
        }
        
        for uuid, _ in pairs(DTNPCManager.Data) do
            stats.activeNPCs = stats.activeNPCs + 1
        end
        
        print("[DTNPC] Bandwidth Report:")
        print("  Active NPCs: " .. stats.activeNPCs)
        print("  Players: " .. stats.playerCount)
        print("  Time: " .. stats.timestamp)
    end
end
```

### Step 1.2.5: Test Delta Sync

**Test Steps:**
1. Spawn NPC and observe SyncNPC message (should use SIMPLE, ~500 bytes)
2. Change NPC state (from "Guard" to "Trading")
3. Check if state change uses DELTA message (~100 bytes instead of 2-3 KB)
4. Compare bandwidth in logs

**Expected Result**: 60-70% reduction in state change message size

---

## TIER 2.1: CLIENT-SIDE POSITION INTERPOLATION

### Step 2.1.1: Add Velocity Tracking

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Update BroadcastPosition to include velocity**:

```lua
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
    local vel = zombie:getVelocity()
    
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = x,
        y = y,
        z = z,
        health = zombie:getHealth(),
        state = brain.state,
        -- NEW: Add velocity for client-side interpolation
        velX = vel.x or 0,
        velY = vel.y or 0,
        velZ = vel.z or 0,
        timestamp = getGameTime()  -- For sync validation
    }
    
    if isServer() then
        local playersNotified = DTNPCManager.SendToNearbyPlayers(
            "DTNPC", "UpdatePosition", posData, x, y, z,
            DTNPCManager.BROADCAST_RANGES.CLOSE
        )
    else
        sendServerCommand("DTNPC", "UpdatePosition", posData)
    end
end
```

### Step 2.1.2: Implement Client-Side Interpolation

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientInterpolation.lua` (NEW)

Create this new file:

```lua
-- ============================================
-- Client-Side NPC Position Interpolation
-- ============================================

if not DTNPCClient then DTNPCClient = {} end

DTNPCClient.Interpolation = {
    enabled = true,
    updateFrequency = 12,  -- Update every 12 seconds (changed from 6)
    positions = {}  -- {uuid → {x, y, z, velX, velY, velZ, lastUpdate}}
}

-- ============================================
-- Function: Update NPC position with interpolation data
-- ============================================
function DTNPCClient.UpdatePositionWithInterpolation(uuid, x, y, z, velX, velY, timestamp)
    if not DTNPCClient.Interpolation.enabled then
        -- Fallback to non-interpolated if disabled
        return
    end
    
    DTNPCClient.Interpolation.positions[uuid] = {
        x = x,
        y = y,
        z = z,
        velX = velX or 0,
        velY = velY or 0,
        velZ = velZ or 0,
        targetX = x,
        targetY = y,
        timestamp = timestamp or getGameTime(),
        interpStartTime = getGameTime()
    }
end

-- ============================================
-- Function: Get interpolated position
-- Predicts where NPC should be between updates
-- ============================================
function DTNPCClient.GetInterpolatedPosition(uuid)
    local data = DTNPCClient.Interpolation.positions[uuid]
    if not data then return nil end
    
    local currentTime = getGameTime()
    local timeDelta = (currentTime - data.interpStartTime) * 0.05  -- Convert ticks to seconds
    
    -- Linear interpolation with velocity
    local interpX = data.x + (data.velX * timeDelta)
    local interpY = data.y + (data.velY * timeDelta)
    
    return {
        x = interpX,
        y = interpY,
        z = data.z,
        confidence = math.min(1.0, timeDelta / 12)  -- Decay confidence over time
    }
end

-- ============================================
-- Function: Apply interpolated position to zombie
-- ============================================
function DTNPCClient.ApplyInterpolation(uuid, zombie)
    if not DTNPCClient.Interpolation.enabled then return end
    
    local interpPos = DTNPCClient.GetInterpolatedPosition(uuid)
    if not interpPos then return end
    
    -- Only apply if we have reasonable confidence
    if interpPos.confidence < 0.1 then return end
    
    -- Smooth movement toward target position
    -- Use setX/setY for smooth interpolation (don't teleport)
    local lastX, lastY = zombie:getX(), zombie:getY()
    
    -- Apply partial movement (smoothing)
    local smoothFactor = 0.3  -- Blend 30% of interpolated position
    local newX = lastX + (interpPos.x - lastX) * smoothFactor
    local newY = lastY + (interpPos.y - lastY) * smoothFactor
    
    -- Only update if movement is significant
    local moveDist = math.sqrt((newX - lastX)^2 + (newY - lastY)^2)
    if moveDist > 0.1 then
        zombie:setX(newX)
        zombie:setY(newY)
    end
end

-- ============================================
-- Function: Clear old interpolation data (garbage collection)
-- ============================================
function DTNPCClient.CleanupInterpolation(uuid)
    DTNPCClient.Interpolation.positions[uuid] = nil
end
```

### Step 2.1.3: Update Client Network Handler

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Find** (the UpdatePosition handler):
```lua
if command == "UpdatePosition" then
    local cached = DTNPCClient.NPCCache[uuid]
    if cached then
        cached.brain.lastX = args.x
        cached.brain.lastY = args.y
        cached.brain.state = args.state
        -- Reconcile position with in-world zombie
    end
end
```

**Replace with**:
```lua
if command == "UpdatePosition" then
    local uuid = args.uuid
    local cached = DTNPCClient.NPCCache[uuid]
    
    if cached then
        -- Update cache
        cached.brain.lastX = args.x
        cached.brain.lastY = args.y
        cached.brain.state = args.state
        
        -- NEW: Add interpolation data
        if DTNPCClient.Interpolation and DTNPCClient.Interpolation.enabled then
            DTNPCClient.UpdatePositionWithInterpolation(
                uuid, args.x, args.y, args.z,
                args.velX, args.velY, args.timestamp
            )
        end
        
        -- Find and update zombie
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie then
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
    end
end
```

### Step 2.1.4: Add Interpolation Tick

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientEvents.lua`

**Add to tick events** (or create one if doesn't exist):

```lua
Events.OnTick.Add(function()
    if DTNPCClient.Interpolation and DTNPCClient.Interpolation.enabled then
        for uuid, npcData in pairs(DTNPCClient.NPCCache) do
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            if zombie and not zombie:isRemoving() then
                DTNPCClient.ApplyInterpolation(uuid, zombie)
            end
        end
    end
end)
```

### Step 2.1.5: Reduce Position Broadcast Frequency

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Tick.lua`

**Find**:
```lua
POSITION_BROADCAST_RATE = 120 ticks  -- Every 6 seconds
```

**Change to**:
```lua
-- OPTIMIZATION: Reduced frequency with client-side interpolation
POSITION_BROADCAST_RATE = 240 ticks  -- Every 12 seconds (was 6)
```

### Step 2.1.6: Test Interpolation

**Test Steps:**
1. Spawn NPC with interpolation enabled
2. Move NPC around (observe movement)
3. Disable interpolation and compare: movement should be "choppier"
4. Re-enable and confirm smooth movement
5. Monitor bandwidth: Should see ~50% reduction in positio updates

**Expected Result**: Smooth NPC movement despite half the update frequency

---

## TIER 2.2: INITIAL SYNC DISTANCE FILTERING

### Step 2.2.1: Update Client Initial Sync Request

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientVisuals.lua`

**Find**:
```lua
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)

function DTNPCClient.RequestInitialSync(playerNum)
    local player = getSpecificPlayer(playerNum)
    sendClientCommand(player, "DTNPC", "RequestFullSync", {})
end
```

**Replace with**:
```lua
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)

function DTNPCClient.RequestInitialSync(playerNum)
    local player = getSpecificPlayer(playerNum)
    
    -- OPTIMIZATION: Request only nearby NPCs
    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = player:getX(),
        y = player:getY(),
        z = player:getZ(),
        radius = 200  -- Load NPCs within 200 tiles
    })
end
```

### Step 2.2.2: Add Server Handler for RequestNearbySync

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/ServerCore/DTNPC_ServerCore_Commands.lua`

**Find** (the command handlers section):
```lua
if command == "RequestFullSync" then
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
end
```

**Add after it**:
```lua
if command == "RequestNearbySync" then
    -- NEW: Distance-filtered initial sync
    local npcsToSync = {}
    local playerX = args.x
    local playerY = args.y
    local playerZ = args.z
    local radius = args.radius or 200
    
    for uuid, brain in pairs(DTNPCManager.Data) do
        local npcX = brain.lastX
        local npcY = brain.lastY
        local npcZ = brain.lastZ
        
        local dx = npcX - playerX
        local dy = npcY - playerY
        local dz = npcZ - playerZ
        local dist = math.sqrt(dx*dx + dy*dy)
        
        -- Only include NPCs within radius and same floor
        if math.abs(dz) <= 1 and dist <= radius then
            npcsToSync[uuid] = brain
        end
    end
    
    sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {
        npcs = npcsToSync,
        playerX = playerX,
        playerY = playerY,
        playerZ = playerZ,
        radius = radius
    })
    
    if DTNPC_DEBUG_SYNC then
        print("[DTNPC] Initial sync for player: " .. #npcsToSync .. " NPCs in range")
    end
end

-- Fallback: Support old RequestFullSync for backwards compatibility
if command == "RequestFullSync" then
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
end
```

### Step 2.2.3: Update Client Handler

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Add handler** (in OnServerCommand):

```lua
if command == "SyncNearbyNPCs" then
    -- NEW: Handle distance-filtered NPCs
    for uuid, brain in pairs(args.npcs or {}) do
        local outfitID = brain.currentOutfitID or 0
        DTNPCClient.CacheBrain(uuid, outfitID, brain)
    end
    
    if DTNPC_DEBUG_SYNC then
        print("[DTNPC] Client received " .. (args.npcs and #args.npcs or 0) .. " nearby NPCs")
    end
end
```

### Step 2.2.4: Test Initial Sync Filtering

**Test Steps:**
1. Create 100 NPCs spread across map
2. Have player join server
3. Check initial data transfer size
4. Without optimization: Should send 200-600 KB
5. With optimization: Should send 20-60 KB

**Expected Result**: ~90% reduction in join spike

---

## MONITORING & DEBUGGING

### Enable Debug Logging

**Add to top of DTNPC files**:

```lua
-- Global debug flags
DTNPC_DEBUG_BROADCASTS = false  -- Enable to see broadcast messages
DTNPC_DEBUG_SYNC = false        -- Enable to see sync messages
DTNPC_BANDWIDTH_TRACKING = true -- Enable bandwidth logging
```

### Create Bandwidth Report

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_BandwidthMonitor.lua` (NEW)

```lua
if not DTNPCManager then DTNPCManager = {} end

DTNPCManager.BandwidthMonitor = {
    enabled = true,
    trackingInterval = 1200,  -- Every 60 seconds
    stats = {
        messagesPerMinute = 0,
        estimatedBandwidthPerMinute = 0,
        syncCallCount = 0,
        broadcastCallCount = 0,
        interpolationActive = false
    }
}

function DTNPCManager.PrintBandwidthReport()
    if not DTNPCManager.BandwidthMonitor.enabled then return end
    
    print("\n=== DTNPC V2 BANDWIDTH REPORT ===")
    print("Timestamp: " .. getGameTime())
    print("Active NPCs: " .. countTable(DTNPCManager.Data))
    print("Players: " .. getNumPlayers())
    print("---")
    print("Messages/Min: " .. DTNPCManager.BandwidthMonitor.stats.messagesPerMinute)
    print("Est. BW/Min: " .. DTNPCManager.BandwidthMonitor.stats.estimatedBandwidthPerMinute .. " KB")
    print("Sync Calls: " .. DTNPCManager.BandwidthMonitor.stats.syncCallCount)
    print("Broadcast Calls: " .. DTNPCManager.BandwidthMonitor.stats.broadcastCallCount)
    print("==================================\n")
end

function countTable(tbl)
    local count = 0
    for _, _ in pairs(tbl) do count = count + 1 end
    return count
end
```

---

## VALIDATION CHECKLIST

### Before Deploying to Production:

- [ ] All existing NPC functionality works (spawn, despawn, trading)
- [ ] Distance-aware broadcasting reduces messages correctly
- [ ] Delta sync works for state changes
- [ ] Client interpolation doesn't cause visual artifacts
- [ ] Initial sync completes within 5 seconds
- [ ] No desyncs between server and clients
- [ ] NPCs can still be seen by all clients who should see them
- [ ] Bandwidth reduced by at least 70% (measured)
- [ ] CPU usage reduced (server-side, especially CheckRosterSpawns)
- [ ] Load tested with 10+ players + 50+ NPCs

---

## TROUBLESHOOTING

### Issue: NPCs not visible to nearby players

**Diagnosis:**
- Check if broadcast range is too small
- Verify distance calculation uses X,Y correctly

**Solution:**
```lua
-- Increase broadcast range temporarily
DTNPCManager.BROADCAST_RANGES.CLOSE = 200  -- Was 150
DTNPCManager.BROADCAST_RANGES.MEDIUM = 350  -- Was 300
```

### Issue: Jerky/Choppy NPC Movement

**Diagnosis:**
- Interpolation enabled but velocity data not included
- Update frequency too low

**Solution:**
```lua
-- Check BroadcastPosition includes velocity
-- Adjust interpolation settings:
DTNPCClient.Interpolation.updateFrequency = 9  -- Increase frequency (tighter updates)
```

### Issue: Initial Sync Takes Too Long

**Diagnosis:**
- Player loading too many far-away NPCs
- Network latency

**Solution:**
```lua
-- Reduce initial sync radius
radius = 150  -- Was 200
-- Or enable progressive loading (load more NPCs as player explores)
```

---

## PERFORMANCE TARGETS

| Metric | Current | Target | Timeline |
|--------|---------|--------|----------|
| Player Join Data | 200-600 KB | <50 KB | Week 2 |
| Position Bandwidth | 300 KB/min | 30 KB/min | Week 2-3 |
| Server CPU (CheckRoster) | High | Low | Week 3 |
| Visible NPC Sync Delay | <1sec | <0.5 sec | Week 3 |

