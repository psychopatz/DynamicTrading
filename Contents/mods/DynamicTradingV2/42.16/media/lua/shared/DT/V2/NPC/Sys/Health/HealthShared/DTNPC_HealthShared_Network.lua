-- ==============================================================================
-- DTNPC_HealthShared_Network.lua
-- Network and client-report helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function applyFactionBiasPenalty(playerObj, factionID, delta, reason)
    if not playerObj or not factionID then
        return false
    end

    local amount = tonumber(delta) or 0
    if amount == 0 then
        return false
    end

    if isServer() then
        return DynamicTrading
            and DynamicTrading.ServerHelpers
            and DynamicTrading.ServerHelpers.SendReputationSync
            and DynamicTrading.ServerHelpers.SendReputationSync(playerObj, {
                action = "factionBiasDelta",
                factionID = tostring(factionID),
                amount = amount,
                reason = reason or "npc_damage_penalty"
            })
            or false
    end

    if not isClient() and DT_Reputation and DT_Reputation.ModifyFactionBias then
        DT_Reputation.ModifyFactionBias(tostring(factionID), amount, reason or "npc_damage_penalty")
        return true
    end

    return false
end

internal.applyFactionBiasPenalty = applyFactionBiasPenalty

local function isLocalPlayerAttacker(attacker)
    if not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return false
    end

    if attacker.isLocalPlayer then
        local ok, result = pcall(attacker.isLocalPlayer, attacker)
        if ok and result == true then
            return true
        end
    end

    if attacker.getPlayerNum and getSpecificPlayer then
        local ok, playerNum = pcall(attacker.getPlayerNum, attacker)
        if ok and playerNum ~= nil and playerNum >= 0 then
            local localPlayer = getSpecificPlayer(playerNum)
            if localPlayer == attacker then
                return true
            end
        end
    end

    return false
end

internal.isLocalPlayerAttacker = isLocalPlayerAttacker

local function reportWeaponHitToServer(attacker, target, weapon, damage)
    if not internal.isRemoteClient() or not sendClientCommand then
        return false
    end
    if not isLocalPlayerAttacker(attacker) then
        return false
    end

    local modData = target and target.getModData and target:getModData() or nil
    local uuid = modData and modData.DTNPC_UUID or nil
    if not uuid then
        return false
    end

    sendClientCommand("DTNPC", "ReportWeaponHit", {
        uuid = uuid,
        bodyInstanceID = target.getPersistentOutfitID and target:getPersistentOutfitID() or nil,
        damage = tonumber(damage) or 0,
        attackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil,
        weaponFullType = weapon and weapon.getFullType and weapon:getFullType() or nil,
        targetHealthAfterHit = target.getHealth and target:getHealth() or nil,
    })

    return true
end

internal.reportWeaponHitToServer = reportWeaponHitToServer
