require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DT_Labour = DT_Labour or {}
DT_Labour.Config = DT_Labour.Config or {}

local Config = DT_Labour.Config

Config.MOD_DATA_KEY = "DynamicTrading_Labour"
Config.COMMAND_MODULE = "DynamicTrading_V2"
Config.PROJECTION_PREFIX = "DTLAB_"
Config.HOURS_PER_DAY = 24
Config.SIM_TICK_RATE = 60
Config.PRESENTATION_TICK_RATE = 120
Config.PROJECTION_RANGE = 100
Config.DEFAULT_SITE_RADIUS = 8
Config.DEFAULT_STARVATION_DEATH_HOURS = 72
Config.DEFAULT_DEHYDRATION_DEATH_HOURS = 72
Config.HYDRATION_POINTS_PER_THIRST = 1000
Config.RECRUIT_START_CALORIES_MIN = 500
Config.RECRUIT_START_CALORIES_MAX = 800
Config.RECRUIT_START_HYDRATION_MIN = 500
Config.RECRUIT_START_HYDRATION_MAX = 800
Config.RECRUIT_REQUIRED_REPUTATION = 100
Config.RECRUIT_DAILY_CHANCE = 50

Config.States = {
    Idle = "Idle",
    Working = "Working",
    MissingTool = "MissingTool",
    MissingSite = "MissingSite",
    Starving = "Starving",
    Dehydrated = "Dehydrated",
    Dead = "Dead"
}

Config.SiteTypes = {
    FarmPlotSite = "FarmPlotSite",
    FishingSite = "FishingSite",
    ScavengeSite = "ScavengeSite"
}

Config.JobTypes = {
    Farm = "Farm",
    Fish = "Fish",
    Scavenge = "Scavenge"
}

Config.JobProfiles = {
    Farm = {
        jobType = Config.JobTypes.Farm,
        displayName = "Farming",
        siteType = Config.SiteTypes.FarmPlotSite,
        requiredToolTags = { "Tool.Farming" },
        cycleHours = 24,
        dailyCaloriesNeed = 2200,
        dailyHydrationNeed = 1800,
        outputRules = {
            { tags = { "Food.Perishable.Vegetable" }, picks = 2, minQty = 1, maxQty = 2 },
            { tags = { "Food.Perishable.Fruit" }, picks = 1, minQty = 1, maxQty = 1 }
        }
    },
    Fish = {
        jobType = Config.JobTypes.Fish,
        displayName = "Fishing",
        siteType = Config.SiteTypes.FishingSite,
        requiredToolTags = { "Tool.Fishing" },
        cycleHours = 18,
        dailyCaloriesNeed = 2100,
        dailyHydrationNeed = 1700,
        outputRules = {
            { tags = { "Food.Perishable.Fish" }, picks = 2, minQty = 1, maxQty = 2 },
            { tags = { "Resource.Fishing" }, picks = 1, minQty = 1, maxQty = 1 }
        }
    },
    Scavenge = {
        jobType = Config.JobTypes.Scavenge,
        displayName = "Scavenging",
        siteType = Config.SiteTypes.ScavengeSite,
        requiredToolTags = { "Tool.General" },
        cycleHours = 16,
        dailyCaloriesNeed = 2300,
        dailyHydrationNeed = 1900,
        outputRules = {
            { tags = { "Quality.Waste" }, picks = 1, minQty = 1, maxQty = 2 },
            { tags = { "Resource.Material.General" }, picks = 1, minQty = 1, maxQty = 2 },
            { tags = { "Tool.General" }, picks = 1, minQty = 1, maxQty = 1 }
        }
    }
}

Config.LegacyProfessionToJob = {
    Farmer = Config.JobTypes.Farm,
    Angler = Config.JobTypes.Fish,
    Scavenger = Config.JobTypes.Scavenge
}

Config.ArchetypeJobBonuses = {
    Farmer = {
        [Config.JobTypes.Farm] = 1.35
    },
    Angler = {
        [Config.JobTypes.Fish] = 1.35
    },
    Scavenger = {
        [Config.JobTypes.Scavenge] = 1.35
    }
}

function Config.NormalizeArchetypeID(archetypeID)
    local value = tostring(archetypeID or "")
    if value == "" then
        return "General"
    end

    if Config.JobProfiles[value] then
        return "General"
    end

    return value
end

