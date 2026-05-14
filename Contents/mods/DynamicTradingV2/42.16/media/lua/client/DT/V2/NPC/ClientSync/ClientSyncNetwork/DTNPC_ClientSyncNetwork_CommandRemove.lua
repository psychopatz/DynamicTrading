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

require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle"

local function resolveRemovalZombie(uuid, bodyInstanceID, reason, staleBodyOnly)
    if (staleBodyOnly == true or reason == "Incapacitated") and bodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID then
        return DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    return Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
end

function Handlers.HandleRemoveNPC(args)
    if not args or not args.uuid then
        return
    end

    local uuid = args.uuid
    local name = args.name or "Unknown"
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)
    local shouldAccept, presenceRevision = Helpers.ShouldAcceptPresence(uuid, args)
    if not shouldAccept then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Remove",
            "Ignored stale RemoveNPC for uuid=" .. tostring(uuid)
                .. " bodyInstanceID=" .. tostring(bodyInstanceID)
                .. " presenceRevision=" .. tostring(presenceRevision)
        )
        return
    end
    if DTNPCClient.SetPresenceRevision then
        DTNPCClient.SetPresenceRevision(uuid, presenceRevision)
    end
    local cachedEntry = DTNPCClient.NPCCache[uuid]
    local factionID = cachedEntry and cachedEntry.npcData and cachedEntry.npcData.factionID or nil
    local reason = args.removalReason or args.status
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
            .. " presenceRevision=" .. tostring(presenceRevision)
    )

    if removeCache then
        DTNPC_ClientInterpolation.ClearNPC(uuid)
    end

    local zombie = resolveRemovalZombie(uuid, bodyInstanceID, reason, staleBodyOnly)

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

    local npcData = cachedEntry and cachedEntry.npcData or nil
    if DTNPCLifecycle and DTNPCLifecycle.HandleClientRemovalCorpse then
        DTNPCLifecycle.HandleClientRemovalCorpse(args, zombie, npcData)
    end

    if removeCache then
        DTNPCClient.RemoveFromCache(uuid, bodyInstanceID)
    elseif bodyInstanceID and DTNPCClient.BodyInstanceIDToUUID and DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] == uuid then
        if DTNPCClient.UncacheLiveZombie then
            DTNPCClient.UncacheLiveZombie(uuid, bodyInstanceID)
        end
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

    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance.refresh then
        DT_RadioScannerWindow.instance:refresh()
    end
end

function Handlers.HandleRemoveNPCInstance(args)
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)
    if not args or not bodyInstanceID then
        return
    end

    local uuid = args.uuid
    local shouldAccept, presenceRevision = Helpers.ShouldAcceptPresence(uuid, args)
    if not shouldAccept then
        return
    end
    if DTNPCClient.SetPresenceRevision then
        DTNPCClient.SetPresenceRevision(uuid, presenceRevision)
    end
    local zombie = DTNPCClient.FindZombieByBodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID) or nil

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    if DTNPCClient.BodyInstanceIDToUUID and DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] == uuid then
        DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = nil
    end
    if DTNPCClient.UncacheLiveZombie then
        DTNPCClient.UncacheLiveZombie(uuid, bodyInstanceID)
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
