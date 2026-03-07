# DynamicTrading V2 - Final Optimization Implementation Plan

**Target Scale**: 50 players / 300 NPCs  
**Visibility**: Strict (only nearby players get updates)  
**Join Strategy**: Nearby full sync + Far metadata (for Pokedex/Radar)  
**Priority**: Network Bandwidth First  
**Implementation**: Tier-by-tier with validation (4-week timeline)

---

## CONFIGURATION CONSTANTS

### Broadcast Ranges (Tuned for 50 players / 300 NPCs)

```lua
DTNPCManager.BROADCAST_RANGES = {
    SPAWN_TRIGGER = 100,    -- Proximity to spawn NPC (unchanged)
    CLOSE = 200,            -- Position updates (frequent)
    MEDIUM = 350,           -- State changes, full syncs
    FAR = 500,              -- Initial awareness, rare updates
    METADATA_ONLY = 1000    -- Gossip/Radar metadata range
}
```

**Rationale:**
- CLOSE (200): Ensures smooth experience for players actively near NPCs
- MEDIUM (350): Buffer for behavioral changes without pop-in
- FAR (500): Extended awareness for Radar system
- METADATA_ONLY (1000): Pokedex/gossip system coverage

### Update Frequencies

```lua
-- Position updates (distance-based throttling)
POSITION_BROADCAST_RATES = {
    CLOSE = 240,      -- Every 12 sec (with interpolation)
    MEDIUM = 600,     -- Every 30 sec
    FAR = 1200,       -- Every 60 sec
    METADATA = -1     -- No position updates, only state changes
}

-- Check frequencies (optimized for 300 NPCs)
RESPAWN_CHECK_RATE = 60         -- Every 3 sec (unchanged)
TRANSITION_CHECK_RATE = 600     -- Every 30 sec (unchanged)
```

### Network Message Sizes

```lua
-- Target sizes for 50 players / 300 NPCs
MESSAGE_BUDGETS = {
    SIMPLE_SPAWN = 500,       -- bytes: UUID, name, position, appearance
    DELTA_UPDATE = 150,       -- bytes: UUID + changed fields only
    FULL_BRAIN = 2500,        -- bytes: Complete brain (use sparingly)
    METADATA_SYNC = 300,      -- bytes: Pokedex/Radar data
    POSITION_UPDATE = 400     -- bytes: Position + velocity + state
}
```

---

## FAR NPC METADATA SPECIFICATION

### For Pokedex/Gossip System & Radar

When player joins, send **two-tier sync**:

**Tier A: Nearby NPCs (within 200 tiles)** - Full Simple Sync
```lua
{
    syncType = "SIMPLE",
    uuid = "...",
    outfitID = 12345,
    name = "Bob",
    x = 100, y = 100, z = 0,
    isFemale = false,
    visualID = 654321,
    state = "Guard",
    archetypeID = "Soldier",
    factionID = "militia_01",
    portraitID = 42,
    status = "Resting"
}
```

**Tier B: Far NPCs (200-1000 tiles)** - Metadata Only
```lua
{
    syncType = "METADATA",
    uuid = "...",
    name = "Alice",
    archetypeID = "Doctor",
    factionID = "hospital_faction",
    factionName = "Riverside Medical",
    isFemale = true,
    portraitID = 88,
    status = "Trading",
    lastX = 800, lastY = 600, lastZ = 0,
    -- NO: outfitID, visualID, state, tasks, trading history, inventory
}
```

**Why This Works:**
- Faction UI can render portraits and names ✓
- Radar can calculate distance and show status ✓
- Pokedex can list discovered NPCs ✓
- No unnecessary data (tasks, inventory) ✓
- Player gets aware of world without bandwidth cost ✓

---

## TIER 1: DISTANCE-AWARE BROADCASTING (Week 1-2)

### Priority: CRITICAL - 60-70% bandwidth reduction

### Phase 1.1: Distance Filtering Infrastructure

**Goal**: Stop broadcasting to all players; only send to nearby ones

#### Step 1.1.1: Create Broadcast Manager

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Broadcast.lua` (NEW)

```lua
-- ============================================
-- Distance-Aware Broadcasting Utilities
-- Optimized for 50 players / 300 NPCs
-- ============================================

if not DTNPCManager then DTNPCManager = {} end

-- CONFIGURATION (Tuned for your scale)
DTNPCManager.BROADCAST_RANGES = {
    SPAWN_TRIGGER = 100,    -- Proximity to spawn NPC (unchanged)
    CLOSE = 200,            -- Position updates frequently
    MEDIUM = 350,           -- State changes, full syncs
    FAR = 500,              -- Extended awareness
    METADATA_ONLY = 1000    -- Gossip/Radar metadata
}

-- ============================================
-- Function: Get players in range of position
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
            
            -- STRICT visibility: Player must be on same floor OR adjacent
            if ignoreZ or math.abs(dz) <= 1 then
                if horizontalDist <= maxDist then
                    table.insert(nearbyPlayers, {
                        player = player,
                        playerNum = i,
                        distance = horizontalDist,
                        distanceBucket = DTNPCManager.GetDistanceBucket(horizontalDist)
                    })
                end
            end
        end
    end
    
    return nearbyPlayers
end

-- ============================================
-- Function: Categorize distance for update frequency
-- ============================================
function DTNPCManager.GetDistanceBucket(dist)
    if dist <= DTNPCManager.BROADCAST_RANGES.CLOSE then
        return "CLOSE"
    elseif dist <= DTNPCManager.BROADCAST_RANGES.MEDIUM then
        return "MEDIUM"
    elseif dist <= DTNPCManager.BROADCAST_RANGES.FAR then
        return "FAR"
    else
        return "METADATA"
    end
end

