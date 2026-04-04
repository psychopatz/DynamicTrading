-- ==============================================================================
-- DTNPC_ProtectProfile_logic.lua
-- Skill and profile resolution logic for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local clamp = Internal.clamp

local function getSkillSeed(npcData, skillID)
    local seed = tonumber(npcData and npcData.identitySeed) or 1
    local text = tostring(skillID or "Skill")

    for i = 1, #text do
        seed = ((seed * 33) + string.byte(text, i)) % 2147483647
    end

    return seed
end

local function getProfile(npcData)
    if not DynamicTrading or not DynamicTrading.GetArchetypeSkillProfile then
        return nil
    end

    return DynamicTrading.GetArchetypeSkillProfile(npcData and npcData.archetypeID or "General")
end

local function getEquipmentProfile(npcData)
    if not DynamicTrading or not DynamicTrading.GetArchetypeEquipmentProfile then
        return nil
    end

    return DynamicTrading.GetArchetypeEquipmentProfile(npcData and npcData.archetypeID or "General")
end

local function resolveSkillLevel(npcData, skillID)
    npcData._resolvedSkillLevels = npcData._resolvedSkillLevels or {}
    if npcData._resolvedSkillLevels[skillID] ~= nil then
        return npcData._resolvedSkillLevels[skillID]
    end

    local profile = getProfile(npcData)
    local baseRange = profile and profile.baseRanges and profile.baseRanges[skillID] or nil
    local masteryChance = profile and profile.masteryChances and profile.masteryChances[skillID] or 0
    local minValue = baseRange and tonumber(baseRange.min) or 0
    local maxValue = baseRange and tonumber(baseRange.max) or minValue
    if maxValue < minValue then
        maxValue = minValue
    end

    local seed = getSkillSeed(npcData, skillID)
    local level = minValue
    if maxValue > minValue then
        level = minValue + (seed % ((maxValue - minValue) + 1))
    end

    if tonumber(masteryChance) and masteryChance > 0 then
        local masteryRoll = math.floor(seed / 7) % 100
        if masteryRoll < masteryChance then
            level = 20
        end
    end

    npcData._resolvedSkillLevels[skillID] = level
    return level
end

local function getSkillXpBucket(npcData)
    if type(npcData.skillXP) ~= "table" then
        npcData.skillXP = {}
    end
    return npcData.skillXP
end

local function getSkillXpPerLevel(skillID)
    local perLevel = tonumber(DTNPCProtect.SKILL_XP_PER_LEVEL and DTNPCProtect.SKILL_XP_PER_LEVEL[skillID]) or 0
    if perLevel < 1 then
        return 0
    end
    return math.floor(perLevel)
end

local function getEarnedSkillLevelBonus(npcData, skillID)
    local perLevel = getSkillXpPerLevel(skillID)
    if perLevel <= 0 then
        return 0
    end

    local skillXP = getSkillXpBucket(npcData)
    local earnedXP = math.max(0, tonumber(skillXP[skillID]) or 0)
    return math.floor(earnedXP / perLevel)
end

local function getResolvedSkillLevel(npcData, skillID)
    return clamp(resolveSkillLevel(npcData, skillID) + getEarnedSkillLevelBonus(npcData, skillID), 0, 20)
end

Internal.getSkillSeed = getSkillSeed
Internal.getProfile = getProfile
Internal.getEquipmentProfile = getEquipmentProfile
Internal.resolveSkillLevel = resolveSkillLevel
Internal.getSkillXpBucket = getSkillXpBucket
Internal.getSkillXpPerLevel = getSkillXpPerLevel
Internal.getEarnedSkillLevelBonus = getEarnedSkillLevelBonus
Internal.getResolvedSkillLevel = getResolvedSkillLevel

function DTNPCProtect.GetSkillLevel(npcData, skillID)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local baseLevel = resolveSkillLevel(npcData or {}, skillID)
    local earnedBonus = getEarnedSkillLevelBonus(npcData or {}, skillID)
    return clamp(baseLevel + earnedBonus, 0, 20)
end

function DTNPCProtect.GetSkillXP(npcData, skillID)
    DTNPCProtect.EnsureDataDefaults(npcData)
    local skillXP = getSkillXpBucket(npcData)
    return math.max(0, tonumber(skillXP[skillID]) or 0)
end

function DTNPCProtect.AddSkillXP(npcData, skillID, amount)
    if not npcData or not skillID then
        return 0
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    local gain = math.max(0, tonumber(amount) or 0)
    if gain <= 0 then
        return DTNPCProtect.GetSkillXP(npcData, skillID)
    end

    local skillXP = getSkillXpBucket(npcData)
    skillXP[skillID] = math.max(0, tonumber(skillXP[skillID]) or 0) + gain
    return skillXP[skillID]
end
