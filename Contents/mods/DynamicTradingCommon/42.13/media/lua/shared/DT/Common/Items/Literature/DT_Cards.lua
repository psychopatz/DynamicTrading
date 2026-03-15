-- ============================================================================
-- Literature Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Literature.Cards] [Rarity.Common] (3 items)
    { item="Base.Card_Christmas", basePrice=25, tags={"Literature.Cards", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Card_Valentine", basePrice=25, tags={"Literature.Cards", "Rarity.Common"}, stockRange={min=5, max=25} },
    { item="Base.Postcard", basePrice=50, tags={"Literature.Cards", "Rarity.Common"}, stockRange={min=5, max=25} },

    -- [Literature.Cards] [Rarity.Rare] (16 items)
    { item="Base.BusinessCard_Nolans", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.BusinessCard_Personal", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Card_Birthday", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_Easter", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_Halloween", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_Hanukkah", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_LunarYear", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_StPatrick", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Card_Sympathy", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.CardDeck", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.CreditCard_Stolen", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.IDcard_Blank", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.IDcard_Female", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.IDcard_Male", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.IDcard_Stolen", basePrice=85, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TarotCardDeck", basePrice=42, tags={"Literature.Cards", "Rarity.Rare"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Cards Registry Complete")
