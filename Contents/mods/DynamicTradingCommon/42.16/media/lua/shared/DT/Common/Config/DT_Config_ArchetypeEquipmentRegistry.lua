-- =============================================================================
-- ARCHETYPE EQUIPMENT REGISTRY
-- =============================================================================
DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipment = DynamicTrading.ArchetypeEquipment or {}

local fallbackProfileCache = {
    masterCount = -1,
    profile = nil,
}

local normalizePool

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = deepCopy(entry)
    end
    return copy
end

local function clampNumber(value, minimum, maximum)
    local number = tonumber(value) or minimum or 0
    if minimum ~= nil and number < minimum then
        number = minimum
    end
    if maximum ~= nil and number > maximum then
        number = maximum
    end
    return number
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function getMasterList()
    return DynamicTrading
        and DynamicTrading.Config
        and type(DynamicTrading.Config.MasterList) == "table"
        and DynamicTrading.Config.MasterList
        or {}
end

local function getMasterListCount()
    local count = 0
    for _ in pairs(getMasterList()) do
        count = count + 1
    end
    return count
end

local function getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if not manager then
        return nil
    end
    if manager.FindItem then
        return manager:FindItem(fullType)
    end
    if manager.getItem then
        return manager:getItem(fullType)
    end

    return nil
end

local function hasTag(itemData, targetTag)
    local tags = type(itemData) == "table" and itemData.tags or nil
    if type(tags) ~= "table" then
        return false
    end

    for _, tag in ipairs(tags) do
        if tag == targetTag then
            return true
        end
    end

    return false
end

local function hasTagPrefix(itemData, prefix)
    local tags = type(itemData) == "table" and itemData.tags or nil
    if type(tags) ~= "table" then
        return false
    end

    for _, tag in ipairs(tags) do
        if type(tag) == "string" and string.sub(tag, 1, #prefix) == prefix then
            return true
        end
    end

    return false
end

local function isRangedWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if scriptItem then
        if scriptItem.isRanged and scriptItem:isRanged() then
            return true
        end
        if scriptItem.isAimedFirearm and scriptItem:isAimedFirearm() then
            return true
        end
        if scriptItem.getAmmoType and scriptItem:getAmmoType() and scriptItem:getAmmoType() ~= "" then
            return true
        end

        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if lower(displayCategory):find("firearm", 1, true) then
            return true
        end
    end

    local lowered = lower(fullType)
    return lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("carbine", 1, true) ~= nil
        or lowered:find("smg", 1, true) ~= nil
        or lowered:find("firearm", 1, true) ~= nil
        or lowered:find("gun", 1, true) ~= nil
end

local function isMeleeWeapon(fullType, scriptItem)
    if not fullType or fullType == "" then
        return false
    end

    if isRangedWeapon(fullType, scriptItem) then
        return false
    end

    if scriptItem then
        local swingAnim = scriptItem.getSwingAnim and scriptItem:getSwingAnim() or nil
        local displayCategory = scriptItem.getDisplayCategory and scriptItem:getDisplayCategory() or nil
        if swingAnim and lower(swingAnim) ~= "" then
            return true
        end
        if lower(displayCategory):find("melee", 1, true) then
            return true
        end
    end

    local lowered = lower(fullType)
    return lowered:find("bat", 1, true) ~= nil
        or lowered:find("axe", 1, true) ~= nil
        or lowered:find("knife", 1, true) ~= nil
        or lowered:find("machete", 1, true) ~= nil
        or lowered:find("club", 1, true) ~= nil
        or lowered:find("hammer", 1, true) ~= nil
        or lowered:find("spear", 1, true) ~= nil
        or lowered:find("crowbar", 1, true) ~= nil
end

local function deriveWeight(itemData)
    local explicitWeight = math.floor(tonumber(itemData and itemData.loadoutWeight) or tonumber(itemData and itemData.weight) or 0)
    if explicitWeight > 0 then
        return explicitWeight
    end

    local stockRange = type(itemData) == "table" and itemData.stockRange or nil
    local stockMax = math.floor(tonumber(stockRange and stockRange.max) or 0)
    local weight = math.max(1, math.min(8, stockMax))

    if hasTag(itemData, "Rarity.Common") then
        weight = weight + 2
    elseif hasTag(itemData, "Rarity.Uncommon") then
        weight = weight + 1
    end

    if hasTag(itemData, "Quality.Waste") then
        weight = math.max(1, weight - 1)
    end

    return math.max(1, weight)
end

local function deriveRangedAmmoWindow(fullType, scriptItem)
    local ammoType = nil
    if scriptItem and scriptItem.getAmmoType then
        ammoType = scriptItem:getAmmoType()
    end

    local clipSize = nil
    if scriptItem and scriptItem.getClipSize then
        clipSize = tonumber(scriptItem:getClipSize())
    end
    clipSize = math.max(1, math.floor(clipSize or 0))

    local lowered = lower(fullType)
    if lowered:find("revolver", 1, true) then
        clipSize = math.max(clipSize, 6)
        return ammoType, clipSize, clipSize * 3
    end
    if lowered:find("shotgun", 1, true) then
        clipSize = math.max(clipSize, 6)
        return ammoType, clipSize + 2, clipSize * 4
    end
    if lowered:find("rifle", 1, true) or lowered:find("carbine", 1, true) then
        clipSize = math.max(clipSize, 5)
        return ammoType, clipSize * 2, clipSize * 5
    end

    clipSize = math.max(clipSize, 8)
    return ammoType, math.max(clipSize, math.floor(clipSize * 1.5)), clipSize * 4
end

local function getSortedMasterListKeys()
    local keys = {}
    for key, itemData in pairs(getMasterList()) do
        local item = type(itemData) == "table" and itemData.item or key
        if item and item ~= "" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys, function(left, right)
        local masterList = getMasterList()
        local leftItem = type(masterList[left]) == "table" and masterList[left].item or left
        local rightItem = type(masterList[right]) == "table" and masterList[right].item or right
        return tostring(leftItem) < tostring(rightItem)
    end)

    return keys
