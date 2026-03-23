DT_Buildings = DT_Buildings or {}
DT_Buildings.Config = DT_Buildings.Config or {}

local Config = DT_Buildings.Config

Config.MOD_DATA_KEY = "DynamicTrading_Buildings"
Config.DEFAULT_UNHOUSED_RECOVERY_MULTIPLIER = 0.33
Config.DEFAULT_BARRACKS_CAPACITY = 4
Config.DEFAULT_BUILDER_BASE_WORK_POINTS_PER_HOUR = 1.0

Config.ToolTags = {
    Builder = "Builder.Tool",
    Hammer = "Builder.Tool.Hammer",
    Saw = "Builder.Tool.Saw"
}

Config.BuilderToolFullTypes = {
    ["Base.Hammer"] = { Config.ToolTags.Builder, Config.ToolTags.Hammer },
    ["Base.BallPeenHammer"] = { Config.ToolTags.Builder, Config.ToolTags.Hammer },
    ["Base.ClubHammer"] = { Config.ToolTags.Builder, Config.ToolTags.Hammer },
    ["Base.Saw"] = { Config.ToolTags.Builder, Config.ToolTags.Saw },
    ["Base.GardenSaw"] = { Config.ToolTags.Builder, Config.ToolTags.Saw },
    ["Base.SmallSaw"] = { Config.ToolTags.Builder, Config.ToolTags.Saw },
    ["Base.CrudeSaw"] = { Config.ToolTags.Builder, Config.ToolTags.Saw }
}

local function buildBuildingDefinition(definition)
    return definition
end

Config.Definitions = {
    Barracks = buildBuildingDefinition({
        buildingType = "Barracks",
        displayName = "Barracks",
        iconPath = "media/ui/Buildings/DT_Barracks.png",
        enabled = true,
        maxLevel = 3,
        levels = {
            [1] = {
                enabled = true,
                workPoints = 36,
                xpReward = 120,
                recipe = {
                    { fullType = "Base.Log", count = 4 },
                    { fullType = "Base.Nails", count = 10 },
                    { fullType = "Base.Sheet", count = 2 },
                    { fullType = "Base.Hinge", count = 1 }
                },
                effects = {
                    housingSlots = 4,
                    recoveryMultiplier = 1.00
                }
            },
            [2] = {
                enabled = true,
                workPoints = 54,
                xpReward = 120,
                recipe = {
                    { fullType = "Base.Log", count = 6 },
                    { fullType = "Base.Nails", count = 16 },
                    { fullType = "Base.Sheet", count = 4 },
                    { fullType = "Base.Hinge", count = 2 },
                    { fullType = "Base.Woodglue", count = 1 }
                },
                effects = {
                    housingSlots = 4,
                    recoveryMultiplier = 1.20
                }
            },
            [3] = {
                enabled = true,
                workPoints = 78,
                xpReward = 120,
                recipe = {
                    { fullType = "Base.Log", count = 8 },
                    { fullType = "Base.Nails", count = 24 },
                    { fullType = "Base.Sheet", count = 6 },
                    { fullType = "Base.Hinge", count = 4 },
                    { fullType = "Base.Woodglue", count = 2 }
                },
                effects = {
                    housingSlots = 4,
                    recoveryMultiplier = 1.40
                }
            }
        }
    }),
    Armory = buildBuildingDefinition({
        buildingType = "Armory",
        displayName = "Armory",
        iconPath = "media/ui/Buildings/DT_Armory.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Barricade = buildBuildingDefinition({
        buildingType = "Barricade",
        displayName = "Barricade",
        iconPath = "media/ui/Buildings/DT_Barricade.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Greenhouse = buildBuildingDefinition({
        buildingType = "Greenhouse",
        displayName = "Greenhouse",
        iconPath = "media/ui/Buildings/DT_Greenhouse.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Headquarters = buildBuildingDefinition({
        buildingType = "Headquarters",
        displayName = "Headquarters",
        iconPath = "media/ui/Buildings/DT_Headquarters.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Kitchen = buildBuildingDefinition({
        buildingType = "Kitchen",
        displayName = "Kitchen",
        iconPath = "media/ui/Buildings/DT_Kitchen.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Laboratory = buildBuildingDefinition({
        buildingType = "Laboratory",
        displayName = "Laboratory",
        iconPath = "media/ui/Buildings/DT_Laboratory.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    ResearchStation = buildBuildingDefinition({
        buildingType = "ResearchStation",
        displayName = "Research Station",
        iconPath = "media/ui/Buildings/DT_ResearchStation",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    Warehouse = buildBuildingDefinition({
        buildingType = "Warehouse",
        displayName = "Warehouse",
        iconPath = "media/ui/Buildings/DT_Warehouse.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    }),
    TradeStand = buildBuildingDefinition({
        buildingType = "TradeStand",
        displayName = "Trade Stand",
        iconPath = "media/ui/Buildings/DT_tradeStand.png",
        enabled = false,
        maxLevel = 3,
        levels = {}
    })
}

function Config.GetDefinition(buildingType)
    return Config.Definitions[tostring(buildingType or "")]
end

function Config.GetLevelDefinition(buildingType, level)
    local definition = Config.GetDefinition(buildingType)
    local levelIndex = math.max(0, math.floor(tonumber(level) or 0))
    return definition and definition.levels and definition.levels[levelIndex] or nil
end

function Config.GetBuilderToolTags(fullType)
    local mapped = Config.BuilderToolFullTypes[tostring(fullType or "")]
    local tags = {}
    for _, tag in ipairs(mapped or {}) do
        tags[#tags + 1] = tag
    end
    return tags
end

function Config.IsBuilderToolFullType(fullType)
    return Config.BuilderToolFullTypes[tostring(fullType or "")] ~= nil
end

function Config.GetBuilderBaseWorkPointsPerHour()
    return math.max(0.01, tonumber(Config.DEFAULT_BUILDER_BASE_WORK_POINTS_PER_HOUR) or 1.0)
end

function Config.GetUnhousedRecoveryMultiplier()
    return math.max(0.01, tonumber(Config.DEFAULT_UNHOUSED_RECOVERY_MULTIPLIER) or 0.33)
end

function Config.GetBarracksSlotsForLevel(level)
    local levelDefinition = Config.GetLevelDefinition("Barracks", level)
    return math.max(
        0,
        math.floor(tonumber(levelDefinition and levelDefinition.effects and levelDefinition.effects.housingSlots) or Config.DEFAULT_BARRACKS_CAPACITY)
    )
end

function Config.GetBarracksRecoveryMultiplier(level)
    local levelDefinition = Config.GetLevelDefinition("Barracks", level)
    return math.max(
        0.01,
        tonumber(levelDefinition and levelDefinition.effects and levelDefinition.effects.recoveryMultiplier) or 1.0
    )
end

return Config
