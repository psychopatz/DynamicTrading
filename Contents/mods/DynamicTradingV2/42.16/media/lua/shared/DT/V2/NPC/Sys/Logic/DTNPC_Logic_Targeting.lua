-- ==============================================================================
-- DTNPC_Logic_Targeting.lua
-- Target selection helpers for NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

local function findDTNPCTargetByCombatID(combatTargetID)
    local text = tostring(combatTargetID or "")
    local uuid = string.match(text, "^dtnpc:(.+)$")
    if not uuid or uuid == "" then
        return nil
    end

    if DTNPCServerCore and DTNPCServerCore.FindZombieByUUID then
        local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
        if zombie and not zombie:isDead() then
            return zombie
        end
    end

    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        return nil
    end

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        local modData = candidate and candidate.getModData and candidate:getModData() or nil
        if candidate and not candidate:isDead() and modData and modData.DTNPC_UUID == uuid then
            return candidate
        end
    end

    return nil
end

function DTNPCLogic.GetClosestTarget(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then
        return nil, 9999
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return nil, 9999
    end

    if npcData.isHostile then
        if npcData.combatTargetType == "dtnpc" and npcData.combatTargetID then
            local npcTarget = findDTNPCTargetByCombatID(npcData.combatTargetID)
            if npcTarget then
                return npcTarget, Internal.CalculateDistance(zombie, npcTarget)
            end
        end

        local player = zombie:getTarget()

        if isPlayerTarget(player) then
            zombie:setTarget(nil)
        end

        local activePlayers = DTNPCLogic.GetActivePlayers()
        for i = 1, #activePlayers do
            local p = activePlayers[i]
            if p and not p:isDead() then
                local onlineMatch = npcData.lastPlayerAttackerOnlineID
                    and p.getOnlineID
                    and p:getOnlineID() == npcData.lastPlayerAttackerOnlineID
                local usernameMatch = npcData.lastPlayerAttackerUsername
                    and p.getUsername
                    and p:getUsername() == npcData.lastPlayerAttackerUsername
                if onlineMatch or usernameMatch then
                    return p, Internal.CalculateDistance(zombie, p)
                end
            end
        end

        if npcData.masterID then
            for i = 1, #activePlayers do
                local p = activePlayers[i]
                if p and p:getOnlineID() == npcData.masterID then
                    return p, Internal.CalculateDistance(zombie, p)
                end
            end

            local p = getSpecificPlayer(0)
            if p and p:getUsername() == npcData.master then
                return p, Internal.CalculateDistance(zombie, p)
            end
        end
    end

    if npcData.masterID or npcData.master then
        local activePlayers = DTNPCLogic.GetActivePlayers()
        for i = 1, #activePlayers do
            local p = activePlayers[i]
            if p and ((npcData.masterID and p:getOnlineID() == npcData.masterID)
                or (npcData.master and p:getUsername() == npcData.master)) then
                return p, Internal.CalculateDistance(zombie, p)
            end
        end

        local p = getSpecificPlayer(0)
        if p and p:getUsername() == npcData.master then
            return p, Internal.CalculateDistance(zombie, p)
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Logic",
            "Master not found for: " .. (npcData.name or "NPC") .. " (Master: " .. tostring(npcData.master) .. ")"
        )
    end

    return nil, 9999
end
