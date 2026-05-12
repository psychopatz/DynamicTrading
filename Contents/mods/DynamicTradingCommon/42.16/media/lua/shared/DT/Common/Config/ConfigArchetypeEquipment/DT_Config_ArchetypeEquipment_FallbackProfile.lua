-- =============================================================================
-- ARCHETYPE EQUIPMENT: FALLBACK PROFILE
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function internal.buildFallbackProfile()
    local masterCount = internal.getMasterListCount()
    if internal.fallbackProfileCache.profile and internal.fallbackProfileCache.masterCount == masterCount then
        return internal.deepCopy(internal.fallbackProfileCache.profile)
    end

    local meleeWeapons = internal.buildDynamicWeaponPool("melee")
    if #meleeWeapons == 0 then
        meleeWeapons = internal.normalizePool({
            { module = "DynamicTradingCommon", item = "Base.BaseballBat", weight = 6 },
            { module = "DynamicTradingCommon", item = "Base.Crowbar", weight = 4 },
            { module = "DynamicTradingCommon", item = "Base.LeadPipe", weight = 4 },
            { module = "DynamicTradingCommon", item = "Base.Nightstick", weight = 3 },
            { module = "DynamicTradingCommon", item = "Base.Hammer", weight = 2 },
            { module = "DynamicTradingCommon", item = "Base.KitchenKnife", weight = 2 },
        })
    end

    local rangedWeapons = internal.buildDynamicWeaponPool("ranged")
    if #rangedWeapons == 0 then
        rangedWeapons = internal.normalizePool({
            { module = "DynamicTradingCommon", item = "Base.Pistol", ammoMin = 12, ammoMax = 36, weight = 6 },
            { module = "DynamicTradingCommon", item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 4 },
            { module = "DynamicTradingCommon", item = "Base.Pistol2", ammoMin = 8, ammoMax = 24, weight = 3 },
            { module = "DynamicTradingCommon", item = "Base.Revolver_Short", ammoMin = 6, ammoMax = 18, weight = 2 },
        })
    end

    local profile = {
        meleeWeapons = meleeWeapons,
        rangedWeapons = rangedWeapons,
        bags = internal.normalizePool({
            { module = "DynamicTradingCommon", item = "Base.Bag_Schoolbag", weight = 6 },
            { module = "DynamicTradingCommon", item = "Base.Bag_BurglarBag", weight = 4 },
            { module = "DynamicTradingCommon", item = "Base.Bag_SheetSlingBag", weight = 3 },
            { module = "DynamicTradingCommon", item = "Base.Bag_NormalHikingBag", weight = 2 },
        }),
        bagChance = 0.55,
        rangedChance = {
            shootingThreshold = 8,
            base = 0.02,
            perLevel = 0.045,
            max = 0.35,
        },
    }

    internal.fallbackProfileCache.masterCount = masterCount
    internal.fallbackProfileCache.profile = internal.deepCopy(profile)

    return internal.deepCopy(profile)
end
