-- ==============================================================================
-- DTNPC_Logic_Combat.lua
-- Combat initiation checks for shared NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}

local function isFriendlyAuthorityPlayer(npcData, player)
    if DTNPCProtect and DTNPCProtect.Internal and DTNPCProtect.Internal.isFriendlyAuthorityPlayer then
        local ok, result = pcall(DTNPCProtect.Internal.isFriendlyAuthorityPlayer, npcData, player)
        if ok then
            return result == true
        end
    end

    return false
end

local function isPlayerTarget(target)
    return target and instanceof and instanceof(target, "IsoPlayer")
end

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

        if npcData.isBandit == true and DTNPCBandits and DTNPCBandits.OnBanditDamagedByPlayer then
            if DTNPCBandits.OnBanditDamagedByPlayer(npcData, attacker) then
                zombie:setAttackedBy(nil)
                return
            end
        end

        if (master and attacker == master) or isFriendlyAuthorityPlayer(npcData, attacker) then
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "Ignoring friendly authority damage for " .. tostring(npcData.name or npcData.uuid)
                    .. " attacker=" .. tostring(attacker.getUsername and attacker:getUsername() or "Unknown Player")
            )
            zombie:setAttackedBy(nil)
            return
        end

        if not npcData.isHostile then
            local dist = nil
            if attacker.getX and attacker.getY and zombie.getX and zombie.getY then
                local dx = attacker:getX() - zombie:getX()
                local dy = attacker:getY() - zombie:getY()
                dist = math.sqrt((dx * dx) + (dy * dy))
            end

            local nextState = "Attack"
            if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
                DTNPCProtect.EnsureDataDefaults(npcData)
                if DTNPCProtect.ResolveHostileCombatState then
                    nextState = DTNPCProtect.ResolveHostileCombatState(npcData, npcData.state, dist)
                end
            end

            npcData.state = nextState
            npcData.isHostile = true
            npcData.tasks = {}

            local attackerName = attacker:getUsername() or "Unknown Player"
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "Combat Initiated! " .. npcData.name .. " is attacking " .. attackerName
                    .. " using state=" .. tostring(nextState)
            )

            if not isPlayerTarget(attacker) then
                zombie:setTarget(attacker)
            else
                zombie:setTarget(nil)
            end
            zombie:setAttackedBy(nil)
        end
    end
end
