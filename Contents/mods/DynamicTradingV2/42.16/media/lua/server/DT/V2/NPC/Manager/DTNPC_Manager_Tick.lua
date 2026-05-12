-- ==============================================================================
-- DTNPC_Manager_Tick.lua
-- Main tick loop: position tracking, visual fixes, and periodic broadcasts.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic_TradeScheduler"

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading optimization modules...")

require "DT/V2/NPC/Sys/Data/DTNPC_Data"
require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

require "DT/V2/NPC/Manager/DTNPC_ZombieAggro/DTNPC_ZombieAggro"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_ZombieAggro loaded: " .. tostring(DTNPC_ZombieAggro ~= nil))

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
local SHELL_CLEANUP_CHECK_RATE = 5 -- Sweep stale restart shells quickly after chunks load (~0.25s)
local shellCleanupCheckCounter = 0

local ROSTER_RESPAWN_CHECK_RATE = 60 -- Discover/spawn nearby roster NPCs every ~3 seconds
local rosterRespawnCheckCounter = 0

local AWAY_TRANSITION_CHECK_RATE = 60 -- Resolve expired traders/departures every ~3 seconds
local awayTransitionCheckCounter = 0
local RESTING_REGEN_CHECK_RATE = 120 -- Simulate unloaded resting healing every ~6 seconds
local restingRegenCheckCounter = 0
local TRADE_CYCLE_CHECK_RATE = 600 -- Start new trade missions every ~30 seconds
local tradeCycleCheckCounter = 0

local hasLoggedMissingRespawnHooks = false
local startupHintPassTicks = 0

local function getSavedCoords(npcData)
    if not npcData then
        return nil, nil, nil
    end

    return npcData.lastX or (npcData.homeCoords and npcData.homeCoords.x),
        npcData.lastY or (npcData.homeCoords and npcData.homeCoords.y),
        npcData.lastZ or (npcData.homeCoords and npcData.homeCoords.z) or 0
end

local function isZombieNearSavedCoords(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    local sx, sy, sz = getSavedCoords(npcData)
    if not sx or not sy then
        return false
    end

    local dx = zombie:getX() - sx
    local dy = zombie:getY() - sy
    local dz = zombie:getZ() - sz
    return math.abs(dz) <= 1 and math.sqrt(dx * dx + dy * dy) <= 3.0
end

local function findZombieByBodyInstanceHint(bodyInstanceID)
    if not bodyInstanceID then
        return nil
    end

    if DTNPCServerCore and DTNPCServerCore.FindZombieByBodyInstanceID then
        return DTNPCServerCore.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    local cell = getCell()
    local zombieList = cell and cell:getZombieList() or nil
    if not zombieList then
        return nil
    end

    local wanted = tostring(bodyInstanceID)
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and tostring(zombie:getPersistentOutfitID()) == wanted then
            return zombie
        end
    end

    return nil
end

local function removeStaleWorldBody(uuid, zombie, npcData, reason)
    if not zombie or zombie:isDead() then
        return false
    end

    local bodyInstanceID = zombie:getPersistentOutfitID()
    local removalRevision = DTNPCManager and DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or nil

    if DTNPCManager and DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    end
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and uuid and npcData then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        DTNPCManager.Save()
    end

    zombie:removeFromWorld()
    zombie:removeFromSquare()

    if bodyInstanceID and DTNPCServerCore and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, removalRevision)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Repair",
        "Removed stale world body for " .. tostring(npcData and (npcData.name or uuid) or uuid)
            .. " reason=" .. tostring(reason or "stale-world-body")
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
    )

    return true
end

