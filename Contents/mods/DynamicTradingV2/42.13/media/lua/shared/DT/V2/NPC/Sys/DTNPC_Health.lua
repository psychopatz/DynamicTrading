-- ==============================================================================
-- DTNPC_Health.lua
-- Authoritative custom health handling for DT NPCs.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}

DTNPCHealth.BASE_HP_BY_ARCHETYPE = DTNPCHealth.BASE_HP_BY_ARCHETYPE or {
    General = 120,
    Teacher = 110,
    Librarian = 110,
    Tailor = 115,
    Bartender = 120,
    Chef = 125,
    Doctor = 125,
    Angler = 130,
    Burglar = 130,
    Welder = 130,
    Mechanic = 135,
    Hiker = 135,
    Foreman = 140,
    Athlete = 145,
    Sheriff = 160,
    Survivalist = 170,
}

DTNPCHealth.DEFAULT_ENGINE_BUFFER = DTNPCHealth.DEFAULT_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_ENGINE_HEALTH = DTNPCHealth.INCAP_ENGINE_HEALTH or 2
DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_GRACE_WINDOW_MS = DTNPCHealth.INCAP_GRACE_WINDOW_MS or 1200
DTNPCHealth.MIN_DAMAGE = DTNPCHealth.MIN_DAMAGE or 0.01
DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS = DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS or 250

local function isRemoteClient()
    return isClient() and not isServer()
end

local function getBaseHPMultiplier()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.NPCBaseHealthMultiplier) or nil
    if configured and configured > 0 then
        return configured
    end

    return 1.0
end

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

local function getAttackerType(attacker)
    if not attacker then
        return nil
    end
    if instanceof and instanceof(attacker, "IsoPlayer") then
        return "player"
    end
    if instanceof and instanceof(attacker, "IsoZombie") then
        return "zombie"
    end
    return attacker.getObjectName and tostring(attacker:getObjectName()) or tostring(attacker)
end

local function getAttackerID(attacker)
    if not attacker then
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

    if attacker.getPersistentOutfitID then
        local outfitID = attacker:getPersistentOutfitID()
        if outfitID and outfitID ~= 0 then
            return "outfit:" .. tostring(outfitID)
        end
    end

    if attacker.getID then
        local objectID = attacker:getID()
        if objectID and objectID ~= 0 then
            return "id:" .. tostring(objectID)
        end
    end

    return tostring(attacker)
end

local function getResolvedSkillLevelForHealth(npcData, skillID)
    if not npcData or not skillID then
        return 0
    end

    local internal = DTNPCProtect and DTNPCProtect.Internal or nil
    if internal and internal.getResolvedSkillLevel then
        local ok, value = pcall(internal.getResolvedSkillLevel, npcData, skillID)
        if ok then
            return tonumber(value) or 0
        end
    end

    if DTNPCProtect and DTNPCProtect.GetSkillLevel then
        local ok, value = pcall(DTNPCProtect.GetSkillLevel, npcData, skillID)
        if ok then
            return tonumber(value) or 0
        end
    end

    return 0
end

local function syncHealth(zombie, npcData, fullSync)
    if not zombie or not npcData or not npcData.uuid then
        return
    end
    if not DTNPCServerCore then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return
    end

    if DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData, true)
    end
end

local function queueFallbackIgnore(combatHealth, amount)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then
        return
    end

    combatHealth.pendingFallbackIgnoreAmount = math.max(0, tonumber(combatHealth.pendingFallbackIgnoreAmount) or 0) + amount
    combatHealth.pendingFallbackIgnoreUntil = nowMillis() + DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS
end

local function consumeFallbackIgnore(combatHealth, delta)
    local now = nowMillis()
    local ignoreAmount = math.max(0, tonumber(combatHealth.pendingFallbackIgnoreAmount) or 0)
    local ignoreUntil = tonumber(combatHealth.pendingFallbackIgnoreUntil) or 0
    if ignoreAmount <= 0 or now > ignoreUntil then
        combatHealth.pendingFallbackIgnoreAmount = 0
        combatHealth.pendingFallbackIgnoreUntil = 0
        return delta
    end

    local consumed = math.min(ignoreAmount, math.max(0, tonumber(delta) or 0))
    combatHealth.pendingFallbackIgnoreAmount = ignoreAmount - consumed
    if combatHealth.pendingFallbackIgnoreAmount <= DTNPCHealth.MIN_DAMAGE then
        combatHealth.pendingFallbackIgnoreAmount = 0
        combatHealth.pendingFallbackIgnoreUntil = 0
    end

    return math.max(0, delta - consumed)
end

