-- ==============================================================================
-- DTNPC_ServerCore_Sync.lua
-- Multiplayer synchronization functions for NPCs.
-- ==============================================================================

-- GUARD: Ensure DTNPCServerCore table exists
DTNPCServerCore = DTNPCServerCore or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

DTNPCServerCore.BROADCAST_RANGES = DTNPCServerCore.BROADCAST_RANGES or {
    CLOSE = 200,
    MEDIUM = 350,
    FAR = 500,
}

if not DTNPCServerCore.SanitizeNetworkData then
    local function sanitizeNetworkKey(key)
        local keyType = type(key)
        if keyType == "string" or keyType == "number" then
            return key
        end
        if keyType == "boolean" then
            return tostring(key)
        end
        return nil
    end

    local function sanitizeNetworkValue(value, seen, depth)
        local valueType = type(value)
        if valueType == "nil" then
            return nil
        end
        if valueType == "string" or valueType == "boolean" then
            return value
        end
        if valueType == "number" then
            if value ~= value then
                return 0
            end
            return value
        end
        if valueType ~= "table" then
            return nil
        end

        local safeDepth = math.floor(tonumber(depth) or 0)
        if safeDepth > 32 then
            return nil
        end

        seen = seen or {}
        if seen[value] then
            return nil
        end
        seen[value] = true

        local copy = {}
        for key, child in pairs(value) do
            local safeKey = sanitizeNetworkKey(key)
            local safeChild = sanitizeNetworkValue(child, seen, safeDepth + 1)
            if safeKey ~= nil and safeChild ~= nil then
                copy[safeKey] = safeChild
            end
        end

        seen[value] = nil
        return copy
    end

    function DTNPCServerCore.SanitizeNetworkData(data)
        local safeData = sanitizeNetworkValue(data or {}, nil, 0)
        if type(safeData) == "table" then
            return safeData
        end
        return {}
    end
end

local function getActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end

    local players = {}
    local online = getOnlinePlayers()
    if online then
        for i = 0, online:size() - 1 do
            local p = online:get(i)
            if p then table.insert(players, p) end
        end
    end
    return players
end

local function sendToNearbyPlayers(command, data, x, y, z, range)
    local players = getActivePlayers()
    local sent = 0
    local safeData = DTNPCServerCore.SanitizeNetworkData and DTNPCServerCore.SanitizeNetworkData(data) or (data or {})
    local rangeSq = math.max(0, tonumber(range) or 0)
    rangeSq = rangeSq * rangeSq

    for _, player in ipairs(players) do
        local dx = player:getX() - x
        local dy = player:getY() - y
        local dz = player:getZ() - z
        local distSq = (dx * dx) + (dy * dy)

        -- Strict visibility: only nearby players get world-sync data.
        if math.abs(dz) <= 1 and distSq <= rangeSq then
            sendServerCommand(player, "DTNPC", command, safeData)
            sent = sent + 1
        end
    end

    return sent, #players
end

-- ==============================================================================
-- MULTIPLAYER SYNC FUNCTIONS
-- ==============================================================================

function DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if not zombie or not npcData then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        presenceRevision = DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(npcData) or tonumber(npcData.presenceRevision) or 0,
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() then
        local sent, total = sendToNearbyPlayers(
            "SyncNPC",
            syncData,
            syncData.x,
            syncData.y,
            syncData.z,
            DTNPCServerCore.BROADCAST_RANGES.MEDIUM
        )
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Sync",
            "SyncNPC send name=" .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                .. " presenceRevision=" .. tostring(syncData.presenceRevision)
                .. " pos=" .. tostring(syncData.x) .. "," .. tostring(syncData.y) .. "," .. tostring(syncData.z)
                .. " engineHealth=" .. tostring(zombie:getHealth())
                .. " customCurrent=" .. tostring(npcData.combatHealth and npcData.combatHealth.current or nil)
                .. " customMax=" .. tostring(npcData.combatHealth and npcData.combatHealth.max or nil)
                .. " sentPlayers=" .. tostring(sent) .. "/" .. tostring(total)
        )
        if sent == 0 then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Warn",
                "SyncNPC reached zero nearby players for "
                    .. tostring(npcData.name or uuid)
                    .. " uuid=" .. tostring(uuid)
                    .. " at " .. tostring(syncData.x) .. "," .. tostring(syncData.y) .. "," .. tostring(syncData.z)
            )
        end
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", DTNPCServerCore.SanitizeNetworkData(syncData))
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC: " .. (npcData.name or uuid) .. " at " .. syncData.x .. "," .. syncData.y)
    end
end

