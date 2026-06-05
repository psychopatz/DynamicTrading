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
    if DTNPCRoles and DTNPCRoles.ResolveContext then
        local ok, context = pcall(DTNPCRoles.ResolveContext, npcData)
        if ok and type(context) == "table" then
            return context.isPlayerOwned == true
        end
    end

    return type(npcData) == "table" and npcData.linkedWorkerID ~= nil
end

local function getOwnedFactionForUsername(username)
    local owner = tostring(username or "")
    if owner == "" then
        return nil
    end
    if not (DynamicTrading_Factions and DynamicTrading_Factions.GetPlayerFaction) then
        return nil
    end

    local ok, faction = pcall(DynamicTrading_Factions.GetPlayerFaction, owner)
    if ok and type(faction) == "table" and faction.playerOwned == true then
        return faction
    end
    return nil
end

local function getOwnedFactionForNPC(npcData)
    if not npcData then
        return nil
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local factionID = tostring(npcData.factionID or "")
        if factionID ~= "" and factionID ~= "Independent" then
            local ok, faction = pcall(DynamicTrading_Factions.GetFaction, factionID)
            if ok and type(faction) == "table" and faction.playerOwned == true then
                return faction
            end
        end
    end

    return getOwnedFactionForUsername(npcData.ownerUsername)
end

local function isFriendlyOwnedFactionMember(npcData, username)
    local playerFaction = getOwnedFactionForUsername(username)
    local npcFaction = getOwnedFactionForNPC(npcData)
    if not playerFaction or not npcFaction then
        return false
    end

    return tostring(playerFaction.id or "") ~= ""
        and tostring(playerFaction.id or "") == tostring(npcFaction.id or "")
end

local function isFriendlyAuthorityPlayer(npcData, player)
    if DTNPCRoles and DTNPCRoles.CanUsePlayerAuthority then
        local ok, result = pcall(DTNPCRoles.CanUsePlayerAuthority, npcData, player)
        if ok then
            return result == true
        end
    end

    return false
end

local function getDynamicColoniesSandbox()
    return SandboxVars and SandboxVars.DynamicColonies or nil
end

local function isDynamicColoniesToggleEnabled(key)
    local sandbox = getDynamicColoniesSandbox()
    if sandbox and sandbox[key] ~= nil then
        return sandbox[key] ~= false
    end
    return false
end

local function isWeaponDurabilitySandboxEnabled()
    return isDynamicColoniesToggleEnabled("PlayerOwnedNPCWeaponDurability")
end

local function isAmmoConsumptionSandboxEnabled()
    return isDynamicColoniesToggleEnabled("PlayerOwnedNPCAmmoConsumption")
end

local function shouldConsumeWeaponDurabilityRaw(npcData)
    if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
        local ok, shouldRequire = pcall(DTNPCRoles.ShouldRequireItems, npcData, "durability")
        if ok then
            return shouldRequire == true and isWeaponDurabilitySandboxEnabled()
        end
    end
    return isPlayerOwnedTraderRaw(npcData) and isWeaponDurabilitySandboxEnabled()
end

local function shouldConsumeAmmoRaw(npcData)
    if DTNPCRoles and DTNPCRoles.ShouldRequireItems then
        local ok, shouldRequire = pcall(DTNPCRoles.ShouldRequireItems, npcData, "ammo")
        if ok then
            return shouldRequire == true and isAmmoConsumptionSandboxEnabled()
        end
    end
    return isPlayerOwnedTraderRaw(npcData) and isAmmoConsumptionSandboxEnabled()
end

Internal.syncProtectNotice = syncProtectNotice
Internal.buildProtectDebugSummary = buildProtectDebugSummary
Internal.isPlayerOwnedTraderRaw = isPlayerOwnedTraderRaw
Internal.isFriendlyAuthorityPlayer = isFriendlyAuthorityPlayer
Internal.isWeaponDurabilitySandboxEnabled = isWeaponDurabilitySandboxEnabled
Internal.isAmmoConsumptionSandboxEnabled = isAmmoConsumptionSandboxEnabled
Internal.shouldConsumeWeaponDurabilityRaw = shouldConsumeWeaponDurabilityRaw
Internal.shouldConsumeAmmoRaw = shouldConsumeAmmoRaw
