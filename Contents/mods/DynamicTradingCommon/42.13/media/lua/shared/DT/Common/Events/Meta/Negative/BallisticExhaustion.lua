require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: BALLISTIC EXHAUSTION
-- =============================================================================

DynamicTrading.Events.Register("BallisticExhaustion", {
    name = "Ballistic Exhaustion",
    type = "meta",
    description = "The world's ammo reserves are running dry. Bullets are a luxury.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 90 
    end,
    effects = {
        ["Ammo"] = { price = 4.0, vol = 0.3 },      -- Extremely expensive and rare
        ["Gun"] = { price = 0.4 },                  -- Useless without ammo
        ["Gunrunner"] = { price = 0.5 },            -- Losing business
        ["Spear"] = { price = 1.5, vol = 2.0 },     -- Primitive weapons rise
        ["Blade"] = { price = 1.5, vol = 2.0 },
        ["Heavy"] = { price = 1.5 }                 -- Blunt weapons
    }
})