-- ============================================
-- Function: Send command to specific players only
-- ============================================
function DTNPCManager.SendToNearbyPlayers(module, command, data, x, y, z, maxDist)
    local nearbyPlayers = DTNPCManager.GetPlayersInRange(x, y, z, maxDist, false)
    
    for _, nearby in ipairs(nearbyPlayers) do
        sendServerCommand(nearby.player, module, command, data)
    end
    
    -- Telemetry (for monitoring)
    if DTNPC_BANDWIDTH_TRACKING then
        DTNPCManager.RecordBroadcast(command, #nearbyPlayers, getNumPlayers())
    end
    
    return #nearbyPlayers
end

-- ============================================
-- Function: Smart broadcast with distance awareness
-- ============================================
function DTNPCManager.BroadcastSmart(module, command, data, x, y, z)
    local broadcastRange = DTNPCManager.BROADCAST_RANGES.MEDIUM
    
    -- Adjust range based on command type
    if command == "UpdatePosition" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.CLOSE
    elseif command == "SyncNPC" or command == "UpdateNPC" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.MEDIUM
    elseif command == "RemoveNPC" then
        broadcastRange = DTNPCManager.BROADCAST_RANGES.FAR
    end
    
    return DTNPCManager.SendToNearbyPlayers(module, command, data, x, y, z, broadcastRange)
end

-- ============================================
-- TELEMETRY (Optional but recommended)
-- ============================================
DTNPC_Stats = DTNPC_Stats or {
    messagesSent = 0,
    messagesAvoided = 0,
    lastResetTime = 0,
    byCommand = {}
}

function DTNPCManager.RecordBroadcast(command, sentCount, totalPlayers)
    DTNPC_Stats.messagesSent = DTNPC_Stats.messagesSent + sentCount
    DTNPC_Stats.messagesAvoided = DTNPC_Stats.messagesAvoided + (totalPlayers - sentCount)
    
    DTNPC_Stats.byCommand[command] = DTNPC_Stats.byCommand[command] or {sent = 0, avoided = 0}
    DTNPC_Stats.byCommand[command].sent = DTNPC_Stats.byCommand[command].sent + sentCount
    DTNPC_Stats.byCommand[command].avoided = DTNPC_Stats.byCommand[command].avoided + (totalPlayers - sentCount)
end

function DTNPCManager.PrintBandwidthReport()
    if not DTNPC_BANDWIDTH_TRACKING then return end
    
    local currentTime = getGameTime():getWorldAgeHours()
    if currentTime - DTNPC_Stats.lastResetTime < 1 then return end -- Every hour
    
    print("\n=== DTNPC BANDWIDTH REPORT ===")
    print("Time: " .. currentTime .. " hours")
    print("Active NPCs: " .. DTNPCManager.GetActiveCount())
    print("Players: " .. getNumPlayers())
    print("---")
    print("Messages Sent: " .. DTNPC_Stats.messagesSent)
    print("Messages Avoided: " .. DTNPC_Stats.messagesAvoided)
    local efficiency = 0
    if (DTNPC_Stats.messagesSent + DTNPC_Stats.messagesAvoided) > 0 then
        efficiency = (DTNPC_Stats.messagesAvoided / (DTNPC_Stats.messagesSent + DTNPC_Stats.messagesAvoided)) * 100
    end
    print("Bandwidth Savings: " .. string.format("%.1f", efficiency) .. "%")
    print("==============================\n")
    
    -- Reset counters
    DTNPC_Stats.messagesSent = 0
    DTNPC_Stats.messagesAvoided = 0
    DTNPC_Stats.lastResetTime = currentTime
end

function DTNPCManager.GetActiveCount()
    local count = 0
    for _ in pairs(DTNPCManager.Data or {}) do count = count + 1 end
    return count
end
```

#### Step 1.1.2: Update SyncToAllClients

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
    local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
    
    -- NOTE: This will use SyncSimpleNPC in Phase 1.2
    -- For now, still using full brain but distance-filtered
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = x,
        y = y,
        z = z,
        brain = brain
    }
    
    if isServer() then
        -- OPTIMIZATION: Only send to nearby players (strict visibility)
        local playersSent = DTNPCManager.BroadcastSmart("DTNPC", "SyncNPC", syncData, x, y, z)
        
        if DTNPC_DEBUG_BROADCASTS then
            print("[DTNPC] SyncNPC(" .. brain.name .. "): Sent to " .. playersSent .. "/" .. getNumPlayers() .. " players")
        end
    else
        -- Single-player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", syncData)
    end
end
```

#### Step 1.1.3: Update BroadcastPosition

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
        -- OPTIMIZATION: Only send to close players (200 tiles)
        local playersSent = DTNPCManager.BroadcastSmart("DTNPC", "UpdatePosition", posData, x, y, z)
        
        -- Detailed debug (disable in production)
        if DTNPC_DEBUG_BROADCASTS and DTNPC_DEBUG_VERBOSE then
            print("[DTNPC] UpdatePosition(" .. brain.name .. "): " .. playersSent .. " players")
        end
    else
        sendServerCommand("DTNPC", "UpdatePosition", posData)
    end
end
```

### Phase 1.2: Delta Sync Variants

**Goal**: Reduce message sizes by 60-80%

#### Step 1.2.1: Create Sync Variants

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Add before existing SyncToAllClients** (around line 10-15):

```lua
-- ============================================
-- SYNC VARIANTS: Optimized for 50 players / 300 NPCs
-- ============================================

-- Simple sync: For initial spawn (500 bytes vs 2-3 KB)
function DTNPCSpawn.SyncSimpleNPC(zombie, brain)
    return {
        syncType = "SIMPLE",
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        name = brain.name,
        isFemale = brain.isFemale,
        visualID = brain.visualID,
        state = brain.state,
        archetypeID = brain.archetypeID or "General",
        factionID = brain.factionID or "Independent",
        portraitID = brain.portraitID or 1,
        status = brain.status or "Resting"
    }
end

-- Metadata sync: For far NPCs (300 bytes, no visuals)
-- Used for Pokedex/Gossip/Radar systems
function DTNPCSpawn.SyncMetadataNPC(brain)
    return {
        syncType = "METADATA",
        uuid = brain.uuid,
        name = brain.name,
        archetypeID = brain.archetypeID or "General",
        factionID = brain.factionID or "Independent",
        factionName = brain.factionName or "Independent",
        isFemale = brain.isFemale,
        portraitID = brain.portraitID or 1,
        status = brain.status or "Resting",
        lastX = brain.lastX,
        lastY = brain.lastY,
        lastZ = brain.lastZ or 0
    }
end

-- Delta sync: For incremental updates (150 bytes)
function DTNPCSpawn.SyncDeltaBrain(uuid, outfitID, changedFields)
    return {
        syncType = "DELTA",
        uuid = uuid,
        outfitID = outfitID,
        changes = changedFields  -- Only: {state = "Guard", health = 95}
    }
end

-- Full sync: For critical updates only (2-3 KB, use sparingly)
function DTNPCSpawn.SyncFullBrain(zombie, brain)
    return {
        syncType = "FULL",
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        brain = brain  -- Complete object
    }
end
```

#### Step 1.2.2: Update SyncToAllClients to Use Simple Sync

**Same file, update the function you just modified**:

**Find**:
```lua
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = x,
        y = y,
        z = z,
        brain = brain
    }
