-- =============================================================================
-- ARCHETYPE SKILL REGISTRY
-- =============================================================================
DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeSkills = DynamicTrading.ArchetypeSkills or {}

DynamicTrading.SkillDefinitions = DynamicTrading.SkillDefinitions or {
    { id = "Construction", label = "Construction" },
    { id = "Crafting", label = "Crafting" },
    { id = "Mining", label = "Mining" },
    { id = "Plants", label = "Plants" },
    { id = "Medical", label = "Medical" },
    { id = "Cooking", label = "Cooking" },
    { id = "Intellectual", label = "Intellectual" },
    { id = "Social", label = "Social" },
    { id = "Animals", label = "Animals" },
    { id = "Shooting", label = "Shooting" },
    { id = "Melee", label = "Melee" },
    { id = "Maintenance", label = "Maintenance" }
}

local DEFAULT_MIN_CAP = 0
local DEFAULT_MAX_CAP = 8
local DEFAULT_XP_RATE = 1.0
local PRIMARY_XP_RATE = 1.15
local SECONDARY_XP_RATE = 1.05
local MIN_MAINTENANCE_LEVEL = 1

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

local function clampInteger(value, minimum, maximum)
    local number = math.floor(tonumber(value) or minimum or 0)
    if minimum ~= nil and number < minimum then
        return minimum
    end
    if maximum ~= nil and number > maximum then
        return maximum
    end
    return number
end

local function buildSkillTemplate(minCap, maxCap, mastery, xpRate)
    -- Reserve 20-cap rolls for mastery promotion; raw ranges only describe normal caps.
    local minValue = clampInteger(minCap, 0, 19)
    local maxValue = clampInteger(maxCap, minValue, 19)
    local masteryChance = 0
    if mastery == true then
        masteryChance = 100
    elseif type(mastery) == "number" then
        masteryChance = clampInteger(mastery, 0, 100)
    end

    return {
        min = minValue,
        max = maxValue,
        mastery = masteryChance,
        xpRate = xpRate
    }
end

local function hasValue(list, target)
    for _, entry in ipairs(list or {}) do
        if entry == target then
            return true
        end
    end
    return false
end

