-- ==============================================================================
-- DTNPC_Logic_Combat.lua
-- Combat initiation checks for shared NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}

function DTNPCLogic.CheckForCombatInitiation(zombie, npcData, master, wasDamaged)
    if not zombie or not npcData then
        return
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        npcData.state = "Incapacitated"
        npcData.isHostile = false
        zombie:setTarget(nil)
        zombie:setAttackedBy(nil)
        return
    end

    local attacker = zombie:getAttackedBy()

    if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
        npcData.lastPlayerAttackerUsername = attacker.getUsername and attacker:getUsername() or nil
        npcData.lastPlayerAttackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil
        npcData.lastPlayerAttackedAt = getTimeInMillis and getTimeInMillis() or nil

        local isMaster = (master and attacker == master)

        if isMaster or not npcData.isHostile then
            npcData.state = "AttackRange"
            npcData.isHostile = true
            npcData.tasks = {}

            local attackerName = attacker:getUsername() or "Unknown Player"
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "Combat Initiated! " .. npcData.name .. " is attacking " .. attackerName
            )

            zombie:setTarget(attacker)
            zombie:setAttackedBy(nil)
        end
    end
end