```

**Replace with**:
```lua
    -- Use SIMPLE sync for spawns (500 bytes instead of 2-3 KB)
    local syncData = DTNPCSpawn.SyncSimpleNPC(zombie, brain)
```

#### Step 1.2.3: Create Client Handlers for Sync Variants

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Find** (around OnServerCommand handler for "SyncNPC"):
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
    local syncType = args.syncType or "FULL"  -- Backward compatibility
    
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
            archetypeID = args.archetypeID,
            factionID = args.factionID,
            portraitID = args.portraitID,
            status = args.status,
            syncType = "SIMPLE"
        }
        DTNPCClient.CacheBrain(args.uuid, args.outfitID, cacheEntry)
        
        local zombie = DTNPCClient.FindZombieByUUID(args.uuid)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, cacheEntry)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
        
    elseif syncType == "METADATA" then
        -- Metadata sync: For Pokedex/Radar (far NPCs)
        -- Don't try to find zombie (not spawned), just cache for UI
        local metadataEntry = {
            uuid = args.uuid,
            name = args.name,
            archetypeID = args.archetypeID,
            factionID = args.factionID,
            factionName = args.factionName,
            isFemale = args.isFemale,
            portraitID = args.portraitID,
            status = args.status,
            lastX = args.lastX,
            lastY = args.lastY,
            lastZ = args.lastZ,
            syncType = "METADATA",
            isMetadataOnly = true  -- Flag for UI systems
        }
        DTNPCClient.CacheMetadata(args.uuid, metadataEntry)
        
        -- Notify Radar/Faction UI of new metadata
        if DT_V2_RadarManager and DT_V2_RadarManager.OnMetadataReceived then
            DT_V2_RadarManager.OnMetadataReceived(args.uuid, metadataEntry)
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
                -- Only reapply visuals if appearance changed
                if args.changes.visualID or args.changes.state then
                    DTNPCClient.ApplyVisualsToNPC(zombie, cached)
                end
            end
        end
        
    else  -- syncType == "FULL" or legacy
        -- Full sync: Replace entire entry (legacy compatibility)
        DTNPCClient.CacheBrain(args.uuid, args.outfitID, args.brain)
        local zombie = DTNPCClient.FindZombieByUUID(args.uuid)
        if zombie then
            DTNPCClient.ApplyVisualsToNPC(zombie, args.brain)
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
    end
end
```

#### Step 1.2.4: Add Metadata Cache Handler

**Same file, add new function**:

```lua
-- ============================================
-- METADATA CACHE: For far NPCs (Pokedex/Radar)
-- ============================================
DTNPCClient.MetadataCache = DTNPCClient.MetadataCache or {}

function DTNPCClient.CacheMetadata(uuid, metadata)
    DTNPCClient.MetadataCache[uuid] = metadata
    
    if DTNPC_DEBUG_SYNC then
        print("[DTNPC Client] Cached metadata for: " .. (metadata.name or "Unknown") .. " [" .. uuid .. "]")
    end
end

function DTNPCClient.GetMetadata(uuid)
    return DTNPCClient.MetadataCache[uuid]
end

function DTNPCClient.GetAllMetadata()
    return DTNPCClient.MetadataCache
end
```

### Phase 1.3: Testing & Validation

**Test Environment:**
- 10 NPCs spread across map (100-1000 tiles apart)
- 5 test players at different locations

**Test Checklist:**
- [ ] Enable `DTNPC_BANDWIDTH_TRACKING = true`
- [ ] Enable `DTNPC_DEBUG_BROADCASTS = true`
- [ ] Spawn 10 NPCs, verify only nearby players get SyncNPC
- [ ] Have players move around, verify position updates only to close players
- [ ] Check console for bandwidth report (should show 60-80% messages avoided)
- [ ] Verify no desyncs (all players see NPCs when they should)
- [ ] Check Faction UI still works
- [ ] Check Radar still shows far NPCs

**Expected Results:**
- With 5 players and 10 NPCs spread: 60-80% reduction in SyncNPC messages
- Position updates: 80-90% reduction (only close players)
- No visual bugs or desyncs

---

## TIER 2: CLIENT-SIDE OPTIMIZATION (Week 2-3)

### Priority: HIGH - Additional 20-30% reduction + smoother experience

### Phase 2.1: Client-Side Position Interpolation

**Goal**: Reduce position update frequency by 50% while maintaining smooth movement

#### Step 2.1.1: Add Velocity to Position Updates

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/DTNPC_Spawn.lua`

**Find BroadcastPosition** (you modified it in Phase 1):

**Replace with**:
```lua
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
    local vel = zombie:getVelocity() or {x = 0, y = 0, z = 0}
    
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = x,
        y = y,
        z = z,
        health = zombie:getHealth(),
        state = brain.state,
        -- NEW: Velocity for client-side interpolation
        velX = vel.x or 0,
        velY = vel.y or 0,
        velZ = vel.z or 0,
        timestamp = getGameTime():getWorldAgeHours()
    }
    
    if isServer() then
        local playersSent = DTNPCManager.BroadcastSmart("DTNPC", "UpdatePosition", posData, x, y, z)
        
        if DTNPC_DEBUG_BROADCASTS and DTNPC_DEBUG_VERBOSE then
            print("[DTNPC] UpdatePosition(" .. brain.name .. "): " .. playersSent .. " players")
        end
    else
        sendServerCommand("DTNPC", "UpdatePosition", posData)
    end