local function sanitizeSkillList(skillIDs, validSkills, blockedSkillID)
    local sanitized = {}
    local seen = {}
    for _, skillID in ipairs(skillIDs or {}) do
        if validSkills[skillID] and skillID ~= blockedSkillID and not seen[skillID] then
            sanitized[#sanitized + 1] = skillID
            seen[skillID] = true
        end
    end
    return sanitized
end

local function buildImplicitGeneralDefinition()
    return {
        primarySkill = "Social",
        secondarySkills = { "Construction", "Crafting" },
        skills = {
            Construction = { min = 0, max = 7, mastery = 0 },
            Crafting = { min = 0, max = 7, mastery = 0 },
            Mining = { min = 0, max = 6, mastery = 0 },
            Plants = { min = 0, max = 6, mastery = 0 },
            Medical = { min = 0, max = 6, mastery = 0 },
            Cooking = { min = 0, max = 6, mastery = 0 },
            Intellectual = { min = 0, max = 7, mastery = 0 },
            Social = { min = 2, max = 10, mastery = 0 },
            Animals = { min = 0, max = 6, mastery = 0 },
            Shooting = { min = 0, max = 6, mastery = 0 },
            Melee = { min = 0, max = 6, mastery = 0 },
            Maintenance = { min = 0, max = 6, mastery = 0 }
        }
    }
end

local function buildFallbackSkillMap()
    local fallback = {}
    for _, skillData in ipairs(DynamicTrading.SkillDefinitions or {}) do
        fallback[skillData.id] = buildSkillTemplate(DEFAULT_MIN_CAP, DEFAULT_MAX_CAP, false, nil)
    end
    return fallback
end

local function normalizeSkillMap(rawSkills, fallbackSkills)
    local normalized = {}
    for _, skillData in ipairs(DynamicTrading.SkillDefinitions or {}) do
        local skillID = skillData.id
        local rawSkill = type(rawSkills) == "table" and rawSkills[skillID] or nil
        local fallbackSkill = type(fallbackSkills) == "table" and fallbackSkills[skillID] or nil
        local minCap = rawSkill and rawSkill.min or fallbackSkill and fallbackSkill.min or DEFAULT_MIN_CAP
        local maxCap = rawSkill and rawSkill.max or fallbackSkill and fallbackSkill.max or DEFAULT_MAX_CAP

        if skillID == "Maintenance" then
            minCap = math.max(MIN_MAINTENANCE_LEVEL, tonumber(minCap) or MIN_MAINTENANCE_LEVEL)
            maxCap = math.max(minCap, tonumber(maxCap) or minCap)
        end

        normalized[skillID] = buildSkillTemplate(
            minCap,
            maxCap,
            rawSkill and rawSkill.mastery or fallbackSkill and fallbackSkill.mastery or false,
            rawSkill and rawSkill.xpRate or fallbackSkill and fallbackSkill.xpRate or nil
        )
    end
    return normalized
end

function DynamicTrading.BuildArchetypeSkillProfile(archetypeID, data)
    local source = data
    local resolvedID = archetypeID

    if type(archetypeID) == "table" and data == nil then
        source = archetypeID
        resolvedID = source and source.id or nil
    end

    source = type(source) == "table" and source or {}
    local fallback = buildImplicitGeneralDefinition()
    local skillMap = normalizeSkillMap(source.skills, fallback.skills or buildFallbackSkillMap())
    local validSkills = {}
    local highestSkillID = nil
    local highestSkillScore = -1

    local profile = {
        id = tostring(resolvedID or source.id or "General"),
        primarySkill = nil,
        secondarySkills = {},
        baseRanges = {},
        maxCaps = {},
        xpRate = {},
        masteryChances = {}
    }

    for _, skillData in ipairs(DynamicTrading.SkillDefinitions or {}) do
        local skillID = skillData.id
        local skillTemplate = skillMap[skillID]
        local score = ((skillTemplate.max or 0) * 100) + (skillTemplate.min or 0)

        validSkills[skillID] = true
        profile.baseRanges[skillID] = {
            min = skillTemplate.min,
            max = skillTemplate.max
        }
        profile.maxCaps[skillID] = skillTemplate.max
        profile.masteryChances[skillID] = clampInteger(skillTemplate.mastery, 0, 100)
        profile.xpRate[skillID] = skillTemplate.xpRate

        if score > highestSkillScore then
            highestSkillScore = score
            highestSkillID = skillID
        end
    end

    profile.primarySkill = validSkills[source.primarySkill] and source.primarySkill
        or (validSkills[fallback.primarySkill] and fallback.primarySkill)
        or highestSkillID

    profile.secondarySkills = sanitizeSkillList(
        source.secondarySkills or fallback.secondarySkills,
        validSkills,
        profile.primarySkill
    )

    for _, skillData in ipairs(DynamicTrading.SkillDefinitions or {}) do
        local skillID = skillData.id
        local rate = tonumber(profile.xpRate[skillID])
        if rate == nil then
            if skillID == profile.primarySkill then
                rate = PRIMARY_XP_RATE
            elseif hasValue(profile.secondarySkills, skillID) then
                rate = SECONDARY_XP_RATE
            else
                rate = DEFAULT_XP_RATE
            end
        end
        profile.xpRate[skillID] = math.max(0.1, rate)
    end

    return deepCopy(profile)
end

function DynamicTrading.RegisterArchetypeSkills(id, data)
    if not id then
        DynamicTrading.Log("DTCommons", "Core", "Error", "Archetype skills registered without ID.")
        return
    end

    local profile = DynamicTrading.BuildArchetypeSkillProfile(id, data)
    if type(profile) ~= "table" then
        DynamicTrading.Log("DTCommons", "Core", "Error", "Invalid archetype skill profile for " .. tostring(id))
        return
    end

    DynamicTrading.ArchetypeSkills[id] = deepCopy(profile)
    DynamicTrading.Log("DTCommons", "Core", "Info", "Registered Archetype Skills: " .. tostring(id))
end

function DynamicTrading.GetArchetypeSkillProfile(archetypeID)
    local id = tostring(archetypeID or "General")
    local registry = DynamicTrading.ArchetypeSkills or {}
    local profile = registry[id] or registry.General
    if profile then
        return deepCopy(profile)
    end
    return DynamicTrading.BuildArchetypeSkillProfile("General", buildImplicitGeneralDefinition())
end
