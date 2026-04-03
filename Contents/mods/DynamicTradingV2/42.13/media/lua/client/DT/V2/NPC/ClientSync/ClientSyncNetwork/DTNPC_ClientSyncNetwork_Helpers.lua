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

function Helpers.RecordInterpolation(uuid, x, y, z)
    if uuid and x and y then
        DTNPC_ClientInterpolation.RecordUpdate(uuid, x, y, z or 0)
    end
end

function Helpers.ResolveBodyInstanceID(data)
    if not data then return nil end
    return data.bodyInstanceID
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

    cached.lastReportedState = {
        state = npcData.state,
        tasksCount = (npcData.tasks and #npcData.tasks or 0)
    }
end
