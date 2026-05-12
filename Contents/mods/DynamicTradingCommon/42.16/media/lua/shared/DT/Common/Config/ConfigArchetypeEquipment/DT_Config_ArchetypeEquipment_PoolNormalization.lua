-- =============================================================================
-- ARCHETYPE EQUIPMENT: POOL NORMALIZATION
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function internal.normalizePool(pool)
    local normalized = {}

    for _, entry in ipairs(type(pool) == "table" and pool or {}) do
        local item = nil
        if type(entry) == "string" then
            item = entry
            entry = { item = entry }
        elseif type(entry) == "table" then
            item = entry.item or entry.weapon or entry.bag
        end

        if item and item ~= "" then
            local normalizedEntry = internal.deepCopy(entry)
            normalizedEntry.item = item
            normalizedEntry.weight = math.max(0, tonumber(normalizedEntry.weight) or 1)
            if normalizedEntry.ammoMin ~= nil then
                normalizedEntry.ammoMin = math.max(0, math.floor(tonumber(normalizedEntry.ammoMin) or 0))
            end
            if normalizedEntry.ammoMax ~= nil then
                normalizedEntry.ammoMax = math.max(
                    normalizedEntry.ammoMin or 0,
                    math.floor(tonumber(normalizedEntry.ammoMax) or 0)
                )
            end
            if normalizedEntry.ammoCount ~= nil then
                normalizedEntry.ammoCount = math.max(0, math.floor(tonumber(normalizedEntry.ammoCount) or 0))
            end
            normalized[#normalized + 1] = normalizedEntry
        end
    end

    return normalized
end

function internal.buildDynamicWeaponPool(kind)
    local pool = {}
    local masterList = internal.getMasterList()

    for _, key in ipairs(internal.getSortedMasterListKeys()) do
        local itemData = masterList[key]
        local fullType = type(itemData) == "table" and itemData.item or key
        local scriptItem = internal.getScriptItem(fullType)

        if kind == "ranged" then
            if internal.hasTag(itemData, "Weapon.Ranged.Firearm") and internal.isRangedWeapon(fullType, scriptItem) then
                local ammoType, ammoMin, ammoMax = internal.deriveRangedAmmoWindow(fullType, scriptItem)
                pool[#pool + 1] = {
                    item = fullType,
                    ammoType = ammoType,
                    ammoMin = ammoMin,
                    ammoMax = ammoMax,
                    weight = internal.deriveWeight(itemData),
                }
            end
        elseif internal.hasTagPrefix(itemData, "Weapon.Melee.") and internal.isMeleeWeapon(fullType, scriptItem) then
            pool[#pool + 1] = {
                item = fullType,
                weight = internal.deriveWeight(itemData),
            }
        end
    end

    return internal.normalizePool(pool)
end
