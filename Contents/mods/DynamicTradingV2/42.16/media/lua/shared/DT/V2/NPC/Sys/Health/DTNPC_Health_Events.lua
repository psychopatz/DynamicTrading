-- ==============================================================================
-- DTNPC_Health_Events.lua
-- Event hooks for DT NPC health handling.
-- ==============================================================================

require "DT/V2/mod-patches/bandits/DTModPatches_Bandits"

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function restoreLocalEngineBuffer(target, npcData)
    if not target or not npcData or not target.setHealth then
        return
    end

    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    local isDead = target.isDead and target:isDead()

    if npcData.incapState == "Active" then
        local graceUntil = tonumber(combatHealth and combatHealth.incapGraceUntil) or 0
        if isDead and (graceUntil <= 0 or internal.nowMillis() >= graceUntil) then
            return
        end

        target:setHealth(DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER)
        if combatHealth then
            combatHealth.lastEngineHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        end
        npcData.health = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        npcData.lastHealth = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER
        return
    end

    if combatHealth and combatHealth.enabled == true and combatHealth.engineProtected == true then
        local engineBuffer = math.max(1, tonumber(combatHealth.engineBuffer) or DTNPCHealth.DEFAULT_ENGINE_BUFFER)
        target:setHealth(engineBuffer)
        combatHealth.lastEngineHealth = engineBuffer
        npcData.health = engineBuffer
        npcData.lastHealth = engineBuffer
    end
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not target then
        return
    end
    if not instanceof or not instanceof(target, "IsoZombie") then
        return
    end

    if DTModPatchesBandits
        and DTModPatchesBandits.IsBanditsNPC
        and DTModPatchesBandits.IsBanditsNPC(target) then
        local attackerModData = attacker and attacker.getModData and attacker:getModData() or nil
        if attackerModData and attackerModData.IsDTNPC == true then
            local attackerData = (DTNPC and DTNPC.GetData and DTNPC.GetData(attacker))
                or attackerModData.DTNPC_Data
                or attackerModData.DTNPCBrain
            if attackerData and DTModPatchesBandits.NoteBanditsProvokedByDTNPC then
                DTModPatchesBandits.NoteBanditsProvokedByDTNPC(target, attackerData)
            end
        end
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

    if internal.isRemoteClient() then
        internal.reportWeaponHitToServer(attacker, target, weapon, damage)
        restoreLocalEngineBuffer(target, npcData)
        return
    end

    -- Dedicated MP server should trust the hit-owning client report for player weapon hits,
    -- matching the Bandits pattern of client-side hit ownership plus server fan-out sync.
    if internal.isDedicatedServer() and attacker and instanceof and instanceof(attacker, "IsoPlayer") then
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
