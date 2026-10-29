-- Data-only proof fixtures for the generic market event pipeline. The event
-- registry treats these like any other producer-supplied typed definitions.

DTCommon = DTCommon or {}

local Definitions = DTCommon.MarketEventDefinitions or {}
DTCommon.MarketEventDefinitions = Definitions

Definitions.VERSION = 1
Definitions.FOOD_SHORTAGE = {
    schemaVersion = 1,
    type = "food_shortage",
    presentation = {
        headlineKey = "DTCommon_MarketEvent_FoodShortage_Headline",
        descriptionKey = "DTCommon_MarketEvent_FoodShortage_Description",
        importance = 2,
    },
    modifiers = {
        {
            marketTag = "Food",
            supplyDelta = -0.25,
            demandDelta = 0.20,
            availabilityMultiplier = 0.65,
            priceMultiplier = 1.20,
        },
    },
}

Definitions.AGRICULTURAL_SURPLUS = {
    schemaVersion = 1,
    type = "agricultural_surplus",
    presentation = {
        headlineKey = "DTCommon_MarketEvent_AgriculturalSurplus_Headline",
        descriptionKey = "DTCommon_MarketEvent_AgriculturalSurplus_Description",
        importance = 1,
    },
    modifiers = {
        {
            marketTag = "Food",
            supplyDelta = 0.25,
            demandDelta = -0.20,
            availabilityMultiplier = 1.35,
            priceMultiplier = 0.85,
        },
    },
}

function Definitions.Instantiate(definition, eventID, scope, startsAt, endsAt)
    local output = {}
    for key, value in pairs(type(definition) == "table" and definition or {}) do
        output[key] = value
    end
    output.eventID = eventID
    output.scope = scope
    output.startsAt = startsAt
    output.endsAt = endsAt
    return output
end

return Definitions
