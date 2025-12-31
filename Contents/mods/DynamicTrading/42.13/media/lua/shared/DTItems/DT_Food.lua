require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterFood(commonTags, items)
    for _, config in ipairs(items) do
        -- Extract "CannedChili" from "Base.CannedChili"
        local itemName = config.item:match(".*%.(.*)") or config.item
        
        -- Use provided id, otherwise auto-generate "Buy" + "CannedChili"
        local uniqueID = config.id or ("Buy" .. itemName)

        -- Merge common and specific tags
        local finalTags = {}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Food",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 2, max = config.max or 8 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. CANNED GOODS (Non-Perishable)
RegisterFood({"Canned", "NonPerishable"}, {
    { item="Base.CannedChili",      price=40, min=3, max=8, tags={"Meat"} },
    { item="Base.CannedBolognese",  price=40, min=3, max=8, tags={"Meat"} },
    { item="Base.CannedCornedBeef", price=35, min=2, max=6, tags={"Meat"} },
    { item="Base.TinnedBeans",      price=30, min=5, max=15, tags={"Vegetable"}, id="BuyCannedBeans" },
    { item="Base.CannedMushroomSoup", price=25, min=4, max=10, tags={"Soup"} },
    { item="Base.TinnedSoup",       price=25, min=4, max=10, tags={"Soup"}, id="BuyCannedVegetableSoup" },
    { item="Base.CannedCorn",       price=20, min=5, max=12, tags={"Vegetable"} },
    { item="Base.CannedPotato2",    price=18, min=5, max=12, tags={"Vegetable"}, id="BuyCannedPotato" },
    { item="Base.CannedPeas",       price=15, min=5, max=15, tags={"Vegetable"} },
    { item="Base.CannedTomato2",    price=12, min=5, max=15, tags={"Vegetable"}, id="BuyCannedTomato" },
    { item="Base.CannedCarrots2",   price=12, min=5, max=15, tags={"Vegetable"}, id="BuyCannedCarrots" },
    { item="Base.TunaTin",          price=18, min=4, max=10, tags={"Fish"}, id="BuyCannedTuna" },
    { item="Base.CannedSardines",   price=10, min=5, max=20, tags={"Fish"} },
    { item="Base.CannedPeaches",    price=25, min=2, max=8,  tags={"Fruit"} },
    { item="Base.CannedPineapple",  price=25, min=2, max=8,  tags={"Fruit"} },
    { item="Base.CannedFruitCocktail", price=25, min=2, max=8, tags={"Fruit"} },
    { item="Base.CannedFruitBeverage", price=15, min=3, max=10, tags={"Drink"} },
    { item="Base.CannedMilk",       price=15, min=3, max=10, tags={"Dairy", "Drink"} },
    { item="Base.WaterRationCan",   price=20, min=1, max=5,  tags={"Drink", "Survival"}, id="BuyWaterRationCan" },
    { item="Base.CannedDogFood",    price=10, min=5, max=15, tags={"Meat", "JunkFood"} },
    { item="Base.MysteryCan",       price=8,  min=1, max=5,  tags={"Mystery"} },
    { item="Base.DentedCan",        price=4,  min=1, max=3,  tags={"Mystery", "Risky"} },
})

