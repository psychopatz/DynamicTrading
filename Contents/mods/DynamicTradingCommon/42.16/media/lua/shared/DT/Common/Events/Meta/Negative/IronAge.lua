require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: TOOL SCARCITY
-- =============================================================================

DynamicTrading.Events.Register("IronAge", {
    name = "The Iron Age",
    sentiment = "Negative",
    type = "meta",
    description = "Refined steel tools are breaking down. Repairs and smithing are essential.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 240
    end,
    effects = {
        ["Tool"] = { price = 2.0, vol = 0.6 },      -- Hard to find good tools
        ["Clothing.Armor.Heavy"] = { price = 3.0, vol = 0.2 },     -- Sledgehammers are mythical
        ["Resource.Material.Adhesive"] = { price = 3.0, vol = 1.5 },    -- Glue, Duct Tape
        ["Resource.Material.Metal"] = { price = 1.5, vol = 2.0 },  -- Blacksmithing rises
        ["Quality.Waste"] = { price = 0.5 }                  -- Scrap is everywhere, but useless without skill
    },
    factionImpact = {
        stabilityAdd = -2
    }
})
