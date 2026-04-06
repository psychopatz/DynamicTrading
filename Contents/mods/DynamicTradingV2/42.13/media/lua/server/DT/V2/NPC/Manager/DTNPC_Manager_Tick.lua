-- ==============================================================================
-- DTNPC_Manager_Tick.lua
-- Main tick loop: position tracking, visual fixes, and periodic broadcasts.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading optimization modules...")

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_SpatialHash then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() end,
        InsertNPC = function() end,
        RemoveNPC = function() end,
        GetNPCsInRadius = function() return {} end,
        GetNearestNPCs = function() return {} end,
        CleanupEmptyCells = function() end,
        Clear = function() end,
        GetGridStats = function() return {} end,
        ClearDirtyFlags = function() end,
        GetDirtyCells = function() return {} end
    }
end

if not DTNPC_DistanceFrequency then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_DistanceFrequency is nil, creating fallback")
    DTNPC_DistanceFrequency = {
        NPCTimers = {},
        GetTierForDistance = function() return 4 end,
        GetUpdateFrequencyForDistance = function() return 6 end,
        InitializeNPC = function() end,
        ShouldUpdateNPC = function() return true end,
        UpdateNPC = function() end,
        RemoveNPC = function() end,
        Clear = function() end,
        GetUpdateStats = function() return {} end
    }
end

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")

local TICK_RATE = 20
local tickCounter = 0

-- Bandwidth-first tuning: 12s position cadence at 20 ticks/sec.
local POSITION_BROADCAST_RATE = 240
local positionBroadcastCounter = 0

local ACTIVE_RESPAWN_CHECK_RATE = 240 -- Validate already-active NPC bodies every ~12 seconds
local activeRespawnCheckCounter = 0

local ROSTER_RESPAWN_CHECK_RATE = 60 -- Discover/spawn nearby roster NPCs every ~3 seconds
local rosterRespawnCheckCounter = 0

local AWAY_TRANSITION_CHECK_RATE = 60 -- Resolve expired traders/departures every ~3 seconds
local awayTransitionCheckCounter = 0
local TRADE_CYCLE_CHECK_RATE = 600 -- Start new trade missions every ~30 seconds
local tradeCycleCheckCounter = 0

local hasLoggedMissingRespawnHooks = false

local function EnsureRespawnHooks()
    local hasHooks = DTNPCManager
        and DTNPCManager.CheckForRespawn
        and DTNPCManager.CheckRosterSpawns
        and DTNPCManager.ProcessAwayTransitions
        and DTNPCManager.ProcessTradeCycles

    if hasHooks then
        return true
    end

    require "DT/V2/NPC/Manager/DTNPC_ManagerRespawn/DTNPC_ManagerRespawn"

    hasHooks = DTNPCManager
        and DTNPCManager.CheckForRespawn
        and DTNPCManager.CheckRosterSpawns
        and DTNPCManager.ProcessAwayTransitions
        and DTNPCManager.ProcessTradeCycles

    if not hasHooks and not hasLoggedMissingRespawnHooks then
        hasLoggedMissingRespawnHooks = true
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Respawn hooks are still missing after reload; skipping respawn/trade tick work"
        )
    end

    return hasHooks
end

