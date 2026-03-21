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
Config.SIM_TIME_STEP_HOURS = 0.25
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
Config.DEFAULT_LABOUR_DAILY_CALORIES_USE = 500
Config.DEFAULT_LABOUR_DAILY_HYDRATION_USE = 500
Config.DEFAULT_WORKER_MAX_HP = 100
Config.WORKER_HP_LOSS_PER_HOUR = 1
Config.WORKER_HP_REGEN_PER_HOUR = 1
Config.WORKER_ACTIVITY_LOG_LIMIT = 40
Config.NUTRITION_MODEL_VERSION = 3
Config.DEFAULT_WORKER_CARRY_WEIGHT = 8
Config.DEFAULT_SCAVENGE_DUMP_HOURS = 1.0
Config.CONTAINER_CAPACITY_BY_TAG = {
    Tiny = 4,
    Low = 8,
    Medium = 12,
    High = 18
}
Config.CONTAINER_WEIGHT_REDUCTION_BY_TAG = {
    Low = 0.2,
    Medium = 0.5,
    High = 0.8
}
Config.MEAL_SCHEDULE = {
    { id = "breakfast", label = "Breakfast", hour = 7, caloriesShare = 0.28, hydrationShare = 0.24 },
    { id = "lunch", label = "Lunch", hour = 13, caloriesShare = 0.34, hydrationShare = 0.36 },
    { id = "dinner", label = "Dinner", hour = 19, caloriesShare = 0.38, hydrationShare = 0.40 }
}

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
        requiredToolTags = {},
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

Config.ArchetypeCarryWeight = {
    Farmer = 8,
    Angler = 8,
    Scavenger = 10
}

Config.ScavengeLootDefaults = {
    basePoolRolls = 2,
    maxPoolRolls = 5,
    darkSearchSpeedMultiplier = 0.5,
    litSearchSpeedMultiplier = 1.0,
    tierFailureWeights = {
        [0] = 7,
        [1] = 5,
        [2] = 3,
        [3] = 1
    }
}

Config.ScavengeSiteProfileOrder = {
    "GunStore",
    "Medical",
    "ElectronicsStore",
    "AutoShop",
    "Warehouse",
    "Office",
    "Residential"
}