local function isZombieNakedShell(zombie)
    if not zombie or zombie:isDead() then
        return false, false
    end

    local modData = zombie:getModData()
    local hasDTMarkers = modData and (
        modData.IsDTNPC == true
        or modData.DTNPC_UUID ~= nil
        or modData.DTNPC_Data ~= nil
        or modData.DTNPCBrain ~= nil
        or modData.DTNPCPresenceRevision ~= nil
    ) or false
    local hasDTVariable = zombie.getVariableBoolean and zombie:getVariableBoolean("DTNPC") == true or false
    local useless = zombie.isUseless and zombie:isUseless() == true or false
    local hasSignature = hasDTMarkers or hasDTVariable or useless

    local wornItems = zombie.getWornItems and zombie:getWornItems() or nil
    local itemVisuals = zombie.getItemVisuals and zombie:getItemVisuals() or nil
    local wornCount = wornItems and wornItems.size and wornItems:size() or 0
    local visualCount = itemVisuals and itemVisuals.size and itemVisuals:size() or 0

    if wornCount > 0 or visualCount > 0 then
        return false, false
    end

    return true, hasSignature
end

local function findNearbyAbstractSoulForZombie(zombie, players, rosterSouls, requireShellSignature)
    if not zombie or not rosterSouls or not players or #players == 0 then
        return nil, nil
    end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local maxSoulDist = requireShellSignature and 3.5 or 1.25

    for uuid, soul in pairs(rosterSouls) do
        if soul and DTNPCManager.IsPhysicalWorldStatus and not DTNPCManager.IsPhysicalWorldStatus(soul.status, soul) then
            if requireShellSignature or tostring(soul.status or "") == "Away" then
                local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                local sz = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0

                if sx and sy and math.abs(zz - sz) <= 1 then
                    local dx = zx - sx
                    local dy = zy - sy
                    local soulDist = math.sqrt(dx * dx + dy * dy)
                    if soulDist <= maxSoulDist then
                        for _, player in ipairs(players) do
                            if math.abs(player:getZ() - sz) <= 1 then
                                local pdx = player:getX() - sx
                                local pdy = player:getY() - sy
                                local playerDist = math.sqrt(pdx * pdx + pdy * pdy)
                                if playerDist <= 80 then
                                    return uuid, soul
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nil, nil
end

local function CleanupNearbyAbstractSoulShells(zombieList, players)
    if not zombieList or not players or #players == 0 or not DTNPCManager.IsPhysicalWorldStatus then
        return
    end

    local rosterData = ModData and ModData.get and ModData.get("DynamicTrading_Roster") or nil
    local rosterSouls = rosterData and rosterData.Souls or nil
    if not rosterSouls then
        return
    end

    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        local isNakedShell, hasShellSignature = isZombieNakedShell(zombie)
        if isNakedShell then
            local uuid, soul = findNearbyAbstractSoulForZombie(zombie, players, rosterSouls, hasShellSignature)
            if uuid and soul then
                removeStaleWorldBody(
                    uuid,
                    zombie,
                    soul,
                    hasShellSignature and "abstract-shell-cleanup" or "abstract-naked-zombie-cleanup"
                )
            end
        end
    end
end

local function ProcessStartupBodyHints()
    if not DTNPCManager or not DTNPCManager.Data or not DTNPCManager.ReclaimZombie then
        return
    end

    for uuid, npcData in pairs(DTNPCManager.Data) do
        local hintBodyInstanceID = npcData and npcData.startupBodyInstanceHint or nil
        if hintBodyInstanceID and not npcData.currentBodyInstanceID and npcData.status ~= "Dead" then
            local zombie = findZombieByBodyInstanceHint(hintBodyInstanceID)
            if zombie and not zombie:isDead() then
                if not (DTNPCManager.IsPhysicalWorldStatus and DTNPCManager.IsPhysicalWorldStatus(npcData.status, npcData)) then
                    removeStaleWorldBody(uuid, zombie, npcData, "startup-hint-away")
                elseif isZombieNearSavedCoords(zombie, npcData) then
                local existingUUID = DTNPCManager.GetUUIDFromZombie and DTNPCManager.GetUUIDFromZombie(zombie) or nil
                if not existingUUID or existingUUID == uuid then
                    local modData = zombie:getModData()
                    if modData and not modData.DTNPC_UUID then
                        modData.DTNPC_UUID = uuid
                    end
                    if DTNPC and DTNPC.ApplyMarkedBodySafety then
                        DTNPC.ApplyMarkedBodySafety(zombie, npcData, {
                            suppressEngineState = true,
                            clearTarget = true,
                        })
                    end
                    DTNPCManager.ReclaimZombie(zombie, npcData, "startup-tick")
                end
                end
            end
        end
    end