end
```

#### Step 2.1.2: Create Client Interpolation System

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientInterpolation.lua` (NEW)

```lua
-- ============================================
-- Client-Side NPC Position Interpolation
-- Predicts NPC movement between server updates
-- Optimized for 50 players / 300 NPCs
-- ============================================

if not DTNPCClient then DTNPCClient = {} end

DTNPCClient.Interpolation = {
    enabled = true,
    updateFrequency = 12,  -- Server updates every 12 seconds (reduced from 6)
    smoothFactor = 0.4,     -- Blend factor for position correction
    positions = {}  -- {uuid → {x, y, z, velX, velY, lastUpdate, etc.}}
}

-- ============================================
-- Function: Store interpolation data on position update
-- ============================================
function DTNPCClient.UpdatePositionWithInterpolation(uuid, x, y, z, velX, velY, timestamp)
    if not DTNPCClient.Interpolation.enabled then return end
    
    local data = DTNPCClient.Interpolation.positions[uuid] or {}
    
    -- Store previous position for smoothing
    data.prevX = data.x or x
    data.prevY = data.y or y
    data.prevZ = data.z or z
    
    -- Store new target position
    data.x = x
    data.y = y
    data.z = z
    data.velX = velX or 0
    data.velY = velY or 0
    data.velZ = velZ or 0
    data.timestamp = timestamp or getGameTime():getWorldAgeHours()
    data.lastUpdateTime = getGameTime():getWorldAgeHours()
    
    DTNPCClient.Interpolation.positions[uuid] = data
    
    if DTNPC_DEBUG_INTERPOLATION then
        print("[DTNPC Interp] Updated " .. uuid .. ": pos=[" .. x .. "," .. y .. "] vel=[" .. velX .. "," .. velY .. "]")
    end
end

-- ============================================
-- Function: Get interpolated position (called every tick)
-- ============================================
function DTNPCClient.GetInterpolatedPosition(uuid)
    local data = DTNPCClient.Interpolation.positions[uuid]
    if not data then return nil end
    
    local currentTime = getGameTime():getWorldAgeHours()
    local timeDelta = currentTime - data.lastUpdateTime
    
    -- Predict position using velocity
    local predictedX = data.x + (data.velX * timeDelta * 3600)  -- Convert hours to seconds
    local predictedY = data.y + (data.velY * timeDelta * 3600)
    
    -- Confidence decay: Less confident as time passes
    local updateInterval = DTNPCClient.Interpolation.updateFrequency / 3600  -- Convert sec to hours
    local confidence = 1.0 - math.min(1.0, timeDelta / updateInterval)
    
    return {
        x = predictedX,
        y = predictedY,
        z = data.z,
        confidence = confidence
    }
end

-- ============================================
-- Function: Apply interpolation to zombie (called each tick)
-- ============================================
function DTNPCClient.ApplyInterpolation(uuid, zombie)
    if not DTNPCClient.Interpolation.enabled then return end
    
    local interpPos = DTNPCClient.GetInterpolatedPosition(uuid)
    if not interpPos then return end
    
    -- Only apply if confidence is reasonable
    if interpPos.confidence < 0.1 then return end
    
    local currentX, currentY = zombie:getX(), zombie:getY()
    
    -- Smooth movement toward predicted position
    local smoothFactor = DTNPCClient.Interpolation.smoothFactor
    local newX = currentX + (interpPos.x - currentX) * smoothFactor
    local newY = currentY + (interpPos.y - currentY) * smoothFactor
    
    -- Only update if movement is significant (avoid jitter)
    local moveDist = math.sqrt((newX - currentX)^2 + (newY - currentY)^2)
    if moveDist > 0.1 then
        zombie:setX(newX)
        zombie:setY(newY)
        
        if DTNPC_DEBUG_INTERPOLATION and DTNPC_DEBUG_VERBOSE then
            print("[DTNPC Interp] Applied to " .. uuid .. ": [" .. newX .. "," .. newY .. "] confidence=" .. interpPos.confidence)
        end
    end
end

-- ============================================
-- Function: Cleanup old interpolation data
-- ============================================
function DTNPCClient.CleanupInterpolation(uuid)
    DTNPCClient.Interpolation.positions[uuid] = nil
end

-- ============================================
-- Function: Clear all interpolation data (on disconnect)
-- ============================================
function DTNPCClient.ClearAllInterpolation()
    DTNPCClient.Interpolation.positions = {}
end
```

#### Step 2.1.3: Update Client Network Handler for Interpolation

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Find** (in OnServerCommand):
```lua
if command == "UpdatePosition" then
    local uuid = args.uuid
    local cached = DTNPCClient.NPCCache[uuid]
    
    if cached then
        cached.brain.lastX = args.x
        cached.brain.lastY = args.y
        cached.brain.state = args.state
        
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie then
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
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
        
        -- NEW: Store interpolation data
        if DTNPCClient.Interpolation and DTNPCClient.Interpolation.enabled then
            DTNPCClient.UpdatePositionWithInterpolation(
                uuid, args.x, args.y, args.z,
                args.velX, args.velY, args.timestamp
            )
        end
        
        -- Find and update zombie (initial positioning)
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie then
            -- Set to server position immediately, interpolation will smooth from here
            DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
        end
    end
end
```

#### Step 2.1.4: Add Interpolation Tick Handler

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientEvents.lua`

**Add** (or create file if doesn't exist):

```lua
require "DT/V2/NPC/DTNPC_ClientInterpolation"

