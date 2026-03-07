# DynamicTrading V2 - Bandwidth & Scalability Optimization Plan

**Current Architecture Review Date**: March 7, 2026  
**Status**: Analysis Complete - Identifying Critical Issues

---

## EXECUTIVE SUMMARY

Your V2 NPC system HAS the hybrid architecture foundation correct in theory, BUT has **significant bandwidth and scalability gaps** that will cause server strain with 10+ NPCs on multi-player servers.

### Critical Finding
- ✅ **What's Implemented Well**: Proximity-based spawning (100-tile range)
- ❌ **Major Gap #1**: No visibility culling on network layer - ALL clients get ALL NPC updates
- ❌ **Major Gap #2**: Full brain objects sent on every spawn/update (no delta compression)
- ❌ **Major Gap #3**: Initial sync (SyncAllNPCs) broadcasts entire roster to joining player
- ❌ **Major Gap #4**: Position broadcasts are uniform (no distance-based throttling)

---

## ISSUE ANALYSIS

### Issue #1: Broadcast-Based Synchronization (Critical)

**Current Implementation:**
```lua
-- DTNPC_Spawn.lua, Line 18-45
sendServerCommand("DTNPC", "SyncNPC", syncData)  -- Sends to ALL clients
```

**Problem:**
- Every NPC spawn/update goes to **ALL players**, even those 500+ tiles away
- Example: Player A at position [100, 100] gets update about NPC at [800, 50] (unreachable)
- With 50 NPCs and 10 players: **500 messages per sync event**, most irrelevant

**Bandwidth Impact:**
- 1 SyncNPC (spawn): ~1-2 KB (full brain object)
- Per NPC spawn: 1-2 KB × number of players
- With 100 NPCs spawning: 100-200 KB per spawn wave
- **Accumulative**: Position updates every 6 sec × 100 NPCs = 100+ broadcasts per minute per player

### Issue #2: Full Brain Object Serialization (High Impact)

**Current Implementation:**
```lua
-- DTNPC_Spawn.lua, Line 25
brain = brain  -- Entire brain table sent
```

**Problem:**
- Brain object contains: uuid, name, state, tasks[], visuals, health, status, faction data, schedule, trading history, etc.
- Estimated size: **1-3 KB per NPC per sync**
- On join (SyncAllNPCs): Sends ALL NPC brains to single player

**Bandwidth Impact:**
- SyncAllNPCs with 100 NPCs: 100-300 KB on player join
- Multiple joins per day: Significant waste
- Unnecessary fields sent (e.g., full task arrays, trading history) on position updates

### Issue #3: Initial Sync Not Distance-Filtered (High Impact)

**Current Implementation:**
```lua
-- DTNPC_ClientVisuals.lua, Line 158
Events.OnCreatePlayer.Add(DTNPCClient.RequestInitialSync)

-- DTNPC_Spawn.lua, Line 519-524
sendServerCommand(player, "DTNPC", "SyncAllNPCs", { npcs = DTNPCManager.Data })
```

**Problem:**
- Player joins server, immediately receives ALL NPCs in existence
- No filter for distance, no filter for "actually in rendered chunks"
- Example: 200 NPCs exist on server, player at spawn gets data for all 200

**Bandwidth Impact:**
- Player join spike: **200-600 KB** depending on NPC count
- Multiplied by concurrent joins during peak hours
- All that data for NPCs that may never be visited

### Issue #4: Uniform Position Broadcast Rate (Medium Impact)

**Current Implementation:**
```lua
-- DTNPC_Manager_Tick.lua, Line 11
POSITION_BROADCAST_RATE = 120 ticks  -- Every 6 seconds, for ALL in-world NPCs
```

**Problem:**
- Every in-world NPC broadcasts position to every player every 6 seconds
- No consideration for distance: NPC 5 tiles away = same update frequency as NPC 100 tiles away
- No consideration for NPC importance or activity level
- Clients receive position updates even when NPC is motionless

