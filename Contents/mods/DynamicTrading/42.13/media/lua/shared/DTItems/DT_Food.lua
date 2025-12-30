require "DynamicTrading_Config"

if not DynamicTrading then return end

-- === CANNED GOODS (Non-Perishable) ===
-- Balanced based on hunger replenishment (~$1/point) and rarity.
-- All items are the unopened/sealed variants.

-- High-Satiety Meats & Meals
DynamicTrading.AddItem("BuyCannedChili", {
    item = "Base.CannedChili",
    category = "Food",
    tags = {"Canned", "Meat", "NonPerishable"},
    basePrice = 40, -- Hunger -40
    stockRange = { min=3, max=8 }
})

DynamicTrading.AddItem("BuyCannedBolognese", {
    item = "Base.CannedBolognese",
    category = "Food",
    tags = {"Canned", "Meat", "NonPerishable"},
    basePrice = 40, -- Hunger -40
    stockRange = { min=3, max=8 }
})

DynamicTrading.AddItem("BuyCannedCornedBeef", {
    item = "Base.CannedCornedBeef",
    category = "Food",
    tags = {"Canned", "Meat", "NonPerishable"},
    basePrice = 35, -- Hunger -35
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyCannedBeans", {
    item = "Base.TinnedBeans",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 30, -- Hunger -30
    stockRange = { min=5, max=15 }
})

-- Soups
DynamicTrading.AddItem("BuyCannedMushroomSoup", {
    item = "Base.CannedMushroomSoup",
    category = "Food",
    tags = {"Canned", "Soup", "NonPerishable"},
    basePrice = 25, -- Hunger -25
    stockRange = { min=4, max=10 }
})

DynamicTrading.AddItem("BuyCannedVegetableSoup", {
    item = "Base.TinnedSoup",
    category = "Food",
    tags = {"Canned", "Soup", "NonPerishable"},
    basePrice = 25, -- Hunger -25
    stockRange = { min=4, max=10 }
})

-- Vegetables
DynamicTrading.AddItem("BuyCannedCorn", {
    item = "Base.CannedCorn",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 20, -- Hunger -20
    stockRange = { min=5, max=12 }
})

DynamicTrading.AddItem("BuyCannedPotato", {
    item = "Base.CannedPotato2",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 18, -- Hunger -18
    stockRange = { min=5, max=12 }
})

DynamicTrading.AddItem("BuyCannedPeas", {
    item = "Base.CannedPeas",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 15, -- Hunger -15
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyCannedTomato", {
    item = "Base.CannedTomato2",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 12, -- Hunger -12
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyCannedCarrots", {
    item = "Base.CannedCarrots2",
    category = "Food",
    tags = {"Canned", "Vegetable", "NonPerishable"},
    basePrice = 12, -- Hunger -12
    stockRange = { min=5, max=15 }
})

-- Fish
DynamicTrading.AddItem("BuyCannedTuna", {
    item = "Base.TunaTin",
    category = "Food",
    tags = {"Canned", "Fish", "NonPerishable"},
    basePrice = 18, -- Hunger -15 (High Protein)
    stockRange = { min=4, max=10 }
})

DynamicTrading.AddItem("BuyCannedSardines", {
    item = "Base.CannedSardines",
    category = "Food",
    tags = {"Canned", "Fish", "NonPerishable"},
    basePrice = 10, -- Hunger -10
    stockRange = { min=5, max=20 }
})

-- Fruits & Sweets
DynamicTrading.AddItem("BuyCannedPeaches", {
    item = "Base.CannedPeaches",
    category = "Food",
    tags = {"Canned", "Fruit", "NonPerishable"},
    basePrice = 25, -- Hunger -20 + Happiness
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyCannedPineapple", {
    item = "Base.CannedPineapple",
    category = "Food",
    tags = {"Canned", "Fruit", "NonPerishable"},
    basePrice = 25, -- Hunger -20 + Happiness
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyCannedFruitCocktail", {
    item = "Base.CannedFruitCocktail",
    category = "Food",
    tags = {"Canned", "Fruit", "NonPerishable"},
    basePrice = 25, -- Hunger -20 + Happiness
    stockRange = { min=2, max=8 }
})

-- Canned Liquids
DynamicTrading.AddItem("BuyCannedFruitBeverage", {
    item = "Base.CannedFruitBeverage",
    category = "Food",
    tags = {"Canned", "Drink", "NonPerishable"},
    basePrice = 15, -- Hunger -10, Thirst -15
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyCannedMilk", {
    item = "Base.CannedMilk",
    category = "Food",
    tags = {"Canned", "Dairy", "Drink", "NonPerishable"},
    basePrice = 15, -- Hunger -10, Thirst -10
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyWaterRationCan", {
    item = "Base.WaterRationCan",
    category = "Food",
    tags = {"Canned", "Drink", "Survival", "NonPerishable"},
    basePrice = 20, -- Pure Thirst replenishment
    stockRange = { min=1, max=5 }
})

