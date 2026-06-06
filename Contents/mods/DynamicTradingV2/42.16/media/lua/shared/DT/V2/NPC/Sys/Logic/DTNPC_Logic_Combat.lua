-- ==============================================================================
-- DTNPC_Logic_Combat.lua
-- Combat initiation checks for shared NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
require "DT/V2/mod-patches/bandits/DTModPatches_Bandits"

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

local function getPlayerRuntimeTargetID(player)
    if DTNPCProtect
        and DTNPCProtect.Internal
        and DTNPCProtect.Internal.getPlayerRuntimeID then
        return DTNPCProtect.Internal.getPlayerRuntimeID(player)
    end

    return getPlayerAttackerIdentity(player) or ("player:" .. tostring(player))
end

local function isHostilePlayerForNPC(npcData, player)
    local resolver = DTNPCProtect
        and DTNPCProtect.Internal
        and DTNPCProtect.Internal.IsHostilePlayerForNPC
        or nil
    if type(resolver) == "function" then
        return resolver(npcData, player) == true
    end
    return false
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

local function isVanillaZombieAttacker(attacker)
    if not attacker or not instanceof or not instanceof(attacker, "IsoZombie") then
        return false
    end
    if attacker.isDead and attacker:isDead() then
        return false
    end

    local modData = attacker.getModData and attacker:getModData() or nil
    if modData and modData.IsDTNPC == true then
        return false
    end

    if DTModPatchesBandits
        and DTModPatchesBandits.IsBanditsNPC
        and DTModPatchesBandits.IsBanditsNPC(attacker) then
        return false
    end

    return true
end

local function getObjectDistance(left, right)
    if not left or not right or not left.getX or not left.getY or not right.getX or not right.getY then
        return nil
    end

    local dx = right:getX() - left:getX()
    local dy = right:getY() - left:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

local function canSeeHostilePlayer(zombie, player)
    if not zombie or not player then
        return false
    end

    local lineOfSight = DTNPCProtect
        and DTNPCProtect.Internal
        and DTNPCProtect.Internal.HasLineOfSight
        or (DTNPCProtect and DTNPCProtect.HasLineOfSight)
        or nil
    if type(lineOfSight) == "function" then
        return lineOfSight(zombie, player) == true
    end

    return true
end

local function startZombieRetaliation(zombie, npcData, attacker)
    if not isVanillaZombieAttacker(attacker) then
        return false
    end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local hasMelee = DTNPCProtect
        and DTNPCProtect.HasUsableMeleeLoadout
        and DTNPCProtect.HasUsableMeleeLoadout(npcData)
        or false
    local hasRanged = DTNPCProtect
        and DTNPCProtect.HasUsableRangedLoadout
        and DTNPCProtect.HasUsableRangedLoadout(npcData)
        or false
    if not hasMelee and not hasRanged then
        return false
    end

    if DTNPCLogic.RememberHostileChaseOrigin then
        DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
    end

    local dist = getObjectDistance(zombie, attacker)
    local nextState = "Attack"
    if DTNPCProtect and DTNPCProtect.ResolveHostileCombatState then
        nextState = DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
    end

    npcData.state = nextState
    npcData.isHostile = true
    npcData.tasks = {}
    npcData.hostileNoTargetSince = nil
    npcData.hostileNoTargetCooldownMs = nil
    npcData.hostileChaseCooldownUntil = nil
    npcData.banditPassiveFleeEligibleAt = nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.damageRetreatUntil = 0

    local zombieID = DTNPCProtect
        and DTNPCProtect.Internal
        and DTNPCProtect.Internal.getZombieRuntimeID
        and DTNPCProtect.Internal.getZombieRuntimeID(attacker)
        or tostring(attacker)
    npcData.combatTargetID = tostring(zombieID)
    npcData.combatTargetType = "zombie"

    if nextState == "Attack" and DTNPCStamina and DTNPCStamina.ForceCombatResume then
        DTNPCStamina.ForceCombatResume(npcData, "melee", 0.26)
    end

    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)
    return true
end

local function hasUsableCombatLoadout(npcData)
    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    local hasMelee = DTNPCProtect
        and DTNPCProtect.HasUsableMeleeLoadout
        and DTNPCProtect.HasUsableMeleeLoadout(npcData)
        or false
    local hasRanged = DTNPCProtect
        and DTNPCProtect.HasUsableRangedLoadout
        and DTNPCProtect.HasUsableRangedLoadout(npcData)
        or false

    return hasMelee or hasRanged
