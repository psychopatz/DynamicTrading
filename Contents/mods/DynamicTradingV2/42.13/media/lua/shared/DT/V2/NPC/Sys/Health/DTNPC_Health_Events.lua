-- ==============================================================================
-- DTNPC_Health_Events.lua
-- Event hooks for DT NPC health handling.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not target then
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

    if internal.isRemoteClient() then
        internal.reportWeaponHitToServer(attacker, target, weapon, damage)
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