-- ============================================
-- Tick handler for position interpolation
-- ============================================
local function OnTick()
    if not DTNPCClient.Interpolation or not DTNPCClient.Interpolation.enabled then return end
    
    -- Apply interpolation to all active NPCs
    for uuid, npcData in pairs(DTNPCClient.NPCCache or {}) do
        local zombie = DTNPCClient.FindZombieByUUID(uuid)
        if zombie and not zombie:isRemoving() then
            DTNPCClient.ApplyInterpolation(uuid, zombie)
        end
    end
end

Events.OnTick.Add(OnTick)

-- Cleanup on disconnect
local function OnDisconnect()
    if DTNPCClient.ClearAllInterpolation then
        DTNPCClient.ClearAllInterpolation()
    end
end

Events.OnDisconnect.Add(OnDisconnect)
```

#### Step 2.1.5: Reduce Position Broadcast Frequency

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Tick.lua`

**Find**:
```lua
POSITION_BROADCAST_RATE = 120 ticks  -- Every 6 seconds
```

**Change to**:
```lua
-- OPTIMIZATION: Reduced frequency with client-side interpolation
-- From 6 seconds → 12 seconds (50% reduction in messages)
POSITION_BROADCAST_RATE = 240 ticks  -- Every 12 seconds (20 ticks/sec)
```

### Phase 2.2: Initial Sync Distance Filtering

**Goal**: Eliminate join bandwidth spike, enable Pokedex/Radar with metadata

#### Step 2.2.1: Update Client Initial Sync Request

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
    
    -- OPTIMIZATION: Two-tier sync strategy
    -- Tier A: Full sync for nearby NPCs (200 tiles)
    -- Tier B: Metadata only for far NPCs (200-1000 tiles) for Pod edex/Radar
    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = player:getX(),
        y = player:getY(),
        z = player:getZ(),
        nearRadius = 200,      -- Full sync radius
        metadataRadius = 1000  -- Metadata-only radius (for gossip/radar)
    })
    
    if DTNPC_DEBUG_SYNC then
        print("[DTNPC Client] Requesting tiered sync: near=200, metadata=1000")
    end
end
```

#### Step 2.2.2: Add Server Handler for Tiered Sync

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/ServerCore/DTNPC_ServerCore_Commands.lua`

**Find** (command handlers section):
```lua
if command == "RequestFullSync" then
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
end
```

**Replace with (or add after)**:
```lua
-- NEW: Two-tier distance-filtered sync (for 50 players / 300 NPCs)
if command == "RequestNearbySync" then
    local playerX = args.x
    local playerY = args.y
    local playerZ = args.z
    local nearRadius = args.nearRadius or 200
    local metadataRadius = args.metadataRadius or 1000
    
    local nearbyNPCs = {}    -- Full simple sync
    local metadataNPCs = {}  -- Metadata only (Pokedex/Radar)
    
    for uuid, brain in pairs(DTNPCManager.Data or {}) do
        local npcX = brain.lastX
        local npcY = brain.lastY
        local npcZ = brain.lastZ
        
        if npcX and npcY then
            local dx = npcX - playerX
            local dy = npcY - playerY
            local dz = npcZ - playerZ
            local dist = math.sqrt(dx*dx + dy*dy)
            
            -- Same floor or adjacent
            if math.abs(dz) <= 1 then
                if dist <= nearRadius then
                    -- Tier A: Full simple sync (for spawning)
                    local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
                    if zombie then
                        nearbyNPCs[uuid] = DTNPCSpawn.SyncSimpleNPC(zombie, brain)
                    end
                elseif dist <= metadataRadius then
                    -- Tier B: Metadata only (for Pokedex/Radar)
                    metadataNPCs[uuid] = DTNPCSpawn.SyncMetadataNPC(brain)
                end
            end
        end
    end
    
    -- Send tiered sync
    sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {
        nearby = nearbyNPCs,
        metadata = metadataNPCs,
        playerPos = {x = playerX, y = playerY, z = playerZ},
        nearRadius = nearRadius,
        metadataRadius = metadataRadius
    })
    
    print("[DTNPC] Initial sync for " .. (player:getUsername() or "player") .. ": " .. 
          countTable(nearbyNPCs) .. " nearby, " .. countTable(metadataNPCs) .. " metadata")
end

-- Legacy support (still available for debugging)
if command == "RequestFullSync" then
    print("[DTNPC] WARNING: Legacy RequestFullSync used. Recommend using RequestNearbySync.")
    sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
end

-- Helper function
function countTable(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do count = count + 1 end
    return count
end
```

#### Step 2.2.3: Add Client Handler for Tiered Sync

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Add in OnServerCommand**:

```lua
if command == "SyncNearbyNPCs" then
    -- NEW: Two-tier sync response
    local nearbyCount = 0
    local metadataCount = 0
    
    -- Process nearby NPCs (full simple sync)
    for uuid, npcData in pairs(args.nearby or {}) do
        DTNPCClient.CacheBrain(uuid, npcData.outfitID, npcData)
        nearbyCount = nearbyCount + 1
    end
    
    -- Process metadata NPCs (far, for Pokedex/Radar)
    for uuid, metadata in pairs(args.metadata or {}) do
        DTNPCClient.CacheMetadata(uuid, metadata)
        metadataCount = metadataCount + 1
        
        -- Notify Radar/Faction systems
        if DT_V2_RadarManager and DT_V2_RadarManager.OnMetadataReceived then
            DT_V2_RadarManager.OnMetadataReceived(uuid, metadata)
        end
    end
    
    if DTNPC_DEBUG_SYNC then
        print("[DTNPC Client] Received tiered sync: " .. nearbyCount .. " nearby, " .. metadataCount .. " metadata")
    end
end
```

### Phase 2.3: Testing & Validation

**Test Environment:**
- 50 NPCs spread across map
- 10 test players

**Test Checklist:**
- [ ] Enable interpolation: `DTNPCClient.Interpolation.enabled = true`
- [ ] Test player join: should receive 10-15 nearby + 30-40 metadata
- [ ] Verify NPC movement is smooth despite 12-sec updates
- [ ] Open Faction UI: should show all metadata NPCs
- [ ] Open Radar: should show distance to far NPCs
- [ ] Check join time: should be < 5 seconds
- [ ] Monitor bandwidth: should see 70-85% total reduction vs baseline

