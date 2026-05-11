-- ==============================================================================
-- DTNPC_ProtectCombat_Stats.lua
-- Weapon, sound, and combat stat helpers for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local clamp = Internal.clamp

local function playEmitterSound(character, soundName)
    if not character or not soundName or soundName == "" then
        return false
    end

    local emitter = character.getEmitter and character:getEmitter() or nil
    if emitter and emitter.playSound then
        emitter:playSound(soundName)
        return true
    end

    return false
end

local function getAttackWeaponItem(npcData, attackType)
    if attackType == "ranged" then
        return DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    end
    if attackType == "melee" then
        return DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
    end
    return nil
end

local function playSuccessfulHitSound(zombie, target, weaponItem, attackType)
    if target and instanceof(target, "IsoPlayer") then
        if target.playerVoiceSound then
            target:playerVoiceSound("PainFromFallHigh")
        elseif target.playSound then
            target:playSound("ZSHit" .. tostring(1 + ZombRand(3)))
        end
    end

    if attackType == "ranged" then
        playEmitterSound(target, "ImpactFlesh")
        return
    end

    local swingSound = weaponItem and weaponItem.getSwingSound and weaponItem:getSwingSound() or nil
    local hitSound = weaponItem and weaponItem.getZombieHitSound and weaponItem:getZombieHitSound() or nil

    if playEmitterSound(zombie, swingSound) then
        return
    end
    if target and target.playSound and hitSound and hitSound ~= "" then
        target:playSound(hitSound)
        return
    end
    if playEmitterSound(target, hitSound) then
        return
    end
    playEmitterSound(target, "ImpactFlesh")
end

function DTNPCProtect.GetRangedShotSpecs(npcData)
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    if not weaponItem then
        return {
            shotSound = "DT_GunRandom",
            isAuto = false,
            recoilDelay = 10,
            shellSound = nil
        }
    end

    local shotSound = weaponItem:getSwingSound() or "DT_GunRandom"
    local isAuto = false
    local modes = weaponItem:getFireModePossibilities()
    if modes then
        for i = 0, modes:size() - 1 do
            if modes:get(i) == "Auto" then
                isAuto = true
                break
            end
        end
    end

    return {
        shotSound = shotSound,
        isAuto = isAuto,
        recoilDelay = weaponItem:getRecoilDelay() or 10,
        shellSound = not weaponItem:isManuallyRemoveSpentRounds() and weaponItem:getShellFallSound() or nil,
        weaponItem = weaponItem
    }
end

function DTNPCProtect.GetRangedCombatStats(npcData)
    local shooting = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
    local normalized = math.min(math.max(shooting, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    local damage = DT_DamageSystem.GetScaledDamage(npcData, "ranged", weaponItem)

    return {
        hitStill = math.floor(22 + (normalized * 58)),
        hitMove = math.floor(10 + (normalized * 35)),
        fireRate = math.max(36, math.floor(96 - (normalized * 44))),
        damage = damage,
    }
end

function DTNPCProtect.GetMeleeCombatStats(npcData)
    local melee = DTNPCProtect.GetSkillLevel(npcData, "Melee")
    local normalized = math.min(math.max(melee, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
    local weaponRange = weaponItem and weaponItem.getMaxRange and tonumber(weaponItem:getMaxRange()) or 1.0
    local damage = DT_DamageSystem.GetScaledDamage(npcData, "melee", weaponItem)

    return {
        hitChance = math.floor(55 + (normalized * 40)),
        attackRate = math.max(24, math.floor(42 - (normalized * 16))),
        damage = damage,
        chaseSpeed = 0.045 + (normalized * 0.02),
        reach = clamp(weaponRange + 0.15, 1.15, 1.9),
    }
end

Internal.ProtectCombatPlayEmitterSound = playEmitterSound
Internal.ProtectCombatGetAttackWeaponItem = getAttackWeaponItem
Internal.ProtectCombatPlaySuccessfulHitSound = playSuccessfulHitSound
