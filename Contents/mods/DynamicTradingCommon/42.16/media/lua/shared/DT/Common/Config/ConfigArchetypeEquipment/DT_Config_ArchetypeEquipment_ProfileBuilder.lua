-- =============================================================================
-- ARCHETYPE EQUIPMENT: PROFILE BUILDER
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function DynamicTrading.BuildArchetypeEquipmentProfile(archetypeID, data)
    local source = type(data) == "table" and data or {}
    local fallback = internal.buildFallbackProfile()
    local profile = internal.deepCopy(fallback)

    profile.id = tostring(archetypeID or source.id or "General")

    if type(source.meleeWeapons) == "table" and #source.meleeWeapons > 0 then
        profile.meleeWeapons = internal.normalizePool(source.meleeWeapons)
    end
    if type(source.rangedWeapons) == "table" and #source.rangedWeapons > 0 then
        profile.rangedWeapons = internal.normalizePool(source.rangedWeapons)
    end
    if type(source.bags) == "table" and #source.bags > 0 then
        profile.bags = internal.normalizePool(source.bags)
    end

    profile.bagChance = internal.clampNumber(
        source.bagChance ~= nil and source.bagChance or fallback.bagChance,
        0,
        1
    )

    local rangedChance = type(source.rangedChance) == "table" and source.rangedChance or {}
    local fallbackRangedChance = type(fallback.rangedChance) == "table" and fallback.rangedChance or {}
    profile.rangedChance = {
        shootingThreshold = math.max(
            0,
            math.floor(tonumber(rangedChance.shootingThreshold) or tonumber(fallbackRangedChance.shootingThreshold) or 8)
        ),
        base = internal.clampNumber(rangedChance.base ~= nil and rangedChance.base or fallbackRangedChance.base, 0, 1),
        perLevel = internal.clampNumber(
            rangedChance.perLevel ~= nil and rangedChance.perLevel or fallbackRangedChance.perLevel,
            0,
            1
        ),
        max = internal.clampNumber(rangedChance.max ~= nil and rangedChance.max or fallbackRangedChance.max, 0, 1),
    }

    return profile
end