Config.ScavengeSiteProfiles = {
    Unknown = {
        id = "Unknown",
        displayName = "Unsorted Location",
        ruleWeights = {}
    },
    Residential = {
        id = "Residential",
        displayName = "Residential",
        matchTokens = {
            "bedroom", "kitchen", "bathroom", "livingroom", "diningroom",
            "closet", "laundry", "garage", "apartment", "house", "motelroom"
        },
        failureWeightDelta = -1,
        ruleWeights = {
            open_food = 1.6,
            open_clothing = 1.5,
            open_media = 1.2,
            waste_scrap = 0.8,
            general_material = 0.9,
            locked_house_tools = 1.3,
            electronics_components = 0.5,
            carpentry_strip = 1.3,
            plumbing_parts = 1.2,
            metal_salvage = 0.3,
            industrial_hardware = 0.4,
            medical_cache = 0.3,
            firearms_cache = 0.2,
            ammo_cache = 0.2
        }
    },
    Medical = {
        id = "Medical",
        displayName = "Medical",
        matchTokens = {
            "medical", "clinic", "hospital", "pharmacy", "doctor",
            "ward", "treatment", "ambulance"
        },
        failureWeightDelta = 1,
        ruleWeights = {
            open_food = 0.5,
            open_clothing = 0.4,
            open_media = 0.3,
            waste_scrap = 0.7,
            general_material = 0.5,
            locked_house_tools = 0.6,
            electronics_components = 0.8,
            carpentry_strip = 0.2,
            plumbing_parts = 0.6,
            metal_salvage = 0.2,
            industrial_hardware = 0.4,
            medical_cache = 2.8,
            firearms_cache = 0.1,
            ammo_cache = 0.1
        }
    },
    Warehouse = {
        id = "Warehouse",
        displayName = "Warehouse",
        matchTokens = {
            "warehouse", "storage", "storageroom", "toolstorage", "loading",
            "shipping", "industrial", "factory", "crate"
        },
        poolRollBonus = 1,
        failureWeightDelta = -1,
        ruleWeights = {
            open_food = 0.3,
            open_clothing = 0.2,
            open_media = 0.2,
            waste_scrap = 1.4,
            general_material = 1.9,
            locked_house_tools = 1.1,
            electronics_components = 0.5,
            carpentry_strip = 1.4,
            plumbing_parts = 0.7,
            metal_salvage = 1.8,
            industrial_hardware = 1.8,
            medical_cache = 0.2,
            firearms_cache = 0.1,
            ammo_cache = 0.2
        }
    },
    ElectronicsStore = {
        id = "ElectronicsStore",
        displayName = "Electronics",
        matchTokens = {
            "electronics", "electronic", "computer", "server", "control",
            "tech", "audio", "radio"
        },
        failureWeightDelta = 1,
        ruleWeights = {
            open_food = 0.2,
            open_clothing = 0.2,
            open_media = 0.6,
            waste_scrap = 1.0,
            general_material = 0.4,
            locked_house_tools = 0.7,
            electronics_components = 2.8,
            carpentry_strip = 0.2,
            plumbing_parts = 0.2,
            metal_salvage = 0.6,
            industrial_hardware = 0.8,
            medical_cache = 0.1,
            firearms_cache = 0.1,
            ammo_cache = 0.1
        }
    },
    AutoShop = {
        id = "AutoShop",
        displayName = "Auto Shop",
        matchTokens = {
            "mechanic", "garage", "carrepair", "autoshop", "autostore",
            "repair", "tools", "vehicle"
        },
        ruleWeights = {
            open_food = 0.2,
            open_clothing = 0.2,
            open_media = 0.2,
            waste_scrap = 1.3,
            general_material = 1.1,
            locked_house_tools = 0.9,
            electronics_components = 0.9,
            carpentry_strip = 0.5,
            plumbing_parts = 0.5,
            metal_salvage = 1.7,
            industrial_hardware = 1.6,
            medical_cache = 0.1,
            firearms_cache = 0.1,
            ammo_cache = 0.1
        }
    },
    Office = {
        id = "Office",
        displayName = "Office",
        matchTokens = {
            "office", "meeting", "conference", "classroom", "library",
            "school", "reception", "admin"
        },
        failureWeightDelta = -1,
        ruleWeights = {
            open_food = 0.8,
            open_clothing = 0.6,
            open_media = 1.8,
            waste_scrap = 0.4,
            general_material = 0.3,
            locked_house_tools = 0.5,
            electronics_components = 1.4,
            carpentry_strip = 0.1,
            plumbing_parts = 0.1,
            metal_salvage = 0.1,
            industrial_hardware = 0.2,
            medical_cache = 0.2,
            firearms_cache = 0.0,
            ammo_cache = 0.0
        }
    },
    GunStore = {
        id = "GunStore",
        displayName = "Gun Store",
        matchTokens = {
            "gun", "weapon", "ammo", "armory", "armoury", "locker"
        },
        failureWeightDelta = 2,
        ruleWeights = {
            open_food = 0.1,
            open_clothing = 0.3,
            open_media = 0.1,
            waste_scrap = 0.8,
            general_material = 0.5,
            locked_house_tools = 0.6,
            electronics_components = 0.4,
            carpentry_strip = 0.1,
            plumbing_parts = 0.1,
            metal_salvage = 0.5,
            industrial_hardware = 0.6,
            medical_cache = 0.2,
            firearms_cache = 3.5,
            ammo_cache = 3.2
        }
    }
}

