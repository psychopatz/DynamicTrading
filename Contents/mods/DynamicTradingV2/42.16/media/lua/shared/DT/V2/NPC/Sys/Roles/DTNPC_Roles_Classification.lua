-- ==============================================================================
-- DTNPC_Roles_Classification.lua
-- Public role classification helpers for DT NPC policy.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}
DTNPCRoles.Internal = DTNPCRoles.Internal or {}

local Internal = DTNPCRoles.Internal

local function isFriendlyOwnedFactionMember(npcData, username)
    local playerFaction = Internal.getOwnedFactionForUsername(username)
    local npcFaction = Internal.getNPCOwnedFaction(npcData)
    if not playerFaction or not npcFaction then
        return false
    end

    local leftID = Internal.toText(playerFaction.id)
    local rightID = Internal.toText(npcFaction.id)
    return leftID ~= "" and leftID == rightID
end

function DTNPCRoles.CanUsePlayerAuthority(npcData, playerObj)
    if type(npcData) ~= "table" or not playerObj or not instanceof or not instanceof(playerObj, "IsoPlayer") then
        return false
    end

    local context = DTNPCRoles.ResolveContext(npcData)
    if context.isPlayerOwned ~= true or context.isBanditLike == true or context.isHostileFaction == true then
        return false
    end

    local playerID = Internal.getPlayerOnlineID(playerObj)
    if playerID ~= nil then
        if npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end
        if npcData.preIncapMasterID ~= nil and tonumber(npcData.preIncapMasterID) == tonumber(playerID) then
            return true
        end
    end

    local username = Internal.getPlayerUsername(playerObj)
    if not username or username == "" then
        return false
    end

    if Internal.toText(npcData.master) == username
        or Internal.toText(npcData.preIncapMaster) == username
        or Internal.toText(npcData.ownerUsername) == username then
        return true
    end

    local faction = Internal.getFactionData(npcData.factionID)
    local leaderUsername = faction and Internal.toText(faction.leaderUsername or faction.ownerUsername) or ""
    if leaderUsername ~= "" and leaderUsername == username then
        return true
    end

    return isFriendlyOwnedFactionMember(npcData, username)
end

function DTNPCRoles.ResolveDefaultState(npcData)
    if type(npcData) ~= "table" then
        return "Idle"
    end

    if Internal.toText(npcData.linkedWorkerID) ~= ""
        and DTNPCColonyRuntime
        and DTNPCColonyRuntime.SyncBehaviorIdentity then
        local ok, state = pcall(DTNPCColonyRuntime.SyncBehaviorIdentity, npcData)
        if ok and Internal.toText(state) ~= "" then
            return tostring(state)
        end
    end

    if Internal.hasAssignedMaster(npcData) then
        return "Follow"
    end

    if npcData.guardCombatOrder ~= nil or npcData.stationaryPostX ~= nil then
        return "Guard"
    end

    local colonyState = Internal.toText(npcData.dcBehaviorState)
    if colonyState ~= "" then
        return colonyState
    end

    return "Idle"
end