local function capturePlayerAttacker(npcData, attacker)
    if not npcData or not attacker or not instanceof or not instanceof(attacker, "IsoPlayer") then
        return
    end

    npcData.lastPlayerAttackerUsername = attacker.getUsername and attacker:getUsername() or nil
    npcData.lastPlayerAttackerOnlineID = attacker.getOnlineID and attacker:getOnlineID() or nil
    npcData.lastPlayerAttackedAt = nowMillis()
end

local function setIncapacitatedState(zombie, npcData)
    local incapacitatedAt = nowMillis()

    npcData.lastX = math.floor(zombie:getX())
    npcData.lastY = math.floor(zombie:getY())
    npcData.lastZ = math.floor(zombie:getZ())
    npcData.state = "Incapacitated"
    npcData.incapState = "Active"
    npcData.preIncapStatus = npcData.status or "Resting"
    npcData.isHostile = false
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = "Resting"
    npcData.removalRequested = nil
    npcData.incapStrugglePauseUntil = nil
    npcData.incapNextPauseAt = nil
    npcData.lastFleeX = nil
    npcData.lastFleeY = nil
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.combatOrder = nil
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.combatResumeState = nil
    npcData.autoProtectActiveState = nil
    npcData.combatPursuitTargetID = nil
    npcData.combatPursuitStartedAt = 0
    npcData.combatPursuitLastProgressAt = 0
    npcData.combatPursuitLastAttackAt = 0
    npcData.combatPursuitLastDistance = nil
    npcData.companionCombatActive = false
    npcData.companionLastCombatTargetID = nil
    npcData.companionLastRangedTargetID = nil

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    combatHealth.enabled = false
    combatHealth.engineProtected = true
    combatHealth.current = 0
    combatHealth.lastDamageAt = incapacitatedAt
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0
    combatHealth.incapGraceUntil = incapacitatedAt + DTNPCHealth.INCAP_GRACE_WINDOW_MS
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
    npcData.lastCustomDamageHandledAt = combatHealth.lastDamageAt

    zombie:setTarget(nil)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setRunning(false)
    zombie:setVariable("bBecomeCrawler", true)
    zombie:setVariable("bCrawling", true)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("WalkType", "2")
    zombie:setVariable("DTWalkType", "Crawl")
    zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Health",
        "NPC entered incapacitated state on existing body: " .. tostring(npcData.name or npcData.uuid or "Unknown")
    )
end

function DTNPCHealth.ComputeMaxHP(npcData)
    local archetypeID = tostring(npcData and npcData.archetypeID or "General")
    local baseTemplate = tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE[archetypeID]) or tonumber(DTNPCHealth.BASE_HP_BY_ARCHETYPE.General) or 120
    local baseMax = math.max(1, math.floor((baseTemplate * getBaseHPMultiplier()) + 0.5))
    local melee = getResolvedSkillLevelForHealth(npcData, "Melee")
    local shooting = getResolvedSkillLevelForHealth(npcData, "Shooting")
    local maintenance = getResolvedSkillLevelForHealth(npcData, "Maintenance")
    local skillBonus = math.min(50, math.floor((melee * 2) + (shooting * 2) + maintenance))
    local maxHealth = math.max(1, math.floor(baseMax + skillBonus))
    return baseMax, skillBonus, maxHealth
end