-- Specialty / Junk Cans
DynamicTrading.AddItem("BuyCannedDogFood", {
    item = "Base.CannedDogFood",
    category = "Food",
    tags = {"Canned", "Meat", "JunkFood", "NonPerishable"},
    basePrice = 10, -- Hunger -40 (Cheaper due to massive Unhappiness/Boredom)
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyMysteryCan", {
    item = "Base.MysteryCan",
    category = "Food",
    tags = {"Canned", "Mystery", "NonPerishable"},
    basePrice = 8, -- Random Hunger values when opened
    stockRange = { min=1, max=5 }
})

DynamicTrading.AddItem("BuyDentedCan", {
    item = "Base.DentedCan",
    category = "Food",
    tags = {"Canned", "Mystery", "Risky", "NonPerishable"},
    basePrice = 4, -- Botulism risk / Random contents
    stockRange = { min=1, max=3 }
})


-- === PICKLED / JARRED GOODS (Long Shelf Life) ===
-- Balanced at a premium (~$1.5/hunger) due to the weight and preservation quality.
-- These are the sealed (unopened) versions.

DynamicTrading.AddItem("BuyPickles", {
    item = "Base.Pickles",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred"},
    basePrice = 12, -- Hunger -8
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyJarredCabbage", {
    item = "Base.CabbageJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 38, -- Hunger -25
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyJarredPotato", {
    item = "Base.PotatoJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 27, -- Hunger -18
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyJarredCarrots", {
    item = "Base.CarrotsJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 18, -- Hunger -12
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyJarredTomato", {
    item = "Base.TomatoJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 18, -- Hunger -12
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyJarredBroccoli", {
    item = "Base.BroccoliJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 16, -- Hunger -11
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyJarredEggplant", {
    item = "Base.EggplantJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 16, -- Hunger -11
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyJarredLeeks", {
    item = "Base.LeeksJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 15, -- Hunger -10
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyJarredRadish", {
    item = "Base.RadishJar",
    category = "Food",
    tags = {"Pickled", "Vegetable", "Preserved", "Jarred", "Crop"},
    basePrice = 15, -- Hunger -10
    stockRange = { min=1, max=3 }
})

-- Common Jarred Ingredients (Non-Perishable)
DynamicTrading.AddItem("BuyJarMayo", {
    item = "Base.Mayonnaise",
    category = "Food",
    tags = {"Jarred", "Condiment", "Fats", "NonPerishable"},
    basePrice = 25, -- Hunger -11 (High calorie/fat)
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyJarPeanutButter", {
    item = "Base.PeanutButter",
    category = "Food",
    tags = {"Jarred", "Protein", "HighCalorie", "NonPerishable"},
    basePrice = 45, -- Hunger -25 (Extreme calorie density)
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyJarHoney", {
    item = "Base.Honey",
    category = "Food",
    tags = {"Jarred", "Sweet", "Preserved", "NonPerishable"},
    basePrice = 30, -- Hunger -20
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyJarJam", {
    item = "Base.JamFruit",
    category = "Food",
    tags = {"Jarred", "Sweet", "Preserved", "NonPerishable"},
    basePrice = 20, -- Hunger -10
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyJarMarmalade", {
    item = "Base.Marmalade",
    category = "Food",
    tags = {"Jarred", "Sweet", "Preserved", "NonPerishable"},
    basePrice = 20, -- Hunger -10
    stockRange = { min=1, max=4 }
})


-- === FRESH VEGETABLES ===
-- Perishable. Balanced lower than canned goods due to spoil risk.
-- "Crop" tag indicates items that can be grown via Farming.

DynamicTrading.AddItem("BuyCabbage", {
    item = "Base.Cabbage",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 15, -- Hunger -25
    stockRange = { min=10, max=30 }
})

DynamicTrading.AddItem("BuyCorn", {
    item = "Base.Corn",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 14, -- Hunger -20
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyPotato", {
    item = "Base.Potato",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 12, -- Hunger -18
    stockRange = { min=10, max=30 }
})

DynamicTrading.AddItem("BuyLettuce", {
    item = "Base.Lettuce",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyZucchini", {
    item = "Base.Zucchini",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyTomato", {
    item = "Base.Tomato",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 8, -- Hunger -12
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyBellPepper", {
    item = "Base.BellPepper",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 8, -- Hunger -12
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyCarrots", {
    item = "Base.Carrots",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 8, -- Hunger -12
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyBroccoli", {
    item = "Base.Broccoli",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 7, -- Hunger -11
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyEggplant", {
    item = "Base.Eggplant",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 7, -- Hunger -11
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyLeek", {
    item = "Base.Leek",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Forage"},
    basePrice = 7, -- Hunger -10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyOnion", {
    item = "Base.Onion",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 7, -- Hunger -10
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyRedRadish", {
    item = "Base.RedRadish",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Crop"},
    basePrice = 6, -- Hunger -10
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyMushroom", {
    item = "Base.Mushroom",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Forage"},
    basePrice = 5, -- Hunger -7
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyPeas", {
    item = "Base.Peas",
    category = "Food",
    tags = {"Fresh", "Vegetable"},
    basePrice = 3, -- Hunger -5
    stockRange = { min=10, max=30 }
})

