-- Data-driven settlement baselines. Keys are MarketSense category values, not
-- a DynamicTrading item taxonomy; profiles contain no item definitions.

DTCommon = DTCommon or {}

local Profiles = DTCommon.MarketProfiles or {}
DTCommon.MarketProfiles = Profiles

Profiles.VERSION = 1
Profiles.DEFAULT_ID = "default"
Profiles.RECOVERY_RATE_PER_HOUR = 0.1
Profiles.MAX_CATEGORIES = 32

local DEFINITIONS = {
    default = {
        wealth = 0.5,
        categories = {
            Food = { supply = 0.5, demand = 0.5 },
            Medical = { supply = 0.5, demand = 0.5 },
            Tool = { supply = 0.5, demand = 0.5 },
            Weapon = { supply = 0.5, demand = 0.5 },
        },
    },
    farm = {
        wealth = 0.6,
        categories = {
            Food = { supply = 0.85, demand = 0.25 },
            Medical = { supply = 0.35, demand = 0.7 },
            Resource = { supply = 0.7, demand = 0.4 },
            Tool = { supply = 0.6, demand = 0.45 },
        },
    },
    military = {
        wealth = 0.65,
        categories = {
            Food = { supply = 0.35, demand = 0.75 },
            Medical = { supply = 0.65, demand = 0.8 },
            Weapon = { supply = 0.8, demand = 0.7 },
            Tool = { supply = 0.65, demand = 0.6 },
        },
    },
}

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function clamp(value, low, high, fallback)
    value = number(value, fallback)
    return math.max(low, math.min(high, value))
end

local function text(value, fallback)
    if value == nil then return fallback end
    value = tostring(value)
    return value ~= "" and value or fallback
end

local function sortedKeys(value)
    local keys = {}
    for key, _ in pairs(value or {}) do
        if type(key) == "string" and key ~= "" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function normalize(value, profileID)
    local source = type(value) == "table" and value or {}
    local categories = {}
    local keys = sortedKeys(source.categories)
    for index = 1, math.min(#keys, Profiles.MAX_CATEGORIES) do
        local key = keys[index]
        local category = source.categories[key]
        if type(category) == "table" then
            categories[key] = {
                supply = clamp(category.supply, 0, 1, 0.5),
                demand = clamp(category.demand, 0, 1, 0.5),
            }
        end
    end
    return {
        version = Profiles.VERSION,
        profileID = text(profileID, Profiles.DEFAULT_ID),
        wealth = clamp(source.wealth, 0, 1, 0.5),
        categories = categories,
    }
end

local function definition(profileID)
    local requested = text(profileID, Profiles.DEFAULT_ID)
    local source = DEFINITIONS[requested]
    local fallback = false
    if not source then
        source = DEFINITIONS[Profiles.DEFAULT_ID]
        requested = Profiles.DEFAULT_ID
        fallback = true
    end
    return normalize(source, requested), fallback
end

local function copyCategories(value)
    local categories = {}
    for key, category in pairs(value or {}) do
        if type(category) == "table" then
            categories[key] = {
                supply = category.supply,
                demand = category.demand,
            }
        end
    end
    return categories
end

function Profiles.Get(profileID)
    return definition(profileID)
end

function Profiles.Baseline(profileID, category)
    local profile = definition(profileID)
    local value = profile and profile.categories[tostring(category or "")]
    if value then
        return { supply = value.supply, demand = value.demand }
    end
    return { supply = 0.5, demand = 0.5 }
end

function Profiles.BuildMarketDefinition(profileID, overrides)
    local profile = definition(profileID)
    local source = type(overrides) == "table" and overrides or {}
    local output = {}
    for key, value in pairs(source) do output[key] = value end
    output.profileID = profile.profileID
    if source.wealth == nil then output.wealth = profile.wealth end
    output.categories = copyCategories(profile.categories)
    for key, category in pairs(source.categories or {}) do
        if type(category) == "table" then
            local baseline = output.categories[key]
                or { supply = 0.5, demand = 0.5 }
            output.categories[key] = {
                supply = category.supply == nil
                    and baseline.supply or category.supply,
                demand = category.demand == nil
                    and baseline.demand or category.demand,
            }
        end
    end
    return output, profile
end

function Profiles.List()
    local output = {}
    for key, _ in pairs(DEFINITIONS) do output[#output + 1] = key end
    table.sort(output)
    return output
end

function Profiles.Diagnostics()
    local categories = {}
    for _, profileID in ipairs(Profiles.List()) do
        local profile = definition(profileID)
        for category, _ in pairs(profile.categories) do
            categories[category] = true
        end
    end
    local categoryCount = 0
    for _, _ in pairs(categories) do categoryCount = categoryCount + 1 end
    return {
        version = Profiles.VERSION,
        profileCount = #Profiles.List(),
        categoryCount = categoryCount,
        recoveryRatePerHour = Profiles.RECOVERY_RATE_PER_HOUR,
    }
end

return Profiles
