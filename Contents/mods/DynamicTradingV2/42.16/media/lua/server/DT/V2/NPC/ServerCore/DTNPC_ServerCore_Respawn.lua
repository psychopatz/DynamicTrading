-- ==============================================================================
-- DTNPC_ServerCore_Respawn.lua
-- NPC respawning logic with advanced location search.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

local function getBanditEncounterTargetIdentity(npcData)
    if type(npcData) ~= "table" then
        return nil, nil
    end

    local username = npcData.master
        or npcData.banditTargetUsername
        or npcData.lastPlayerAttackerUsername
        or npcData.tradeCycleTargetPlayerUsername
        or npcData.banditPausedTargetUsername
    local onlineID = npcData.masterID
        or npcData.banditTargetOnlineID
        or npcData.lastPlayerAttackerOnlineID
        or npcData.tradeCycleTargetPlayerOnlineID
        or npcData.banditPausedTargetOnlineID

    return username, onlineID
end

local function shouldPreserveBanditEncounterState(npcData, status)
    if type(npcData) ~= "table" or tostring(status or "") ~= "Trading" then
        return false
    end

    local mode = tostring(npcData.tradeCycleMode or "")
    local activeEncounter = npcData.banditGroupID ~= nil
        or npcData.raidHostileFaction == true
        or npcData.banditRoamActive == true
        or mode == "robbery"
        or mode == "hostile_bribe"
    if not activeEncounter then
        return false
    end

    if npcData.banditDemandResolved == true and npcData.isHostile ~= true then
        return false
    end

    local username, onlineID = getBanditEncounterTargetIdentity(npcData)
    if username ~= nil or onlineID ~= nil then
        return true
    end

    return npcData.isHostile == true
end

local function resolveTradingRespawnState(npcData, preserveContactVisitFollow, preserveBanditEncounterState)
    if preserveContactVisitFollow then
        return "Follow"
    end

    if preserveBanditEncounterState then
        local state = tostring(npcData and npcData.state or "")
        if state == "Attack" or state == "AttackRange" or state == "Stay" or state == "Flee" then
            return state
        end

        if npcData and npcData.isHostile == true then
            return "Attack"
        end

        if npcData and npcData.banditRoamActive == true then
            return "Stay"
        end

        return "Stay"
    end

    return "Trading"
end

-- ==============================================================================
-- RESPAWN FUNCTION
-- ==============================================================================