**Expected Results:**
- Join data: 200-600 KB → 40-80 KB (80-90% reduction)
- Smooth NPC movement despite half the update frequency
- Faction UI/Radar fully functional with metadata

---

## TIER 3: SCALABILITY ENHANCEMENTS (Week 3-4)

### Priority: MEDIUM - Additional 10-15% + better CPU usage

### Phase 3.1: Smart Distance-Based Update Frequency

**Goal**: Further reduce updates based on distance tiers

#### Step 3.1.1: Distance-Aware Broadcast Timing

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Tick.lua`

**Add new function**:

```lua
-- ============================================
-- Smart broadcast: Adjust frequency by distance
-- ============================================
function DTNPCManager.ShouldBroadcastPosition(uuid, currentTick)
    local brain = DTNPCManager.Data[uuid]
    if not brain then return false end
    
    local lastBroadcast = brain.lastPositionBroadcast or 0
    local ticksSince = currentTick - lastBroadcast
    
    -- Get nearest player distance
    local minDist = 9999
    for i = 0, getNumPlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local dx = brain.lastX - player:getX()
            local dy = brain.lastY - player:getY()
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < minDist then minDist = dist end
        end
    end
    
    -- Distance-based throttling
    if minDist <= DTNPCManager.BROADCAST_RANGES.CLOSE then
        -- Close: Every 12 sec (240 ticks)
        return ticksSince >= 240
    elseif minDist <= DTNPCManager.BROADCAST_RANGES.MEDIUM then
        -- Medium: Every 30 sec (600 ticks)
        return ticksSince >= 600
    elseif minDist <= DTNPCManager.BROADCAST_RANGES.FAR then
        -- Far: Every 60 sec (1200 ticks)
        return ticksSince >= 1200
    else
        -- Very far: No position updates (metadata only)
        return false
    end
end
```

**In main tick loop, replace uniform broadcast**:

**Find**:
```lua
if DTNPCManager.tickCount % POSITION_BROADCAST_RATE == 0 then
    for uuid, brain in pairs(DTNPCManager.Data) do
        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if zombie then
            DTNPCSpawn.BroadcastPosition(zombie, brain)
        end
    end
end
```

**Replace with**:
```lua
-- Smart broadcast: Check each NPC individually for distance-based timing
for uuid, brain in pairs(DTNPCManager.Data) do
    if DTNPCManager.ShouldBroadcastPosition(uuid, DTNPCManager.tickCount) then
        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if zombie then
            DTNPCSpawn.BroadcastPosition(zombie, brain)
            brain.lastPositionBroadcast = DTNPCManager.tickCount
        end
    end
end
```

### Phase 3.2: Message Batching

**Goal**: Reduce network overhead by batching small updates

#### Step 3.2.1: Create Batch Queue

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_Manager_Broadcast.lua`

**Add**:

```lua
-- ============================================
-- MESSAGE BATCHING (for position updates)
-- ============================================
DTNPCManager.BatchQueue = {}

function DTNPCManager.QueuePositionUpdate(player, npcUpdate)
    local playerIdx = player:getOnlineID()
    if not DTNPCManager.BatchQueue[playerIdx] then
        DTNPCManager.BatchQueue[playerIdx] = {
            player = player,
            updates = {},
            lastFlush = getGameTime():getWorldAgeHours()
        }
    end
    
    table.insert(DTNPCManager.BatchQueue[playerIdx].updates, npcUpdate)
end

function DTNPCManager.FlushBatchQueue()
    local currentTime = getGameTime():getWorldAgeHours()
    
    for playerIdx, batch in pairs(DTNPCManager.BatchQueue) do
        if #batch.updates > 0 then
            -- Send batched updates (max 10 per batch to avoid huge messages)
            local batchSize = math.min(#batch.updates, 10)
            local toBatch = {}
            for i = 1, batchSize do
                table.insert(toBatch, table.remove(batch.updates, 1))
            end
            
            sendServerCommand(batch.player, "DTNPC", "BatchPositionUpdate", {
                updates = toBatch
            })
            
            if DTNPC_DEBUG_BATCHING then
                print("[DTNPC] Flushed batch: " .. #toBatch .. " updates to player " .. playerIdx)
            end
        end
    end
end

-- Call this in main tick loop every 3 seconds
function DTNPCManager.OnTickBatching()
    if DTNPCManager.tickCount % 60 == 0 then  -- Every 3 seconds
        DTNPCManager.FlushBatchQueue()
    end
end
```