-- Wild / Foraged Greens
DynamicTrading.AddItem("BuyWildEdiblePlant", {
    item = "Base.WildEdiblePlant",
    category = "Food",
    tags = {"Fresh", "Vegetable", "Forage"},
    basePrice = 2, -- Hunger -2
    stockRange = { min=10, max=40 }
})


-- === FRESH FRUITS ===
-- Perishable. Balanced based on hunger and happiness.
-- "Exotic" tags can be used for high-end importers.
-- "Berry" tags for foraging-specific merchants.

DynamicTrading.AddItem("BuyWatermelon", {
    item = "Base.Watermelon",
    category = "Food",
    tags = {"Fresh", "Fruit", "Heavy"},
    basePrice = 35, -- Hunger -50
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyPineapple", {
    item = "Base.Pineapple",
    category = "Food",
    tags = {"Fresh", "Fruit", "Exotic"},
    basePrice = 22, -- Hunger -30
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyPeach", {
    item = "Base.Peach",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 14, -- Hunger -20
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyApple", {
    item = "Base.Apple",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyBanana", {
    item = "Base.Banana",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyOrange", {
    item = "Base.Orange",
    category = "Food",
    tags = {"Fresh", "Fruit", "Citrus"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyPear", {
    item = "Base.Pear",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyMango", {
    item = "Base.Mango",
    category = "Food",
    tags = {"Fresh", "Fruit", "Exotic"},
    basePrice = 10, -- Hunger -15
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyGrapes", {
    item = "Base.Grapes",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 8, -- Hunger -12
    stockRange = { min=5, max=12 }
})

DynamicTrading.AddItem("BuyPlum", {
    item = "Base.Plum",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 7, -- Hunger -10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyLemon", {
    item = "Base.Lemon",
    category = "Food",
    tags = {"Fresh", "Fruit", "Citrus"},
    basePrice = 5, -- Hunger -5
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyLime", {
    item = "Base.Lime",
    category = "Food",
    tags = {"Fresh", "Fruit", "Citrus"},
    basePrice = 5, -- Hunger -5
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyStrawberries", {
    item = "Base.Strawberries",
    category = "Food",
    tags = {"Fresh", "Fruit", "Crop"},
    basePrice = 4, -- Hunger -5
    stockRange = { min=10, max=30 }
})

DynamicTrading.AddItem("BuyCherry", {
    item = "Base.Cherry",
    category = "Food",
    tags = {"Fresh", "Fruit"},
    basePrice = 3, -- Hunger -4
    stockRange = { min=10, max=25 }
})

-- Wild Berries (Foraged)
DynamicTrading.AddItem("BuyBerryBlack", {
    item = "Base.BerryBlack",
    category = "Food",
    tags = {"Fresh", "Fruit", "Berry", "Forage"},
    basePrice = 3, -- Hunger -5
    stockRange = { min=10, max=40 }
})

DynamicTrading.AddItem("BuyBerryBlue", {
    item = "Base.BerryBlue",
    category = "Food",
    tags = {"Fresh", "Fruit", "Berry", "Forage"},
    basePrice = 3, -- Hunger -5
    stockRange = { min=10, max=40 }
})

DynamicTrading.AddItem("BuyBerryGeneric", {
    item = "Base.BerryGeneric",
    category = "Food",
    tags = {"Fresh", "Fruit", "Berry", "Forage"},
    basePrice = 2, -- Hunger -5
    stockRange = { min=10, max=40 }
})

-- Other Foraged Fruits
DynamicTrading.AddItem("BuyRosehips", {
    item = "Base.Rosehips",
    category = "Food",
    tags = {"Fresh", "Fruit", "Forage"},
    basePrice = 2, -- Hunger -3
    stockRange = { min=5, max=20 }
})


-- === CULINARY HERBS ===
-- Very low hunger reduction, but high value for cooking recipes.
-- Price floor set at $4 to reflect rarity vs. weight.

DynamicTrading.AddItem("BuyBasil", {
    item = "Base.Basil",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyChives", {
    item = "Base.Chives",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyCilantro", {
    item = "Base.Cilantro",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyOregano", {
    item = "Base.Oregano",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyParsley", {
    item = "Base.Parsley",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyRosemary", {
    item = "Base.Rosemary",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuySage", {
    item = "Base.Sage",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyThyme", {
    item = "Base.Thyme",
    category = "Food",
    tags = {"Fresh", "Herb", "Culinary"},
    basePrice = 4, -- Hunger -2
    stockRange = { min=2, max=8 }
})

-- === WILD / MEDICINAL HERBS ===
-- Foraged items. Priced higher due to medical utility.
-- These effectively act as "Natural Medicine".

DynamicTrading.AddItem("BuyLemongrass", {
    item = "Base.LemonGrass",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 15, -- Utility: Cures Food Poisoning
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyGinseng", {
    item = "Base.Ginseng",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 12, -- Utility: Restores Endurance
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyGarlicMustard", {
    item = "Base.GarlicMustard",
    category = "Food",
    tags = {"Herb", "Culinary", "Forage"},
    basePrice = 5, -- Utility: Cooking ingredient
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyCommonMallow", {
    item = "Base.CommonMallow",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 8, -- Utility: Cures Cold/Flu
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyBlackSage", {
    item = "Base.BlackSage",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 10, -- Utility: Pain Relief
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyPlantain", {
    item = "Base.Plantain",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 12, -- Utility: Heals Wounds Faster
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyWildGarlic", {
    item = "Base.WildGarlic",
    category = "Food",
    tags = {"Herb", "Medicinal", "Forage"},
    basePrice = 12, -- Utility: Fights Infection
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyViolets", {
    item = "Base.Violets",
    category = "Food",
    tags = {"Herb", "Fruit", "Forage"},
    basePrice = 3, -- Hunger -1 (Mainly for happiness)
    stockRange = { min=5, max=15 }
})


-- === SPICES & PANTRY STAPLES ===
-- These items are non-perishable and have high utility in cooking recipes.
-- Balanced by rarity and their effect on Boredom/Unhappiness.

DynamicTrading.AddItem("BuySalt", {
    item = "Base.Salt",
    category = "Food",
    tags = {"Spice", "Condiment", "Pantry", "NonPerishable"},
    basePrice = 25, -- High utility for flavor/recipes
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyPepper", {
    item = "Base.Pepper",
    category = "Food",
    tags = {"Spice", "Condiment", "Pantry", "NonPerishable"},
    basePrice = 25, 
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuySugar", {
    item = "Base.Sugar",
    category = "Food",
    tags = {"Spice", "Sweet", "Pantry", "Baking", "NonPerishable"},
    basePrice = 40, -- High value for baking and calories
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyYeast", {
    item = "Base.Yeast",
    category = "Food",
    tags = {"Spice", "Pantry", "Baking", "NonPerishable"},
    basePrice = 20, -- Essential for making bread
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyVinegar", {
    item = "Base.Vinegar",
    category = "Food",
    tags = {"Spice", "Pantry", "Preservation", "NonPerishable"},
    basePrice = 45, -- High price: Essential for pickling/preservation
    stockRange = { min=1, max=3 }
})

-- === OILS & FATS ===
-- Extremely high calorie density.
DynamicTrading.AddItem("BuyOliveOil", {
    item = "Base.OliveOil",
    category = "Food",
    tags = {"Spice", "CookingOil", "Fats", "NonPerishable"},
    basePrice = 35, -- Hunger -2, but massive calories
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyVegetableOil", {
    item = "Base.VegetableOil",
    category = "Food",
    tags = {"Spice", "CookingOil", "Fats", "NonPerishable"},
    basePrice = 30,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyLard", {
    item = "Base.Lard",
    category = "Food",
    tags = {"Spice", "Fats", "Cooking", "NonPerishable"},
    basePrice = 25, -- Hunger -10, high calories
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyMargarine", {
    item = "Base.Margarine",
    category = "Food",
    tags = {"Spice", "Fats", "Cooking", "NonPerishable"},
    basePrice = 20,
    stockRange = { min=2, max=5 }
})

-- === SAUCES & CONDIMENTS ===
-- Used to remove unhappiness and boredom from meals.
DynamicTrading.AddItem("BuyKetchup", {
    item = "Base.Ketchup",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 15,
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyMustard", {
    item = "Base.Mustard",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 15,
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyHotSauce", {
    item = "Base.HotSauce",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 18,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuySoySauce", {
    item = "Base.SoySauce",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 20,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyHoisinSauce", {
    item = "Base.HoisinSauce",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 20,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyMarinara", {
    item = "Base.Marinara",
    category = "Food",
    tags = {"Condiment", "Sauce", "NonPerishable"},
    basePrice = 15,
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyBouillonCube", {
    item = "Base.BouillonCube",
    category = "Food",
    tags = {"Spice", "Pantry", "Cooking", "NonPerishable"},
    basePrice = 10,
    stockRange = { min=3, max=10 }
})


-- === ANIMAL CARCASSES (Whole Animals) ===
-- These must be butchered to produce meat. 
-- Balanced by total potential hunger yield and weight.
-- Tags: AnimalCarcass (General), Game (Wild), Livestock (Farm).

-- Small Game (Trapping/Foraging)
DynamicTrading.AddItem("BuyDeadRabbit", {
    item = "Base.DeadRabbit",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Trapping"},
    basePrice = 40, -- Yields ~30 Hunger meat
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyDeadSquirrel", {
    item = "Base.DeadSquirrel",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Trapping"},
    basePrice = 20, -- Yields ~15 Hunger meat
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyDeadBird", {
    item = "Base.DeadBird",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Trapping"},
    basePrice = 20, -- Yields ~15 Hunger meat
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyDeadRat", {
    item = "Base.DeadRat",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Pest"},
    basePrice = 10, -- Yields ~10 Hunger (Low quality)
    stockRange = { min=1, max=5 }
})

-- Poultry (Farm & Wild)
DynamicTrading.AddItem("BuyDeadChicken", {
    item = "Base.DeadChicken",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Livestock", "Poultry"},
    basePrice = 35, -- Yields ~25-30 Hunger meat
    stockRange = { min=2, max=5 }
})

DynamicTrading.AddItem("BuyDeadDuck", {
    item = "Base.DeadDuck",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Poultry"},
    basePrice = 40, 
    stockRange = { min=1, max=3 }
})

DynamicTrading.AddItem("BuyDeadTurkey", {
    item = "Base.DeadTurkey",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Poultry"},
    basePrice = 70, -- Large yield
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyDeadGoose", {
    item = "Base.DeadGoose",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "Poultry"},
    basePrice = 55,
    stockRange = { min=1, max=2 }
})

