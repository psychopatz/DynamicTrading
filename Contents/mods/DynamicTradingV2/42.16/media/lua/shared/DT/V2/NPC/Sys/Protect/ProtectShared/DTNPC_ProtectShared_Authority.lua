-- ==============================================================================
-- DTNPC_ProtectShared_Authority.lua
-- Shared authority, ownership, and sync helpers for DTNPC protect modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function syncProtectNotice(zombie, npcData)
    if not zombie or not npcData or not npcData.uuid then
        return false
    end
    if not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return false
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return false
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
    return true
end

local function buildProtectDebugSummary(npcData)
    npcData = type(npcData) == "table" and npcData or {}
    local loadout = type(npcData.loadout) == "table" and npcData.loadout or {}

    return table.concat({
        "uuid=" .. tostring(npcData.uuid or "?"),
        "state=" .. tostring(npcData.state or "nil"),
        "order=" .. tostring(npcData.combatOrder or "nil"),
        "melee=" .. tostring(loadout.meleeWeapon or "nil"),
        "ranged=" .. tostring(loadout.rangedWeapon or "nil"),
        "ammo=" .. tostring(loadout.ammoCount or 0),
    }, " | ")
end

local function isPlayerOwnedTraderRaw(npcData)
    if not npcData then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    if npcData.isPlayerFactionTrader == true then
        return true
    end

    if npcData.masterID ~= nil then
        return true
    end
    if npcData.master and tostring(npcData.master) ~= "" then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        if faction and faction.playerOwned == true then
            return true
        end
    end

    return npcData.linkedWorkerID ~= nil
end

local function isFriendlyAuthorityPlayer(npcData, player)
    if not npcData or not player or not instanceof or not instanceof(player, "IsoPlayer") then
        return false
    end

    if npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits" then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
        return true
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return false
    end

    if npcData.master and tostring(npcData.master) == username then
        return true
    end

    if npcData.ownerUsername and tostring(npcData.ownerUsername) == username then
        return true
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(npcData.factionID)
        local leaderUsername = faction and (faction.leaderUsername or faction.ownerUsername) or nil
        if leaderUsername and tostring(leaderUsername) == username then
            return true
        end
    end

    return false
end

local function isWeaponDurabilitySandboxEnabled()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and sandbox.NPCWeaponDurability ~= nil then
        return sandbox.NPCWeaponDurability ~= false
    end
    return true
end

local function shouldConsumeWeaponDurabilityRaw(npcData)
    return isPlayerOwnedTraderRaw(npcData) and isWeaponDurabilitySandboxEnabled()
end

Internal.syncProtectNotice = syncProtectNotice
Internal.buildProtectDebugSummary = buildProtectDebugSummary
Internal.isPlayerOwnedTraderRaw = isPlayerOwnedTraderRaw
Internal.isFriendlyAuthorityPlayer = isFriendlyAuthorityPlayer
Internal.isWeaponDurabilitySandboxEnabled = isWeaponDurabilitySandboxEnabled
Internal.shouldConsumeWeaponDurabilityRaw = shouldConsumeWeaponDurabilityRaw
