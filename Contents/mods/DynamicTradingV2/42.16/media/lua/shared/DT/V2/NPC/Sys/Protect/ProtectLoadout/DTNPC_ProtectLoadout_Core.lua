-- ==============================================================================
-- DTNPC_ProtectLoadout_Core.lua
-- Core loadout APIs for DTNPC protect behavior.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getScriptItem = Internal.getScriptItem
local buildSeededWorldLoadout = Internal.buildSeededWorldLoadout

function DTNPCProtect.CopyLoadout(loadout)
    loadout = type(loadout) == "table" and loadout or {}
    return {
        rangedWeapon = loadout.rangedWeapon or nil,
        rangedAmmoType = loadout.rangedAmmoType or nil,
        ammoCount = math.max(0, tonumber(loadout.ammoCount) or 0),
        meleeWeapon = loadout.meleeWeapon or nil,
        bag = loadout.bag or nil,
        rangedCondition = loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or nil,
        meleeCondition = loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or nil,
    }
end

function DTNPCProtect.HasExplicitLoadout(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    return (loadout.rangedWeapon and loadout.rangedWeapon ~= "")
        or (loadout.meleeWeapon and loadout.meleeWeapon ~= "")
end

function DTNPCProtect.IsPlayerOwnedTrader(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return Internal.isPlayerOwnedTraderRaw(npcData)
end

function DTNPCProtect.ShouldConsumeAmmo(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return Internal.shouldConsumeAmmoRaw(npcData)
end

function DTNPCProtect.IsFiniteAmmoTrader(npcData)
    return DTNPCProtect.ShouldConsumeAmmo(npcData)
end

function DTNPCProtect.ShouldConsumeWeaponDurability(npcData)
    return Internal.shouldConsumeWeaponDurabilityRaw(npcData)
end

function DTNPCProtect.GetRandomWorldLoadoutType()
    local weights = DTNPCProtect.LOADOUT_WEIGHTS or {}
    local meleeWeight = math.max(0, tonumber(weights.melee) or 0)
    local rangedWeight = math.max(0, tonumber(weights.ranged) or 0)
    local hybridWeight = math.max(0, tonumber(weights.hybrid) or 0)
    local totalWeight = meleeWeight + rangedWeight + hybridWeight

    if totalWeight <= 0 then
        return "melee"
    end

    local roll = ZombRand(totalWeight)
    if roll < meleeWeight then
        return "melee"
    end
    roll = roll - meleeWeight
    if roll < rangedWeight then
        return "ranged"
    end
    return "hybrid"
end

function DTNPCProtect.GetWorldLoadoutPreset(loadoutType)
    local presets = DTNPCProtect.LOADOUT_PRESETS or {}
    local preset = presets[loadoutType] or presets.melee or {}
    return DTNPCProtect.CopyLoadout(preset)
end

function DTNPCProtect.AssignRandomWorldLoadout(npcData, forcedType)
    DTNPCProtect.EnsureDataDefaults(npcData)

    if DTNPCProtect.IsPlayerOwnedTrader(npcData) or DTNPCProtect.HasExplicitLoadout(npcData) then
        return npcData.loadout
    end

    local loadout, loadoutType = buildSeededWorldLoadout(npcData, forcedType)
    npcData.loadout = loadout
    npcData.randomLoadoutType = loadoutType
    return npcData.loadout
end

function DTNPCProtect.GetTradingDefenseState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local dist = tonumber(targetDist) or 9999

    if hasMelee and dist <= 2.0 then
        return "TradingDefenseMelee"
    end
    if hasRanged then
        return "TradingDefenseRanged"
    end
    if hasMelee then
        return "TradingDefenseMelee"
    end

    return nil
end

function DTNPCProtect.GetRangedAmmoType(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local loadout = npcData.loadout
    if loadout.rangedAmmoType and loadout.rangedAmmoType ~= "" then
        return loadout.rangedAmmoType
    end

    local scriptItem = getScriptItem(loadout.rangedWeapon)
    if scriptItem and scriptItem.getAmmoType then
        local ammoType = scriptItem:getAmmoType()
        if ammoType and ammoType ~= "" then
            return ammoType
        end
    end

    return nil
end