-- Big Game (Hunting / B42)
DynamicTrading.AddItem("BuyDeadDeer", {
    item = "Base.DeadDeer",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "LargeGame"},
    basePrice = 250, -- Massive meat yield
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyDeadBoar", {
    item = "Base.DeadBoar",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "LargeGame"},
    basePrice = 220,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyDeadBear", {
    item = "Base.DeadBear",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Game", "LargeGame"},
    basePrice = 450, -- Highest yield / Dangerous to hunt
    stockRange = { min=0, max=1 }
})

-- Farm Livestock (B42)
DynamicTrading.AddItem("BuyDeadCow", {
    item = "Base.DeadCow",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Livestock"},
    basePrice = 500, -- Highest calorie investment
    stockRange = { min=0, max=1 }
})

DynamicTrading.AddItem("BuyDeadPig", {
    item = "Base.DeadPig",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Livestock"},
    basePrice = 240,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyDeadSheep", {
    item = "Base.DeadSheep",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Livestock"},
    basePrice = 180,
    stockRange = { min=1, max=2 }
})

DynamicTrading.AddItem("BuyDeadGoat", {
    item = "Base.DeadGoat",
    category = "Food",
    tags = {"Fresh", "Meat", "AnimalCarcass", "Livestock"},
    basePrice = 160,
    stockRange = { min=1, max=3 }
})



