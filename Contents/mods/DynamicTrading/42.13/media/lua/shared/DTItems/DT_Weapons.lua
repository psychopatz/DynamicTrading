require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterWeapon(commonTags, items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        local finalTags = {}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Weapon",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 0, max = config.max or 3 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. FIREARMS (Handguns, Shotguns, Rifles)
RegisterWeapon({"Gun"}, {
    -- Handguns
    { item="Base.Revolver",      price=180, min=1, max=3, tags={"Police", "Civilian"}, id="BuyM36Revolver" },
    { item="Base.Pistol",        price=220, min=1, max=4, tags={"Police"}, id="BuyM9Pistol" },
    { item="Base.Pistol2",       price=280, min=1, max=3, tags={"Police"}, id="BuyM1911Pistol" },
    { item="Base.Revolver_Long", price=260, min=1, max=2, tags={"Police"}, id="BuyM625Revolver" },
    { item="Base.Pistol3",       price=450, min=0, max=1, tags={"Rare", "Military"}, id="BuyDEPistol" },
    { item="Base.Revolver",      price=500, min=0, max=1, tags={"Rare"}, id="BuyMagnum" },
    -- Shotguns
    { item="Base.Shotgun",             price=450, min=1, max=3, tags={"Police", "Hunting"}, id="BuyJS2000" },
    { item="Base.DoubleBarrelShotgun", price=400, min=1, max=2, tags={"Hunting", "Civilian"}, id="BuyDoubleBarrel" },
    -- Rifles
    { item="Base.VarmintRifle",  price=350, min=1, max=2, tags={"Hunting"} },
    { item="Base.HuntingRifle",  price=550, min=0, max=2, tags={"Hunting", "Rare"} },
    { item="Base.AssaultRifle2", price=750, min=0, max=1, tags={"Military", "Rare"}, id="BuyM14Rifle" },
    { item="Base.AssaultRifle",  price=1200, min=0, max=1, tags={"Military", "Rare"}, id="BuyM16" },
})

-- 2. AXES
RegisterWeapon({"Blade", "Tool"}, {
    { item="Base.Axe",          price=120, min=1, max=3, tags={"Build", "Military"}, id="BuyFireAxe" },
    { item="Base.HandAxe",      price=70,  min=1, max=5, tags={"Survival", "Police"} },
    { item="Base.WoodAxe",      price=140, min=0, max=2, tags={"Build", "Heavy"} },
    { item="Base.PickAxe",      price=150, min=0, max=1, tags={"Heavy"}, id="BuyPickaxe" },
    { item="Base.StoneAxe",     price=15,  min=2, max=6, tags={"Survival", "Junk"} },
    { item="Base.SplittingAxe", price=110, min=0, max=2, tags={"Build"} },
    { item="Base.Hatchet",      price=65,  min=1, max=4, tags={"Survival"} },
})

-- 3. LONG BLUNT
RegisterWeapon({"Heavy"}, {
    { item="Base.Sledgehammer",      price=450, min=0, max=1, tags={"Tool", "Build", "Rare"} },
    { item="Base.Crowbar",           price=110, min=1, max=4, tags={"Tool", "Mechanic"} },
    { item="Base.BaseballBat",       price=60,  min=1, max=5, tags={"Sports", "Civilian"} },
    { item="Base.BaseballBatSpiked", price=95,  min=0, max=2, tags={"Weapon", "Illegal"} },
    { item="Base.Shovel",            price=75,  min=1, max=3, tags={"Tool", "Gardening", "Build"} },
    { item="Base.SnowShovel",        price=70,  min=0, max=2, tags={"Tool", "Gardening"} },
    { item="Base.GardenHoe",         price=65,  min=1, max=3, tags={"Tool", "Gardening", "Farmer"} },
    { item="Base.LeadPipe",          price=45,  min=1, max=4, tags={"Material", "Scavenge"} },
    { item="Base.MetalPipe",         price=40,  min=2, max=6, tags={"Material", "Scavenge"} },
    { item="Base.GolfClub",          price=35,  min=1, max=4, tags={"Sports", "Civilian"} },
    { item="Base.CanoePaddle",       price=30,  min=1, max=3, tags={"Survival", "Civilian"} },
})

-- 4. SHORT BLUNT & KITCHEN
RegisterWeapon({}, {
    { item="Base.Nightstick",     price=85, min=1, max=3, tags={"Weapon", "Police"} },
    { item="Base.Hammer",         price=50, min=2, max=6, tags={"Tool", "Build", "Carpenter"} },
    { item="Base.BallPeenHammer", price=40, min=1, max=4, tags={"Tool", "Mechanic", "Scavenge"} },
    { item="Base.ClubHammer",     price=55, min=1, max=3, tags={"Tool", "Build", "Heavy"} },
    { item="Base.PipeWrench",     price=75, min=1, max=3, tags={"Tool", "Mechanic", "Car"} },
    { item="Base.Wrench",         price=45, min=2, max=5, tags={"Tool", "Mechanic", "Car"} },
    { item="Base.WoodenMallet",   price=30, min=1, max=4, tags={"Tool", "Build"} },
    { item="Base.Pan",            price=20, min=2, max=5, tags={"Kitchen", "Food", "Civilian"}, id="BuyFryingPan" },
    { item="Base.GriddlePan",     price=25, min=1, max=3, tags={"Kitchen", "Food", "Civilian"} },
    { item="Base.Saucepan",       price=15, min=2, max=5, tags={"Kitchen", "Food", "Civilian"} },
    { item="Base.RollingPin",     price=12, min=1, max=4, tags={"Kitchen", "Food", "Civilian"} },
    { item="Base.MeatMasher",     price=25, min=1, max=3, tags={"Kitchen", "Meat", "Butcher"} },
    { item="Base.Plunger",        price=5,  min=1, max=2, tags={"Junk"} },
})

-- 5. BLADES (Long & Short)
RegisterWeapon({"Blade"}, {
    -- Long Blades
    { item="Base.Katana",        price=1500, min=0, max=1, tags={"Rare", "Military"} },
    { item="Base.Machete",       price=350,  min=0, max=2, tags={"Rare", "Military", "Survival"} },
    { item="Base.Scythe",        price=180,  min=0, max=1, tags={"Farmer", "Heavy"} },
    -- Short Blades
    { item="Base.HuntingKnife",  price=85, min=1, max=4, tags={"Survival", "Military", "Hunting"} },
    { item="Base.MeatCleaver",   price=60, min=1, max=3, tags={"Meat", "Butcher", "Kitchen"} },
    { item="Base.KitchenKnife",  price=25, min=2, max=6, tags={"Kitchen", "Civilian"} },
    { item="Base.Scalpel",       price=45, min=1, max=3, tags={"Medical", "Rare"} },
    { item="Base.IcePick",       price=40, min=1, max=2, tags={"Kitchen", "Scavenge"} },
    { item="Base.LetterOpener",  price=10, min=1, max=3, tags={"Junk", "Civilian"} },
    { item="Base.BreadKnife",    price=15, min=2, max=5, tags={"Kitchen", "Food"} },
    { item="Base.ButterKnife",   price=5,  min=2, max=10, tags={"Kitchen", "Junk"} },
    { item="Base.StoneKnife",    price=12, min=1, max=4, tags={"Survival", "Scavenge"} },
    { item="Base.HandFork",      price=20, min=1, max=3, tags={"Gardening", "Farmer"} },
    { item="Base.FlensingKnife", price=55, min=0, max=2, tags={"Butcher", "Survival"} },
})