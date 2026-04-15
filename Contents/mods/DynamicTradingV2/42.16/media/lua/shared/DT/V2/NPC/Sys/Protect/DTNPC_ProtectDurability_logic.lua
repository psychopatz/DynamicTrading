-- ==============================================================================
-- DTNPC_ProtectDurability_logic.lua
-- Ammo and weapon durability handling for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getConditionMax = Internal.getConditionMax
local createConditionProbeItem = Internal.createConditionProbeItem

function DTNPCProtect.ConsumeAmmo(npcData, amount)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if not DTNPCProtect.IsFiniteAmmoTrader(npcData) then
        return tonumber(npcData.loadout.ammoCount) or 0
    end

    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    local current = tonumber(npcData.loadout.ammoCount) or 0
    current = math.max(0, current - spend)
    npcData.loadout.ammoCount = current
    return current
end

function DTNPCProtect.GetWeaponCondition(npcData, slot)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout
    if slot == "ranged" then
        return loadout.rangedCondition
    end
    if slot == "melee" then
        return loadout.meleeCondition
    end
    return nil
end

function DTNPCProtect.CreateLoadoutWeaponItem(npcData, slot)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local loadout = npcData.loadout
    local weaponKey = nil
    local conditionKey = nil
    if slot == "ranged" then
        weaponKey = "rangedWeapon"
        conditionKey = "rangedCondition"
    elseif slot == "melee" then
        weaponKey = "meleeWeapon"
        conditionKey = "meleeCondition"
    else
        return nil
    end

    local fullType = loadout[weaponKey]
    if not fullType or fullType == "" then
        return nil
    end

    local item = createConditionProbeItem(fullType)
    if not item then
        return nil
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition ~= nil and item.setCondition then
        local maxCondition = item.getConditionMax and tonumber(item:getConditionMax()) or nil
        local appliedCondition = math.max(0, math.floor(currentCondition))
        if maxCondition and appliedCondition > maxCondition then
            appliedCondition = maxCondition
        end
        item:setCondition(appliedCondition)
    end

    return item
end

function DTNPCProtect.ConsumeWeaponCondition(npcData, slot, amount)
    DTNPCProtect.EnsureDataDefaults(npcData)

    if not DTNPCProtect.ShouldConsumeWeaponDurability(npcData) then
        return nil
    end

    local loadout = npcData.loadout
    local weaponKey = nil
    local conditionKey = nil
    if slot == "ranged" then
        weaponKey = "rangedWeapon"
        conditionKey = "rangedCondition"
    elseif slot == "melee" then
        weaponKey = "meleeWeapon"
        conditionKey = "meleeCondition"
    else
        return nil
    end

    local weapon = loadout[weaponKey]
    if not weapon or weapon == "" then
        loadout[conditionKey] = nil
        return nil
    end

    local maxCondition = getConditionMax(weapon)
    if not maxCondition then
        loadout[conditionKey] = nil
        return nil
    end

    local currentCondition = tonumber(loadout[conditionKey])
    if currentCondition == nil then
        currentCondition = maxCondition
    end
    currentCondition = math.max(0, math.min(maxCondition, math.floor(currentCondition)))

    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    local maintenanceLevel = DTNPCProtect.GetSkillLevel(npcData, "Maintenance")
    local probeItem = createConditionProbeItem(weapon)
    if probeItem and probeItem.setCondition then
        probeItem:setCondition(currentCondition)
    end

    if probeItem and probeItem.damageCheck and probeItem.getCondition then
        local ok = pcall(function()
            probeItem:damageCheck(maintenanceLevel, spend, true)
        end)
        if ok then
            local nextCondition = tonumber(probeItem:getCondition())
            if nextCondition ~= nil then
                currentCondition = math.max(0, math.min(maxCondition, math.floor(nextCondition)))
                loadout[conditionKey] = currentCondition
                return currentCondition
            end
        end
    end

    local lowerChance = probeItem and probeItem.getConditionLowerChance
        and tonumber(probeItem:getConditionLowerChance())
        or 1000000
    if not lowerChance or lowerChance < 1 then
        lowerChance = 1000000
    end

    local maintenanceBonus = 1 + (math.max(0, tonumber(maintenanceLevel) or 0) * 0.5)
    local rollMax = math.max(1, math.floor(lowerChance * maintenanceBonus * spend))
    if ZombRand(rollMax) ~= 0 then
        loadout[conditionKey] = currentCondition
        return currentCondition
    end

    currentCondition = math.max(0, currentCondition - spend)
    loadout[conditionKey] = currentCondition
    return currentCondition
end
