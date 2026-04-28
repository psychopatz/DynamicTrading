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

local function getPlayerAttackerIdentity(attacker)
    if not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return nil
    end

    if attacker.getOnlineID then
        local onlineID = attacker:getOnlineID()
        if onlineID and onlineID ~= 0 then
            return "online:" .. tostring(onlineID)
        end
    end

    if attacker.getUsername then
        local username = attacker:getUsername()
        if username and username ~= "" then
            return "user:" .. tostring(username)
        end
    end

    return nil
end

local function isValidPlayerDamageAttribution(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return false
    end

    local combatHealth = npcData.combatHealth
    if type(combatHealth) ~= "table" then
        return false
    end

    if tostring(combatHealth.lastAttackerType or "") ~= "player" then
        return false
    end

    local expectedAttackerID = tostring(combatHealth.lastAttackerID or "")
    local resolvedAttackerID = tostring(getPlayerAttackerIdentity(attacker) or "")
    if expectedAttackerID ~= "" and resolvedAttackerID ~= "" then
        return expectedAttackerID == resolvedAttackerID
    end

    return true
end

local function getDTNPCAttackerData(attacker)
    local modData = attacker and attacker.getModData and attacker:getModData() or nil
    if not (modData and modData.IsDTNPC == true) then
        return nil, nil
    end

    local attackerData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (attackerData and attackerData.uuid)
    if not attackerData and uuid and DTNPCManager and DTNPCManager.Data then
        attackerData = DTNPCManager.Data[uuid]
    end
    return attackerData, uuid
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
        if not isValidPlayerDamageAttribution(npcData, attacker) then
            zombie:setAttackedBy(nil)
            return
        end

        if DTNPCLogic.RememberHostileChaseOrigin then
            DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
        end
        npcData.hostileChaseCooldownUntil = nil
        npcData.banditPassiveFleeEligibleAt = nil
        npcData.hostileChaseTargetID = nil
        npcData.hostileChaseStartedAt = nil
        npcData.hostileChaseGiveUpAfterMs = nil

        npcData.lastPlayerAttackerUsername = attacker.getUsername and attacker:getUsername() or nil
        npcData.lastPlayerAttackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil
        npcData.lastPlayerAttackedAt = getTimeInMillis and getTimeInMillis() or nil

        if (npcData.isBandit == true or npcData.banditGroupID ~= nil or npcData.raidHostileFaction == true)
            and DTNPCBandits and DTNPCBandits.OnBanditDamagedByPlayer then
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

    if wasDamaged and attacker then
        local attackerData, attackerUUID = getDTNPCAttackerData(attacker)
        if attackerData and attackerUUID ~= npcData.uuid then
            local hostile = true
            if DTNPCProtect
                and DTNPCProtect.Internal
                and DTNPCProtect.Internal.isDTNPCHostileToNPC then
                hostile = DTNPCProtect.Internal.isDTNPCHostileToNPC(npcData, attackerData)
                    or DTNPCProtect.Internal.isDTNPCHostileToNPC(attackerData, npcData)
            end

            if hostile then
                local dx = attacker:getX() - zombie:getX()
                local dy = attacker:getY() - zombie:getY()
                local dist = math.sqrt((dx * dx) + (dy * dy))
                local nextState = "Attack"
                if DTNPCProtect and DTNPCProtect.ResolveHostileCombatState then
                    nextState = DTNPCProtect.ResolveHostileCombatState(npcData, npcData.state, dist)
                end

                npcData.state = nextState
                npcData.isHostile = true
                npcData.tasks = {}
                npcData.combatTargetID = "dtnpc:" .. tostring(attackerUUID)
                npcData.combatTargetType = "dtnpc"

                zombie:setTarget(attacker)
                zombie:setAttackedBy(nil)
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Combat",
                    "NPC combat initiated: " .. tostring(npcData.name or npcData.uuid)
                        .. " retaliating against " .. tostring(attackerData.name or attackerUUID)
                        .. " state=" .. tostring(nextState)
                )
            else
                zombie:setAttackedBy(nil)
            end
        end
    end
end
