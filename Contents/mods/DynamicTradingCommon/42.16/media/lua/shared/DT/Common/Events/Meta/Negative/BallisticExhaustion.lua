require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: BALLISTIC EXHAUSTION
-- =============================================================================

DynamicTrading.Events.Register("BallisticExhaustion", {
    name = "Ballistic Exhaustion",
    sentiment = "Negative",
    type = "meta",
    description = "The world's ammo reserves are running dry. Bullets are a luxury.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 90 
    end,
    effects = {
        ["Weapon.Ranged.Ammo"] = { price = 4.0, vol = 0.3 },      -- Extremely expensive and rare
        ["Weapon.Ranged.Firearm"] = { price = 0.4 },                  -- Useless without ammo
        ["Weapon.Part"] = { price = 0.5 },            -- Losing business
        ["Weapon.Melee.General"] = { price = 1.5, vol = 2.0 },     -- Primitive weapons rise
        ["Weapon.Melee.Blade"] = { price = 1.5, vol = 2.0 },
        ["Clothing.Armor.Heavy"] = { price = 1.5 }                 -- Blunt weapons
    },
    factionImpact = {
        stockpileAdd = { ammo = -500 }
    }
})