function DTNPCManager.OnTick()
    -- Run on Server or Single Player

    tickCounter = tickCounter + 1
    positionBroadcastCounter = positionBroadcastCounter + 1
    activeRespawnCheckCounter = activeRespawnCheckCounter + 1
    rosterRespawnCheckCounter = rosterRespawnCheckCounter + 1
    awayTransitionCheckCounter = awayTransitionCheckCounter + 1
    tradeCycleCheckCounter = tradeCycleCheckCounter + 1
    
    local shouldBroadcast = (positionBroadcastCounter >= POSITION_BROADCAST_RATE)
    if shouldBroadcast then
        positionBroadcastCounter = 0
    end
    
    local shouldCheckActiveRespawn = (activeRespawnCheckCounter >= ACTIVE_RESPAWN_CHECK_RATE)
    if shouldCheckActiveRespawn then
        activeRespawnCheckCounter = 0
    end

    local shouldCheckRosterRespawn = (rosterRespawnCheckCounter >= ROSTER_RESPAWN_CHECK_RATE)
    if shouldCheckRosterRespawn then
        rosterRespawnCheckCounter = 0
    end

    local shouldCheckAwayTransitions = (awayTransitionCheckCounter >= AWAY_TRANSITION_CHECK_RATE)
    if shouldCheckAwayTransitions then
        awayTransitionCheckCounter = 0
        if EnsureRespawnHooks() then
            DTNPCManager.ProcessAwayTransitions()
        end
    end

    local shouldCheckTradeCycles = (tradeCycleCheckCounter >= TRADE_CYCLE_CHECK_RATE)
    if shouldCheckTradeCycles then
        tradeCycleCheckCounter = 0
        if EnsureRespawnHooks() then
            DTNPCManager.ProcessTradeCycles()
        end
    end
    
    -- Respawn check
    if shouldCheckActiveRespawn and EnsureRespawnHooks() then
        -- 1. Validate existing tracked NPCs at a slower cadence.
        for uuid, npcData in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(npcData, uuid)
        end
    end

    if shouldCheckRosterRespawn and EnsureRespawnHooks() then
        -- 2. Check for new spawns from Roster (Bridge) more frequently for responsiveness.
        DTNPCManager.CheckRosterSpawns()
    end
    
    if tickCounter < TICK_RATE then return end
    tickCounter = 0

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    -- Get active players for distance-based frequency updates
    local players = DTNPCManager.GetActivePlayers()
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            
            if uuid then
                local savedData = DTNPCManager.Data[uuid]
                
                -- [NEW] Active Adoption: If physical NPC exists but is NOT in runtime Data (e.g. after restart)
                if not savedData and DynamicTrading_Roster then
                    local rosterData = DynamicTrading_Roster.GetSoul(uuid)
                    if rosterData and rosterData.status ~= "Dead" then
                        DynamicTrading.Log("DTV2", "NPC", "Adopt", "Active Adoption: Found existing NPC in world, reclaiming: " .. (rosterData.name or uuid))
                        DTNPCManager.Register(zombie, rosterData)
                        savedData = DTNPCManager.Data[uuid] -- Refresh local reference
                    end
                end

                if savedData then
                    if DTNPCHealth and DTNPCHealth.ProcessDeferredSpawnRestore then
                        local restored = DTNPCHealth.ProcessDeferredSpawnRestore(zombie, savedData)
                        if restored then
                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Health",
                                "Server manager restored deferred engine buffer for "
                                    .. tostring(savedData.name or uuid)
                                    .. " uuid=" .. tostring(uuid)
                                    .. " engineHealth=" .. tostring(zombie:getHealth())
                            )
                        end
                    end

                    -- 1. Sync Body Instance ID (for body-instance-to-uuid mapping)
                    local currentBodyInstanceID = zombie:getPersistentOutfitID()
                    local savedBodyInstanceID = savedData.currentBodyInstanceID
                    if savedBodyInstanceID ~= currentBodyInstanceID then
                        -- Clear old mapping
                        if savedBodyInstanceID then
                            DTNPCManager.BodyInstanceIDToUUID[savedBodyInstanceID] = nil
                        end
                        -- Set new mapping
                        savedData.currentBodyInstanceID = currentBodyInstanceID
                        DTNPCManager.BodyInstanceIDToUUID[currentBodyInstanceID] = uuid
                    end
                    
                    -- 2. Update Position History (used for respawn/teleport)
                    local newX, newY, newZ = math.floor(zombie:getX()), math.floor(zombie:getY()), math.floor(zombie:getZ())
                    savedData.lastX = newX
                    savedData.lastY = newY
                    savedData.lastZ = newZ
                    savedData.health = zombie:getHealth()
                    
                    -- Update spatial hash with current position
                    DTNPC_SpatialHash.InsertNPC(uuid, newX, newY, newZ, nil)
                    
                    -- Update distance-based frequency for this NPC (Phase 2.2)
                    if #players > 0 then
                        DTNPC_DistanceFrequency.UpdateNPC(uuid, newX, newY, players)
                    end
                    
                    -- Keep local DTNPCs detached from the stock zombie horde logic.
                    if zombie:isUseless() and (savedData.state == "Stay" or savedData.state == "Guard" or savedData.state == "Idle" or savedData.state == "Trading") then
                        zombie:setPath2(nil)
                        zombie:setTarget(nil)
                    end
                    
                    -- 3. Visual & Data Sanity Check (Multiplayer Jitter fix)
                    local modData = zombie:getModData()
                    local needsRepair = (not modData.IsDTNPC)
                        or (modData.DTNPC_UUID ~= uuid)
                        or (not modData.DTNPC_Data)
                        or (not modData.DTNPCVisualID)
                        or (modData.DTNPCVisualID == 0)
                        or (savedData.visualID and modData.DTNPCVisualID ~= savedData.visualID)

                    if needsRepair and DTNPCManager.ReclaimZombie then
                        DTNPCManager.ReclaimZombie(zombie, savedData, "tick-repair")
                    end
                    
                    -- Periodic position broadcast
                    if shouldBroadcast and DTNPCServerCore and DTNPCServerCore.BroadcastPosition then
                        DTNPCServerCore.BroadcastPosition(zombie, savedData)
                    end
                end
            end
        end
    end
end

Events.OnTick.Add(DTNPCManager.OnTick)