**Bandwidth Impact:**
- Per player: 100 position broadcasts/minute (if 10 NPCs nearby)
- Each UpdatePosition: ~300-500 bytes
- **Per player**: 30-50 KB/minute in position updates alone

### Issue #5: No Client-Side Position Interpolation (Medium Impact)

**Current Implementation:**
- Server sends position every 6 seconds
- Client just places NPC at received coordinates
- Creates "teleporting" appearance on low-tick updates

**Problem:**
- Could use client-side interpolation/extrapolation to reduce broadcast frequency
- Instead, server broadcasts constantly to maintain smooth appearance

**Bandwidth Impact:**
- Position broadcast frequency could be halved with interpolation
- **Potential Savings**: 15-25 KB/minute per player

---

## BANDWIDTH CALCULATION EXAMPLE

### Scenario: 50 NPCs, 10 Players, Active Server

**Current Implementation:**
- SyncNPC on spawn: 1-2 KB × 10 players = 10-20 KB per spawn
- UpdatePosition: every 6 sec = 10/min
  - Per update: 300 bytes × 10 NPCs × 10 players = 30 KB per broadcast
  - Per minute: 30 KB × 10 broadcasts = **300 KB/minute**

- Behavioral changes (state change): Once per NPC per cycle (~30 min)
  - 50 NPCs × 2 KB (full brain) × 10 players = **1000 KB** per cycle

**Total: ~300 KB/minute baseline + 1 MB every 30 minutes in state changes**

### Optimized Implementation (with all fixes):
- Distance-culled SyncNPC: 1-2 KB × 3-5 nearby players = 3-10 KB per spawn
- Interpolated position updates: every 12-15 sec (half frequency)
  - 5 nearby NPCs × 300 bytes × 5 nearby players = 7.5 KB per broadcast
  - Per minute: 7.5 KB × 4 broadcasts = **30 KB/minute**

- Delta-synced state changes: 500 bytes × targeted clients = **200-500 KB per cycle**

**Total: ~30 KB/minute baseline + 300 KB every 30 minutes**

**Improvement: ~90% reduction in bandwidth**

---

## ROOT CAUSE ANALYSIS

### Why This Happened

1. **Single-Server Assumption**: Original design assumed 1 server, few players
2. **Conservative Sync**: Broadcast-to-all ensures no client misses updates (simple, safe)
3. **No Visibility Culling**: PZ doesn't have built-in server-side visibility system
4. **Full Object Serialization**: Easier than delta/partial updates (less debugging)

### Why It's a Problem Now

1. **Scaling**: More NPCs + more players = exponential message growth
2. **Network Stack**: Each message goes through sendServerCommand → network serialization → client deserialization
3. **Memory**: Position broadcasts create memory churn on clients
4. **CPU (Server)**: Checking all NPCs × all players every 6 seconds is O(n² players × NPCs)

---

## OPTIMIZATION STRATEGY

### Tier 1: Critical (Implement First)
These provide 50-70% bandwidth reduction and are essential for multi-player servers.

#### 1.1: Distance-Aware Broadcasting
**Concept**: Only send network messages to players who can see the NPC

**Implementation Approach**:
```lua
function DTNPCSpawn.SyncToNearbyPlayers(zombie, brain, maxDistance)
    local broadcastDist = maxDistance or 150  -- Tiles
    local x, y, z = zombie:getX(), zombie:getY(), zombie:getZ()
    
    for i = 0, getNumPlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local dist = math.sqrt((x-px)^2 + (y-py)^2)
            if math.abs(z - pz) <= 1 and dist <= broadcastDist then
                -- Send ONLY to this player (targeted broadcast)
                sendServerCommand(player, "DTNPC", "SyncNPC", syncData)
            end
        end
    end
end
```

**Benefits**:
- Reduces messages by 80-90% in multi-player
- Only relevant clients get updates
- Respects proximity design philosophy

