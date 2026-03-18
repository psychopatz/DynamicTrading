if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

function DT_Reputation.RecordNPCHit(uuid, factionID)
    if not uuid then return end
    if not DT_Reputation.EnsureLoaded() then return end

    DT_Reputation.state.recentHits[uuid] = {
        factionID = factionID,
        at = getTimeInMillis(),
    }
end

local function isLocalPlayerKiller(killerUsername, killerOnlineID)
    local player = Internal.GetLocalPlayer()
    if not player then return false end

    if killerOnlineID ~= nil and player.getOnlineID and player:getOnlineID() == killerOnlineID then
        return true
    end

    if killerUsername and player.getUsername and player:getUsername() == killerUsername then
        return true
    end

    return false
end

function DT_Reputation.TryApplyKillPenalty(uuid, factionID, zombie, killerUsername, killerOnlineID)
    if not uuid then return false end
    if not DT_Reputation.EnsureLoaded() then return false end

    local hit = DT_Reputation.state.recentHits[uuid]
    DT_Reputation.state.recentHits[uuid] = nil

    local confirmedDead = false
    if zombie and (zombie:isDead() or zombie:getHealth() <= 0) then
        confirmedDead = true
    elseif hit and (getTimeInMillis() - (hit.at or 0)) <= DT_Reputation.FAST_KILL_CONFIRM_MS then
        confirmedDead = true
    end

    if killerUsername ~= nil or killerOnlineID ~= nil then
        local resolvedFactionID = factionID or (hit and hit.factionID) or nil
        if resolvedFactionID and isLocalPlayerKiller(killerUsername, killerOnlineID) then
            DT_Reputation.ApplyKillPenalty(resolvedFactionID)
            if DT_Reputation.AUTO_DEBUG then
                DT_Reputation.DebugDump(uuid, resolvedFactionID, "kill_confirmed_server")
            end
            return true
        end
        return false
    end

    if not hit then
        return false
    end

    local elapsed = getTimeInMillis() - (hit.at or 0)
    if elapsed > DT_Reputation.HIT_ATTRIBUTION_MS then
        return false
    end

    if not confirmedDead then
        return false
    end

    local resolvedFactionID = factionID or hit.factionID
    if not resolvedFactionID then
        return false
    end

    DT_Reputation.ApplyKillPenalty(resolvedFactionID)
    if DT_Reputation.AUTO_DEBUG then
        DT_Reputation.DebugDump(uuid, resolvedFactionID, "kill_confirmed")
    end
    return true
end
