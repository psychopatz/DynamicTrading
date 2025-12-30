require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================
-- AMMUNITION BOXES (The Standard Trade Unit)
-- ==========================================

DynamicTrading.AddItem("Buy9mmBox", {
    item = "Base.Bullets9mmBox",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Police"},
    basePrice = 30,
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("Buy38Box", {
    item = "Base.Bullets38Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Police"},
    basePrice = 25, -- Low damage, high commonality
    stockRange = { min=3, max=12 }
})

DynamicTrading.AddItem("Buy45Box", {
    item = "Base.Bullets45Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Police"},
    basePrice = 40,
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("Buy44Box", {
    item = "Base.Bullets44Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Rare"},
    basePrice = 55, -- High damage magnum rounds
    stockRange = { min=1, max=5 }
})

DynamicTrading.AddItem("BuyShotgunShellsBox", {
    item = "Base.ShotgunShellsBox",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Hunting", "Police"},
    basePrice = 60, -- Extremely high demand for leveling Aiming
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("Buy223Box", {
    item = "Base.223Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Hunting", "Rare"},
    basePrice = 65,
    stockRange = { min=1, max=5 }
})

DynamicTrading.AddItem("Buy308Box", {
    item = "Base.308Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Hunting", "Rare"},
    basePrice = 75, -- Highest damage sniper/rifle rounds
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("Buy556Box", {
    item = "Base.556Box",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Military", "Rare"},
    basePrice = 85, -- Military exclusive
    stockRange = { min=1, max=3 }
})

-- ==========================================
-- AMMUNITION CARTONS (Bulk/Heavy Trade)
-- ==========================================

local cartonTypes = {
    {id="9mm", item="Base.Bullets9mmCarton", price=320, tag="Police"},
    {id="38", item="Base.Bullets38Carton", price=280, tag="Police"},
    {id="45", item="Base.Bullets45Carton", price=420, tag="Police"},
    {id="44", item="Base.Bullets44Carton", price=580, tag="Rare"},
    {id="Shotgun", item="Base.ShotgunShellsCarton", price=650, tag="Hunting"},
    {id="223", item="Base.223Carton", price=700, tag="Hunting"},
    {id="308", item="Base.308Carton", price=800, tag="Rare"},
    {id="556", item="Base.556Carton", price=900, tag="Military"}
}

for _, data in ipairs(cartonTypes) do
    DynamicTrading.AddItem("BuyCarton"..data.id, {
        item = data.item,
        category = "Ammo",
        tags = {"Ammo", "Bulk", data.tag},
        basePrice = data.price,
        stockRange = { min=0, max=2 }
    })
end

-- ==========================================
-- LOOSE ROUNDS (For Scavengers)
-- ==========================================

-- DynamicTrading.AddItem("Buy9mmLoose", { item = "Base.Bullets9mm", category = "Ammo", tags = {"Ammo"}, basePrice = 2, stockRange = {min=10, max=50} })
-- DynamicTrading.AddItem("Buy38Loose", { item = "Base.Bullets38", category = "Ammo", tags = {"Ammo"}, basePrice = 1, stockRange = {min=10, max=50} })
-- DynamicTrading.AddItem("Buy45Loose", { item = "Base.Bullets45", category = "Ammo", tags = {"Ammo"}, basePrice = 3, stockRange = {min=10, max=40} })
-- DynamicTrading.AddItem("Buy44Loose", { item = "Base.Bullets44", category = "Ammo", tags = {"Ammo"}, basePrice = 4, stockRange = {min=5, max=20} })
-- DynamicTrading.AddItem("BuyShotgunShellLoose", { item = "Base.ShotgunShells", category = "Ammo", tags = {"Ammo"}, basePrice = 4, stockRange = {min=10, max=30} })
-- DynamicTrading.AddItem("Buy223Loose", { item = "Base.223Bullets", category = "Ammo", tags = {"Ammo"}, basePrice = 5, stockRange = {min=5, max=20} })
-- DynamicTrading.AddItem("Buy308Loose", { item = "Base.308Bullets", category = "Ammo", tags = {"Ammo"}, basePrice = 7, stockRange = {min=5, max=20} })
-- DynamicTrading.AddItem("Buy556Loose", { item = "Base.556Bullets", category = "Ammo", tags = {"Ammo"}, basePrice = 8, stockRange = {min=5, max=20} })

-- ==========================================
-- MAGAZINES (Essential Hardware)
-- ==========================================

DynamicTrading.AddItem("Buy9mmClip", {
    item = "Base.9mmClip",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Police"},
    basePrice = 60, -- M9 Magazine
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("Buy45Clip", {
    item = "Base.45Clip",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Police"},
    basePrice = 65, -- M1911 Magazine
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("Buy44Clip", {
    item = "Base.44Clip",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Rare"},
    basePrice = 80, -- D-E Magazine
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("BuyM14Clip", {
    item = "Base.M14Clip",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Hunting"},
    basePrice = 90, -- .308 Magazine
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("Buy556Clip", {
    item = "Base.556Clip",
    category = "Ammo",
    tags = {"Ammo", "Gun", "Military"},
    basePrice = 110, -- M16 Magazine
    stockRange = { min=0, max=2 }
})