Config.ScavengeItemProfiles = {
    ["Base.Crowbar"] = {
        tier = 1,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.LockedHome" },
        capabilities = { "Scavenge.Access.LockedHome" }
    },
    ["Base.CrowbarForged"] = {
        tier = 1,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.LockedHome" },
        capabilities = { "Scavenge.Access.LockedHome" }
    },
    ["Base.Screwdriver"] = {
        tier = 1,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" },
        capabilities = { "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" }
    },
    ["Base.Screwdriver_Old"] = {
        tier = 1,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" },
        capabilities = { "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" }
    },
    ["Base.Screwdriver_Improvised"] = {
        tier = 1,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" },
        capabilities = { "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" }
    },
    ["Base.Sledgehammer"] = {
        tier = 3,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.HeavyEntry" },
        capabilities = { "Scavenge.Access.HeavyEntry" }
    },
    ["Base.Sledgehammer2"] = {
        tier = 3,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.HeavyEntry" },
        capabilities = { "Scavenge.Access.HeavyEntry" }
    },
    ["Base.SledgehammerForged"] = {
        tier = 3,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Access.HeavyEntry" },
        capabilities = { "Scavenge.Access.HeavyEntry" }
    },
    ["Base.Hammer"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.HammerForged"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.HammerStone"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.BallPeenHammer"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.BallPeenHammerForged"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.ClubHammer"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.ClubHammerForged"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentryHammer" },
        capabilities = { "Scavenge.Extraction.CarpentryHammer" }
    },
    ["Base.Saw"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentrySaw" },
        capabilities = { "Scavenge.Extraction.CarpentrySaw" }
    },
    ["Base.SmallSaw"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentrySaw" },
        capabilities = { "Scavenge.Extraction.CarpentrySaw" }
    },
    ["Base.GardenSaw"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentrySaw" },
        capabilities = { "Scavenge.Extraction.CarpentrySaw" }
    },
    ["Base.CrudeSaw"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.CarpentrySaw" },
        capabilities = { "Scavenge.Extraction.CarpentrySaw" }
    },
    ["Base.PipeWrench"] = {
        tier = 2,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.Plumbing" },
        capabilities = { "Scavenge.Extraction.Plumbing" }
    },
    ["Base.BlowTorch"] = {
        tier = 3,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.MetalTorch" },
        capabilities = { "Scavenge.Extraction.MetalTorch" }
    },
    ["Base.WeldingMask"] = {
        tier = 3,
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Extraction.MetalMask" },
        capabilities = { "Scavenge.Extraction.MetalMask" }
    },
    ["Base.EmptySandbag"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bulk" },
        capabilities = { "Scavenge.Haul.Bulk" }
    },
    ["Base.Garbagebag"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bulk" },
        capabilities = { "Scavenge.Haul.Bulk" }
    },
    ["Base.SheetRope"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bundle" },
        capabilities = { "Scavenge.Haul.Bundle" }
    },
    ["Base.SheetRopeBundle"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bundle" },
        capabilities = { "Scavenge.Haul.Bundle" }
    },
    ["Base.Pen"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.BluePen"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.GreenPen"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.RedPen"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.PenFancy"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.PenMultiColor"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    },
    ["Base.PenSpiffo"] = {
        labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Pen" },
        capabilities = { "Scavenge.Utility.Pen" },
        routePlanning = 1
    }
}

Config.ScavengeLootRules = {
    { id = "open_food", tags = { "Food" }, weight = 18, minQty = 1, maxQty = 2 },
    { id = "open_clothing", tags = { "Clothing" }, weight = 10, minQty = 1, maxQty = 1 },
    { id = "open_media", tags = { "Literature" }, weight = 4, minQty = 1, maxQty = 1 },
    { id = "waste_scrap", tags = { "Quality.Waste" }, weight = 16, minQty = 1, maxQty = 2, bulkBonus = 1, bundleBonus = 1 },
    { id = "general_material", tags = { "Resource.Material.General" }, weight = 9, minQty = 1, maxQty = 2, bulkBonus = 1, bundleBonus = 1 },
    {
        id = "locked_house_tools",
        tags = { "Resource.Material.Hardware" },
        weight = 8,
        minTier = 1,
        minQty = 1,
        maxQty = 2,
        bulkBonus = 1,
        requiresAnyCapabilities = { "Scavenge.Access.LockedHome", "Scavenge.Access.ElectronicStore" }
    },
    {
        id = "electronics_components",
        tags = { "Electronics.Gadget" },
        weight = 7,
        minTier = 1,
        minQty = 1,
        maxQty = 2,
        requiresAnyCapabilities = { "Scavenge.Access.ElectronicStore" }
    },
    {
        id = "carpentry_strip",
        tags = { "Resource.Material.Hardware" },
        weight = 11,
        minTier = 2,
        minQty = 2,
        maxQty = 4,
        bulkBonus = 1,
        requiresAllCapabilities = { "Scavenge.Extraction.CarpentryHammer", "Scavenge.Extraction.CarpentrySaw" }
    },
    {
        id = "plumbing_parts",
        tags = { "Resource.Parts" },
        weight = 7,
        minTier = 2,
        minQty = 1,
        maxQty = 2,
        requiresAnyCapabilities = { "Scavenge.Extraction.Plumbing" }
    },
    {
        id = "metal_salvage",
        tags = { "Resource.Material.Metal" },
        weight = 10,
        minTier = 3,
        minQty = 2,
        maxQty = 4,
        bulkBonus = 1,
        bundleBonus = 1,
        requiresAllCapabilities = { "Scavenge.Extraction.MetalTorch", "Scavenge.Extraction.MetalMask" }
    },
    {
        id = "industrial_hardware",
        tags = { "Resource.Material.Hardware" },
        weight = 8,
        minTier = 3,
        minQty = 2,
        maxQty = 3,
        bulkBonus = 1,
        requiresAnyCapabilities = { "Scavenge.Extraction.MetalTorch", "Scavenge.Access.HeavyEntry" }
    },
    {
        id = "medical_cache",
        tags = { "Medical" },
        weight = 6,
        minTier = 3,
        minQty = 1,
        maxQty = 2,
        requiresAnyCapabilities = { "Scavenge.Access.HeavyEntry", "Scavenge.Access.ElectronicStore" }
    },
    {
        id = "firearms_cache",
        tags = { "Weapon.Ranged.Firearm" },
        weight = 3,
        minTier = 3,
        minQty = 1,
        maxQty = 1,
        requiresAnyCapabilities = { "Scavenge.Access.HeavyEntry" }
    },
    {
        id = "ammo_cache",
        tags = { "Weapon.Ranged.Ammo" },
        weight = 5,
        minTier = 3,
        minQty = 1,
        maxQty = 2,
        requiresAnyCapabilities = { "Scavenge.Access.HeavyEntry" }
    }
}

local function appendUniqueValues(target, values)
    target = type(target) == "table" and target or {}
    local seen = {}
    for _, existing in ipairs(target) do
        seen[existing] = true
    end

    for _, value in ipairs(values or {}) do
        if value and not seen[value] then
            target[#target + 1] = value
            seen[value] = true
        end
    end

    return target
end

local function cloneProfileTable(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            local child = {}
            for index, childValue in ipairs(value) do
                child[index] = childValue
            end
            copy[key] = child
        else
            copy[key] = value
        end
    end
    return copy
end

local function extendScavengeProfile(profile, values)
    if not values then
        return profile
    end

    profile.labourTags = appendUniqueValues(profile.labourTags, values.labourTags)
    profile.capabilities = appendUniqueValues(profile.capabilities, values.capabilities)
    profile.tier = math.max(tonumber(profile.tier) or 0, tonumber(values.tier) or 0)
    profile.haulBonus = math.max(tonumber(profile.haulBonus) or 0, tonumber(values.haulBonus) or 0)
    profile.routePlanning = math.max(tonumber(profile.routePlanning) or 0, tonumber(values.routePlanning) or 0)

    local speed = tonumber(values.searchSpeedMultiplier)
    if speed and speed > 0 then
        profile.searchSpeedMultiplier = math.max(tonumber(profile.searchSpeedMultiplier) or 0, speed)
    end

    return profile
end

local function hasTableEntries(value)
    if type(value) ~= "table" then
        return false
    end

    for _, _ in pairs(value) do
        return true
    end

    return false
end

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

function Config.GetWorkerBaseCarryWeight(worker)
    local explicitCarryWeight = tonumber(worker and worker.baseCarryWeightOverride)
    if explicitCarryWeight and explicitCarryWeight > 0 then
        return explicitCarryWeight
    end

    local archetypeID = Config.NormalizeArchetypeID(worker and worker.archetypeID)
    local archetypeCarryWeight = tonumber(Config.ArchetypeCarryWeight and Config.ArchetypeCarryWeight[archetypeID])
    if archetypeCarryWeight and archetypeCarryWeight > 0 then
        return archetypeCarryWeight
    end

    return Config.GetDefaultWorkerCarryWeight and Config.GetDefaultWorkerCarryWeight()
        or math.max(0, tonumber(Config.DEFAULT_WORKER_CARRY_WEIGHT) or 8)
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

function Config.GetCurrentWorldHours()
    local gt = getGameTime()
    if not gt then return 0 end
    return tonumber(gt:getWorldAgeHours()) or 0
end

function Config.GetCurrentHour()
    return math.floor(Config.GetCurrentWorldHours())
end

function Config.GetSandboxTable()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

function Config.GetSandboxNumber(key, fallback)
    local sandbox = Config.GetSandboxTable()
    local value = tonumber(sandbox and sandbox[key])
    if value == nil then
        return fallback
    end
    return value
end

function Config.GetLabourDailyCaloriesUse()
    return math.max(0, Config.GetSandboxNumber("LabourDailyCaloriesUse", Config.DEFAULT_LABOUR_DAILY_CALORIES_USE) or Config.DEFAULT_LABOUR_DAILY_CALORIES_USE)
end

function Config.GetLabourDailyHydrationUse()
    return math.max(0, Config.GetSandboxNumber("LabourDailyHydrationUse", Config.DEFAULT_LABOUR_DAILY_HYDRATION_USE) or Config.DEFAULT_LABOUR_DAILY_HYDRATION_USE)
end

function Config.GetDefaultWorkerCarryWeight()
    return math.max(0, Config.GetSandboxNumber("LabourBaseCarryWeight", Config.DEFAULT_WORKER_CARRY_WEIGHT) or Config.DEFAULT_WORKER_CARRY_WEIGHT)
end

function Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    return Config.GetLabourDailyCaloriesUse()
end

function Config.GetEffectiveDailyHydrationNeed(worker, profile)
    return Config.GetLabourDailyHydrationUse()
end

function Config.GetEffectiveHourlyCaloriesNeed(worker, profile)
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end
    return Config.GetEffectiveDailyCaloriesNeed(worker, profile) / hoursPerDay
end

function Config.GetEffectiveHourlyHydrationNeed(worker, profile)
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end
    return Config.GetEffectiveDailyHydrationNeed(worker, profile) / hoursPerDay
end

function Config.GetMealSchedule()
    return Config.MEAL_SCHEDULE or {}
end

function Config.GetMealsPerDay()
    return #Config.GetMealSchedule()
end

function Config.GetMealCheckpointCountAtHour(worldHour)
    local safeHour = math.max(0, math.floor(tonumber(worldHour) or 0))
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end

    local day = math.floor(safeHour / hoursPerDay)
    local hourOfDay = safeHour % hoursPerDay
    local count = day * Config.GetMealsPerDay()

    for _, meal in ipairs(Config.GetMealSchedule()) do
        if hourOfDay >= (tonumber(meal.hour) or 0) then
            count = count + 1
        end
    end

    return count
end

function Config.GetMealProfileByCheckpoint(checkpointCount)
    local mealsPerDay = Config.GetMealsPerDay()
    if mealsPerDay <= 0 then
        return nil
    end

    local safeCount = math.floor(tonumber(checkpointCount) or 0)
    if safeCount <= 0 then
        return nil
    end

    local slotIndex = ((safeCount - 1) % mealsPerDay) + 1
    return Config.GetMealSchedule()[slotIndex]
end

function Config.GetNextMealProfile(checkpointCount)
    local safeCount = math.max(0, math.floor(tonumber(checkpointCount) or 0))
    return Config.GetMealProfileByCheckpoint(safeCount + 1)
end

function Config.GetMealNeeds(dailyCaloriesNeed, dailyHydrationNeed, mealProfile)
    local meal = mealProfile or {}
    return math.max(0, (tonumber(dailyCaloriesNeed) or 0) * (tonumber(meal.caloriesShare) or 0)),
        math.max(0, (tonumber(dailyHydrationNeed) or 0) * (tonumber(meal.hydrationShare) or 0))
end

function Config.GetMealCheckpointHourByCount(checkpointCount)
    local mealsPerDay = Config.GetMealsPerDay()
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if mealsPerDay <= 0 or hoursPerDay <= 0 then
        return 0
    end

    local safeCount = math.floor(tonumber(checkpointCount) or 0)
    if safeCount <= 0 then
        return 0
    end

    local day = math.floor((safeCount - 1) / mealsPerDay)
    local meal = Config.GetMealProfileByCheckpoint(safeCount) or {}
    return (day * hoursPerDay) + math.floor(tonumber(meal.hour) or 0)
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

function Config.GetScavengeItemProfile(fullType)
    if not fullType or fullType == "" then
        return nil
    end

    local profile = cloneProfileTable(Config.ScavengeItemProfiles[fullType] or {})
    local tags = Config.FindItemTags(fullType)
    local defaults = Config.ScavengeLootDefaults or {}

    if Config.HasMatchingTag(tags, "Container.Bag.Backpack") then
        extendScavengeProfile(profile, {
            labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bag" },
            capabilities = { "Scavenge.Haul.Bag" },
            haulBonus = Config.HasMatchingTag(tags, "Container.WeightReduction.High") and 2 or 1
        })
    elseif Config.HasMatchingTag(tags, "Container.Bag.Duffel") then
        extendScavengeProfile(profile, {
            labourTags = { "Labour.Tool.Scavenge", "Scavenge.Haul.Bag" },
            capabilities = { "Scavenge.Haul.Bag" },
            haulBonus = 1
        })
    end

    if Config.HasMatchingTag(tags, "Electronics.Light") or Config.HasMatchingTag(tags, "Electronics.LightSource") then
        extendScavengeProfile(profile, {
            labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Light" },
            capabilities = { "Scavenge.Utility.Light" },
            searchSpeedMultiplier = defaults.litSearchSpeedMultiplier or 1.0
        })
    end

    if Config.HasMatchingTag(tags, "Literature.Media") then
        extendScavengeProfile(profile, {
            labourTags = { "Labour.Tool.Scavenge", "Scavenge.Utility.Map" },
            capabilities = { "Scavenge.Utility.Map" },
            routePlanning = 1
        })
    end

    if not hasTableEntries(profile) then
        return nil
    end

    return profile
end

function Config.GetItemCombinedTags(fullType)
    local tags = appendUniqueValues({}, Config.FindItemTags(fullType))
    local scavengeProfile = Config.GetScavengeItemProfile(fullType)
    if scavengeProfile and scavengeProfile.labourTags then
        appendUniqueValues(tags, scavengeProfile.labourTags)
    end
    return tags
end

function Config.IsLabourToolFullType(fullType)
    if not fullType or fullType == "" then
        return false
    end

    local tags = Config.FindItemTags(fullType)
    if Config.HasMatchingTag(tags, "Tool") then
        return true
    end

    return Config.GetScavengeItemProfile(fullType) ~= nil
end

function Config.GetItemWeight(fullType)
    if not fullType or not getScriptManager then
        return 0
    end

    local item = getScriptManager():getItem(fullType)
    if not item then
        return 0
    end

    local actualWeight = item.getActualWeight and tonumber(item:getActualWeight()) or nil
    if actualWeight and actualWeight > 0 then
        return actualWeight
    end

    local weight = item.getWeight and tonumber(item:getWeight()) or nil
    if weight and weight > 0 then
        return weight
    end

    return 0
end

function Config.GetCarryContainerProfile(fullType)
    if not fullType or fullType == "" then
        return nil
    end

    local tags = Config.FindItemTags(fullType)
    if not Config.HasMatchingTag(tags, "Container") then
        return nil
    end

    local capacity = 0
    local weightReduction = 0
    local item = getScriptManager and getScriptManager():getItem(fullType) or nil

    if item then
        if item.getCapacity then
            capacity = math.max(capacity, tonumber(item:getCapacity()) or 0)
        end
        if item.getWeightReduction then
            local rawReduction = tonumber(item:getWeightReduction()) or 0
            if rawReduction > 1 then
                rawReduction = rawReduction / 100
            end
            weightReduction = math.max(weightReduction, rawReduction)
        end
    end

    for sizeTag, fallbackCapacity in pairs(Config.CONTAINER_CAPACITY_BY_TAG or {}) do
        if Config.HasMatchingTag(tags, "Container.Capacity." .. sizeTag) then
            capacity = math.max(capacity, fallbackCapacity)
        end
    end

    for sizeTag, fallbackReduction in pairs(Config.CONTAINER_WEIGHT_REDUCTION_BY_TAG or {}) do
        if Config.HasMatchingTag(tags, "Container.WeightReduction." .. sizeTag) then
            weightReduction = math.max(weightReduction, fallbackReduction)
        end
    end

    if capacity <= 0 or weightReduction <= 0 then
        return nil
    end

    return {
        fullType = fullType,
        displayName = (getScriptManager and getScriptManager():getItem(fullType) and getScriptManager():getItem(fullType):getDisplayName()) or tostring(fullType),
        capacity = capacity,
        weightReduction = math.max(0, math.min(1, weightReduction))
    }
end

function Config.CalculateEffectiveCarryWeight(rawWeight, carryProfile)
    local remainingWeight = math.max(0, tonumber(rawWeight) or 0)
    local effectiveWeight = 0

    for _, container in ipairs(carryProfile and carryProfile.containers or {}) do
        if remainingWeight <= 0 then
            break
        end

        local usableWeight = math.min(remainingWeight, math.max(0, tonumber(container.capacity) or 0))
        local reduction = math.max(0, math.min(1, tonumber(container.weightReduction) or 0))
        effectiveWeight = effectiveWeight + (usableWeight * (1 - reduction))
        remainingWeight = remainingWeight - usableWeight
    end

    effectiveWeight = effectiveWeight + remainingWeight
    return math.max(0, effectiveWeight)
end

function Config.GetScavengeCarryProfile(worker)
    local containers = {}
    for _, entry in ipairs(worker and worker.toolLedger or {}) do
        local fullType = entry and entry.fullType or nil
        local container = Config.GetCarryContainerProfile(fullType)
        if container then
            containers[#containers + 1] = container
        end
    end

    table.sort(containers, function(a, b)
        local reductionA = tonumber(a and a.weightReduction) or 0
        local reductionB = tonumber(b and b.weightReduction) or 0
        if reductionA == reductionB then
            return (tonumber(a and a.capacity) or 0) > (tonumber(b and b.capacity) or 0)
        end
        return reductionA > reductionB
    end)

    local bodyCapacity = Config.GetWorkerBaseCarryWeight and Config.GetWorkerBaseCarryWeight(worker)
        or (Config.GetDefaultWorkerCarryWeight and Config.GetDefaultWorkerCarryWeight())
        or math.max(0, tonumber(Config.DEFAULT_WORKER_CARRY_WEIGHT) or 8)
    local rawAllowance = bodyCapacity
    for _, container in ipairs(containers) do
        rawAllowance = rawAllowance + ((tonumber(container.capacity) or 0) * (tonumber(container.weightReduction) or 0))
    end

    return {
        bodyCapacity = bodyCapacity,
        maxCarryWeight = bodyCapacity,
        rawAllowance = rawAllowance,
        containers = containers
    }
end

function Config.GetScavengeTierLabel(tier)
    local safeTier = math.max(0, math.floor(tonumber(tier) or 0))
    if safeTier <= 0 then
        return "Tier 0 - Open Containers"
    end
    if safeTier == 1 then
        return "Tier 1 - Locked Entry"
    end
    if safeTier == 2 then
        return "Tier 2 - Salvage and Strip"
    end
    return "Tier 3 - Secure and Industrial"
end

function Config.GetScavengeSiteProfile(profileID)
    local profiles = Config.ScavengeSiteProfiles or {}
    return profiles[tostring(profileID or "")] or profiles.Unknown or { id = "Unknown", displayName = "Unsorted Location", ruleWeights = {} }
end

function Config.GetScavengeLoadout(worker)
    local defaults = Config.ScavengeLootDefaults or {}
    local loadout = {
        tier = 0,
        capabilityList = {},
        capabilityMap = {},
        searchSpeedMultiplier = defaults.darkSearchSpeedMultiplier or 0.5,
        poolRolls = defaults.basePoolRolls or 2,
        haulBonus = 0,
        routePlanning = 0,
        failureWeight = (defaults.tierFailureWeights and defaults.tierFailureWeights[0]) or 7,
        hasCarpentryKit = false,
        hasMetalKit = false,
        hasRoutePlan = false,
        bulkLoot = false,
        bundleLoot = false
    }

    local capabilitySeen = {}
    for _, entry in ipairs(worker and worker.toolLedger or {}) do
        local fullType = entry and entry.fullType or nil
        local profile = Config.GetScavengeItemProfile(fullType)
        if profile then
            loadout.tier = math.max(loadout.tier, tonumber(profile.tier) or 0)
            loadout.haulBonus = loadout.haulBonus + math.max(0, tonumber(profile.haulBonus) or 0)
            loadout.routePlanning = loadout.routePlanning + math.max(0, tonumber(profile.routePlanning) or 0)

            local speed = tonumber(profile.searchSpeedMultiplier)
            if speed and speed > 0 then
                loadout.searchSpeedMultiplier = math.max(loadout.searchSpeedMultiplier, speed)
            end

            for _, capability in ipairs(profile.capabilities or {}) do
                if not capabilitySeen[capability] then
                    capabilitySeen[capability] = true
                    loadout.capabilityMap[capability] = true
                    loadout.capabilityList[#loadout.capabilityList + 1] = capability
                end
            end
        end
    end

    loadout.hasCarpentryKit = loadout.capabilityMap["Scavenge.Extraction.CarpentryHammer"] == true
        and loadout.capabilityMap["Scavenge.Extraction.CarpentrySaw"] == true
    loadout.hasMetalKit = loadout.capabilityMap["Scavenge.Extraction.MetalTorch"] == true
        and loadout.capabilityMap["Scavenge.Extraction.MetalMask"] == true
    loadout.hasRoutePlan = loadout.capabilityMap["Scavenge.Utility.Map"] == true
        and loadout.capabilityMap["Scavenge.Utility.Pen"] == true
    loadout.bulkLoot = loadout.capabilityMap["Scavenge.Haul.Bulk"] == true
    loadout.bundleLoot = loadout.capabilityMap["Scavenge.Haul.Bundle"] == true
    loadout.carryProfile = Config.GetScavengeCarryProfile(worker)
    loadout.maxCarryWeight = loadout.carryProfile and loadout.carryProfile.maxCarryWeight
        or (Config.GetWorkerBaseCarryWeight and Config.GetWorkerBaseCarryWeight(worker))
        or (Config.GetDefaultWorkerCarryWeight and Config.GetDefaultWorkerCarryWeight())
        or (tonumber(Config.DEFAULT_WORKER_CARRY_WEIGHT) or 8)
    loadout.rawCarryAllowance = loadout.carryProfile and loadout.carryProfile.rawAllowance or loadout.maxCarryWeight
    loadout.carryContainerCount = #(loadout.carryProfile and loadout.carryProfile.containers or {})

    if loadout.capabilityMap["Scavenge.Access.LockedHome"] or loadout.capabilityMap["Scavenge.Access.ElectronicStore"] then
        loadout.tier = math.max(loadout.tier, 1)
    end
    if loadout.hasCarpentryKit or loadout.capabilityMap["Scavenge.Extraction.Plumbing"] then
        loadout.tier = math.max(loadout.tier, 2)
    end
    if loadout.hasMetalKit or loadout.capabilityMap["Scavenge.Access.HeavyEntry"] then
        loadout.tier = math.max(loadout.tier, 3)
    end

    loadout.poolRolls = loadout.poolRolls + loadout.haulBonus
    if loadout.bulkLoot then
        loadout.poolRolls = loadout.poolRolls + 1
    end
    if loadout.hasRoutePlan then
        loadout.poolRolls = loadout.poolRolls + 1
    end
    loadout.poolRolls = math.max(1, math.min(defaults.maxPoolRolls or 5, loadout.poolRolls))

    local failureWeights = defaults.tierFailureWeights or {}
    loadout.failureWeight = failureWeights[loadout.tier] or failureWeights[0] or 7
    if loadout.capabilityMap["Scavenge.Utility.Light"] then
        loadout.failureWeight = math.max(0, loadout.failureWeight - 1)
    end
    if loadout.hasRoutePlan then
        loadout.failureWeight = math.max(0, loadout.failureWeight - 1)
    end

    return loadout
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
    return Config.IsLabourToolFullType(fullType)
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

function Config.IsOwnerOnline(ownerUsername)
    local owner = Config.GetOwnerUsername(ownerUsername)
    if owner == "local" then
        return Config.GetPlayerObject() ~= nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and Config.GetOwnerUsername(player) == owner then
                return true
            end
        end
    end

    local player = Config.GetPlayerObject()
    if player and Config.GetOwnerUsername(player) == owner then
        return true
    end

    return false
end

return Config