end

local function findHostilePlayerTarget(zombie, npcData, preferredTarget)
    local searchRadius = tonumber(DTNPCProtect and DTNPCProtect.CONFIG and DTNPCProtect.CONFIG.ScanRadius) or 12

    if preferredTarget
        and instanceof
        and instanceof(preferredTarget, "IsoPlayer")
        and not preferredTarget:isDead()
        and isHostilePlayerForNPC(npcData, preferredTarget)
        and canSeeHostilePlayer(zombie, preferredTarget) then
        local preferredDist = getObjectDistance(zombie, preferredTarget) or 9999
        if preferredDist <= searchRadius or npcData.isHostile == true then
            return preferredTarget, preferredDist
        end
    end

    local players = DTNPCLogic.GetActivePlayers and DTNPCLogic.GetActivePlayers() or {}
    local bestPlayer = nil
    local bestDist = 9999
    local i
    for i = 1, #players do
        local player = players[i]
        if player
            and not player:isDead()
            and isHostilePlayerForNPC(npcData, player)
            and canSeeHostilePlayer(zombie, player) then
            local dist = getObjectDistance(zombie, player) or 9999
            if dist <= searchRadius and dist < bestDist then
                bestPlayer = player
                bestDist = dist
            end
        end
    end

    if not bestPlayer then
        local player = getSpecificPlayer and getSpecificPlayer(0) or nil
        if player
            and not player:isDead()
            and isHostilePlayerForNPC(npcData, player)
            and canSeeHostilePlayer(zombie, player) then
            local dist = getObjectDistance(zombie, player) or 9999
            if dist <= searchRadius then
                bestPlayer = player
                bestDist = dist
            end
        end
    end

    return bestPlayer, bestDist
end

local function startHostilePlayerEngagement(zombie, npcData, target, dist)
    if not zombie or not npcData or not target or not instanceof or not instanceof(target, "IsoPlayer") then
        return false
    end
    if target:isDead() or not isHostilePlayerForNPC(npcData, target) then
        return false
    end
    if not hasUsableCombatLoadout(npcData) then
        return false
    end

    dist = tonumber(dist) or getObjectDistance(zombie, target)
    local nextState = "Attack"
    if DTNPCProtect and DTNPCProtect.ResolveHostileCombatState then
        nextState = DTNPCProtect.ResolveHostileCombatState(npcData, "Attack", dist)
    end

    if npcData.state == nextState and npcData.combatTargetType == "player" then
        return false
    end

    if DTNPCLogic.RememberHostileChaseOrigin then
        DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
    end

    npcData.state = nextState
    npcData.isHostile = true
    npcData.tasks = {}
    npcData.hostileNoTargetSince = nil
    npcData.hostileNoTargetCooldownMs = nil
    npcData.hostileChaseCooldownUntil = nil
    npcData.banditPassiveFleeEligibleAt = nil
    npcData.combatTargetID = getPlayerRuntimeTargetID(target)
    npcData.combatTargetType = "player"
    npcData.lastPlayerAttackerUsername = target.getUsername and target:getUsername() or nil
    npcData.lastPlayerAttackerOnlineID = target.getOnlineID and target:getOnlineID() or nil
    npcData.lastPlayerAttackedAt = getTimeInMillis and getTimeInMillis() or nil
    npcData.meleeCombatPhaseUntil = 0
    npcData.damageRetreatUntil = 0

    if nextState == "Attack" and DTNPCStamina and DTNPCStamina.ForceCombatResume then
        DTNPCStamina.ForceCombatResume(npcData, "melee", 0.26)
    end

    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)
    return true
end

