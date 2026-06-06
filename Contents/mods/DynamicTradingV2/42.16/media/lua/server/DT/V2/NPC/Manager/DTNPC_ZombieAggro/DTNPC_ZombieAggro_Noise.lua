-- ==============================================================================
-- DTNPC_ZombieAggro_Noise.lua
-- Server-side radial noise emission for NPC combat.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

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

local function isAuthoritativeSide()
    if isClient and isClient() and not (isServer and isServer()) then
        return false
    end
    return true
end

local function emitWorldSound(x, y, z, radius, volume, source)
    local ok = false

    if addSound then
        ok = pcall(function()
            addSound(source, x, y, z, radius, volume)
        end)
    end

    if not ok and getWorldSoundManager then
        local manager = getWorldSoundManager()
        if manager and manager.addSound then
            ok = pcall(function()
                manager:addSound(source, x, y, z, radius, volume)
            end)
        end
    end

    return ok == true
end

function DTNPC_ZombieAggro.EmitCombatNoise(zombie, npcData, attackType)
    if not isAuthoritativeSide() or not zombie or not npcData then
        return false
    end

    local now = nowMillis()
    local nextAllowed = tonumber(npcData.combatNoiseNextAt) or 0
    if nextAllowed > now then
        return false
    end

    local radius, cooldownMs, volume
    if attackType == "ranged" then
        radius = DTNPCCombat and DTNPCCombat.CONFIG and DTNPCCombat.CONFIG.RangedPresenceRadius or 20
        cooldownMs = 450
        volume = 0.9
    elseif attackType == "melee" then
        radius = DTNPCCombat and DTNPCCombat.CONFIG and DTNPCCombat.CONFIG.MeleePresenceRadius or 12
        cooldownMs = 320
        volume = 0.6
    else
        radius = DTNPCCombat and DTNPCCombat.CONFIG and DTNPCCombat.CONFIG.GenericPresenceRadius or 10
        cooldownMs = 500
        volume = 0.5
    end

    local threatCount = math.max(0, tonumber(npcData.zombieThreatCount) or 0)
    if threatCount >= 3 then
        radius = radius * 0.55
        volume = volume * 0.8
    elseif threatCount >= 1 then
        radius = radius * 0.72
        volume = volume * 0.9
    end

    if npcData.isMovingState == true then
        radius = radius * 0.85
    end

    radius = math.max(5, tonumber(radius) or 0)
    local emitted = emitWorldSound(zombie:getX(), zombie:getY(), zombie:getZ(), radius, volume, zombie)

    npcData.combatNoiseNextAt = now + cooldownMs
    return emitted
end

function DTNPC_ZombieAggro.EmitVocalNoise(zombie, npcData, cueType, options)
    if not isAuthoritativeSide() or not zombie or not npcData then
        return false
    end

    local opts = type(options) == "table" and options or {}
    local radius = tonumber(opts.radius)
    local volume = tonumber(opts.volume)
    local cooldownMs = tonumber(opts.cooldownMs)

    if cueType == "Death" then
        radius = radius or 22
        volume = volume or 1.2
        cooldownMs = cooldownMs or 0
    elseif cueType == "Incap" then
        radius = radius or 10
        volume = volume or 0.5
        cooldownMs = cooldownMs or 700
    else
        radius = radius or 12
        volume = volume or 0.6
        cooldownMs = cooldownMs or 400
    end

    local now = nowMillis()
    local throttleKey = "_dtVocalNoiseNextAt_" .. tostring(cueType or "generic")
    local nextAllowed = tonumber(npcData[throttleKey]) or 0
    if cooldownMs > 0 and nextAllowed > now then
        return false
    end

    local emitted = emitWorldSound(zombie:getX(), zombie:getY(), zombie:getZ(), math.max(5, radius), volume, zombie)
    if cooldownMs > 0 then
        npcData[throttleKey] = now + cooldownMs
    end
    return emitted
end