end

local function ApplySafetyToMarkedServerZombie(zombie)
    if not zombie or zombie:isDead() then
        return
    end

    local modData = zombie:getModData()
    if not modData then
        return
    end

    local npcData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (npcData and npcData.uuid) or nil

    if not (modData.IsDTNPC or uuid or npcData) then
        return
    end

    local savedData = (uuid and DTNPCManager.Data and DTNPCManager.Data[uuid]) or npcData
    if not savedData and uuid and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        savedData = DynamicTrading_Roster.GetSoul(uuid)
    end

    if DTNPC and DTNPC.ApplyMarkedBodySafety then
        DTNPC.ApplyMarkedBodySafety(zombie, savedData)
    elseif DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, savedData, { clearPlayerTarget = true })
    elseif DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, savedData)
    end
end

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

local function ProcessOfflineRestingRegen()
    if not DTNPCHealth or not DTNPCHealth.ProcessPassiveRestRegen then
        return
    end
    if not DynamicTrading_Roster or not DynamicTrading_Roster.MOD_DATA_KEY or not ModData then
        return
    end

    local rosterData = ModData.get(DynamicTrading_Roster.MOD_DATA_KEY)
    local souls = rosterData and rosterData.Souls or nil
    if not souls then
        return
    end

    for uuid, registry in pairs(souls) do
        if registry
            and registry.status == "Resting"
            and not DTNPCManager.Data[uuid] then
            local currentHp = tonumber(registry.combatHealthCurrent) or tonumber(registry.health) or 0
            local maxHp = tonumber(registry.combatHealthMax) or 0
            if currentHp > 0 and (maxHp <= 0 or currentHp < maxHp) then
                local npcData = DynamicTrading_Roster.GetSoul(uuid)
                if npcData then
                    DTNPCHealth.ProcessPassiveRestRegen(nil, npcData, {
                        forceManagerSave = false,
                    })
                end
            end
        end
    end
end