function DTNPCHealth.EnsureDefaults(npcData)
    if not npcData then
        return nil
    end

    if type(npcData.combatHealth) ~= "table" then
        npcData.combatHealth = {}
    end
    if npcData._dtHealthDefaultsActive then
        return npcData.combatHealth
    end
    npcData._dtHealthDefaultsActive = true

    local combatHealth = npcData.combatHealth
    local baseMax, skillBonus, maxHealth = DTNPCHealth.ComputeMaxHP(npcData)

    if combatHealth.enabled == nil then combatHealth.enabled = npcData.incapState ~= "Active" end
    if combatHealth.engineProtected == nil then combatHealth.engineProtected = combatHealth.enabled == true end
    if combatHealth.baseMax == nil then combatHealth.baseMax = baseMax end
    if combatHealth.skillBonus == nil then combatHealth.skillBonus = skillBonus end
    if combatHealth.max == nil then combatHealth.max = maxHealth end
    if combatHealth.current == nil then
        combatHealth.current = npcData.incapState == "Active" and 0 or combatHealth.max
    end
    if combatHealth.engineBuffer == nil then combatHealth.engineBuffer = DTNPCHealth.DEFAULT_ENGINE_BUFFER end
    if combatHealth.zeroHpMode == nil then combatHealth.zeroHpMode = "Incapacitated" end
    if combatHealth.lastEngineHealth == nil then
        combatHealth.lastEngineHealth = combatHealth.enabled and combatHealth.engineBuffer or DTNPCHealth.INCAP_ENGINE_HEALTH
    end
    if combatHealth.lastDamageAt == nil then combatHealth.lastDamageAt = 0 end
    if combatHealth.lastDamageAmount == nil then combatHealth.lastDamageAmount = 0 end
    if combatHealth.lastAttackerType == nil then combatHealth.lastAttackerType = nil end
    if combatHealth.lastAttackerID == nil then combatHealth.lastAttackerID = nil end
    if combatHealth.pendingFallbackIgnoreAmount == nil then combatHealth.pendingFallbackIgnoreAmount = 0 end
    if combatHealth.pendingFallbackIgnoreUntil == nil then combatHealth.pendingFallbackIgnoreUntil = 0 end
    if combatHealth.incapGraceUntil == nil then combatHealth.incapGraceUntil = 0 end

    combatHealth.baseMax = baseMax
    combatHealth.skillBonus = skillBonus
    combatHealth.max = maxHealth
    if npcData.incapState == "Active" then
        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = 0
    else
        combatHealth.current = clamp(combatHealth.current, 0, combatHealth.max)
        combatHealth.incapGraceUntil = 0
    end

    npcData._dtHealthDefaultsActive = nil
    return combatHealth
end

