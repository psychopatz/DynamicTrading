-- ==============================================================================
-- DTNPC_Logic_Targeting.lua
-- Target selection helpers for NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

function DTNPCLogic.GetClosestTarget(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then
        return nil, 9999
    end

    if npcData.isHostile then
        local player = zombie:getTarget()

        if player and instanceof(player, "IsoPlayer") then
            return player, Internal.CalculateDistance(zombie, player)
        end

        if npcData.masterID then
            local activePlayers = DTNPCLogic.GetActivePlayers()
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