**Changes Required**:
- Replace `sendServerCommand("DTNPC", ...)` with distance check
- Maintain "dirty" flag for in-world NPCs to avoid rechecking stale data
- Add to all sync functions: SyncToAllClients, BroadcastPosition, update operations

#### 1.2: Delta/Partial Synchronization
**Concept**: Send only changed fields, not entire brain object

**Implementation Approach**:
```lua
-- Create sync variants:
function DTNPCSpawn.SyncSimpleNPC(zombie, brain)
    -- For initial spawn, only send:
    local syncData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        visualID = brain.visualID,
        name = brain.name,
        isFemale = brain.isFemale,
        state = brain.state
    }
    return syncData
end

function DTNPCSpawn.SyncFullBrain(zombie, brain)
    -- For full updates (state change), send complete brain
    local syncData = {
        uuid = brain.uuid,
        brain = brain  -- Full object
    }
    return syncData
end

function DTNPCSpawn.SyncDeltaBrain(uuid, changedFields)
    -- For incremental updates: {state = "Guard", health = 95}
    return { uuid = uuid, changes = changedFields }
end
```

**Changes Required**:
- Create sync variants (InitialSync, FullSync, DeltaSync)
- Use InitialSync on spawn (1 KB instead of 2-3 KB)
- Use UpdatePosition for movement (300 bytes)
- Use DeltaSync for state changes (500 bytes instead of 2-3 KB)

**Benefits**:
- 50-60% reduction in message size
- Bandwidth savings compound with distance-aware broadcasting

### Tier 2: Important (Implement Second)
These provide 20-30% additional reduction and improve client-side performance.

#### 2.1: Client-Side Position Interpolation
**Concept**: Client interpolates position between server updates; server broadcasts less frequently

**Implementation Approach**:

*Server Side*:
```lua
function DTNPCSpawn.BroadcastPosition(zombie, brain)
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        velX = zombie:getVelocity().x,  -- Add velocity for interpolation
        velY = zombie:getVelocity().y,
        health = zombie:getHealth(),
        state = brain.state,
        timestamp = getGameTime()  -- Server time for sync
    }
    -- Reduce broadcast frequency: every 12 sec instead of 6 sec
    sendServerCommand("DTNPC", "UpdatePosition", posData)
end
```

*Client Side*:
```lua
function DTNPCClient.InterpolatePosition(uuid, lastPos, targetPos, velocity, timeDelta)
    -- Interpolate position based on timestamp and velocity
    local interpX = lastPos.x + (velocity.x * timeDelta)
    local interpY = lastPos.y + (velocity.y * timeDelta)
    return {x = interpX, y = interpY}
end

-- In OnServerCommand handler:
if command == "UpdatePosition" then
    local cached = DTNPCClient.NPCCache[uuid]
    if cached then
        cached.lastPos = {x = cached.x, y = cached.y}
        cached.x = args.x
        cached.y = args.y
        cached.velocity = {x = args.velX, y = args.velY}
        cached.lastUpdateTime = getGameTime()
    end
end

-- In client tick:
function DTNPCClient.OnTick()
    for uuid, npc in pairs(DTNPCClient.NPCCache) do
        if npc.interpolate then
            local timeSinceUpdate = (getGameTime() - npc.lastUpdateTime) * 0.05  -- Convert ticks to seconds
            local interpPos = DTNPCClient.InterpolatePosition(uuid, npc.lastPos, {x = npc.x, y = npc.y}, npc.velocity, timeSinceUpdate)
            -- Apply interpolated position
        end
    end
end
```

**Benefits**:
- Reduce position broadcast frequency by 50% (6 sec → 12 sec)
- Smooth movement on client-side despite less frequent updates
- Additional 15-25 KB/minute savings per player

#### 2.2: Initial Sync Distance Filtering
**Concept**: Only sync NPCs within playable distance on player join

