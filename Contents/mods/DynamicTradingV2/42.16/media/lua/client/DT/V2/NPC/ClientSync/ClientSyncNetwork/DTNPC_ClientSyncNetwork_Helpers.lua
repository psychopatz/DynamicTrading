-- ==============================================================================
-- Shared helpers for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Helpers = Network.Helpers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Helpers
Network.Handlers = Network.Handlers or {}

if Network.Modules.Helpers then
    return
end

Network.Modules.Helpers = true

function Helpers.GetLocalPlayer(playerNum)
    if type(playerNum) == "number" then
        local indexedPlayer = getSpecificPlayer(playerNum)
        if indexedPlayer then
            return indexedPlayer
        end
    end

    local defaultPlayer = getSpecificPlayer(0)
    if defaultPlayer then
        return defaultPlayer
    end

    if getPlayer then
        return getPlayer()
    end

    return nil
end

function Helpers.GetNowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    return os.time() * 1000
end

function Helpers.RecordInterpolation(uuid, x, y, z, updateFreq, motionHint)
    if uuid and x and y then
        DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z or 0, updateFreq, motionHint)
    end
end

function Helpers.ResolveBodyInstanceID(data)
    if not data then return nil end
    return data.bodyInstanceID
end

function Helpers.ResolvePresenceRevision(data)
    if not data then
        return 0
    end

    local revision = data.presenceRevision
    if revision == nil and type(data.npcData) == "table" then
        revision = data.npcData.presenceRevision
    end

    return math.max(0, math.floor(tonumber(revision) or 0))
end

function Helpers.ShouldAcceptPresence(uuid, data)
    local revision = Helpers.ResolvePresenceRevision(data)
    if DTNPCClient.ShouldAcceptPresenceRevision and not DTNPCClient.ShouldAcceptPresenceRevision(uuid, revision) then
        return false, revision
    end

    return true, revision
end

function Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
    local zombie = DTNPCClient.FindZombieByUUID(uuid)
    if not zombie and bodyInstanceID then
        zombie = DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end
    return zombie
end

function Helpers.TrackNPCSystems(zombie, npcData, uuid, bodyInstanceID)
    if DTNPCClient.TrackNPCForHealthBars then
        DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, bodyInstanceID)
    end
    if DTNPCClient.TrackNPCForAmbientDialogue then
        DTNPCClient.TrackNPCForAmbientDialogue(zombie, npcData, uuid, bodyInstanceID)
    end
end

function Helpers.SetReportedState(cached, npcData)
    if not cached or not npcData then
        return
    end

    local loadout = type(npcData.loadout) == "table" and npcData.loadout or {}
    local loadoutSignature = table.concat({
        tostring(loadout.rangedWeapon or ""),
        tostring(loadout.rangedAmmoType or ""),
        tostring(math.max(0, tonumber(loadout.ammoCount) or 0)),
        tostring(loadout.meleeWeapon or ""),
        tostring(loadout.bag or ""),
        tostring(loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or ""),
        tostring(loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or ""),
    }, "|")

    cached.lastReportedState = {
        state = npcData.state,
        tasksCount = (npcData.tasks and #npcData.tasks or 0),
        loadoutSignature = loadoutSignature,
        specialActionSignature = table.concat({
            tostring(npcData._dtSpecialAction or ""),
            tostring(npcData._dtSpecialActionUntil or ""),
            tostring(npcData._dtSpecialActionMode or ""),
            tostring(npcData._dtSpecialActionSeq or ""),
            tostring(npcData._dtFenceActionSeq or ""),
            tostring(npcData._dtReloadUntil or ""),
            tostring(npcData._dtReloadActionSeq or ""),
            tostring(npcData._dtReloadFamily or ""),
            tostring(npcData._dtMagAmmo or ""),
            tostring(npcData._dtMagSize or ""),
        }, "|"),
        combatOrder = npcData.combatOrder,
        guardCombatOrder = npcData.guardCombatOrder,
        protectNoticeSerial = npcData.protectNoticeSerial or 0,
    }
end