function DTNPCServerCore.RespawnNPC(npcData, uuid)
    if not npcData or not npcData.lastX or not npcData.lastY then return end
    if npcData.status == "Dead" then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Refusing to respawn dead NPC: " .. tostring(npcData.name or uuid or "Unknown"))
        return nil
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Respawn",
        "RespawnNPC request name=" .. tostring(npcData.name or uuid or "Unknown")
            .. " uuid=" .. tostring(uuid or npcData.uuid)
            .. " lastPos=" .. tostring(npcData.lastX) .. "," .. tostring(npcData.lastY) .. "," .. tostring(npcData.lastZ or 0)
            .. " status=" .. tostring(npcData.status)
            .. " incapState=" .. tostring(npcData.incapState)
    )

    uuid = uuid or npcData.uuid
    local previousBodyInstanceID = npcData.currentBodyInstanceID
    if uuid then
        local existingZombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if not existingZombie and DTNPCServerCore.FindReusableWorldBody then
            existingZombie = DTNPCServerCore.FindReusableWorldBody(uuid, npcData, {
                allowPositionalMatch = true,
                positionRadius = 1.25,
            })
        end
        if existingZombie then
            if DTNPCServerCore.PruneDuplicateZombies then
                existingZombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, existingZombie, "respawn-guard")
            end

            if DTNPCManager and DTNPCManager.ReclaimZombie then
                return DTNPCManager.ReclaimZombie(existingZombie, npcData, "respawn-guard"), npcData
            end

            return existingZombie, npcData
        end
    end
    
    local x = npcData.lastX
    local y = npcData.lastY
    local z = npcData.lastZ or 0
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Targeted Square: " .. x .. "," .. y .. "," .. z)
    
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    
    -- EXTREME SPAWN SEARCH (15 Tile Radius, 2 Passes)
    local foundSq = nil
    
    -- Pass 1: Perfect Square (Not Solid, Free, Not Nil)
    if sq and sq:isFree(false) and not sq:isSolid() and not sq:isSolidTrans() then
        foundSq = sq
    else
        if not sq then DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Target chunk not fully loaded (sq is nil). Searching wider...") end
        for radius = 1, 15 do
            for _x = -radius, radius do
                for _y = -radius, radius do
                    if math.abs(_x) == radius or math.abs(_y) == radius then
                        local tSq = cell:getGridSquare(x + _x, y + _y, z)
                        if tSq and tSq:isFree(false) and not tSq:isSolid() and not tSq:isSolidTrans() then
                            x = x + _x
                            y = y + _y
                            foundSq = tSq
                            break
                        end
                    end
                end
                if foundSq then break end
            end
            if foundSq then break end
        end
    end
    
    -- Pass 2: Tolerable Square (Not Solid, but maybe has objects/blocked)
    if not foundSq then
        DynamicTrading.Log("DTV2", "NPC", "Respawn", "| No perfect square found. Searching for any non-solid square...")
        for radius = 1, 15 do
            for _x = -radius, radius do
                for _y = -radius, radius do
                    if math.abs(_x) == radius or math.abs(_y) == radius then
                        local tSq = cell:getGridSquare(x + _x, y + _y, z)
                        if tSq and not tSq:isSolid() and not tSq:isSolidTrans() then
                            x = x + _x
                            y = y + _y
                            foundSq = tSq
                            break
                        end
                    end
                end
                if foundSq then break end
            end
            if foundSq then break end
        end
    end
    
    if foundSq then
        DynamicTrading.Log("DTV2", "NPC", "Respawn", "| SUCCESS: Found suitable square at " .. x .. "," .. y)
    else
        DynamicTrading.Log("DTV2", "NPC", "Error", "| ERROR: Extreme search failed. Chunk likely UNLOADED or area is blocked. Skipping spawn attempt.")
        return nil
    end
    
    local femaleChance = npcData.isFemale and 100 or 0
    local startIncapacitated = npcData.incapState == "Active"
    local spawnAsCrawler = false
    local fallOnFront = false
    local knockedDown = false
    local invulnerable = true
    local zombieList = addZombiesInOutfit(
        x,
        y,
        z,
        1,
        "Naked",
        femaleChance,
        spawnAsCrawler,
        fallOnFront,
        false,
        knockedDown,
        invulnerable,
        false,
        1
    )
    
    if not zombieList or zombieList:size() == 0 then 
        DynamicTrading.Log("DTV2", "NPC", "Error", "| ERROR: addZombiesInOutfit returned 0 even on found square!")
        return nil
    end

    local zombie = zombieList:get(0)
    local newBodyInstanceID = zombie:getPersistentOutfitID()
    local newPresenceRevision = DTNPCManager and DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or nil
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "Respawned with new BodyInstanceID: " .. newBodyInstanceID)

    if previousBodyInstanceID and previousBodyInstanceID ~= newBodyInstanceID and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, previousBodyInstanceID, newPresenceRevision)
    end
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPC_UUID = uuid
    
    -- Keep the same UUID
    npcData.uuid = uuid
    
    -- Keep the saved appearance stable across legitimate body recovery.
    if not npcData.visualID or npcData.visualID == 0 then
        npcData.visualID = ZombRand(1000000)
    end
    
    -- CRITICAL: Determine state based on status
    local status = npcData.status or "Resting"
    local preserveCompanionControl = status == "Working"
        and npcData.master ~= nil
        and (npcData.state == "Follow"
            or npcData.state == "ProtectRanged"
            or npcData.state == "ProtectMelee"
            or npcData.state == "ProtectAuto")
    local preserveContactVisitFollow = status == "Trading"
        and npcData.contactVisitActive == true
        and npcData.master ~= nil
        and (npcData.state == "Follow" or npcData.contactVisitMode == "Follow")
    local preserveBanditEncounterState = shouldPreserveBanditEncounterState(npcData, status)
    local banditTargetUsername, banditTargetOnlineID = getBanditEncounterTargetIdentity(npcData)
    if npcData.incapState == "Active" then
        npcData.state = "Incapacitated"
    elseif status == "Trading" then
        npcData.state = resolveTradingRespawnState(npcData, preserveContactVisitFollow, preserveBanditEncounterState)
    elseif npcData.linkedWorkerID ~= nil
        and npcData.dcCompanionActive ~= true
        and tostring(npcData.dcBehaviorState or "") ~= "" then
        npcData.state = tostring(npcData.dcBehaviorState)
    elseif status == "Working" then
        npcData.state = preserveCompanionControl and npcData.state or "Guard"
    elseif npcData.linkedWorkerID ~= nil then
        npcData.state = "PlayerZone"
    else
        npcData.state = "Idle"
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Respawn", "| Mapped Status [" .. status .. "] to Behavior State [" .. npcData.state .. "]")
    
    if preserveBanditEncounterState then
        npcData.master = banditTargetUsername or npcData.master
        npcData.masterID = banditTargetOnlineID or npcData.masterID
    elseif not preserveCompanionControl and not preserveContactVisitFollow then
        npcData.master = nil
        npcData.masterID = nil
    end

    if preserveContactVisitFollow then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Respawn",
            "Preserving Follow state for called trader arrival name=" .. tostring(npcData.name or uuid)
                .. " requester=" .. tostring(npcData.contactVisitRequestedBy)
        )
    elseif preserveBanditEncounterState then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Respawn",
            "Preserving robbery pursuit state for " .. tostring(npcData.name or uuid)
                .. " state=" .. tostring(npcData.state)
                .. " target=" .. tostring(npcData.master or banditTargetUsername)
        )
    end
    
    DTNPC.AttachData(zombie, npcData)
    DTNPC.ApplyVisuals(zombie, npcData)

    if startIncapacitated then
        zombie:setVariable("bBecomeCrawler", false)
        zombie:setVariable("bCrawling", false)
        zombie:setVariable("FallOnFront", false)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("isMoving", false)
        zombie:setVariable("DTNPCMoveAnim", "")
        zombie:setVariable("DTNPCAnimSpeed", 0.0)
        zombie:setVariable("MovementSpeed", 0.0)
        zombie:setVariable("WalkSpeed", 0.0)
        zombie:setVariable("RunSpeed", 0.0)
        zombie:setVariable("Speed", 0.0)
        zombie:setVariable("WalkType", "")
        zombie:setVariable("DTWalkType", "Crawl")
    end
    
    modData.DTNPCVisualID = npcData.visualID
    if newPresenceRevision ~= nil then
        modData.DTNPCPresenceRevision = newPresenceRevision
    end

    zombie:setUseless(true) 
    zombie:DoZombieStats()
    if DTNPCHealth and DTNPCHealth.InitializeForSpawn then
        DTNPCHealth.InitializeForSpawn(zombie, npcData, {
            resetCurrent = false,
            deferNetworkSafeBuffer = isServer(),
            spawnReason = "server_respawn",
        })
    else
        zombie:setHealth(2)
    end
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Respawn",
        "RespawnNPC initialized health name=" .. tostring(npcData.name or uuid or "Unknown")
            .. " engineHealth=" .. tostring(zombie:getHealth())
            .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
            .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
            .. " deferredBuffer=" .. tostring(npcData.combatHealth and npcData.combatHealth.deferredSpawnBufferTarget or nil)
    )
    
    zombie:resetModelNextFrame()

    if DTNPCManager then
        DTNPCManager.Register(zombie, npcData)
    end

    -- Force sync to all clients with new visual ID
    DTNPCServerCore.SyncToAllClients(zombie, npcData)

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Respawn",
        "RespawnNPC complete name=" .. tostring(npcData.name)
            .. " uuid=" .. tostring(uuid)
            .. " bodyInstanceID=" .. tostring(newBodyInstanceID)
            .. " pos=" .. tostring(math.floor(zombie:getX())) .. "," .. tostring(math.floor(zombie:getY())) .. "," .. tostring(math.floor(zombie:getZ()))
            .. " visualID=" .. tostring(npcData.visualID)
    )
    
    return zombie, npcData
end