-- === RAW MEATS (Individual Cuts) ===
-- All items are perishable (Fresh). 
-- Balanced by hunger replenishment and calorie density.

-- Red Meats (Beef, Pork, Lamb)
DynamicTrading.AddItem("BuySteak", {
    item = "Base.Steak",
    category = "Food",
    tags = {"Fresh", "Meat", "Beef", "RawMeat"},
    basePrice = 20, -- Hunger -15
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyGroundBeef", {
    item = "Base.GroundBeef",
    category = "Food",
    tags = {"Fresh", "Meat", "Beef", "RawMeat"},
    basePrice = 20, -- Hunger -15
    stockRange = { min=5, max=12 }
})

DynamicTrading.AddItem("BuyPorkChop", {
    item = "Base.PorkChop",
    category = "Food",
    tags = {"Fresh", "Meat", "Pork", "RawMeat"},
    basePrice = 16, -- Hunger -12
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyMuttonChop", {
    item = "Base.MuttonChop",
    category = "Food",
    tags = {"Fresh", "Meat", "Lamb", "RawMeat"},
    basePrice = 16, -- Hunger -12
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyHam", {
    item = "Base.Ham",
    category = "Food",
    tags = {"Fresh", "Meat", "Pork", "RawMeat"},
    basePrice = 30, -- Hunger -20 (High Calorie)
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyBacon", {
    item = "Base.Bacon",
    category = "Food",
    tags = {"Fresh", "Meat", "Pork", "RawMeat", "Breakfast"},
    basePrice = 18, -- Hunger -10 (Very high fat/calorie value)
    stockRange = { min=4, max=10 }
})

-- Poultry
DynamicTrading.AddItem("BuyChickenMeat", {
    item = "Base.Chicken",
    category = "Food",
    tags = {"Fresh", "Meat", "Poultry", "RawMeat"},
    basePrice = 25, -- Hunger -25
    stockRange = { min=3, max=10 }
})