function Config.NormalizeJobType(jobType)
    if Config.JobProfiles[jobType] then
        return jobType
    end

    local mapped = Config.LegacyProfessionToJob[jobType]
    if mapped then
        return mapped
    end

    return Config.JobTypes.Scavenge
end

function Config.GetJobProfile(jobType)
    return Config.JobProfiles[Config.NormalizeJobType(jobType)] or Config.JobProfiles.Scavenge
end

function Config.GetProfile(profession)
    return Config.GetJobProfile(profession)
end

function Config.GetDefaultJobForArchetype(archetypeID)
    local archetype = Config.NormalizeArchetypeID(archetypeID)
    if archetype == "Farmer" then
        return Config.JobTypes.Farm
    end
    if archetype == "Angler" then
        return Config.JobTypes.Fish
    end
    return Config.JobTypes.Scavenge
end

function Config.GetJobSpeedMultiplier(archetypeID, jobType)
    local normalizedJobType = Config.NormalizeJobType(jobType)
    local bonuses = Config.ArchetypeJobBonuses[tostring(archetypeID or "")]
    if bonuses and bonuses[normalizedJobType] then
        return bonuses[normalizedJobType]
    end
    return 1.0
end

function Config.GetNextJobType(jobType)
    local order = {
        Config.JobTypes.Scavenge,
        Config.JobTypes.Farm,
        Config.JobTypes.Fish
    }
    local normalized = Config.NormalizeJobType(jobType)
    for index, value in ipairs(order) do
        if value == normalized then
            return order[(index % #order) + 1]
        end
    end
    return order[1]
end

function Config.GetProjectionUUID(workerID)
    return Config.PROJECTION_PREFIX .. tostring(workerID or "unknown")
end

function Config.GetOwnerUsername(playerOrUsername)
    if type(playerOrUsername) == "string" then
        return playerOrUsername
    end

    local player = playerOrUsername
    if player and player.getUsername then
        local username = player:getUsername()
        if username and username ~= "" then
            return username
        end
    end

    return "local"
end

function Config.GetCurrentHour()
    local gt = getGameTime()
    if not gt then return 0 end
    return math.floor(gt:getWorldAgeHours() or 0)
end

function Config.NormalizeUnitValue(value)
    if not value then return 0 end
    value = tonumber(value) or 0
    if math.abs(value) > 1.0 then
        return value / 100.0
    end
    return value
end

function Config.RandomRangeInclusive(minValue, maxValue)
    local minNumber = math.floor(tonumber(minValue) or 0)
    local maxNumber = math.floor(tonumber(maxValue) or minNumber)
    if maxNumber < minNumber then
        minNumber, maxNumber = maxNumber, minNumber
    end

    local span = (maxNumber - minNumber) + 1
    if span <= 1 then
        return minNumber
    end

    return minNumber + ZombRand(span)
end

function Config.TagMatches(itemTag, queryTag)
    if not itemTag or not queryTag then return false end
    if itemTag == queryTag then return true end
    return string.find(itemTag, queryTag .. "%.") == 1
end

function Config.HasMatchingTag(tagList, queryTag)
    if type(tagList) ~= "table" then return false end
    for _, itemTag in ipairs(tagList) do
        if Config.TagMatches(itemTag, queryTag) then
            return true
        end
    end
    return false
end

function Config.FindItemTags(fullType)
    local masterList = DynamicTrading
        and DynamicTrading.Config
        and DynamicTrading.Config.MasterList or nil

    local entry = masterList and masterList[fullType] or nil
    if entry and type(entry.tags) == "table" then
        return entry.tags
    end

    return {}
end

function Config.IsFoodOrDrinkItem(itemObj)
    if not itemObj then return false end
    local fullType = itemObj.getFullType and itemObj:getFullType() or nil
    local tags = Config.FindItemTags(fullType)
    return Config.HasMatchingTag(tags, "Food")
        or Config.HasMatchingTag(tags, "Container.Liquid")
        or (itemObj.getFluidContainer and itemObj:getFluidContainer() ~= nil)
end

function Config.IsToolItem(itemObj)
    if not itemObj then return false end
    local fullType = itemObj.getFullType and itemObj:getFullType() or nil
    local tags = Config.FindItemTags(fullType)
    return Config.HasMatchingTag(tags, "Tool")
end

function Config.GetPlayerObject()
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    if getPlayer then
        return getPlayer()
    end
    return nil
end

return Config