function DTNPCHealth.IsCustomHealthEnabled(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and combatHealth.enabled == true
end

function DTNPCHealth.GetCurrentHP(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and tonumber(combatHealth.current) or nil
end

function DTNPCHealth.GetMaxHP(npcData)
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    return combatHealth and tonumber(combatHealth.max) or nil
end

function DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true or combatHealth.engineProtected ~= true then
        return false
    end

    local engineBuffer = math.max(1, tonumber(combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
    zombie:setHealth(engineBuffer)
    combatHealth.lastEngineHealth = engineBuffer
    npcData.health = engineBuffer
    return true
end

function DTNPCHealth.InitializeForSpawn(zombie, npcData, options)
    if not npcData then
        return nil
    end

    options = type(options) == "table" and options or {}
    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    local resetCurrent = options.resetCurrent == true
    combatHealth.lastDamageAt = 0
    combatHealth.lastDamageAmount = 0
    combatHealth.pendingFallbackIgnoreAmount = 0
    combatHealth.pendingFallbackIgnoreUntil = 0

    if npcData.incapState == "Active" then
        combatHealth.enabled = false
        combatHealth.engineProtected = true
        combatHealth.current = 0
        combatHealth.incapGraceUntil = math.max(tonumber(combatHealth.incapGraceUntil) or 0, nowMillis())
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        if zombie then
            zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        end
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastCustomDamageHandledAt = 0
        return combatHealth
    end

    combatHealth.enabled = true
    combatHealth.engineProtected = true
    if resetCurrent then
        combatHealth.current = combatHealth.max
    else
        combatHealth.current = clamp(combatHealth.current, 0, combatHealth.max)
    end

    if zombie then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        npcData.lastHealth = zombie:getHealth()
    else
        combatHealth.lastEngineHealth = combatHealth.engineBuffer
        npcData.health = combatHealth.engineBuffer
        npcData.lastHealth = combatHealth.engineBuffer
    end
    npcData.lastCustomDamageHandledAt = 0

    return combatHealth
end

function DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
    if not zombie or not npcData or isRemoteClient() then
        return false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.zeroHpMode ~= "Incapacitated" then
        return false
    end

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    capturePlayerAttacker(npcData, attacker)
    setIncapacitatedState(zombie, npcData)
    syncHealth(zombie, npcData, true)
    return true
end

function DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or isRemoteClient() or npcData.incapState ~= "Active" then
        return false, false
    end

    context = type(context) == "table" and context or {}

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth then
        return false, false
    end

    local currentTime = nowMillis()
    local graceUntil = tonumber(combatHealth.incapGraceUntil) or 0

    capturePlayerAttacker(npcData, attacker)

    if currentTime < graceUntil then
        combatHealth.lastDamageAt = currentTime
        combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
        combatHealth.lastAttackerType = getAttackerType(attacker)
        combatHealth.lastAttackerID = getAttackerID(attacker)
        combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        zombie:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        syncHealth(zombie, npcData, false)
        return true, false
    end

    combatHealth.engineProtected = false
    combatHealth.incapGraceUntil = 0
    combatHealth.lastDamageAt = currentTime
    combatHealth.lastDamageAmount = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    combatHealth.lastAttackerType = getAttackerType(attacker)
    combatHealth.lastAttackerID = getAttackerID(attacker)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    npcData.health = DTNPCHealth.INCAP_ENGINE_HEALTH
    npcData.lastHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    combatHealth.lastEngineHealth = DTNPCHealth.INCAP_ENGINE_HEALTH
    zombie:setHealth(DTNPCHealth.INCAP_ENGINE_HEALTH)

    if zombie.Kill then
        zombie:Kill(attacker or zombie)
        return true, true
    end

    return false, false
end

function DTNPCHealth.ApplyDamage(zombie, npcData, amount, attacker, context)
    if not zombie or not npcData or isRemoteClient() then
        return false, false
    end

    if npcData.incapState == "Active" then
        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, amount, attacker, context)
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if not combatHealth or combatHealth.enabled ~= true then
        return false, false
    end

    context = type(context) == "table" and context or {}
    local damage = math.max(DTNPCHealth.MIN_DAMAGE, tonumber(amount) or 0)
    local now = nowMillis()

    capturePlayerAttacker(npcData, attacker)

    combatHealth.lastDamageAt = now
    combatHealth.lastDamageAmount = damage
    combatHealth.lastAttackerType = getAttackerType(attacker)
    combatHealth.lastAttackerID = getAttackerID(attacker)

    if context.queueFallbackIgnore ~= false then
        queueFallbackIgnore(combatHealth, damage)
    end

    combatHealth.current = clamp((tonumber(combatHealth.current) or combatHealth.max) - damage, 0, combatHealth.max)

    if attacker and zombie.setAttackedBy then
        zombie:setAttackedBy(attacker)
    end

    if combatHealth.current <= 0 then
        local handled = DTNPCHealth.HandleZeroHP(zombie, npcData, attacker, context)
        return handled, handled
    end

    DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
    syncHealth(zombie, npcData, false)
    return true, false
end

function DTNPCHealth.ProcessFallbackDamage(zombie, npcData)
    if not zombie or not npcData or isRemoteClient() then
        return false, false
    end

    local combatHealth = DTNPCHealth.EnsureDefaults(npcData)
    if npcData.incapState == "Active" then
        local currentHealth = tonumber(zombie:getHealth()) or 0
        local previousHealth = tonumber(combatHealth and combatHealth.lastEngineHealth) or currentHealth
        local healthDelta = math.max(0, previousHealth - currentHealth)

        if healthDelta <= 0 then
            if combatHealth then
                combatHealth.lastEngineHealth = currentHealth
            end
            npcData.health = currentHealth
            return false, false
        end

        return DTNPCHealth.HandleIncapacitatedDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
            source = "incap_engine_fallback",
            queueFallbackIgnore = false,
        })
    end

    if not combatHealth or combatHealth.enabled ~= true or combatHealth.engineProtected ~= true then
        if combatHealth then
            combatHealth.lastEngineHealth = zombie:getHealth()
        end
        npcData.health = zombie:getHealth()
        return false, false
    end

    local currentHealth = tonumber(zombie:getHealth()) or 0
    local previousHealth = tonumber(combatHealth.lastEngineHealth) or currentHealth
    local healthDelta = math.max(0, previousHealth - currentHealth)
    if healthDelta <= 0 then
        combatHealth.lastEngineHealth = currentHealth
        npcData.health = currentHealth
        return false, false
    end

    healthDelta = consumeFallbackIgnore(combatHealth, healthDelta)
    if healthDelta <= DTNPCHealth.MIN_DAMAGE then
        DTNPCHealth.RestoreEngineBuffer(zombie, npcData)
        return false, false
    end

    return DTNPCHealth.ApplyDamage(zombie, npcData, healthDelta, zombie:getAttackedBy(), {
        source = "engine_fallback",
        queueFallbackIgnore = false,
    })
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if isRemoteClient() or not target then
        return
    end
    if not instanceof or not instanceof(target, "IsoZombie") then
        return
    end

    local modData = target:getModData()
    if not modData or not modData.IsDTNPC then
        return
    end

    local npcData = (DTNPC and DTNPC.GetData and DTNPC.GetData(target)) or modData.DTNPC_Data or modData.DTNPCBrain
    if not npcData then
        return
    end

    DTNPCHealth.ApplyDamage(target, npcData, damage, attacker, {
        source = "weapon_hit_event",
        weapon = weapon,
    })
end

if Events and Events.OnWeaponHitCharacter and not DTNPCHealth.WeaponHitHookRegistered then
    Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
    DTNPCHealth.WeaponHitHookRegistered = true
end
