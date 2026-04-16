-- ==============================================================================
-- Nearby sync request flow for client-side network sync modules.
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

if Network.Modules.RequestFlow then
    return
end

Network.Modules.RequestFlow = true

function DTNPCClient.QueueNearbySync(reason, resetState)
    if isServer() and isDedicatedServer() then
        return
    end

    if resetState and DTNPCClient.ResetSessionState then
        DTNPCClient.ResetSessionState(reason or "queued-nearby-sync")
    else
        DTNPCClient.PendingNearbySyncReason = tostring(reason or "queued-nearby-sync")
    end
end

function DTNPCClient.SendNearbySyncRequest(player, reason)
    if not isClient() then
        return false
    end

    player = player or Helpers.GetLocalPlayer(0)
    if not player then
        DTNPCClient.PendingNearbySyncReason = tostring(reason or DTNPCClient.PendingNearbySyncReason or "missing-player")
        return false
    end

    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()

    sendClientCommand(player, "DTNPC", "RequestNearbySync", {
        x = px,
        y = py,
        z = pz,
        nearRadius = DTNPCClient.NEARBY_SYNC_NEAR_RADIUS or 350,
        metadataRadius = DTNPCClient.NEARBY_SYNC_METADATA_RADIUS or 1000,
    })

    DTNPCClient.LastNearbySyncX = px
    DTNPCClient.LastNearbySyncY = py
    DTNPCClient.LastNearbySyncZ = pz
    DTNPCClient.LastNearbySyncTime = Helpers.GetNowMillis()
    DTNPCClient.PendingNearbySyncReason = nil
    DTNPCClient.hasSyncedOnce = true

    DynamicTrading.Log("DTV2", "NPC", "Sync", "Requested nearby sync (" .. tostring(reason or "periodic") .. ") for player: " .. player:getUsername())
    return true
end

function DTNPCClient.MaybeRequestNearbySync()
    if not isClient() then
        return
    end

    local player = Helpers.GetLocalPlayer(0)
    if not player then
        return
    end

    local now = Helpers.GetNowMillis()
    local lastSyncTime = DTNPCClient.LastNearbySyncTime or 0
    local elapsed = now - lastSyncTime
    local minInterval = DTNPCClient.NEARBY_SYNC_MIN_INTERVAL_MS or 4000
    local recoveryInterval = DTNPCClient.NEARBY_SYNC_RECOVERY_INTERVAL_MS or 750
    local staleInterval = DTNPCClient.NEARBY_SYNC_STALE_INTERVAL_MS or 15000

    if DTNPCClient.PendingNearbySyncReason then
        if elapsed >= recoveryInterval then
            DTNPCClient.SendNearbySyncRequest(player, DTNPCClient.PendingNearbySyncReason)
        end
        return
    end

    if not DTNPCClient.hasSyncedOnce then
        if elapsed >= recoveryInterval then
            DTNPCClient.SendNearbySyncRequest(player, "first-nearby-sync")
        end
        return
    end

    local lastX = DTNPCClient.LastNearbySyncX
    local lastY = DTNPCClient.LastNearbySyncY
    local lastZ = DTNPCClient.LastNearbySyncZ

    if lastX == nil or lastY == nil or lastZ == nil then
        if elapsed >= recoveryInterval then
            DTNPCClient.SendNearbySyncRequest(player, "sync-position-missing")
        end
        return
    end

    local dx = player:getX() - lastX
    local dy = player:getY() - lastY
    local dz = player:getZ() - lastZ
    local dist = math.sqrt(dx * dx + dy * dy)
    local moveThreshold = DTNPCClient.NEARBY_SYNC_MOVE_THRESHOLD or 45

    if elapsed >= staleInterval then
        DTNPCClient.SendNearbySyncRequest(player, "stale-refresh")
        return
    end

    if elapsed >= minInterval and (dist >= moveThreshold or math.abs(dz) >= 1) then
        DTNPCClient.SendNearbySyncRequest(player, "movement-refresh")
    end
end

function DTNPCClient.RequestInitialSync(playerNum)
    if isServer() and isDedicatedServer() then
        return
    end

    DTNPCClient.QueueNearbySync("initial-sync", true)

    local player = Helpers.GetLocalPlayer(playerNum)
    if player then
        DTNPCClient.SendNearbySyncRequest(player, "initial-sync")
    else
        DynamicTrading.Log("DTV2", "NPC", "Sync", "Queued initial nearby sync until player is ready")
    end
end