function DTNPCServerCore.SyncToPlayer(player, zombie, npcData)
    if not player or not zombie or not npcData then return end
    
    local bodyInstanceID = zombie:getPersistentOutfitID()
    local uuid = npcData.uuid
    
    local modData = zombie:getModData()
    modData.IsDTNPC = true
    modData.DTNPCVisualID = npcData.visualID
    modData.DTNPC_UUID = uuid
    
    local syncData = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        presenceRevision = DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(npcData) or tonumber(npcData.presenceRevision) or 0,
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        npcData = npcData
    }
    
    if isServer() or isClient() then
        sendServerCommand(player, "DTNPC", "SyncNPC", DTNPCServerCore.SanitizeNetworkData(syncData))
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "SyncNPC", DTNPCServerCore.SanitizeNetworkData(syncData))
    end
    
    DynamicTrading.Log("DTV2", "NPC", "Sync", "Synced NPC to player: " .. (npcData.name or uuid))
end

function DTNPCServerCore.BroadcastPosition(zombie, npcData, forceUpdate)
    if not zombie or not npcData then return end
    
    local uuid = npcData.uuid
    local tier = nil
    if forceUpdate ~= true then
        local shouldUpdate
        shouldUpdate, tier = DTNPC_DistanceFrequency.ShouldUpdateNPC(uuid)
        if not shouldUpdate then
            return
        end
    else
        tier = "forced"
    end

    local motionHint = type(npcData._dtMotionHint) == "table" and npcData._dtMotionHint or nil
    local currentTime = getTimeInMillis and getTimeInMillis() or 0
    if currentTime <= 0 and getGameTime and getGameTime() and getGameTime().getWorldAgeHours then
        currentTime = math.floor((tonumber(getGameTime():getWorldAgeHours()) or 0) * 3600000)
    end
    local specialActionKind = nil
    local specialActionUntil = tonumber(npcData._dtSpecialActionUntil) or 0
    local specialActionMode = npcData._dtSpecialActionMode
    if npcData._dtSpecialAction and specialActionUntil > 0 and currentTime < specialActionUntil then
        specialActionKind = npcData._dtSpecialAction
    else
        specialActionUntil = 0
        specialActionMode = nil
    end
    local isMoving = npcData.isMovingState == true
    if specialActionKind then
        isMoving = false
    end
    local isRunning = isMoving and motionHint and motionHint.running == true or false
    local isCrawling = tostring(npcData.state or "") == "Incapacitated"
        or (motionHint and motionHint.crawl == true)
    local isWeakenedDeparture = tostring(npcData.healthState or "") == "Weakened"
        and tostring(npcData.state or "") == "Departure"
    local hintedWalkType = motionHint and tostring(motionHint.dtWalkType or "") or ""
    if not isRunning and zombie.isRunning then
        local ok, result = pcall(zombie.isRunning, zombie)
        isRunning = isMoving and ok and result == true or false
    end
    if isWeakenedDeparture then
        isRunning = false
    end

    local moveAnim = ""
    local animSpeed = 0.0
    local walkType = nil
    local dtWalkType = ""
    if isMoving then
        if isCrawling then
            moveAnim = "Crawl"
            animSpeed = 0.28
            dtWalkType = "Crawl"
        else
            moveAnim = hintedWalkType ~= "" and hintedWalkType or (isRunning and "Run" or "Walk")
            animSpeed = isRunning and 1.2
                or (isWeakenedDeparture and (tonumber(DTNPCHealth and DTNPCHealth.WEAKENED_DEPARTURE_ANIM_SPEED) or 0.82) or 1.0)
            walkType = motionHint and motionHint.walkType ~= nil and tostring(motionHint.walkType) or "1"
            dtWalkType = hintedWalkType ~= "" and hintedWalkType or moveAnim
        end
    elseif isCrawling then
        walkType = ""
        dtWalkType = "Crawl"
    elseif isWeakenedDeparture and hintedWalkType ~= "" then
        walkType = motionHint and motionHint.walkType ~= nil and tostring(motionHint.walkType) or "1"
        dtWalkType = hintedWalkType
    end

    local posData = {
        uuid = uuid,
        bodyInstanceID = zombie:getPersistentOutfitID(),
        presenceRevision = DTNPCManager and DTNPCManager.GetPresenceRevision and DTNPCManager.GetPresenceRevision(npcData) or tonumber(npcData.presenceRevision) or 0,
        onlineID = zombie:getOnlineID(),
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        health = zombie:getHealth(),
        combatHealthCurrent = npcData.combatHealth and npcData.combatHealth.current or nil,
        combatHealthMax = npcData.combatHealth and npcData.combatHealth.max or nil,
        combatHealthEnabled = npcData.combatHealth and npcData.combatHealth.enabled or nil,
        combatHealthBandageActive = npcData.combatHealth and npcData.combatHealth.activeBandage or nil,
        combatHealthBandageDirty = npcData.combatHealth and npcData.combatHealth.bandageDirty or nil,
        combatHealthBandageTier = npcData.combatHealth and npcData.combatHealth.bandageTier or nil,
        combatHealthBandageItemFullType = npcData.combatHealth and npcData.combatHealth.bandageItemFullType or nil,
        healthState = npcData.healthState,
        state = npcData.state,
        status = npcData.status,
        combatOrder = npcData.combatOrder,
        guardCombatOrder = npcData.guardCombatOrder,
        guardAttackMode = npcData.guardAttackMode,
        protectNoticeSerial = npcData.protectNoticeSerial,
        protectNoticeText = npcData.protectNoticeText,
        protectNoticeSentiment = npcData.protectNoticeSentiment,
        protectNoticeDialogueStatus = npcData.protectNoticeDialogueStatus,
        protectNoticeDialogueState = npcData.protectNoticeDialogueState,
        isMoving = isMoving,
        isRunning = isRunning,
        isCrawling = isCrawling,
        moveAnim = moveAnim,
        animSpeed = animSpeed,
        walkType = walkType,
        dtWalkType = dtWalkType,
        locomotionProfileKey = motionHint and motionHint.profileKey or nil,
        motionHint = motionHint and {
            fromX = motionHint.fromX,
            fromY = motionHint.fromY,
            toX = motionHint.toX,
            toY = motionHint.toY,
            dirX = motionHint.dirX,
            dirY = motionHint.dirY,
            durationMs = motionHint.durationMs,
            crawl = motionHint.crawl == true,
            running = motionHint.running == true,
            dtWalkType = motionHint.dtWalkType,
            walkType = motionHint.walkType,
            profileKey = motionHint.profileKey,
        } or nil,
        specialActionKind = specialActionKind,
        specialActionUntil = specialActionUntil,
        specialActionMode = specialActionMode,
        specialActionSeq = npcData._dtSpecialActionSeq,
        fenceActionSeq = npcData._dtFenceActionSeq,
        reloadUntil = npcData._dtReloadUntil,
        reloadActionSeq = npcData._dtReloadActionSeq,
        reloadFamily = npcData._dtReloadFamily,
        magAmmo = npcData._dtMagAmmo,
        magSize = npcData._dtMagSize,
        staminaCurrent = npcData.staminaCurrent,
        staminaMax = npcData.staminaMax,
        staminaState = npcData.staminaState,
        staminaVisibleUntil = npcData._dtStaminaVisibleUntil,
        sprintMode = npcData._dtSprintMode,
        sprintSlowUntil = npcData._dtSprintSlowUntil,
        meleeFatigueUntil = npcData._dtMeleeFatigueUntil,
        rangedFatigueUntil = npcData._dtRangedFatigueUntil,
        tier = tier
    }
    
    if isServer() then
        sendToNearbyPlayers(
            "UpdatePosition",
            posData,
            posData.x,
            posData.y,
            posData.z,
            DTNPCServerCore.BROADCAST_RANGES.CLOSE
        )
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "UpdatePosition", posData)
    end