**Implementation Approach**:
```lua
-- Replace SyncAllNPCs call in DTNPC_ClientNetwork.lua
Events.OnCreatePlayer.Add(function(playerNum)
    local player = getSpecificPlayer(playerNum)
    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = player:getX(),
        y = player:getY(),
        z = player:getZ(),
        radius = 200  -- Load only NPCs within 200 tiles
    })
end)

-- Server handler:
if command == "RequestNearbySync" then
    local npcsToSync = {}
    for uuid, brain in pairs(DTNPCManager.Data) do
        local dx = brain.lastX - args.x
        local dy = brain.lastY - args.y
        local dz = brain.lastZ - args.z
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if math.abs(dz) <= 1 and dist <= args.radius then
            npcsToSync[uuid] = brain
        end
    end
    
    sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {npcs = npcsToSync})
end
```

**Benefits**:
- Eliminates the join spike (200-600 KB → 20-60 KB)
- Defers loading of far NPCs until player gets closer
- Can progressively load NPCs as player explores

### Tier 3: Enhancement (Implement Third)
These provide ongoing improvements and better scalability.

#### 3.1: Smart Update Frequency Based on Distance
**Concept**: NPCs far away get position updates less frequently than nearby ones

**Implementation Approach**:
```lua
function DTNPCSpawn.BroadcastPositionSmart(zombie, brain)
    local posData = {
        uuid = brain.uuid,
        outfitID = zombie:getPersistentOutfitID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        state = brain.state,
        timestamp = getGameTime()
    }
    
    -- Send to all nearby players, with frequency based on distance
    for i = 0, getNumPlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local px, py, pz = player:getX(), player:getY(), player:getZ()
            local dist = math.sqrt((zombie:getX()-px)^2 + (zombie:getY()-py)^2)
            
            if dist <= 150 then
                -- Very close: send every 6 sec (normal)
                DTNPCSpawn.QueueBroadcast(player, posData, BROADCAST_RATE_HIGH)
            elseif dist <= 300 then
                -- Medium distance: send every 12 sec
                DTNPCSpawn.QueueBroadcast(player, posData, BROADCAST_RATE_MEDIUM)
            elseif dist <= 500 then
                -- Far: send every 24 sec or on significant change only
                DTNPCSpawn.QueueBroadcast(player, posData, BROADCAST_RATE_LOW)
            end
        end
    end
end
```

**Benefits**:
- Adaptive update frequency reduces bandwidth for distant NPCs
- Doesn't compromise responsiveness for nearby NPCs
- Can reduce 25-40% of position update traffic

#### 3.2: Server-Side Visibility Frustum
**Concept**: Calculate which clients can actually see an NPC based on chunk loading

**Implementation Approach**:
- Use PZ's chunk management to determine loaded chunks per player
- Only send updates about NPCs in loaded chunks
- Respects game's natural rendering distance

```lua
function DTNPCSpawn.IsNPCVisibleToPlayer(zombie, player)
    local zx, zy = zombie:getX(), zombie:getY()
    local px, py = player:getX(), player:getY()
    
    -- PZ loads chunks roughly 10 chunks (~300 tiles) in each direction
    local VISIBILITY_RANGE = 300
    local dist = math.sqrt((zx-px)^2 + (zy-py)^2)
    
    return dist <= VISIBILITY_RANGE
end
```

#### 3.3: Update Batching
**Concept**: Queue updates and send in batches to reduce message count

**Implementation Approach**:
```lua
DTNPCSpawn.UpdateBatch = {
    [player] = {updates = {}, lastSent = 0}
}

function DTNPCSpawn.QueuePositionUpdate(player, npcUpdate)
    local batch = DTNPCSpawn.UpdateBatch[player]
    table.insert(batch.updates, npcUpdate)
end

function DTNPCSpawn.FlushUpdates()
    -- Every 3 seconds, send batched updates
    for player, batch in pairs(DTNPCSpawn.UpdateBatch) do
        if #batch.updates > 0 then
            sendServerCommand(player, "DTNPC", "BatchPositionUpdate", {
                updates = batch.updates
            })
            batch.updates = {}
        end
    end
end
```

