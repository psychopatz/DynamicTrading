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

function DTNPCLogic.GetClosestTarget(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then
        return nil, 9999
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return nil, 9999
    end

    if npcData.isHostile then
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