-- Small Game Meat (Butchered)
DynamicTrading.AddItem("BuyRabbitMeat", {
    item = "Base.RabbitMeat",
    category = "Food",
    tags = {"Fresh", "Meat", "GameMeat", "RawMeat"},
    basePrice = 15, -- Hunger -15
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyBirdMeat", {
    item = "Base.BirdMeat",
    category = "Food",
    tags = {"Fresh", "Meat", "GameMeat", "RawMeat"},
    basePrice = 10, -- Hunger -10
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("BuySmallAnimalMeat", {
    item = "Base.SmallAnimalMeat",
    category = "Food",
    tags = {"Fresh", "Meat", "GameMeat", "RawMeat"},
    basePrice = 8, -- Hunger -8 (Squirrel/Rat/etc)
    stockRange = { min=5, max=15 }
})

-- Fish & Seafood
DynamicTrading.AddItem("BuySalmon", {
    item = "Base.Salmon",
    category = "Food",
    tags = {"Fresh", "Meat", "Fish", "RawMeat"},
    basePrice = 35, -- Hunger -30
    stockRange = { min=1, max=4 }
})

DynamicTrading.AddItem("BuyBass", {
    item = "Base.Bass",
    category = "Food",
    tags = {"Fresh", "Meat", "Fish", "RawMeat"},
    basePrice = 25, -- Hunger -25
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyCatfish", {
    item = "Base.Catfish",
    category = "Food",
    tags = {"Fresh", "Meat", "Fish", "RawMeat"},
    basePrice = 30, -- Hunger -30
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyTrout", {
    item = "Base.Trout",
    category = "Food",
    tags = {"Fresh", "Meat", "Fish", "RawMeat"},
    basePrice = 15, -- Hunger -15
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyShrimp", {
    item = "Base.Shrimp",
    category = "Food",
    tags = {"Fresh", "Meat", "Seafood", "RawMeat"},
    basePrice = 6, -- Hunger -5
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyLobster", {
    item = "Base.Lobster",
    category = "Food",
    tags = {"Fresh", "Meat", "Seafood", "RawMeat"},
    basePrice = 35, -- Hunger -25 + Happiness
    stockRange = { min=1, max=3 }
})

-- Wild/Alternative Meats
DynamicTrading.AddItem("BuyFrogMeat", {
    item = "Base.FrogMeat",
    category = "Food",
    tags = {"Fresh", "Meat", "GameMeat", "RawMeat"},
    basePrice = 5, -- Hunger -5
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuySnakeMeat", {
    item = "Base.SnakeMeat",
    category = "Food",
    tags = {"Fresh", "Meat", "GameMeat", "RawMeat"},
    basePrice = 10, -- Hunger -8
    stockRange = { min=2, max=8 }
})


-- === GRAINS & DRY GOODS ===
-- Most of these require water and cooking to reach full hunger potential.
-- Non-perishable and excellent for long-term storage.

-- Bulk Staples
DynamicTrading.AddItem("BuyRice", {
    item = "Base.Rice",
    category = "Food",
    tags = {"Grains", "DryGood", "Cookable", "NonPerishable"},
    basePrice = 25, -- Hunger -30 (when cooked)
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyPasta", {
    item = "Base.Pasta",
    category = "Food",
    tags = {"Grains", "DryGood", "Cookable", "NonPerishable"},
    basePrice = 25, -- Hunger -30 (when cooked)
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyFlour", {
    item = "Base.Flour",
    category = "Food",
    tags = {"Grains", "DryGood", "Baking", "NonPerishable"},
    basePrice = 20, -- Essential ingredient for bread/cakes
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyCornmeal", {
    item = "Base.Cornmeal",
    category = "Food",
    tags = {"Grains", "DryGood", "Baking", "NonPerishable"},
    basePrice = 20,
    stockRange = { min=3, max=10 }
})

-- Ready-to-Eat Grains
DynamicTrading.AddItem("BuyCereal", {
    item = "Base.Cereal",
    category = "Food",
    tags = {"Grains", "DryGood", "Breakfast", "NonPerishable"},
    basePrice = 60, -- Hunger -80 (The gold standard of survival food)
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyOats", {
    item = "Base.Oats",
    category = "Food",
    tags = {"Grains", "DryGood", "Breakfast", "NonPerishable"},
    basePrice = 15, -- Hunger -20
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyDryRamen", {
    item = "Base.Ramen",
    category = "Food",
    tags = {"Grains", "DryGood", "Cookable", "NonPerishable"},
    basePrice = 12, -- Hunger -10 (Can be eaten dry but better cooked)
    stockRange = { min=10, max=25 }
})

-- Build 42 / Advanced Grains
DynamicTrading.AddItem("BuyQuinoa", {
    item = "Base.Quinoa",
    category = "Food",
    tags = {"Grains", "DryGood", "Cookable", "NonPerishable"},
    basePrice = 18, -- Hunger -20
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyBuckwheat", {
    item = "Base.Buckwheat",
    category = "Food",
    tags = {"Grains", "DryGood", "Cookable", "NonPerishable"},
    basePrice = 18, -- Hunger -20
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyWheat", {
    item = "Base.Wheat",
    category = "Food",
    tags = {"Grains", "DryGood", "FarmProduce"},
    basePrice = 10, -- Raw material for Flour
    stockRange = { min=10, max=30 }
})

DynamicTrading.AddItem("BuyBarley", {
    item = "Base.Barley",
    category = "Food",
    tags = {"Grains", "DryGood", "Brewing"},
    basePrice = 12, -- Used in soups or brewing
    stockRange = { min=5, max=20 }
})

-- Grain-based Snacks
DynamicTrading.AddItem("BuyTortillaChips", {
    item = "Base.TortillaChips",
    category = "Food",
    tags = {"Grains", "Snack", "JunkFood", "NonPerishable"},
    basePrice = 15, -- Hunger -15
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyCrackers", {
    item = "Base.Crackers",
    category = "Food",
    tags = {"Grains", "Snack", "NonPerishable"},
    basePrice = 12, -- Hunger -10
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyPopcorn", {
    item = "Base.PopcornCorn",
    category = "Food",
    tags = {"Grains", "Snack", "Cookable", "NonPerishable"},
    basePrice = 8, -- Requires cooking to become Popcorn
    stockRange = { min=5, max=15 }
})



-- === CANDY & SWEETS ===
-- Non-perishable. High value for Happiness/Boredom reduction.
-- Balanced primarily on morale-boosting properties.

DynamicTrading.AddItem("BuyChocolate", {
    item = "Base.Chocolate",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 25, -- Hunger -15, Happiness +10
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("BuyCandyBar", {
    item = "Base.CandyBar",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 15, -- Hunger -10, Happiness +10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyGummyBears", {
    item = "Base.GummyBears",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 30, -- Hunger -10, Happiness +20
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyGummyWorms", {
    item = "Base.GummyWorms",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 30, -- Hunger -10, Happiness +20
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyHardCandy", {
    item = "Base.HardCandy",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 20, -- Hunger -10, Happiness +15
    stockRange = { min=5, max=12 }
})

DynamicTrading.AddItem("BuyLollipop", {
    item = "Base.Lollipop",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 8, -- Hunger -5, Happiness +5
    stockRange = { min=10, max=25 }
})

DynamicTrading.AddItem("BuyJawbreaker", {
    item = "Base.Jawbreaker",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 12, -- Hunger -5, Happiness +10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyLicorice", {
    item = "Base.Licorice",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 18, -- Hunger -10, Happiness +10
    stockRange = { min=3, max=10 }
})

DynamicTrading.AddItem("BuyMarshmallows", {
    item = "Base.Marshmallows",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 20, -- Hunger -10, Happiness +10
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyPeppermints", {
    item = "Base.Mints",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 5, -- Hunger -2, Happiness +5
    stockRange = { min=10, max=30 }
})

-- Chocolate Chips (Baking/Snack)
DynamicTrading.AddItem("BuyChocolateChips", {
    item = "Base.ChocolateChips",
    category = "Food",
    tags = {"Candy", "Sweet", "Baking", "NonPerishable"},
    basePrice = 15, -- Hunger -5, used in recipes
    stockRange = { min=3, max=8 }
})

-- Build 42 Specific / Rare Sweets
DynamicTrading.AddItem("BuyCandyFruitDrops", {
    item = "Base.CandyFruitDrops",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 22,
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyRockCandy", {
    item = "Base.RockCandy",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 15,
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyToffee", {
    item = "Base.Toffee",
    category = "Food",
    tags = {"Candy", "Sweet", "Snack", "NonPerishable"},
    basePrice = 18,
    stockRange = { min=2, max=8 }
})


-- === DAIRY & EGGS (Perishable) ===
-- High protein and fat content.

DynamicTrading.AddItem("BuyCheese", {
    item = "Base.Cheese",
    category = "Food",
    tags = {"Fresh", "Dairy", "Protein"},
    basePrice = 15, -- Hunger -15
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyYogurt", {
    item = "Base.Yogurt",
    category = "Food",
    tags = {"Fresh", "Dairy"},
    basePrice = 12, -- Hunger -10
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyButter", {
    item = "Base.Butter",
    category = "Food",
    tags = {"Fresh", "Dairy", "Fats", "HighCalorie"},
    basePrice = 30, -- Hunger -20 (Extreme calories/Cooking utility)
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyEgg", {
    item = "Base.Egg",
    category = "Food",
    tags = {"Fresh", "Protein", "LivestockProduct"},
    basePrice = 5, -- Hunger -5
    stockRange = { min=12, max=24 }
})

DynamicTrading.AddItem("BuyWildEgg", {
    item = "Base.WildEgg",
    category = "Food",
    tags = {"Fresh", "Protein", "Forage"},
    basePrice = 4, -- Hunger -5
    stockRange = { min=2, max=10 }
})

-- === PREPARED & FROZEN MEALS (Unopened) ===
-- High satiety but requires power/freezers to maintain.

DynamicTrading.AddItem("BuyTVDinner", {
    item = "Base.TVDinner",
    category = "Food",
    tags = {"Fresh", "Frozen", "PreparedMeal"},
    basePrice = 25, -- Hunger -30
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyPizza", {
    item = "Base.Pizza",
    category = "Food",
    tags = {"Fresh", "PreparedMeal"},
    basePrice = 45, -- Hunger -60 (Whole)
    stockRange = { min=1, max=3 }
})

-- === SHELF-STABLE PROTEINS & SNACKS ===
-- Excellent for looting bags and travel.

DynamicTrading.AddItem("BuyMRE", {
    item = "Base.MRE",
    category = "Food",
    tags = {"NonPerishable", "Survival", "Military", "HighCalorie"},
    basePrice = 85, -- Hunger -60 (No thirst penalty, light weight, extreme rare)
    stockRange = { min=0, max=2 }
})

DynamicTrading.AddItem("BuyBeefJerky", {
    item = "Base.BeefJerky",
    category = "Food",
    tags = {"NonPerishable", "Snack", "Meat", "Protein"},
    basePrice = 18, -- Hunger -10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyGranolaBar", {
    item = "Base.GranolaBar",
    category = "Food",
    tags = {"NonPerishable", "Snack", "Grains"},
    basePrice = 12, -- Hunger -10
    stockRange = { min=5, max=15 }
})

DynamicTrading.AddItem("BuyPeanuts", {
    item = "Base.Peanuts",
    category = "Food",
    tags = {"NonPerishable", "Snack", "Protein", "Fats"},
    basePrice = 15, -- Hunger -10
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuySunflowerSeeds", {
    item = "Base.SunflowerSeeds",
    category = "Food",
    tags = {"NonPerishable", "Snack", "Forage"},
    basePrice = 8, -- Hunger -5
    stockRange = { min=5, max=20 }
})

-- === BAKERY & DOUGH ===

DynamicTrading.AddItem("BuyCookie", {
    item = "Base.Cookie",
    category = "Food",
    tags = {"Fresh", "Bakery", "Sweet"},
    basePrice = 10, -- Hunger -5 + Happiness
    stockRange = { min=5, max=20 }
})

DynamicTrading.AddItem("BuyDoughnut", {
    item = "Base.Doughnut",
    category = "Food",
    tags = {"Fresh", "Bakery", "Sweet"},
    basePrice = 12, -- Hunger -15
    stockRange = { min=2, max=8 }
})

DynamicTrading.AddItem("BuyTortilla", {
    item = "Base.Tortilla",
    category = "Food",
    tags = {"Fresh", "Bakery", "Grains"},
    basePrice = 8, -- Hunger -10
    stockRange = { min=5, max=15 }
})

-- === MISC INGREDIENTS ===

DynamicTrading.AddItem("BuyTofu", {
    item = "Base.Tofu",
    category = "Food",
    tags = {"Fresh", "Protein", "Vegetarian"},
    basePrice = 15, -- Hunger -20
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuySeitan", {
    item = "Base.Seitan",
    category = "Food",
    tags = {"Fresh", "Protein", "Vegetarian"},
    basePrice = 15, -- Hunger -20
    stockRange = { min=2, max=6 }
})

DynamicTrading.AddItem("BuyMapleSyrup", {
    item = "Base.MapleSyrup",
    category = "Food",
    tags = {"NonPerishable", "Sweet", "Condiment"},
    basePrice = 25, -- Hunger -10, high calories
    stockRange = { min=1, max=4 }
})

-- === FORAGED PROTEINS ===
-- Useful for "Primitive" or "Survivalist" merchants.

DynamicTrading.AddItem("BuyFrog", {
    item = "Base.Frog",
    category = "Food",
    tags = {"Fresh", "Protein", "Forage"},
    basePrice = 6, -- Hunger -8
    stockRange = { min=2, max=10 }
})

DynamicTrading.AddItem("BuyCricket", {
    item = "Base.Cricket",
    category = "Food",
    tags = {"Fresh", "Protein", "Forage", "Insects"},
    basePrice = 2, -- Hunger -2
    stockRange = { min=5, max=30 }
})

DynamicTrading.AddItem("BuyGrasshopper", {
    item = "Base.Grasshopper",
    category = "Food",
    tags = {"Fresh", "Protein", "Forage", "Insects"},
    basePrice = 2, -- Hunger -2
    stockRange = { min=5, max=30 }
})