-- 2. JARRED & PRESERVED GOODS
RegisterFood({"Preserved", "Jarred"}, {
    { item="Base.Pickles",      price=12, min=2, max=6,  tags={"Pickled", "Vegetable"} },
    { item="Base.CabbageJar",   price=38, min=1, max=4,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredCabbage" },
    { item="Base.PotatoJar",    price=27, min=1, max=4,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredPotato" },
    { item="Base.CarrotsJar",   price=18, min=1, max=4,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredCarrots" },
    { item="Base.TomatoJar",    price=18, min=1, max=4,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredTomato" },
    { item="Base.BroccoliJar",  price=16, min=1, max=3,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredBroccoli" },
    { item="Base.EggplantJar",  price=16, min=1, max=3,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredEggplant" },
    { item="Base.LeeksJar",     price=15, min=1, max=3,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredLeeks" },
    { item="Base.RadishJar",    price=15, min=1, max=3,  tags={"Pickled", "Vegetable", "Crop"}, id="BuyJarredRadish" },
    { item="Base.Mayonnaise",   price=25, min=2, max=5,  tags={"Condiment", "Fats", "NonPerishable"}, id="BuyJarMayo" },
    { item="Base.PeanutButter", price=45, min=1, max=4,  tags={"Protein", "HighCalorie", "NonPerishable"}, id="BuyJarPeanutButter" },
    { item="Base.Honey",        price=30, min=1, max=3,  tags={"Sweet", "NonPerishable"}, id="BuyJarHoney" },
    { item="Base.JamFruit",     price=20, min=2, max=6,  tags={"Sweet", "NonPerishable"}, id="BuyJarJam" },
    { item="Base.Marmalade",    price=20, min=1, max=4,  tags={"Sweet", "NonPerishable"}, id="BuyJarMarmalade" },
})

-- 3. FRESH VEGETABLES
RegisterFood({"Fresh", "Vegetable"}, {
    { item="Base.Cabbage",    price=15, min=10, max=30, tags={"Crop"} },
    { item="Base.Corn",       price=14, min=5,  max=15 },
    { item="Base.Potato",     price=12, min=10, max=30, tags={"Crop"} },
    { item="Base.Lettuce",    price=10, min=5,  max=15 },
    { item="Base.Zucchini",   price=10, min=3,  max=10 },
    { item="Base.Tomato",     price=8,  min=10, max=25, tags={"Crop"} },
    { item="Base.BellPepper", price=8,  min=5,  max=15 },
    { item="Base.Carrots",    price=8,  min=10, max=25, tags={"Crop"} },
    { item="Base.Broccoli",   price=7,  min=5,  max=15, tags={"Crop"} },
    { item="Base.Eggplant",   price=7,  min=3,  max=10 },
    { item="Base.Leek",       price=7,  min=5,  max=15, tags={"Forage"} },
    { item="Base.Onion",      price=7,  min=5,  max=20 },
    { item="Base.RedRadish",  price=6,  min=10, max=25, tags={"Crop"} },
    { item="Base.Mushroom",   price=5,  min=5,  max=15, tags={"Forage"} },
    { item="Base.Peas",       price=3,  min=10, max=30 },
    { item="Base.WildEdiblePlant", price=2, min=10, max=40, tags={"Forage"} },
})

-- 4. FRESH FRUITS
RegisterFood({"Fresh", "Fruit"}, {
    { item="Base.Watermelon",   price=35, min=1,  max=3,  tags={"Heavy"} },
    { item="Base.Pineapple",    price=22, min=2,  max=5,  tags={"Exotic"} },
    { item="Base.Peach",        price=14, min=5,  max=15 },
    { item="Base.Apple",        price=10, min=10, max=25 },
    { item="Base.Banana",       price=10, min=5,  max=15 },
    { item="Base.Orange",       price=10, min=10, max=25, tags={"Citrus"} },
    { item="Base.Pear",         price=10, min=5,  max=15 },
    { item="Base.Mango",        price=10, min=2,  max=6,  tags={"Exotic"} },
    { item="Base.Grapes",       price=8,  min=5,  max=12 },
    { item="Base.Plum",         price=7,  min=5,  max=15 },
    { item="Base.Lemon",        price=5,  min=5,  max=15, tags={"Citrus"} },
    { item="Base.Lime",         price=5,  min=5,  max=15, tags={"Citrus"} },
    { item="Base.Strawberries", price=4,  min=10, max=30, tags={"Crop"} },
    { item="Base.Cherry",       price=3,  min=10, max=25 },
    { item="Base.BerryBlack",   price=3,  min=10, max=40, tags={"Berry", "Forage"} },
    { item="Base.BerryBlue",    price=3,  min=10, max=40, tags={"Berry", "Forage"} },
    { item="Base.BerryGeneric", price=2,  min=10, max=40, tags={"Berry", "Forage"} },
    { item="Base.Rosehips",     price=2,  min=5,  max=20, tags={"Forage"} },
})

-- 5. HERBS (Culinary & Medicinal)
RegisterFood({"Herb"}, {
    { item="Base.Basil",    price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Chives",   price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Cilantro", price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Oregano",  price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Parsley",  price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Rosemary", price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Sage",     price=4, tags={"Fresh", "Culinary"} },
    { item="Base.Thyme",    price=4, tags={"Fresh", "Culinary"} },
    { item="Base.LemonGrass",    price=15, min=1, max=4,  tags={"Medicinal", "Forage"} },
    { item="Base.Ginseng",       price=12, min=2, max=6,  tags={"Medicinal", "Forage"} },
    { item="Base.GarlicMustard", price=5,  min=3, max=10, tags={"Culinary", "Forage"} },
    { item="Base.CommonMallow",  price=8,  min=2, max=5,  tags={"Medicinal", "Forage"} },
    { item="Base.BlackSage",     price=10, min=2, max=5,  tags={"Medicinal", "Forage"} },
    { item="Base.Plantain",      price=12, min=2, max=5,  tags={"Medicinal", "Forage"} },
    { item="Base.WildGarlic",    price=12, min=2, max=5,  tags={"Medicinal", "Forage"} },
    { item="Base.Violets",       price=3,  min=5, max=15, tags={"Fruit", "Forage"} },
})

-- 6. PANTRY STAPLES, OILS & SAUCES
RegisterFood({"NonPerishable"}, {
    { item="Base.Salt",         price=25, min=2, max=6, tags={"Spice", "Pantry"} },
    { item="Base.Pepper",       price=25, min=2, max=6, tags={"Spice", "Pantry"} },
    { item="Base.Sugar",        price=40, min=1, max=4, tags={"Spice", "Sweet", "Baking"} },
    { item="Base.Yeast",        price=20, min=2, max=8, tags={"Spice", "Baking"} },
    { item="Base.Vinegar",      price=45, min=1, max=3, tags={"Spice", "Preservation"} },
    { item="Base.OliveOil",     price=35, min=1, max=4, tags={"Spice", "CookingOil", "Fats"} },
    { item="Base.VegetableOil", price=30, min=1, max=4, tags={"Spice", "CookingOil", "Fats"} },
    { item="Base.Lard",         price=25, min=2, max=5, tags={"Spice", "Fats", "Cooking"} },
    { item="Base.Margarine",    price=20, min=2, max=5, tags={"Spice", "Fats", "Cooking"} },
    { item="Base.Ketchup",      price=15, min=2, max=6, tags={"Condiment", "Sauce"} },
    { item="Base.Mustard",      price=15, min=2, max=6, tags={"Condiment", "Sauce"} },
    { item="Base.HotSauce",     price=18, min=1, max=4, tags={"Condiment", "Sauce"} },
    { item="Base.SoySauce",     price=20, min=1, max=4, tags={"Condiment", "Sauce"} },
    { item="Base.HoisinSauce",  price=20, min=1, max=4, tags={"Condiment", "Sauce"} },
    { item="Base.Marinara",     price=15, min=1, max=4, tags={"Condiment", "Sauce"} },
    { item="Base.BouillonCube", price=10, min=3, max=10, tags={"Spice", "Cooking"} },
})

-- 7. ANIMAL CARCASSES
RegisterFood({"Fresh", "Meat", "AnimalCarcass"}, {
    { item="Base.DeadRabbit",   price=40, min=2, max=6, tags={"Game", "Trapping"} },
    { item="Base.DeadSquirrel", price=20, min=2, max=6, tags={"Game", "Trapping"} },
    { item="Base.DeadBird",     price=20, min=2, max=8, tags={"Game", "Trapping"} },
    { item="Base.DeadRat",      price=10, min=1, max=5, tags={"Game", "Pest"} },
    { item="Base.DeadChicken",  price=35, min=2, max=5, tags={"Livestock", "Poultry"} },
    { item="Base.DeadDuck",     price=40, min=1, max=3, tags={"Game", "Poultry"} },
    { item="Base.DeadTurkey",   price=70, min=1, max=2, tags={"Game", "Poultry"} },
    { item="Base.DeadGoose",    price=55, min=1, max=2, tags={"Game", "Poultry"} },
    { item="Base.DeadDeer",     price=250, min=1, max=2, tags={"Game", "LargeGame"} },
    { item="Base.DeadBoar",     price=220, min=1, max=2, tags={"Game", "LargeGame"} },
    { item="Base.DeadBear",     price=450, min=0, max=1, tags={"Game", "LargeGame"} },
    { item="Base.DeadCow",      price=500, min=0, max=1, tags={"Livestock"} },
    { item="Base.DeadPig",      price=240, min=1, max=2, tags={"Livestock"} },
    { item="Base.DeadSheep",    price=180, min=1, max=2, tags={"Livestock"} },
    { item="Base.DeadGoat",     price=160, min=1, max=3, tags={"Livestock"} },
})

-- 8. RAW MEATS (Cuts)
RegisterFood({"Fresh", "Meat", "RawMeat"}, {
    { item="Base.Steak",        price=20, min=2, max=8, tags={"Beef"} },
    { item="Base.GroundBeef",   price=20, min=5, max=12, tags={"Beef"} },
    { item="Base.PorkChop",     price=16, min=2, max=8, tags={"Pork"} },
    { item="Base.MuttonChop",   price=16, min=2, max=6, tags={"Lamb"} },
    { item="Base.Ham",          price=30, min=1, max=4, tags={"Pork"} },
    { item="Base.Bacon",        price=18, min=4, max=10, tags={"Pork", "Breakfast"} },
    { item="Base.Chicken",      price=25, min=3, max=10, tags={"Poultry"}, id="BuyChickenMeat" },
    { item="Base.RabbitMeat",   price=15, min=2, max=8, tags={"GameMeat"} },
    { item="Base.BirdMeat",     price=10, min=2, max=10, tags={"GameMeat"} },
    { item="Base.SmallAnimalMeat", price=8, min=5, max=15, tags={"GameMeat"} },
    { item="Base.Salmon",       price=35, min=1, max=4, tags={"Fish"} },
    { item="Base.Bass",         price=25, min=2, max=6, tags={"Fish"} },
    { item="Base.Catfish",      price=30, min=2, max=6, tags={"Fish"} },
    { item="Base.Trout",        price=15, min=2, max=8, tags={"Fish"} },
    { item="Base.Shrimp",       price=6,  min=10, max=25, tags={"Seafood"} },
    { item="Base.Lobster",      price=35, min=1, max=3, tags={"Seafood"} },
    { item="Base.FrogMeat",     price=5,  min=5, max=15, tags={"GameMeat"} },
    { item="Base.SnakeMeat",    price=10, min=2, max=8, tags={"GameMeat"} },
})

-- 9. GRAINS & DRY GOODS
RegisterFood({"NonPerishable", "DryGood"}, {
    { item="Base.Rice",         price=25, min=5,  max=15, tags={"Grains", "Cookable"} },
    { item="Base.Pasta",        price=25, min=5,  max=15, tags={"Grains", "Cookable"} },
    { item="Base.Flour",        price=20, min=5,  max=15, tags={"Grains", "Baking"} },
    { item="Base.Cornmeal",     price=20, min=3,  max=10, tags={"Grains", "Baking"} },
    { item="Base.Cereal",       price=60, min=2,  max=6,  tags={"Grains", "Breakfast"} },
    { item="Base.Oats",         price=15, min=5,  max=15, tags={"Grains", "Breakfast"} },
    { item="Base.Ramen",        price=12, min=10, max=25, tags={"Grains", "Cookable"}, id="BuyDryRamen" },
    { item="Base.Quinoa",       price=18, min=2,  max=8,  tags={"Grains", "Cookable"} },
    { item="Base.Buckwheat",    price=18, min=2,  max=8,  tags={"Grains", "Cookable"} },
    { item="Base.Wheat",        price=10, min=10, max=30, tags={"Grains", "FarmProduce"} },
    { item="Base.Barley",       price=12, min=5,  max=20, tags={"Grains", "Brewing"} },
    { item="Base.TortillaChips", price=15, min=5, max=20, tags={"Grains", "Snack", "JunkFood"} },
    { item="Base.Crackers",     price=12, min=5,  max=20, tags={"Grains", "Snack"} },
    { item="Base.PopcornCorn",  price=8,  min=5,  max=15, tags={"Grains", "Snack", "Cookable"} },
})

-- 10. CANDY & SWEETS
RegisterFood({"NonPerishable", "Sweet", "Snack"}, {
    { item="Base.Chocolate",    price=25, min=2,  max=10, tags={"Candy"} },
    { item="Base.CandyBar",     price=15, min=5,  max=15, tags={"Candy"} },
    { item="Base.GummyBears",   price=30, min=2,  max=8,  tags={"Candy"} },
    { item="Base.GummyWorms",   price=30, min=2,  max=8,  tags={"Candy"} },
    { item="Base.HardCandy",    price=20, min=5,  max=12, tags={"Candy"} },
    { item="Base.Lollipop",     price=8,  min=10, max=25, tags={"Candy"} },
    { item="Base.Jawbreaker",   price=12, min=5,  max=15, tags={"Candy"} },
    { item="Base.Licorice",     price=18, min=3,  max=10, tags={"Candy"} },
    { item="Base.Marshmallows", price=20, min=2,  max=6,  tags={"Candy"} },
    { item="Base.Mints",        price=5,  min=10, max=30, tags={"Candy"}, id="BuyPeppermints" },
    { item="Base.ChocolateChips", price=15, min=3, max=8,  tags={"Candy", "Baking"} },
    { item="Base.CandyFruitDrops", price=22, min=2, max=8, tags={"Candy"} },
    { item="Base.RockCandy",    price=15, min=2,  max=6,  tags={"Candy"} },
    { item="Base.Toffee",       price=18, min=2,  max=8,  tags={"Candy"} },
})

-- 11. DAIRY, PREPARED, SURVIVAL & MISC
RegisterFood({}, {
    -- Perishable (Fresh)
    { item="Base.Cheese",       price=15, min=5,  max=15, tags={"Fresh", "Dairy", "Protein"} },
    { item="Base.Yogurt",       price=12, min=2,  max=8,  tags={"Fresh", "Dairy"} },
    { item="Base.Butter",       price=30, min=2,  max=6,  tags={"Fresh", "Dairy", "Fats", "HighCalorie"} },
    { item="Base.Egg",          price=5,  min=12, max=24, tags={"Fresh", "Protein", "LivestockProduct"} },
    { item="Base.WildEgg",      price=4,  min=2,  max=10, tags={"Fresh", "Protein", "Forage"} },
    { item="Base.TVDinner",     price=25, min=2,  max=6,  tags={"Fresh", "Frozen", "PreparedMeal"} },
    { item="Base.Pizza",        price=45, min=1,  max=3,  tags={"Fresh", "PreparedMeal"} },
    { item="Base.Cookie",       price=10, min=5,  max=20, tags={"Fresh", "Bakery", "Sweet"} },
    { item="Base.Doughnut",     price=12, min=2,  max=8,  tags={"Fresh", "Bakery", "Sweet"} },
    { item="Base.Tortilla",     price=8,  min=5,  max=15, tags={"Fresh", "Bakery", "Grains"} },
    { item="Base.Tofu",         price=15, min=2,  max=6,  tags={"Fresh", "Protein", "Vegetarian"} },
    { item="Base.Seitan",       price=15, min=2,  max=6,  tags={"Fresh", "Protein", "Vegetarian"} },
    { item="Base.Frog",         price=6,  min=2,  max=10, tags={"Fresh", "Protein", "Forage"} },
    { item="Base.Cricket",      price=2,  min=5,  max=30, tags={"Fresh", "Protein", "Forage", "Insects"} },
    { item="Base.Grasshopper",  price=2,  min=5,  max=30, tags={"Fresh", "Protein", "Forage", "Insects"} },
    -- Non-Perishable
    { item="Base.MRE",            price=85, min=0, max=2,  tags={"NonPerishable", "Survival", "Military", "HighCalorie"} },
    { item="Base.BeefJerky",      price=18, min=5, max=15, tags={"NonPerishable", "Snack", "Meat", "Protein"} },
    { item="Base.GranolaBar",     price=12, min=5, max=15, tags={"NonPerishable", "Snack", "Grains"} },
    { item="Base.Peanuts",        price=15, min=5, max=20, tags={"NonPerishable", "Snack", "Protein", "Fats"} },
    { item="Base.SunflowerSeeds", price=8,  min=5, max=20, tags={"NonPerishable", "Snack", "Forage"} },
    { item="Base.MapleSyrup",     price=25, min=1, max=4,  tags={"NonPerishable", "Sweet", "Condiment"} },
})