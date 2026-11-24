-- Pure data definition: Dynamic Trading (DT) Trader faction, caravan, and trading-post names.
-- Strictly decoupled from PNC faction pools to prevent cross-contamination.
-- Managed via the pz-name-definitions skill harness.

return {
    id = "DT.trader",
    first = {
        "Amber",
        "Brass",
        "Copper",
        "Crossroads",
        "Freeway",
        "Goldleaf",
        "Highroad",
        "Ironway",
        "Lanternway",
        "Milepost",
        "Riverbend",
        "Wayfarer",
    },
    second = {
        "Barterers",
        "Caravan",
        "Exchange",
        "Guild",
        "Merchants",
        "Syndicate",
        "Traders",
        "Trading Co.",
    },
    site = {
        "Depot",
        "Exchange",
        "Outpost",
        "Trading Post",
    },
}