end

local function buildDynamicWeaponPool(kind)
    local pool = {}
    local masterList = getMasterList()

    for _, key in ipairs(getSortedMasterListKeys()) do
        local itemData = masterList[key]
        local fullType = type(itemData) == "table" and itemData.item or key
        local scriptItem = getScriptItem(fullType)

        if kind == "ranged" then
            if hasTag(itemData, "Weapon.Ranged.Firearm") and isRangedWeapon(fullType, scriptItem) then
                local ammoType, ammoMin, ammoMax = deriveRangedAmmoWindow(fullType, scriptItem)
                pool[#pool + 1] = {
                    item = fullType,
                    ammoType = ammoType,
                    ammoMin = ammoMin,
                    ammoMax = ammoMax,
                    weight = deriveWeight(itemData),
                }
            end
        elseif hasTagPrefix(itemData, "Weapon.Melee.") and isMeleeWeapon(fullType, scriptItem) then
            pool[#pool + 1] = {
                item = fullType,
                weight = deriveWeight(itemData),
            }
        end
    end

    return normalizePool(pool)
end

normalizePool = function(pool)
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
            local normalizedEntry = deepCopy(entry)
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

local function buildFallbackProfile()
    local masterCount = getMasterListCount()
    if fallbackProfileCache.profile and fallbackProfileCache.masterCount == masterCount then
        return deepCopy(fallbackProfileCache.profile)
    end

    local meleeWeapons = buildDynamicWeaponPool("melee")
    if #meleeWeapons == 0 then
        meleeWeapons = normalizePool({
            { module = "DynamicTradingCommon",  item = "Base.BaseballBat", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Crowbar", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.LeadPipe", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Nightstick", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Hammer", weight = 2 },
            { module = "DynamicTradingCommon",  item = "Base.KitchenKnife", weight = 2 },
        })
    end

    local rangedWeapons = buildDynamicWeaponPool("ranged")
    if #rangedWeapons == 0 then
        rangedWeapons = normalizePool({
            { module = "DynamicTradingCommon",  item = "Base.Pistol", ammoMin = 12, ammoMax = 36, weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver", ammoMin = 6, ammoMax = 18, weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Pistol2", ammoMin = 8, ammoMax = 24, weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Revolver_Short", ammoMin = 6, ammoMax = 18, weight = 2 },
        })
    end

    local profile = {
        meleeWeapons = meleeWeapons,
        rangedWeapons = rangedWeapons,
        bags = normalizePool({
            { module = "DynamicTradingCommon",  item = "Base.Bag_Schoolbag", weight = 6 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_BurglarBag", weight = 4 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_SheetSlingBag", weight = 3 },
            { module = "DynamicTradingCommon",  item = "Base.Bag_NormalHikingBag", weight = 2 },
        }),
        bagChance = 0.55,
        rangedChance = {
            shootingThreshold = 8,
            base = 0.02,
            perLevel = 0.045,
            max = 0.35,
        },
    }

    fallbackProfileCache.masterCount = masterCount
    fallbackProfileCache.profile = deepCopy(profile)

    return deepCopy(profile)
end

function DynamicTrading.BuildArchetypeEquipmentProfile(archetypeID, data)
    local source = type(data) == "table" and data or {}
    local fallback = buildFallbackProfile()
    local profile = deepCopy(fallback)

    profile.id = tostring(archetypeID or source.id or "General")

    if type(source.meleeWeapons) == "table" and #source.meleeWeapons > 0 then
        profile.meleeWeapons = normalizePool(source.meleeWeapons)
    end
    if type(source.rangedWeapons) == "table" and #source.rangedWeapons > 0 then
        profile.rangedWeapons = normalizePool(source.rangedWeapons)
    end
    if type(source.bags) == "table" and #source.bags > 0 then
        profile.bags = normalizePool(source.bags)
    end

    profile.bagChance = clampNumber(
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
        base = clampNumber(rangedChance.base ~= nil and rangedChance.base or fallbackRangedChance.base, 0, 1),
        perLevel = clampNumber(
            rangedChance.perLevel ~= nil and rangedChance.perLevel or fallbackRangedChance.perLevel,
            0,
            1
        ),
        max = clampNumber(rangedChance.max ~= nil and rangedChance.max or fallbackRangedChance.max, 0, 1),
    }

    return profile
end

function DynamicTrading.RegisterArchetypeEquipment(id, data)
    if not id then
        if DynamicTrading.Log then
            DynamicTrading.Log("DTCommons", "Core", "Error", "Archetype equipment registered without ID.")
        end
        return
    end

    local profile = DynamicTrading.BuildArchetypeEquipmentProfile(id, data)
    DynamicTrading.ArchetypeEquipment[id] = deepCopy(profile)

    if DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Core", "Info", "Registered Archetype Equipment: " .. tostring(id))
    end
end

function DynamicTrading.GetArchetypeEquipmentProfile(archetypeID)
    local id = tostring(archetypeID or "General")
    local registry = DynamicTrading.ArchetypeEquipment or {}
    local profile = registry[id]
    if profile then
        return deepCopy(profile)
    end

    if id == "General" and registry.General then
        return deepCopy(registry.General)
    end

    return DynamicTrading.BuildArchetypeEquipmentProfile(id, nil)
end