end

function DTNPCServerCore.NotifyRemoval(uuid, bodyInstanceID, name, removalReason, removalContext)
    if not uuid then return end

    local effectiveReason = removalReason
    if effectiveReason == nil then
        if type(removalContext) == "table" then
            effectiveReason = removalContext.reason or removalContext.removalReason
        elseif type(removalContext) == "string" then
            effectiveReason = removalContext
        end
    end

    local data = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        name = name,
        removalReason = effectiveReason,
        presenceRevision = type(removalContext) == "table" and removalContext.presenceRevision or nil,
    }
    if type(removalContext) == "table" then
        data.killerUsername = removalContext.killerUsername
        data.killerOnlineID = removalContext.killerOnlineID
        data.cleanupCorpse = removalContext.cleanupCorpse
        data.corpseX = removalContext.corpseX
        data.corpseY = removalContext.corpseY
        data.corpseZ = removalContext.corpseZ
        data.preserveCorpse = removalContext.preserveCorpse
        data.staleBodyOnly = removalContext.staleBodyOnly
        data.forcedLiveBodyRemoval = removalContext.forcedLiveBodyRemoval
        data.manualCorpseCreated = removalContext.manualCorpseCreated
    end
    
    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPC", DTNPCServerCore.SanitizeNetworkData(data))
    else
        -- Single Player fallback
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPC", DTNPCServerCore.SanitizeNetworkData(data))
    end
    
    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Remove",
        "Notified removal: " .. (name or uuid) .. " reason=" .. tostring(effectiveReason or "unknown")
    )
end

function DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, presenceRevision)
    if not bodyInstanceID then return end

    local data = {
        uuid = uuid,
        bodyInstanceID = bodyInstanceID,
        presenceRevision = presenceRevision,
    }

    if isServer() then
        sendServerCommand("DTNPC", "RemoveNPCInstance", DTNPCServerCore.SanitizeNetworkData(data))
    else
        triggerEvent("OnServerCommand", "DTNPC", "RemoveNPCInstance", DTNPCServerCore.SanitizeNetworkData(data))
    end
end