local function handleLinkedResidentDamage(zombie, npcData, attacker)
    if not npcData
        or npcData.linkedWorkerID == nil
        or npcData.dcResident ~= true
        or npcData.dcCompanionActive == true then
        return false
    end

    if DC_Colony and DC_Colony.Defense and DC_Colony.Defense.RaiseAlert then
        DC_Colony.Defense.RaiseAlert(npcData.ownerUsername, {
            source = "DTNPCLogic",
            reason = "resident_hit",
            target = attacker,
            point = {
                x = math.floor(zombie:getX()),
                y = math.floor(zombie:getY()),
                z = math.floor(zombie:getZ()),
            },
        })
    end

    if DTNPCColonyRuntime and DTNPCColonyRuntime.PushAlertNotice then
        DTNPCColonyRuntime.PushAlertNotice(
            zombie,
            npcData,
            npcData.dcCanFight == true and "guard" or "civilian",
            attacker
        )
    end

    npcData.isHostile = false
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.tasks = {}
    npcData.state = tostring(npcData.dcCanFight == true and (npcData.dcBehaviorState or "Patrol") or (npcData.dcBehaviorState or "ColonyIdle"))
    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)
    return true
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

    if wasDamaged and attacker and handleLinkedResidentDamage(zombie, npcData, attacker) then
        return
    end

    local hostilePlayer, hostilePlayerDist = findHostilePlayerTarget(zombie, npcData, master)
    if hostilePlayer and startHostilePlayerEngagement(zombie, npcData, hostilePlayer, hostilePlayerDist) then
        return
    end

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

        local npcIsHostileToPlayer = npcData.isHostile == true and npcData.combatTargetType == "player"
        if not npcIsHostileToPlayer and ((master and attacker == master) or isFriendlyAuthorityPlayer(npcData, attacker)) then
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

        if not npcData.isHostile
            or (npcData.state ~= "Attack" and npcData.state ~= "AttackRange")
            or npcData.combatTargetType ~= "player" then
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
            npcData.hostileNoTargetSince = nil
            npcData.hostileNoTargetCooldownMs = nil
            npcData.combatTargetID = getPlayerRuntimeTargetID(attacker)
            npcData.combatTargetType = "player"

            local attackerName = attacker:getUsername() or "Unknown Player"
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "Combat Initiated! " .. npcData.name .. " is attacking " .. attackerName
                    .. " using state=" .. tostring(nextState)
            )

            zombie:setTarget(nil)
            zombie:setAttackedBy(nil)
        end
    end

    if wasDamaged and attacker then
        if startZombieRetaliation(zombie, npcData, attacker) then
            return
        end

        local attackerData, attackerUUID = getDTNPCAttackerData(attacker)
        if attackerData and attackerUUID ~= npcData.uuid then
            local hostile = true
            if DTNPCProtect
                and DTNPCProtect.Internal
                and (DTNPCProtect.Internal.IsDTNPCHostileToNPC or DTNPCProtect.Internal.isDTNPCHostileToNPC) then
                local isDTNPCHostileToNPC = DTNPCProtect.Internal.IsDTNPCHostileToNPC
                    or DTNPCProtect.Internal.isDTNPCHostileToNPC
                hostile = isDTNPCHostileToNPC(npcData, attackerData)
                    or isDTNPCHostileToNPC(attackerData, npcData)
            end

            if hostile then
                if DTNPCLogic.RememberHostileChaseOrigin then
                    DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
                end
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
                npcData.hostileNoTargetSince = nil
                npcData.hostileNoTargetCooldownMs = nil
                npcData.combatTargetID = "dtnpc:" .. tostring(attackerUUID)
                npcData.combatTargetType = "dtnpc"

                zombie:setTarget(nil)
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
        elseif DTModPatchesBandits
            and DTModPatchesBandits.IsBanditsNPC
            and DTModPatchesBandits.IsBanditsNPC(attacker) then
            if DTModPatchesBandits.NoteBanditsAggressionAgainstDTNPC then
                DTModPatchesBandits.NoteBanditsAggressionAgainstDTNPC(attacker, npcData)
            end
            if DTNPCLogic.RememberHostileChaseOrigin then
                DTNPCLogic.RememberHostileChaseOrigin(zombie, npcData)
            end
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
            npcData.hostileNoTargetSince = nil
            npcData.hostileNoTargetCooldownMs = nil
            npcData.combatTargetID = DTModPatchesBandits.BuildBanditsCombatTargetID
                and DTModPatchesBandits.BuildBanditsCombatTargetID(attacker)
                or nil
            npcData.combatTargetType = "bandits"

            zombie:setTarget(nil)
            zombie:setAttackedBy(nil)
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Combat",
                "NPC combat initiated: " .. tostring(npcData.name or npcData.uuid)
                    .. " retaliating against Bandits NPC "
                    .. tostring(DTModPatchesBandits.GetBanditZombieID and DTModPatchesBandits.GetBanditZombieID(attacker) or "Unknown")
                    .. " state=" .. tostring(nextState)
            )
        end
    end
end