function DTNPCManager.OnTick()
    -- Run on Server or Single Player

    tickCounter = tickCounter + 1
    positionBroadcastCounter = positionBroadcastCounter + 1
    activeRespawnCheckCounter = activeRespawnCheckCounter + 1
    shellCleanupCheckCounter = shellCleanupCheckCounter + 1
    rosterRespawnCheckCounter = rosterRespawnCheckCounter + 1
    awayTransitionCheckCounter = awayTransitionCheckCounter + 1
    restingRegenCheckCounter = restingRegenCheckCounter + 1
    tradeCycleCheckCounter = tradeCycleCheckCounter + 1

    if startupHintPassTicks < 50 then
        startupHintPassTicks = startupHintPassTicks + 1
        ProcessStartupBodyHints()
    end

    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnManagerTick then
        DTNPC_ZombieAggro.OnManagerTick()
    end
    
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

    local shouldCheckRestingRegen = (restingRegenCheckCounter >= RESTING_REGEN_CHECK_RATE)
    if shouldCheckRestingRegen then
        restingRegenCheckCounter = 0
        ProcessOfflineRestingRegen()
    end

    local shouldCheckTradeCycles = (tradeCycleCheckCounter >= TRADE_CYCLE_CHECK_RATE)
    if shouldCheckTradeCycles then
        tradeCycleCheckCounter = 0
        if EnsureRespawnHooks() then
            DTNPCManager.ProcessTradeCycles()
            if DTNPCManager.ProcessBanditHouseRoamers then
                DTNPCManager.ProcessBanditHouseRoamers()
            end
        end
    end
    
    -- Respawn check
    if shouldCheckActiveRespawn and EnsureRespawnHooks() then
        -- 1. Validate existing tracked NPCs at a slower cadence.
        for uuid, npcData in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(npcData, uuid)
        end
    end

    if DTNPCServerCore and DTNPCServerCore.ProcessPendingArrivals then
        DTNPCServerCore.ProcessPendingArrivals()
    end

    if shellCleanupCheckCounter >= SHELL_CLEANUP_CHECK_RATE then
        shellCleanupCheckCounter = 0
        local cell = getCell()
        local zombieList = cell and cell:getZombieList() or nil
        if zombieList then
            CleanupNearbyAbstractSoulShells(zombieList, DTNPCManager.GetActivePlayers())
        end
    end

    if shouldCheckRosterRespawn and EnsureRespawnHooks() then
        -- 2. Check for new spawns from Roster (Bridge) more frequently for responsiveness.
        DTNPCManager.CheckRosterSpawns()
    end
    
    if tickCounter < TICK_RATE then return end
    tickCounter = 0

    if DynamicTrading_TradeScheduler and DynamicTrading_TradeScheduler.NormalizeRosterState then
        DynamicTrading_TradeScheduler.NormalizeRosterState(nil, getGameTime():getWorldAgeHours())
    end

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    -- Get active players for distance-based frequency updates
    local players = DTNPCManager.GetActivePlayers()
    CleanupNearbyAbstractSoulShells(zombieList, players)
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and zombie:isDead() then
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            if uuid and DTNPCLifecycle and DTNPCLifecycle.HandleZombieDead then
                DTNPCLifecycle.HandleZombieDead(zombie)
            end
        elseif zombie then
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            
            if uuid then
                local savedData = DTNPCManager.Data[uuid]
                
                -- [NEW] Active Adoption: If physical NPC exists but is NOT in runtime Data (e.g. after restart)
                if not savedData and DynamicTrading_Roster then
                    local rosterData = DynamicTrading_Roster.GetSoul(uuid)
                    if rosterData and rosterData.status ~= "Dead" then
                        if not (DTNPCManager.IsPhysicalWorldStatus and DTNPCManager.IsPhysicalWorldStatus(rosterData.status, rosterData)) then
                            removeStaleWorldBody(uuid, zombie, rosterData, "active-adoption-away")
                        else
                        local isWorkerLinkedCompanion = tostring(rosterData.dcCompanionJob or "") == "TravelCompanion"
                            and tostring(rosterData.linkedWorkerID or "") ~= ""
                        if isWorkerLinkedCompanion and #players <= 0 then
                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Adopt",
                                "Skipping active adoption for worker-linked travel companion with no active players: " .. tostring(rosterData.name or uuid)
                            )
                            zombie:removeFromWorld()
                            zombie:removeFromSquare()
                        else
                        DynamicTrading.Log("DTV2", "NPC", "Adopt", "Active Adoption: Found existing NPC in world, reclaiming: " .. (rosterData.name or uuid))
                        if DTNPCManager.ReclaimZombie then
                            DTNPCManager.ReclaimZombie(zombie, rosterData, "active-adoption")
                        else
                            DTNPCManager.Register(zombie, rosterData)
                        end
                        savedData = DTNPCManager.Data[uuid] -- Refresh local reference
                        end
                        end
                    end
                end

                if savedData then
                    if DTNPC and DTNPC.ApplySafetyFlags then
                        DTNPC.ApplySafetyFlags(zombie, savedData, { clearPlayerTarget = true })
                    elseif DTNPC and DTNPC.ApplyCharacterFlags then
                        DTNPC.ApplyCharacterFlags(zombie, savedData)
                    end

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
if Events.OnZombieUpdate then
    Events.OnZombieUpdate.Add(ApplySafetyToMarkedServerZombie)
end
