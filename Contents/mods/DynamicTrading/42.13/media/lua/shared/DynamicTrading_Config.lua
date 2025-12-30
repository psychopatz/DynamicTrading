DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = {}

print("[DynamicTrading] Loading Config...")

-- =================================================
-- STOCK PROFILE
-- =================================================
DynamicTrading.Config.StockProfile = {
    TotalSlots = 30, -- Increased slightly to accommodate the new variety
    Allocations = {
        Food = 15,
        Weapon = 4,
        Medical = 4,
        Material = 7,
    }
}

-- =================================================
-- MASTER ITEM DATABASE
-- Reorganized by Category: Food -> Weapon -> Medical -> Material
-- =================================================
DynamicTrading.Config.MasterList = {

    -- [CATEGORY: FOOD] - Canned & Pickled
    -- Price logic: Hunger value * ~0.7 (Meats/Meals priced higher for calories)
    
    -- Canned Low-Tier (Hunger 15-20)
    BuyCannedCarrots = { item = "Base.CannedCarrots", category = "Food", tags = {"Canned"}, basePrice = 10, stockRange = { min=5, max=15 } },
    BuyCannedTomato = { item = "Base.CannedTomato", category = "Food", tags = {"Canned"}, basePrice = 10, stockRange = { min=5, max=15 } },
    BuyCannedSardines = { item = "Base.CannedSardines", category = "Food", tags = {"Canned", "Fish"}, basePrice = 12, stockRange = { min=5, max=12 } },
    
    -- Canned Mid-Tier (Hunger 25-35)
    BuyCannedCorn = { item = "Base.CannedCorn", category = "Food", tags = {"Canned"}, basePrice = 18, stockRange = { min=5, max=12 } },
    BuyCannedPeas = { item = "Base.CannedPeas", category = "Food", tags = {"Canned"}, basePrice = 18, stockRange = { min=5, max=12 } },
    BuyCannedPotato = { item = "Base.CannedPotato", category = "Food", tags = {"Canned"}, basePrice = 25, stockRange = { min=3, max=10 } },
    BuyCannedTuna = { item = "Base.CannedTuna", category = "Food", tags = {"Canned", "Fish"}, basePrice = 28, stockRange = { min=3, max=10 } },

    -- Canned High-Tier Meals (Hunger 50-80)
    BuyCannedBeans = { item = "Base.CannedBeans", category = "Food", tags = {"Canned"}, basePrice = 45, stockRange = { min=4, max=10 } },
    BuyCannedSoup = { item = "Base.CannedVegetableSoup", category = "Food", tags = {"Canned"}, basePrice = 40, stockRange = { min=3, max=8 } },
    BuyCannedBolognese = { item = "Base.CannedBolognese", category = "Food", tags = {"Canned", "Meal"}, basePrice = 55, stockRange = { min=2, max=6 } },
    BuyCannedChili = { item = "Base.CannedChili", category = "Food", tags = {"Canned", "Meal"}, basePrice = 60, stockRange = { min=2, max=6 } },
    BuyCannedCornedBeef = { item = "Base.CannedCornedBeef", category = "Food", tags = {"Canned", "Meat"}, basePrice = 65, stockRange = { min=2, max=5 } },

    -- Pickled Foods (Jars)
    BuyJarCabbage = { item = "Base.Jar_Cabbage", category = "Food", tags = {"Pickled"}, basePrice = 22, stockRange = { min=2, max=6 } },
    BuyJarCarrots = { item = "Base.Jar_Carrots", category = "Food", tags = {"Pickled"}, basePrice = 15, stockRange = { min=2, max=6 } },
    BuyJarTomatoes = { item = "Base.Jar_Tomatoes", category = "Food", tags = {"Pickled"}, basePrice = 15, stockRange = { min=2, max=6 } },
    
    -- [CATEGORY: WEAPON]
    BuyAxe = {
        item = "Base.Axe",
        category = "Weapon",
        tags = {"Heavy", "Tool"},
        basePrice = 100,
        stockRange = { min=1, max=3 }
    },
    BuyCrowbar = {
        item = "Base.Crowbar",
        category = "Weapon",
        tags = {"Blunt"},
        basePrice = 70,
        stockRange = { min=1, max=4 }
    },
    BuyPistol = {
        item = "Base.Pistol",
        category = "Weapon",
        tags = {"Gun"},
        basePrice = 200,
        stockRange = { min=1, max=2 }
    },
    BuyShotgun = {
        item = "Base.Shotgun",
        category = "Weapon",
        tags = {"Gun"},
        basePrice = 350,
        stockRange = { min=1, max=2 }
    },

    -- [CATEGORY: MEDICAL]
    BuyBandage = {
        item = "Base.Bandage",
        category = "Medical",
        tags = {"Heal"},
        basePrice = 10,
        stockRange = { min=10, max=30 }
    },
    BuyDisinfectant = {
        item = "Base.Disinfectant",
        category = "Medical",
        tags = {"Heal"},
        basePrice = 25,
        stockRange = { min=2, max=8 }
    },
    BuyAlcoholWipes = {
        item = "Base.AlcoholWipes",
        category = "Medical",
        tags = {"Heal"},
        basePrice = 15,
        stockRange = { min=5, max=15 }
    },
    BuyFirstAidKit = {
        item = "Base.FirstAidKit",
        category = "Medical",
        tags = {"Container"},
        basePrice = 80,
        stockRange = { min=1, max=2 }
    },

    -- [CATEGORY: MATERIAL]
    Buy9mmAmmo = {
        item = "Base.Bullets9mmBox",
        category = "Material",
        tags = {"Ammo"},
        basePrice = 50,
        stockRange = { min=2, max=10 }
    },
    BuyShotgunAmmo = {
        item = "Base.ShotgunShellsBox",
        category = "Material",
        tags = {"Ammo"},
        basePrice = 70,
        stockRange = { min=2, max=8 }
    },
    BuyGasCan = {
        item = "Base.PetrolCan",
        category = "Material",
        tags = {"Fuel"},
        basePrice = 75,
        stockRange = { min=1, max=5 }
    },
    BuyNails = {
        item = "Base.NailsBox",
        category = "Material",
        tags = {"Build"},
        basePrice = 20,
        stockRange = { min=2, max=15 }
    },
    BuyWoodGlue = {
        item = "Base.Woodglue",
        category = "Material",
        tags = {"Repair"},
        basePrice = 30,
        stockRange = { min=2, max=6 }
    }
}

print("[DynamicTrading] Config Loaded Successfully.")