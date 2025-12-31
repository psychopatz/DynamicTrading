require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterAmmo(commonTags, items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        local finalTags = {"Ammo"}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Ammo",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. AMMUNITION BOXES
RegisterAmmo({"Gun"}, {
    { item="Base.Bullets9mmBox",      price=30, min=2, max=10, tags={"Police"}, id="Buy9mmBox" },
    { item="Base.Bullets38Box",       price=25, min=3, max=12, tags={"Police"}, id="Buy38Box" },
    { item="Base.Bullets45Box",       price=40, min=2, max=8,  tags={"Police"}, id="Buy45Box" },
    { item="Base.Bullets44Box",       price=55, min=1, max=5,  tags={"Rare"},   id="Buy44Box" },
    { item="Base.ShotgunShellsBox",   price=60, min=2, max=8,  tags={"Hunting", "Police"} },
    { item="Base.223Box",             price=65, min=1, max=5,  tags={"Hunting", "Rare"} },
    { item="Base.308Box",             price=75, min=1, max=4,  tags={"Hunting", "Rare"} },
    { item="Base.556Box",             price=85, min=1, max=3,  tags={"Military", "Rare"} },
})

-- 2. AMMUNITION CARTONS (Bulk)
RegisterAmmo({"Bulk"}, {
    { item="Base.Bullets9mmCarton",    price=320, min=0, max=2, tags={"Police"},  id="BuyCarton9mm" },
    { item="Base.Bullets38Carton",     price=280, min=0, max=2, tags={"Police"},  id="BuyCarton38" },
    { item="Base.Bullets45Carton",     price=420, min=0, max=2, tags={"Police"},  id="BuyCarton45" },
    { item="Base.Bullets44Carton",     price=580, min=0, max=2, tags={"Rare"},    id="BuyCarton44" },
    { item="Base.ShotgunShellsCarton", price=650, min=0, max=2, tags={"Hunting"}, id="BuyCartonShotgun" },
    { item="Base.223Carton",           price=700, min=0, max=2, tags={"Hunting"}, id="BuyCarton223" },
    { item="Base.308Carton",           price=800, min=0, max=2, tags={"Rare"},    id="BuyCarton308" },
    { item="Base.556Carton",           price=900, min=0, max=2, tags={"Military"},id="BuyCarton556" },
})

-- 3. LOOSE ROUNDS
RegisterAmmo({}, {
    { item="Base.Bullets9mm",    price=2, min=10, max=50, id="Buy9mmLoose" },
    { item="Base.Bullets38",     price=1, min=10, max=50, id="Buy38Loose" },
    { item="Base.Bullets45",     price=3, min=10, max=40, id="Buy45Loose" },
    { item="Base.Bullets44",     price=4, min=5,  max=20, id="Buy44Loose" },
    { item="Base.ShotgunShells", price=4, min=10, max=30, id="BuyShotgunShellLoose" },
    { item="Base.223Bullets",    price=5, min=5,  max=20, id="Buy223Loose" },
    { item="Base.308Bullets",    price=7, min=5,  max=20, id="Buy308Loose" },
    { item="Base.556Bullets",    price=8, min=5,  max=20, id="Buy556Loose" },
})

-- 4. MAGAZINES
RegisterAmmo({"Gun"}, {
    { item="Base.9mmClip",  price=60,  min=1, max=4, tags={"Police"} },
    { item="Base.45Clip",  price=65,  min=1, max=3, tags={"Police"} },
    { item="Base.44Clip",  price=80,  min=0, max=2, tags={"Rare"} },
    { item="Base.M14Clip", price=90,  min=0, max=2, tags={"Hunting"} },
    { item="Base.556Clip", price=110, min=0, max=2, tags={"Military"} },
})