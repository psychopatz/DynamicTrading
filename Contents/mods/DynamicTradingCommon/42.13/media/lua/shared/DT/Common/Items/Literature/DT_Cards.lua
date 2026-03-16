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
    { item="Base.Card_Christmas", basePrice=5, tags={"Literature.Cards", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=25} },
    { item="Base.Card_Valentine", basePrice=5, tags={"Literature.Cards", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=25} },
    { item="Base.Postcard", basePrice=5, tags={"Literature.Cards", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=4, max=25} },

    -- [Literature.Cards] [Rarity.Rare] (16 items)
    { item="Base.BusinessCard_Nolans", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=27} },
    { item="Base.BusinessCard_Personal", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=27} },
    { item="Base.Card_Birthday", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_Easter", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_Halloween", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_Hanukkah", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_LunarYear", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_StPatrick", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.Card_Sympathy", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.CardDeck", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.CreditCard_Stolen", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.IDcard_Blank", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.IDcard_Female", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.IDcard_Male", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.IDcard_Stolen", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
    { item="Base.TarotCardDeck", basePrice=7, tags={"Literature.Cards", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=13} },
})

print("[DynamicTrading] Cards Registry Complete")
