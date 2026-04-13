-- ==============================================================================
-- Removal handlers for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Helpers = Network.Helpers or {}
local Handlers = Network.Handlers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Helpers
Network.Handlers = Handlers

if Network.Modules.CommandRemove then
    return
end

Network.Modules.CommandRemove = true

local pendingIncapacitationCorpseCleanups = {}

local function cleanupStrayIncapacitationCorpse(x, y, z, npcData, reason)
    local cell = getCell and getCell() or nil
    local square = cell and cell:getGridSquare(x, y, z or 0) or nil
    if not square then
        return false
    end

    local removed = 0
    local function purgeFromList(list)
        if not list then
            return
        end

        for i = list:size() - 1, 0, -1 do
            local obj = list:get(i)
            if obj and instanceof and instanceof(obj, "IsoDeadBody") then
                obj:removeFromWorld()
                obj:removeFromSquare()
                removed = removed + 1
            end
        end
    end

    if square.getStaticMovingObjects then
        purgeFromList(square:getStaticMovingObjects())
    end
    if removed <= 0 and square.getMovingObjects then
        purgeFromList(square:getMovingObjects())
    end

    if removed > 0 then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Death",
            "Client removed stray incapacitation corpse(s) for "
                .. tostring(npcData and (npcData.name or npcData.uuid) or "Unknown")
                .. " count=" .. tostring(removed)
                .. " reason=" .. tostring(reason or "incap_transition")
                .. " square=" .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z or 0)
        )
        return true
    end

    return false
end

local function runPendingIncapacitationCorpseCleanups()
    for i = #pendingIncapacitationCorpseCleanups, 1, -1 do
        local cleanup = pendingIncapacitationCorpseCleanups[i]
        cleanup.attempts = (cleanup.attempts or 0) + 1

        local removed = cleanupStrayIncapacitationCorpse(
            cleanup.x,
            cleanup.y,
            cleanup.z,
            cleanup.npcData,
            cleanup.reason
        )

        if removed or cleanup.attempts >= (cleanup.maxAttempts or 8) then
            table.remove(pendingIncapacitationCorpseCleanups, i)
        end
    end

    if #pendingIncapacitationCorpseCleanups <= 0 and Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
    end
end

local function scheduleIncapacitationCorpseCleanup(x, y, z, npcData, reason)
    if not x or not y then
        return
    end

    table.insert(pendingIncapacitationCorpseCleanups, {
        x = x,
        y = y,
        z = z or 0,
        npcData = npcData,
        reason = reason,
        attempts = 0,
        maxAttempts = 8,
    })

    if Events and Events.OnTick then
        Events.OnTick.Remove(runPendingIncapacitationCorpseCleanups)
        Events.OnTick.Add(runPendingIncapacitationCorpseCleanups)
    end
end

local function resolveRemovalZombie(uuid, bodyInstanceID, reason, staleBodyOnly)
    if (staleBodyOnly == true or reason == "Incapacitated") and bodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID then
        return DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    return Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
end

local function createCorpseFromLiveRemovalZombie(zombie, npcData, name)
    if not zombie or not IsoDeadBody then
        return false
    end

    local ok, body = pcall(IsoDeadBody.new, zombie, false, true)
    if not ok or not body then
        ok, body = pcall(IsoDeadBody.new, zombie, false)
    end
    if not ok or not body then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "Client failed to create manual corpse for preserved dead NPC "
                .. tostring(name or (npcData and (npcData.name or npcData.uuid)) or "Unknown")
                .. " error=" .. tostring(body)
        )
        return false
    end

    local bodyModData = body.getModData and body:getModData() or nil
    if bodyModData and npcData then
        bodyModData.DTNPC_UUID = npcData.uuid
        bodyModData.DTNPC_Name = npcData.name
        bodyModData.DTNPC_FinalKillCorpse = true
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Death",
        "Client created manual corpse for preserved dead NPC: "
            .. tostring(name or (npcData and (npcData.name or npcData.uuid)) or "Unknown")
    )
    return true
end