#### Step 3.2.2: Add Client Batch Handler

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/client/DT/V2/NPC/DTNPC_ClientNetwork.lua`

**Add in OnServerCommand**:

```lua
if command == "BatchPositionUpdate" then
    -- Process batch of position updates
    for _, update in ipairs(args.updates or {}) do
        local uuid = update.uuid
        local cached = DTNPCClient.NPCCache[uuid]
        
        if cached then
            cached.brain.lastX = update.x
            cached.brain.lastY = update.y
            cached.brain.state = update.state
            
            if DTNPCClient.Interpolation and DTNPCClient.Interpolation.enabled then
                DTNPCClient.UpdatePositionWithInterpolation(
                    uuid, update.x, update.y, update.z,
                    update.velX, update.velY, update.timestamp
                )
            end
            
            local zombie = DTNPCClient.FindZombieByUUID(uuid)
            if zombie then
                DTNPCClient.ReconcilePosition(zombie, update.x, update.y, update.z)
            end
        end
    end
    
    if DTNPC_DEBUG_BATCHING then
        print("[DTNPC Client] Processed batch: " .. #(args.updates or {}) .. " updates")
    end
end
```

### Phase 3.3: CPU Optimization for CheckRosterSpawns

**Goal**: Reduce O(n²) complexity for 300 NPCs

#### Step 3.3.1: Spatial Partitioning for Proximity Checks

**File**: `Contents/mods/DynamicTradingV2/42.13/media/lua/server/DT/V2/NPC/Manager/DTNPC_ManagerRespawn.lua`

**Before CheckRosterSpawns, add helper**:

```lua
-- ============================================
-- OPTIMIZATION: Spatial hash for faster proximity checks
-- ============================================
function DTNPCManager.BuildPlayerSpatialHash()
    local hash = {}
    local cellSize = 200  -- 200-tile cells
    
    for i = 0, getNumPlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local cellX = math.floor(px / cellSize)
            local cellY = math.floor(py / cellSize)
            local key = cellX .. "," .. cellY .. "," .. pz
            
            hash[key] = hash[key] or {}
            table.insert(hash[key], {player = player, x = px, y = py, z = pz})
        end
    end
    
    return hash, cellSize
end

function DTNPCManager.GetNearbyPlayersFromHash(hash, cellSize, npcX, npcY, npcZ, maxDist)
    local cellX = math.floor(npcX / cellSize)
    local cellY = math.floor(npcY / cellSize)
    
    local nearbyPlayers = {}
    
    -- Check NPC's cell and 8 adjacent cells
    for dx = -1, 1 do
        for dy = -1, 1 do
            local key = (cellX + dx) .. "," .. (cellY + dy) .. "," .. npcZ
            local cellPlayers = hash[key] or {}
            
            for _, pdata in ipairs(cellPlayers) do
                local dist = math.sqrt((npcX - pdata.x)^2 + (npcY - pdata.y)^2)
                if dist <= maxDist then
                    table.insert(nearbyPlayers, {player = pdata.player, distance = dist})
                end
            end
        end
    end
    
    return nearbyPlayers
end
```

**Update CheckRosterSpawns**:

**Find**:
```lua
function DTNPCManager.CheckRosterSpawns()
    -- For each soul in roster
    for uuid, soul in pairs(DynamicTrading_Roster.Souls) do
        -- For each player
        for i = 0, getNumPlayers() - 1 do
            -- Calculate distance...
        end
    end
end
```

**Replace with**:
```lua
function DTNPCManager.CheckRosterSpawns()
    -- Build spatial hash once per check (O(players))
    local playerHash, cellSize = DTNPCManager.BuildPlayerSpatialHash()
    
    -- Check each soul against hash (O(souls × log(players)))
    for uuid, soul in pairs((DynamicTrading_Roster and DynamicTrading_Roster.Souls) or {}) do
        -- Only check souls marked for spawning
        if soul.status == "Resting" or soul.status == "Working" or soul.status == "Trading" then
            -- Skip if already in manager
            if not DTNPCManager.Data[uuid] then
                local npcX = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                local npcY = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                local npcZ = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
                
                if npcX and npcY then
                    -- Use spatial hash for O(1) average lookup
                    local nearbyPlayers = DTNPCManager.GetNearbyPlayersFromHash(
                        playerHash, cellSize, npcX, npcY, npcZ, RESPAWN_RANGE
                    )
                    
                    if #nearbyPlayers > 0 then
                        -- Spawn near closest player
                        table.sort(nearbyPlayers, function(a, b) return a.distance < b.distance end)
                        local brain = DynamicTrading_Roster.GetSoul(uuid)
                        if brain then
                            DTNPCServerCore.RespawnNPC(brain, uuid, nearbyPlayers[1].player)
                        end
                    end
                end
            end
        end
    end
end
```

---

## MONITORING & VALIDATION

### Enable Debug Flags

**File**: Any server-side file (e.g., DTNPC_Manager.lua)

```lua
-- Debug flags (set at top of file or in sandbox options)
DTNPC_BANDWIDTH_TRACKING = true      -- Track message counts
DTNPC_DEBUG_BROADCASTS = false        -- Log every broadcast (verbose)
DTNPC_DEBUG_VERBOSE = false           -- Even more verbose
DTNPC_DEBUG_SYNC = true               -- Log sync events
DTNPC_DEBUG_INTERPOLATION = false     -- Log interpolation (client)
DTNPC_DEBUG_BATCHING = false          -- Log message batching
```

### Bandwidth Report (Auto-Generated)

**Called automatically every hour in DTNPC_Manager_Tick.lua**:

```lua
if DTNPCManager.tickCount % 72000 == 0 then  -- Every hour
    DTNPCManager.PrintBandwidthReport()
end
```

**Sample Output**:
```
=== DTNPC BANDWIDTH REPORT ===
Time: 48.5 hours
Active NPCs: 87
Players: 12
---
Messages Sent: 1245
Messages Avoided: 8932
Bandwidth Savings: 87.8%
==============================
```

### Performance Metrics to Track

```lua
-- Add to DTNPC_Stats table
DTNPC_Stats.Performance = {
    checkRosterTime = 0,        -- ms spent in CheckRosterSpawns
    checkRespawnTime = 0,       -- ms spent in CheckForRespawn
    broadcastTime = 0,          -- ms spent broadcasting
    interpolationTime = 0       -- ms spent on client interpolation (client-side)
}

-- Example usage in CheckRosterSpawns:
local startTime = os.clock()
-- ... do check ...
DTNPC_Stats.Performance.checkRosterTime = (os.clock() - startTime) * 1000
```

---

## TESTING PROTOCOL

### Week 1-2: Tier 1 Validation

**Environment**: 10 NPCs, 5 players

**Tests:**
1. **Distance filtering**: Players 50, 200, 500 tiles from NPC
   - Expected: 50 = updates, 200 = updates, 500 = no updates
2. **Message size**: Compare SyncNPC size before/after
   - Expected: 2-3 KB → 500 bytes (75% reduction)
3. **Bandwidth tracking**: Enable tracking, run for 1 hour
   - Expected: 60-70% messages avoided

**Pass Criteria:**
- [ ] No desyncs
- [ ] 60%+ bandwidth reduction
- [ ] All UI systems work (Faction, Radar)

### Week 2-3: Tier 2 Validation

**Environment**: 50 NPCs, 10 players

**Tests:**
1. **Interpolation smoothness**: Watch NPC movement
   - Expected: Smooth despite 12-sec updates
2. **Initial sync**: Player joins
   - Expected: < 5 seconds, 10-15 nearby + 30-40 metadata
3. **Metadata systems**: Open Faction UI/Radar
   - Expected: All far NPCs visible in lists

**Pass Criteria:**
- [ ] Smooth NPC movement
- [ ] Join time < 5 seconds
- [ ] 80%+ total bandwidth reduction
- [ ] Pokedex/Radar fully functional

### Week 3-4: Tier 3 + Stress Testing

**Environment**: 300 NPCs, 50 players

**Tests:**
1. **Distance-based throttling**: Monitor update frequencies
   - Expected: Close NPCs = 12s, Medium = 30s, Far = 60s
2. **CPU usage**: Monitor CheckRosterSpawns time
   - Expected: < 10ms per check (was 50+ ms without spatial hash)
3. **Scalability**: Concurrent players joining/leaving
   - Expected: No lag spikes, stable performance

**Pass Criteria:**
- [ ] Server handles 50 players smoothly
- [ ] CheckRosterSpawns < 10ms
- [ ] 85-90% bandwidth reduction
- [ ] No desyncs under load

---

## ROLLBACK PLAN

If issues occur, disable optimizations incrementally:

### Level 1: Disable Interpolation
```lua
DTNPCClient.Interpolation.enabled = false
-- In DTNPC_Manager_Tick.lua:
POSITION_BROADCAST_RATE = 120  -- Revert to 6 seconds
```

### Level 2: Disable Distance Filtering
```lua
-- In DTNPC_Spawn.lua, revert all BroadcastSmart calls:
sendServerCommand("DTNPC", "SyncNPC", syncData)  -- Broadcast to all
```

### Level 3: Disable Delta Sync
```lua
-- In SyncToAllClients, use full brain:
local syncData = DTNPCSpawn.SyncFullBrain(zombie, brain)
```

### Level 4: Disable Tiered Initial Sync
```lua
-- In DTNPC_ClientVisuals.lua:
sendClientCommand(player, "DTNPC", "RequestFullSync", {})  -- Legacy mode
```

---

## EXPECTED FINAL RESULTS

### Bandwidth Comparison (50 players / 300 NPCs)

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Player Join Data** | 400-800 KB | 40-80 KB | **90%** ↓ |
| **Position Updates/Player** | 300 KB/min | 30 KB/min | **90%** ↓ |
| **State Change Size** | 2-3 KB | 150 bytes | **95%** ↓ |
| **Server Outbound (total)** | 15 MB/min | 1.5 MB/min | **90%** ↓ |
| **Join Time** | 30-60 sec | 3-5 sec | **83%** ↓ |

### CPU Comparison

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| CheckRosterSpawns (300 NPCs) | 50-100 ms | 5-10 ms | **90%** ↓ |
| BroadcastPosition (per NPC) | 50 players | 5-10 players | **80%** ↓ |

### Scalability

- **Current Breaking Point**: 20 concurrent players
- **After Optimization**: 50+ concurrent players
- **Improvement**: **2.5x** capacity increase

---

## CONFIGURATION TUNING

### If Server Still Struggles

**Reduce broadcast ranges**:
```lua
DTNPCManager.BROADCAST_RANGES = {
    CLOSE = 150,   -- Was 200
    MEDIUM = 250,  -- Was 350
    FAR = 350      -- Was 500
}
```

**Reduce update frequency further**:
```lua
POSITION_BROADCAST_RATES = {
    CLOSE = 360,      -- Every 18 sec (was 12)
    MEDIUM = 900,     -- Every 45 sec (was 30)
    FAR = 1800        -- Every 90 sec (was 60)
}
```

### If NPCs Feel Sluggish

**Increase interpolation smoothing**:
```lua
DTNPCClient.Interpolation.smoothFactor = 0.6  -- Was 0.4 (more aggressive)
```

**Increase close-range update frequency**:
```lua
POSITION_BROADCAST_RATES.CLOSE = 180  -- Every 9 sec (was 12)
```

---

## FINAL CHECKLIST

### Before Production Deploy

- [ ] All Tier 1 tests passed
- [ ] All Tier 2 tests passed
- [ ] All Tier 3 tests passed (if implemented)
- [ ] Bandwidth report shows 85%+ savings
- [ ] No desyncs in 100+ hour test
- [ ] Faction UI works with metadata
- [ ] Radar works with metadata
- [ ] Pokedex/gossip systems functional
- [ ] Client interpolation smooth
- [ ] Join time < 5 seconds
- [ ] Server handles 50 concurrent players
- [ ] Documentation updated
- [ ] Rollback plan tested

---

## QUESTIONS?

**Common Questions:**

**Q: What if Faction UI doesn't show far NPCs?**  
A: Check that `DTNPCClient.CacheMetadata()` is being called and `DT_FactionInfoWindow` is reading from `DTNPCClient.MetadataCache`.

**Q: What if Radar distance calculation is wrong?**  
A: Verify `lastX/lastY/lastZ` fields are in metadata sync and that `DT_V2_RadarManager.GetTraderCoords()` checks metadata cache.

**Q: What if interpolation causes jitter?**  
A: Try increasing `smoothFactor` from 0.4 to 0.6-0.8 for more aggressive smoothing.

**Q: What if messages still too large?**  
A: Check that `SyncSimpleNPC` is being used for spawns, not `SyncFullBrain`. Also verify no accidental double-sending.

**Q: Performance still bad with 300 NPCs?**  
A: Verify spatial hash is being used in `CheckRosterSpawns`. Should drop from O(n²) to O(n log n).

---

## SUPPORT CONTACT

If you encounter issues during implementation:
1. Enable all debug flags
2. Capture console output for 5 minutes
3. Check bandwidth report
4. Review test results vs expected
5. Try incremental rollback to isolate issue

---

**END OF IMPLEMENTATION PLAN**

This plan will transform your mod from breaking at 20 players to smoothly handling 50+ players while reducing bandwidth by 90%. Good luck with implementation!