**Benefits**:
- Reduces overhead of sending many small messages
- 10-20% reduction in network stack overhead

---

## IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Week 1-2)
- [ ] Implement distance-aware broadcasting (1.1)
- [ ] Create sync variants (InitialSync, SimpleSYnc, FullSync, DeltaSync) (1.2)
- [ ] Test with 10 NPCs, 5 players

### Phase 2: Client Optimization (Week 2-3)
- [ ] Implement client-side interpolation (2.1)
- [ ] Reduce position broadcast frequency to 12 sec
- [ ] Implement initial sync distance filtering (2.2)
- [ ] Test with 50 NPCs, 10 players

### Phase 3: Advanced Optimization (Week 3-4)
- [ ] Smart distance-based update frequency (3.1)
- [ ] Update batching (3.3)
- [ ] Server-side visibility checks (3.2)
- [ ] Stress test with 100+ NPCs, 20+ players

### Phase 4: Monitoring & Profiling (Ongoing)
- [ ] Add bandwidth logging per player
- [ ] Monitor CPU usage during CheckRosterSpawns
- [ ] Profile network message timing
- [ ] Adjust constants based on real-world usage

---

## EXPECTED IMPROVEMENTS

| Metric | Current | Optimized | Improvement |
|--------|---------|-----------|-------------|
| Player Join Data | 200-600 KB | 20-60 KB | **90% reduction** |
| Position Broadcast/min | 300 KB | 30 KB | **90% reduction** |
| Full Brain Sync Size | 2-3 KB | 0.5 KB (diff) | **75% reduction** |
| Server CPU (CheckRoster) | O(n²) | O(n log n) | **Better scaling** |
| Client Memory/NPC | 3-4 KB | 1-2 KB | **50% reduction** |

---

## RECOMMENDED IMPLEMENTATION ORDER

1. **Start with 1.1 (Distance-Aware Broadcasting)** - Lowest risk, highest impact
2. **Add 1.2 (Delta Sync)** - Complements 1.1, straightforward
3. **Add 2.1 (Client Interpolation)** - Requires client changes, plan carefully
4. **Add 2.2 (Initial Sync Filtering)** - Quick win, improves joins
5. **Final: 3.x features** - Refinements, monitor first

---

## MONITORING RECOMMENDATIONS

### Add These Metrics:

**Server-Side (in DTNPCManager_Tick.lua)**:
```lua
-- Track every 60 seconds
DTNPC_Stats = {
    messagesPerTick = 0,
    totalBandwidthEstimate = 0,  -- Bytes sent
    checkRosterTime = 0,  -- ms spent in CheckRosterSpawns()
    respawnCheckTime = 0,  -- ms spent in CheckForRespawn()
    npcCount = 0,
    playerCount = 0
}
```

**Client-Side (in DTNPC_ClientNetwork.lua)**:
```lua
-- Track every 60 seconds
DTNPC_ClientStats = {
    messagesReceived = 0,
    dataReceived = 0,  -- Bytes
    npcsCached = 0,
    npcsDirty = 0  -- Need resync
}
```

---

## POTENTIAL ISSUES TO WATCH

1. **Desyncs from distance-aware sync**: Ensure state changes still reach all clients
2. **Interpolation errors**: Monitor for visible "jitter" at update boundaries
3. **Memory from cached data**: Ensure old NPC cache entries are cleaned up
4. **Lost updates**: Verify no messages lost when switching from broadcast to targeted
5. **Roster inconsistencies**: Ensure unloaded NPCs still sync to Roster correctly

---

## CONCLUSION

Your V2 system has excellent **conceptual architecture** for hybrid server-client NPC management, but lacks the **network layer optimizations** needed for scalability. The fixes are straightforward and don't require architectural changes—just targeted broadcasts and delta synchronization.

**Priority**: Implement Phase 1-2 before releasing on multi-player servers with 20+ NPCs.