function Handlers.HandleRemoveNPC(args)
    if not args or not args.uuid then
        return
    end

    local uuid = args.uuid
    local name = args.name or "Unknown"
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)
    local cachedEntry = DTNPCClient.NPCCache[uuid]
    local factionID = cachedEntry and cachedEntry.npcData and cachedEntry.npcData.factionID or nil
    local reason = args.removalReason or args.status
    local preserveCorpse = reason == "Dead" and args.preserveCorpse == true
    local staleBodyOnly = args.staleBodyOnly == true
    local removeCache = not staleBodyOnly
    local cachedBodyInstanceID = cachedEntry and cachedEntry.npcData and cachedEntry.npcData.currentBodyInstanceID or nil
    if reason == "Incapacitated" and bodyInstanceID and cachedBodyInstanceID and cachedBodyInstanceID ~= bodyInstanceID then
        removeCache = false
    end

    if name == "Unknown" and DTNPCClient.NPCCache[uuid] then
        name = DTNPCClient.NPCCache[uuid].npcData.name or "Unknown"
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Remove",
        "Received RemoveNPC for: " .. name .. " (" .. uuid .. ")"
            .. " reason=" .. tostring(args.removalReason or args.status or "unknown")
            .. " returnStatus=" .. tostring(args.returnStatus or "nil")
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
    )

    if removeCache then
        DTNPC_ClientInterpolation.ClearNPC(uuid)
    end

    local zombie = resolveRemovalZombie(uuid, bodyInstanceID, reason, staleBodyOnly)
    local zombieX = zombie and math.floor(zombie:getX()) or nil
    local zombieY = zombie and math.floor(zombie:getY()) or nil
    local zombieZ = zombie and math.floor(zombie:getZ()) or nil

    if DT_Reputation and not staleBodyOnly then
        if reason == "Incapacitated" then
            DT_Reputation.ApplyIncapPenalty(uuid, factionID)
        elseif reason == "Dead" then
            if factionID and factionID ~= "Independent" then
                DT_Reputation.TryApplyKillPenalty(
                    uuid,
                    factionID,
                    zombie,
                    args.killerUsername,
                    args.killerOnlineID
                )
            end
        end
    end

    local zombieIsDead = zombie and zombie.isDead and zombie:isDead() == true
    if zombie and preserveCorpse and not zombieIsDead then
        local npcData = cachedEntry and cachedEntry.npcData or nil
        local createdCorpse = args.manualCorpseCreated == true
            or createCorpseFromLiveRemovalZombie(zombie, npcData, name) == true
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Remove",
            "Removed live local body for dead NPC after "
                .. (createdCorpse and "creating/receiving corpse: " or "corpse creation failed: ")
                .. name
        )
    elseif zombie and not preserveCorpse then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log("DTV2", "NPC", "Remove", "SUCCESS: Removed zombie from local world: " .. name)
    elseif zombie and preserveCorpse then
        DynamicTrading.Log("DTV2", "NPC", "Remove", "Preserved dead NPC body in local world: " .. name)
    end

    if args.cleanupCorpse == true or (reason == "Incapacitated" and args.cleanupCorpse == nil) then
        local npcData = cachedEntry and cachedEntry.npcData or nil
        local corpseX = args.corpseX or (npcData and npcData.lastX) or zombieX
        local corpseY = args.corpseY or (npcData and npcData.lastY) or zombieY
        local corpseZ = args.corpseZ or (npcData and npcData.lastZ) or zombieZ or 0
        if corpseX and corpseY then
            local cleanupReason = reason == "Incapacitated" and "client_death_to_incapacitated" or "client_stale_body_cleanup"
            cleanupStrayIncapacitationCorpse(corpseX, corpseY, corpseZ, npcData, cleanupReason)
            scheduleIncapacitationCorpseCleanup(corpseX, corpseY, corpseZ, npcData, cleanupReason .. "_delayed")
        end
    end

    if removeCache then
        DTNPCClient.RemoveFromCache(uuid, bodyInstanceID)
    elseif bodyInstanceID and DTNPCClient.BodyInstanceIDToUUID and DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] == uuid then
        DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = nil
    end

    if removeCache and DT_V2_RadarManager then
        if DT_V2_RadarManager.ClientRoster and DT_V2_RadarManager.ClientRoster.Souls then
            DT_V2_RadarManager.ClientRoster.Souls[uuid] = nil
        end
        DT_V2_RadarManager.FoundTraders[uuid] = nil
    end

    if removeCache and DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Traders then
        DynamicTrading_Client.Cache.Traders[uuid] = nil
    end

    if DT_V2_RadarWindow and DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance.refresh then
        DT_V2_RadarWindow.instance:refresh()
    end
end

function Handlers.HandleRemoveNPCInstance(args)
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)
    if not args or not bodyInstanceID then
        return
    end

    local uuid = args.uuid
    local zombie = DTNPCClient.FindZombieByBodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID) or nil

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    if DTNPCClient.BodyInstanceIDToUUID and DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] == uuid then
        DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = nil
    end

    local tracked = DTNPCClient.HealthBarTracked and uuid and DTNPCClient.HealthBarTracked[uuid] or nil
    if tracked and tracked.bodyInstanceID == bodyInstanceID then
        tracked.zombie = nil
        tracked.bodyInstanceID = nil
        tracked.nextResolveAt = 0
    end

    local ambientTracked = DTNPCClient.DialogueAmbientTracked and uuid and DTNPCClient.DialogueAmbientTracked[uuid] or nil
    if ambientTracked and ambientTracked.bodyInstanceID == bodyInstanceID then
        ambientTracked.zombie = nil
        ambientTracked.bodyInstanceID = nil
        ambientTracked.nextResolveAt = 0
    end
end
