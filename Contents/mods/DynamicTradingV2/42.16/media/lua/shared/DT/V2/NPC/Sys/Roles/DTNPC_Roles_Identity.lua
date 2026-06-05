-- ==============================================================================
-- DTNPC_Roles_Identity.lua
-- Shared identity and faction helpers for DT NPC role policy.
-- ==============================================================================

DTNPCRoles = DTNPCRoles or {}
DTNPCRoles.Internal = DTNPCRoles.Internal or {}

local Internal = DTNPCRoles.Internal

local function toText(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

local function getFactionData(factionID)
    local resolvedID = toText(factionID)
    if resolvedID == "" or not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return nil
    end

    local ok, faction = pcall(DynamicTrading_Factions.GetFaction, resolvedID)
    if ok and type(faction) == "table" then
        return faction
    end

    return nil
end

local function getOwnedFactionForUsername(username)
    local resolvedName = toText(username)
    if resolvedName == "" or not DynamicTrading_Factions or not DynamicTrading_Factions.GetPlayerFaction then
        return nil
    end

    local ok, faction = pcall(DynamicTrading_Factions.GetPlayerFaction, resolvedName)
    if ok and type(faction) == "table" and faction.playerOwned == true then
        return faction
    end

    return nil
end

local function getNPCOwnedFaction(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local faction = getFactionData(npcData.factionID)
    if faction and faction.playerOwned == true then
        return faction
    end

    return getOwnedFactionForUsername(npcData.ownerUsername)
end

local function getPlayerUsername(playerObj)
    if not playerObj or not instanceof or not instanceof(playerObj, "IsoPlayer") then
        return nil
    end

    local username = playerObj.getUsername and playerObj:getUsername() or nil
    if username and username ~= "" then
        return tostring(username)
    end

    return nil
end

local function getPlayerOnlineID(playerObj)
    if not playerObj or not instanceof or not instanceof(playerObj, "IsoPlayer") then
        return nil
    end

    return playerObj.getOnlineID and playerObj:getOnlineID() or nil
end

Internal.toText = toText
Internal.getFactionData = getFactionData
Internal.getOwnedFactionForUsername = getOwnedFactionForUsername
Internal.getNPCOwnedFaction = getNPCOwnedFaction
Internal.getPlayerUsername = getPlayerUsername
Internal.getPlayerOnlineID = getPlayerOnlineID
