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
-- ==========================================================
-- DYNAMIC TRADING: PREPARED FOODS & DRINKS
-- Inner Workings & Balancing:
-- 1. CALORIC VALUE: Prices scaled by Hunger (-100 = High Price) and Boredom/Unhappiness reduction.
-- 2. MERCHANT TAGS: 
--    - "Bakery": Breads, Bagels, Muffins, Toast.
--    - "Barista": All Hot Drinks (Tea/Coffee/Mugs).
--    - "Mexican": Tacos and Burritos.
--    - "Diner": Burgers, Hotdogs, Pancakes, Omelettes, Waffles.
--    - "Canteen": Bulk Pots/Buckets of Soup and Stew.
--    - "Italian": Pizza and Pasta.
--    - "Healthy": Salads and Fruit Salads.
-- 3. UTILITY: Prepared pots (Soup/Stew) are expensive as they provide multiple servings.
-- ==========================================================

local function RegisterFood(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)
        
        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Food",
            tags = config.tags or {"PreparedFood"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- 1. BAKERY & BREAKFAST
RegisterFood({
    { item="Base.BagelPlain",         price=12,  tags={"Bakery", "Breakfast"} },
    { item="Base.BagelPoppy",         price=14,  tags={"Bakery", "Breakfast"} },
    { item="Base.BagelSesame",        price=14,  tags={"Bakery", "Breakfast"} },
    { item="Base.BreadDough",         price=25,  tags={"Bakery"} },
    { item="Base.Toast",              price=8,   tags={"Bakery", "Breakfast"} },
    { item="Base.MuffinTray",         price=45,  tags={"Bakery"}, id="BuyMuffinTray" }, -- Multiple servings
    { item="Base.Oatmeal",            price=15,  tags={"Breakfast"} },
    { item="Base.OmeletteRecipe",     price=22,  tags={"Diner", "Breakfast"} },
    { item="Base.OmeletteRecipeForged", price=22, tags={"Diner", "Breakfast"} },
    { item="Base.PancakesRecipe",     price=28,  tags={"Diner", "Breakfast"} },
    { item="Base.WafflesRecipe",      price=28,  tags={"Diner", "Breakfast"} },
})

-- 2. BARISTA (HOT DRINKS)
RegisterFood({
    { item="Base.HotDrinkTea",        price=20,  tags={"Barista"} },
    { item="Base.HotDrinkTeaCeramic", price=22,  tags={"Barista"} },
    { item="Base.HotDrink",           price=20,  tags={"Barista"} },
    { item="Base.HotDrinkClay",       price=20,  tags={"Barista"} },
    { item="Base.HotDrinkSpiffo",     price=25,  tags={"Barista", "Rare"} },
    { item="Base.HotDrinkWhite",      price=20,  tags={"Barista"} },
    { item="Base.HotDrinkCopper",     price=30,  tags={"Barista", "Metalwork"} },
    { item="Base.HotDrinkGold",       price=100, tags={"Barista", "Rare"} },
    { item="Base.HotDrinkMetal",      price=20,  tags={"Barista"} },
    { item="Base.HotDrinkSilver",     price=60,  tags={"Barista", "Rare"} },
    { item="Base.HotDrinkTumbler",    price=35,  tags={"Barista"} },
})

-- 3. MEXICAN STALL
RegisterFood({
    { item="Base.Burrito",            price=35,  tags={"Mexican"} },
    { item="Base.BurritoRecipe",      price=20,  tags={"Mexican"} },
    { item="Base.Taco",               price=35,  tags={"Mexican"} },
    { item="Base.TacoRecipe",         price=15,  tags={"Mexican"} },
})

-- 4. DINER & FAST FOOD
RegisterFood({
    { item="Base.Burger",             price=40,  tags={"Diner"} },
    { item="Base.BurgerRecipe",       price=30,  tags={"Diner"} },
    { item="Base.Hotdog",             price=25,  tags={"Diner"} },
    { item="Base.Sandwich",           price=20,  tags={"Diner"} },
    { item="Base.BaguetteSandwich",   price=28,  tags={"Diner", "Bakery"} },
    { item="Base.PizzaRecipe",        price=55,  tags={"Italian", "Diner"} },
    { item="Base.PizzaWhole",         price=95,  tags={"Italian", "Diner"} },
    { item="Base.ConeIcecreamToppings", price=18, tags={"Diner", "Dessert"} },
})

-- 5. CANTEEN (BULK SOUPS & STEWS)
RegisterFood({
    { item="Base.PotOfSoup",          price=70,  tags={"Canteen"} },
    { item="Base.PotOfSoupRecipe",    price=75,  tags={"Canteen"} },
    { item="Base.PotForgedSoupRecipe", price=75, tags={"Canteen"} },
    { item="Base.BucketOfSoup",       price=120, tags={"Canteen"} },
    { item="Base.PotOfStew",          price=85,  tags={"Canteen"} },
    { item="Base.PotForgedStew",      price=85,  tags={"Canteen"} },
    { item="Base.BucketOfStew",       price=140, tags={"Canteen"} },
})

-- 6. PASTA, RICE & STIR-FRY (ASIAN / ITALIAN)
RegisterFood({
    { item="Base.PastaPan",           price=50,  tags={"Italian"} },
    { item="Base.PastaPanCopper",     price=55,  tags={"Italian"} },
    { item="Base.PastaPot",           price=60,  tags={"Italian"} },
    { item="Base.PastaPotForged",     price=60,  tags={"Italian"} },
    { item="Base.RicePan",            price=45,  tags={"Asian"} },
    { item="Base.RicePanCopper",      price=50,  tags={"Asian"} },
    { item="Base.RicePot",            price=55,  tags={"Asian"} },
    { item="Base.RicePotForged",      price=55,  tags={"Asian"} },
    { item="Base.PanFriedVegetables", price=30,  tags={"Asian", "Healthy"} },
    { item="Base.PanFriedVegetables2", price=30, tags={"Asian", "Healthy"} },
    { item="Base.PanFriedVegetablesForged", price=30, tags={"Asian", "Healthy"} },
    { item="Base.GriddlePanFriedVegetables", price=35, tags={"Asian", "Healthy"} },
})

-- 7. HEALTHY & DESSERT
RegisterFood({
    { item="Base.Salad",              price=22,  tags={"Healthy"} },
    { item="Base.SaladClay",          price=22,  tags={"Healthy"} },
    { item="Base.FruitSalad",         price=25,  tags={"Healthy", "Fruit"} },
    { item="Base.FruitSaladClay",     price=25,  tags={"Healthy", "Fruit"} },
    { item="Base.CakeRaw",            price=60,  tags={"Bakery", "Dessert"} },
    { item="Base.PieWholeRaw",        price=55,  tags={"Bakery", "Dessert"} },
    { item="Base.PieWholeRawSweet",   price=60,  tags={"Bakery", "Dessert"} },
    { item="Base.Chum",               price=10,  tags={"Fishing", "Junk"} },
})


-- ==========================================================
-- DYNAMIC TRADING: PREPARED FOODS (BOWLS, BAKERY, SNACKS)
-- Inner Workings & Balancing:
-- 1. UTILITY: Slices (Pizza/Cake) and Individual Cookies are low-cost "quick" items.
-- 2. BOREDOM/HAPPINESS: Items with high negative values in these stats (Cookies, Pie, Maki) 
--    command a "Comfort Food" premium beyond just hunger reduction.
-- 3. MERCHANT TAGS: 
--    - "Bakery": Baguettes, Cookies, Muffins, Biscuits.
--    - "Asian": Maki, Onigiri, Rice Bowls.
--    - "Mexican": Guacamole, Tortilla Chips.
--    - "Diner": Pizza Slices, Pancakes, Cereal, Gravy.
--    - "Canteen": Soup, Stew, and Pasta bowls (Individual servings).
--    - "Seasonal": Halloween items.
-- ==========================================================

local function RegisterFood(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem(config.id or ("Buy" .. itemName), {
            item = config.item,
            category = "Food",
            tags = config.tags or {"PreparedFood"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- 1. BAKERY & CONFECTIONERY (Specializing for Bakery/Dessert Stall)
RegisterFood({
    { item="Base.BaguetteDough",         price=28,  min=2, max=6, tags={"Bakery", "Bread", "Raw"} },
    { item="Base.CookieChocolateChipDough", price=35, min=1, max=4, tags={"Bakery", "Sweet", "Dessert", "Raw"} },
    { item="Base.CookiesChocolateDough",    price=35, min=1, max=4, tags={"Bakery", "Sweet", "Dessert", "Raw"} },
    { item="Base.CookiesOatmealDough",      price=30, min=1, max=4, tags={"Bakery", "Sweet", "Dessert", "Raw"} },
    { item="Base.CookiesShortbreadDough",   price=35, min=1, max=4, tags={"Bakery", "Sweet", "Dessert", "Raw"} },
    { item="Base.CookiesSugarDough",        price=30, min=1, max=4, tags={"Bakery", "Sweet", "Dessert", "Raw"} },
    { item="Base.MuffinGeneric",            price=12, min=3, max=8, tags={"Bakery", "Sweet", "Snack"} },
    { item="Base.CakeSlice",                price=15, min=2, max=6, tags={"Bakery", "Sweet", "Dessert"} },
    { item="Base.Pie",                      price=25, min=2, max=5, tags={"Bakery", "Sweet", "Dessert", "Fruit"} },
    -- Individual Cookies
    { item="Base.CookieChocolateChip",      price=5,  min=5, max=15, tags={"Bakery", "Snack", "Sweet"} },
    { item="Base.CookiesChocolate",         price=5,  min=5, max=15, tags={"Bakery", "Snack", "Sweet"} },
    { item="Base.CookiesOatmeal",           price=4,  min=5, max=15, tags={"Bakery", "Snack", "Sweet"} },
    { item="Base.CookiesShortbread",        price=5,  min=5, max=15, tags={"Bakery", "Snack", "Sweet"} },
    { item="Base.CookiesSugar",             price=4,  min=5, max=15, tags={"Bakery", "Snack", "Sweet"} },
})

-- 2. ASIAN & MEXICAN SPECIALTIES (Stall variants)
RegisterFood({
    { item="Base.Maki",                price=35, min=2, max=6, tags={"Asian", "Sushi", "Healthy", "PreparedFood"} },
    { item="Base.Onigiri",             price=40, min=2, max=6, tags={"Asian", "Sushi", "Healthy", "PreparedFood"} },
    { item="Base.Guacamole",           price=18, min=2, max=5, tags={"Mexican", "Dip", "SideDish", "Vegan"} },
    { item="Base.TortillaChipsBaked",  price=12, min=3, max=10, tags={"Mexican", "Snack", "JunkFood"} },
})

-- 3. CANTEEN BOWLS (Portioned Servings)
RegisterFood({
    { item="Base.PastaBowl",           price=20, min=2, max=6, tags={"Canteen", "Italian", "PreparedFood"} },
    { item="Base.PastaBowlClay",       price=20, min=1, max=4, tags={"Canteen", "Italian", "PreparedFood"} },
    { item="Base.RiceBowl",            price=18, min=2, max=6, tags={"Canteen", "Asian", "PreparedFood"} },
    { item="Base.RiceBowlClay",        price=18, min=1, max=4, tags={"Canteen", "Asian", "PreparedFood"} },
    { item="Base.SoupBowl",            price=15, min=3, max=8, tags={"Canteen", "Warm", "PreparedFood"} },
    { item="Base.SoupBowlClay",        price=15, min=2, max=5, tags={"Canteen", "Warm", "PreparedFood"} },
    { item="Base.StewBowl",            price=18, min=3, max=8, tags={"Canteen", "Warm", "PreparedFood"} },
    { item="Base.StewBowlClay",        price=18, min=2, max=5, tags={"Canteen", "Warm", "PreparedFood"} },
})

-- 4. DINER & MISC PREPARED
RegisterFood({
    { item="Base.Pizza",               price=15, min=4, max=12, tags={"Diner", "Italian", "JunkFood"} },
    { item="Base.PancakesCraft",       price=22, min=2, max=5,  tags={"Diner", "Breakfast", "Sweet"} },
    { item="Base.CerealBowl",          price=15, min=2, max=6,  tags={"Diner", "Breakfast", "Dairy"} },
    { item="Base.Biscuit",             price=8,  min=4, max=10, tags={"Bakery", "Breakfast", "Bread"} },
    { item="Base.Muffintray_Biscuit",  price=35, min=1, max=3,  tags={"Bakery", "Breakfast", "Bulk"} },
    { item="Base.Gravy",               price=10, min=2, max=5,  tags={"Diner", "SideDish"} },
    { item="Base.CabbageRoll",         price=25, min=2, max=6,  tags={"Healthy", "PreparedFood", "Veggie"} },
    { item="Base.HalloweenPumpkin",    price=75, min=0, max=2,  tags={"Seasonal", "Rare", "Spooky", "Vegetable"}, id="BuyJackOLantern" },
})


-- 1. SEALED CANS (High Value / Long-term Storage)
RegisterCanned({
    -- Protein/Main Meals
    { item="Base.TinnedBeans",        price=25, tags={"Canned", "Protein", "Prepper", "Survivalist"} },
    { item="Base.CannedChili",        price=35, tags={"Canned", "Protein", "Prepper", "Diner"} },
    { item="Base.CannedCornedBeef",   price=45, tags={"Canned", "Protein", "Butcher", "Rare"} },
    { item="Base.CannedBolognese",    price=40, tags={"Canned", "Protein", "Italian", "Diner"} },
    { item="Base.TunaTin",            price=30, tags={"Canned", "Protein", "Fishing", "Survivalist"} },
    { item="Base.CannedSardines",     price=22, tags={"Canned", "Protein", "Fishing"} },
    
    -- Vegetables
    { item="Base.CannedCarrots2",     price=15, tags={"Canned", "Vegetable", "Farmer", "Healthy"} },
    { item="Base.CannedCorn",         price=20, tags={"Canned", "Vegetable", "Farmer"} },
    { item="Base.CannedPeas",         price=18, tags={"Canned", "Vegetable", "Farmer"} },
    { item="Base.CannedPotato2",      price=22, tags={"Canned", "Vegetable", "Farmer"} },
    { item="Base.CannedTomato2",      price=15, tags={"Canned", "Vegetable", "Farmer", "Italian"} },
    
    -- Soups & Liquids
    { item="Base.TinnedSoup",         price=28, tags={"Canned", "Vegetable", "Canteen"} },
    { item="Base.CannedMushroomSoup", price=25, tags={"Canned", "Vegetable", "Canteen"} },
    { item="Base.CannedMilk",         price=30, tags={"Canned", "Dairy", "Barista", "Bakery"} },
    
    -- Fruits & Sweets
    { item="Base.CannedFruitCocktail", price=32, tags={"Canned", "Fruit", "Healthy", "Dessert"} },
    { item="Base.CannedPeaches",       price=30, tags={"Canned", "Fruit", "Healthy", "Dessert"} },
    { item="Base.CannedPineapple",     price=30, tags={"Canned", "Fruit", "Healthy", "Dessert"} },
    { item="Base.CannedFruitBeverage", price=25, tags={"Canned", "Fruit", "Drink"} },
    
    -- Specialized
    { item="Base.Dogfood",            price=10, tags={"Canned", "Budget", "Pet", "Junk"} },
    { item="Base.MysteryCan",         price=15, tags={"Canned", "Mystery", "Scavenger", "Gambler"} },
    { item="Base.DentedCan",          price=12, tags={"Canned", "Mystery", "Scavenger", "Junk"} },
})

-- 2. OPEN CANS (Reduced Value / Immediate Consumption)
RegisterCanned({
    { item="Base.OpenBeans",               price=10, tags={"Budget", "Opened", "Scavenger"} },
    { item="Base.CannedCarrotsOpen",       price=6,  tags={"Budget", "Opened", "Scavenger"} },
    { item="Base.CannedChiliOpen",         price=15, tags={"Budget", "Opened", "Diner"} },
    { item="Base.CannedCornOpen",          price=8,  tags={"Budget", "Opened", "Farmer"} },
    { item="Base.CannedCornedBeefOpen",    price=18, tags={"Budget", "Opened", "Butcher"} },
    { item="Base.CannedMilkOpen",          price=12, tags={"Budget", "Opened", "Barista"} },
    { item="Base.CannedFruitBeverageOpen", price=10, tags={"Budget", "Opened", "Drink"} },
    { item="Base.CannedFruitCocktailOpen", price=12, tags={"Budget", "Opened", "Healthy"} },
    { item="Base.CannedMushroomSoupOpen",  price=10, tags={"Budget", "Opened", "Canteen"} },
    { item="Base.CannedPeachesOpen",       price=12, tags={"Budget", "Opened", "Fruit"} },
    { item="Base.CannedPeasOpen",          price=8,  tags={"Budget", "Opened", "Farmer"} },
    { item="Base.CannedPineappleOpen",     price=12, tags={"Budget", "Opened", "Fruit"} },
    { item="Base.CannedPotatoOpen",        price=10, tags={"Budget", "Opened", "Farmer"} },
    { item="Base.CannedSardinesOpen",      price=9,  tags={"Budget", "Opened", "Fishing"} },
    { item="Base.CannedBologneseOpen",     price=16, tags={"Budget", "Opened", "Italian"} },
    { item="Base.CannedTomatoOpen",        price=6,  tags={"Budget", "Opened", "Farmer"} },
    { item="Base.TunaTinOpen",             price=12, tags={"Budget", "Opened", "Fishing"} },
    { item="Base.TinnedSoupOpen",          price=12, tags={"Budget", "Opened", "Canteen"} },
    { item="Base.DogfoodOpen",             price=3,  tags={"Budget", "Opened", "Junk"} },
})

-- ==========================================================
-- DYNAMIC TRADING: MEATS & POULTRY
-- Inner Workings & Balancing:
-- 1. SPOILAGE FACTOR: Beef Jerky is the highest price per calorie due to 
--    infinite shelf life (Survivalist premium).
-- 2. CALORIC VALUE: Prices are scaled by Hunger reduction. Whole Turkeys/Chickens 
--    and large Beef/Pork cuts represent massive nutritional value for groups.
-- 3. MERCHANT TAGS:
--    - "Butcher": Raw heavy cuts and whole carcasses.
--    - "Deli": Processed meats like Salami, Pepperoni, and Baloney.
--    - "Diner": Quick-cook items like Patties, Nuggets, and Hotdogs.
--    - "Breakfast": Bacon, Sausages, and Ham slices.
--    - "Hunter": Wild game like Venison.
-- 4. QUANTITY: Packaged items (HotdogPack) are priced for convenience and bulk.
-- ==========================================================

-- 1. HEAVY CUTS & WHOLE POULTRY (Butcher Focus)
RegisterFood({
    { item="Base.Beef",           price=120, tags={"Butcher", "Raw", "Heavy", "Protein"} },
    { item="Base.Pork",           price=100, tags={"Butcher", "Raw", "Heavy", "Protein"} },
    { item="Base.Venison",        price=115, tags={"Butcher", "Hunter", "Raw", "Rare"} },
    { item="Base.ChickenWhole",   price=140, tags={"Butcher", "Poultry", "Raw"} },
    { item="Base.TurkeyWhole",    price=180, tags={"Butcher", "Poultry", "Raw", "Rare"} },
    { item="Base.Steak",          price=65,  tags={"Butcher", "Diner", "Raw"} },
    { item="Base.MincedMeat",     price=50,  tags={"Butcher", "Diner", "Raw"} },
})

-- 2. PROCESSED & SLICED MEATS (Deli Focus)
RegisterFood({
    { item="Base.Baloney",        price=75,  tags={"Deli", "Butcher", "Budget"} },
    { item="Base.BaloneySlice",   price=8,   tags={"Deli", "Budget", "Snack"} },
    { item="Base.Ham",            price=90,  tags={"Deli", "Butcher", "Canteen"} },
    { item="Base.HamSlice",       price=15,  tags={"Deli", "Breakfast", "Snack"} },
    { item="Base.Salami",         price=40,  tags={"Deli", "Italian", "Pizza"} },
    { item="Base.SalamiSlice",    price=5,   tags={"Deli", "Italian", "Snack"} },
    { item="Base.Pepperoni",      price=45,  tags={"Deli", "Italian", "Pizza"} },
    { item="Base.MeatDumpling",   price=20,  tags={"Deli", "Asian", "Snack"} },
})

-- 3. DINER & BREAKFAST SPECIALS
RegisterFood({
    { item="Base.Bacon",          price=45,  tags={"Breakfast", "Diner", "Butcher"} },
    { item="Base.BaconRashers",   price=15,  tags={"Breakfast", "Diner"} },
    { item="Base.BaconBits",      price=10,  tags={"Diner", "Salad", "Topping"} },
    { item="Base.Sausage",        price=35,  tags={"Breakfast", "Diner", "Butcher"} },
    { item="Base.MeatPatty",      price=40,  tags={"Diner", "Butcher", "Burger"} },
    { item="Base.HotdogPack",     price=60,  tags={"Diner", "Budget", "Bulk"} },
    { item="Base.Hotdog_single",  price=12,  tags={"Diner", "Budget"} },
    { item="Base.ChickenNuggets", price=25,  tags={"Diner", "Snack", "Budget"} },
})

-- 4. POULTRY SEGMENTS
RegisterFood({
    { item="Base.Chicken",        price=35,  tags={"Butcher", "Poultry", "Diner"} }, -- Chicken Leg
    { item="Base.ChickenFillet",  price=40,  tags={"Butcher", "Poultry", "Healthy"} },
    { item="Base.ChickenWings",   price=30,  tags={"Diner", "Poultry", "Snack"} },
    { item="Base.TurkeyLegs",     price=50,  tags={"Butcher", "Poultry"} },
    { item="Base.TurkeyFillet",   price=65,  tags={"Butcher", "Poultry", "Healthy"} },
    { item="Base.TurkeyWings",    price=45,  tags={"Diner", "Poultry"} },
    { item="Base.PorkChop",       price=45,  tags={"Butcher", "Raw"} },
    { item="Base.MuttonChop",     price=45,  tags={"Butcher", "Raw"} },
})

-- 5. SURVIVAL & NON-PERISHABLE
RegisterFood({
    { item="Base.BeefJerky",      price=150, tags={"Hunter", "Prepper", "Survivalist", "NonPerishable"}, min=0, max=3 },
})


-- ==========================================================
-- DYNAMIC TRADING: TRAPPED ANIMALS & SMALL GAME
-- Inner Workings & Balancing:
-- 1. UTILITY: Whole carcasses (DeadRabbit, DeadSquirrel) are priced higher than 
--    simple meat because they can be butchered for additional materials (pelt/bones).
-- 2. UNHAPPINESS PENALTY: Vermin (Rats, Mice) are priced low. While they provide 
--    calories, the high Unhappiness/Boredom cost makes them "emergency" food.
-- 3. MERCHANT TAGS:
--    - "Trapper": Whole wild game carcasses (Rabbit, Squirrel, Bird).
--    - "Scavenger": Vermin and rodents (Rats, Mice, Rat King).
--    - "Exotic": Unusual meats (Frog, Rat King).
--    - "Butcher": Processed small meats (RabbitMeat, SmallAnimalMeat).
--    - "PestControl": Specifically for the mouse/rat variations.
-- 4. RARITY: The Rat King is priced as a high-value "trophy" or emergency ration 
--    due to its massive caloric density, despite the sanity penalty.
-- ==========================================================

-- 1. TRAPPER'S HAUL (Whole Carcasses)
RegisterFood({
    { item="Base.DeadRabbit",         price=45, tags={"Trapper", "Hunter", "WildMeat", "SmallGame"} },
    { item="Base.DeadSquirrel",       price=32, tags={"Trapper", "Hunter", "WildMeat", "SmallGame"} },
    { item="Base.DeadBird",           price=18, tags={"Trapper", "Hunter", "WildMeat", "SmallGame"} },
    { item="Base.DeadRat",            price=12, tags={"Scavenger", "Vermin", "PestControl"} },
    { item="Base.DeadMouse",          price=8,  tags={"Scavenger", "Vermin", "PestControl"} },
})

-- 2. PROCESSED WILD MEAT
RegisterFood({
    { item="Base.Rabbitmeat",         price=35, tags={"Butcher", "WildMeat", "Protein", "Hunter"} },
    { item="Base.Smallanimalmeat",    price=20, tags={"Butcher", "WildMeat", "Protein"} }, -- Rodent Meat
    { item="Base.Smallbirdmeat",      price=20, tags={"Butcher", "WildMeat", "Protein", "Poultry"} },
    { item="Base.FrogMeat",           price=15, tags={"Exotic", "WildMeat", "Healthy", "Trapper"} },
})

-- 3. VERMIN & RODENT VARIANTS (Scavenger/PestControl)
RegisterFood({
    { item="Base.DeadRatBaby",        price=6,  tags={"Scavenger", "Vermin", "Budget"} },
    { item="Base.DeadMousePups",      price=4,  tags={"Scavenger", "Vermin", "Budget"} },
    { item="Base.DeadRatSkinned",     price=10, tags={"Scavenger", "Vermin", "PestControl"} },
    { item="Base.DeadRatBabySkinned", price=5,  tags={"Scavenger", "Vermin", "PestControl"} },
    { item="Base.DeadMouseSkinned",   price=7,  tags={"Scavenger", "Vermin", "PestControl"} },
    { item="Base.DeadMousePupsSkinned", price=3, tags={"Scavenger", "Vermin", "PestControl"} },
})

-- 4. THE EXOTIC STALL (Rare/Special)
RegisterFood({
    { item="Base.RatKing",            price=95, tags={"Exotic", "Rare", "Scavenger", "Horror"}, min=0, max=1 },
})


-- ==========================================================
-- DYNAMIC TRADING: FISH & SEAFOOD
-- Inner Workings & Balancing:
-- 1. UTILITY: Whole fish are priced by their versatility (can be filleted or cooked whole).
-- 2. GOURMET PREMIUM: Items like Caviar, Lobster, and Salmon carry high prices due to 
--    high unhappiness reduction and rarity.
-- 3. PREPARATION: Fried and prepared versions (Sushi, Calamari) are valued for immediate consumption.
-- 4. MERCHANT TAGS:
--    - "Fisherman": Fresh whole fish, bait, and raw byproducts (Guts/Roe).
--    - "SushiBar": Sushi, Caviar, Roe, and specific seafood like Shrimp/Squid.
--    - "SeafoodStall": Fried seafood, Lobster, Mussels, and Oysters.
--    - "Gourmet": High-end items like Lobster, Salmon, and Caviar.
--    - "Diner": Mass-market items like Fish Fingers and Fried Fish.
-- ==========================================================

-- 1. WHOLE FRESHWATER FISH (Fisherman Focus)
RegisterFood({
    { item="Base.AligatorGar",        price=45, tags={"Fisherman", "Raw", "Rare"} },
    { item="Base.BlueCatfish",        price=30, tags={"Fisherman", "Raw"} },
    { item="Base.ChannelCatfish",     price=30, tags={"Fisherman", "Raw"} },
    { item="Base.FlatheadCatfish",    price=30, tags={"Fisherman", "Raw"} },
    { item="Base.LargemouthBass",     price=28, tags={"Fisherman", "Raw"} },
    { item="Base.SmallmouthBass",     price=28, tags={"Fisherman", "Raw"} },
    { item="Base.SpottedBass",        price=28, tags={"Fisherman", "Raw"} },
    { item="Base.StripedBass",        price=32, tags={"Fisherman", "Raw"} },
    { item="Base.Muskellunge",        price=35, tags={"Fisherman", "Raw"} },
    { item="Base.Paddlefish",         price=35, tags={"Fisherman", "Raw"} },
    { item="Base.Walleye",            price=25, tags={"Fisherman", "Raw"} },
    { item="Base.FreshwaterDrum",     price=22, tags={"Fisherman", "Raw"} },
    -- Common Panfish
    { item="Base.Bluegill",           price=15, tags={"Fisherman", "Raw", "Budget"} },
    { item="Base.GreenSunfish",       price=15, tags={"Fisherman", "Raw", "Budget"} },
    { item="Base.RedearSunfish",      price=15, tags={"Fisherman", "Raw", "Budget"} },
    { item="Base.BlackCrappie",       price=18, tags={"Fisherman", "Raw"} },
    { item="Base.WhiteCrappie",       price=18, tags={"Fisherman", "Raw"} },
    { item="Base.WhiteBass",          price=18, tags={"Fisherman", "Raw"} },
    { item="Base.YellowPerch",        price=18, tags={"Fisherman", "Raw"} },
    { item="Base.Sauger",             price=20, tags={"Fisherman", "Raw"} },
})

-- 2. GOURMET SEAFOOD & DELICACIES
RegisterFood({
    { item="Base.Lobster",            price=65,  tags={"Gourmet", "SeafoodStall", "Raw", "Rare"} },
    { item="Base.Salmon",             price=50,  tags={"Gourmet", "Fisherman", "Raw"} },
    { item="Base.Caviar",             price=120, tags={"Gourmet", "SushiBar", "NonPerishable", "Rare"} },
    { item="Base.FishRoe",            price=35,  tags={"SushiBar", "Gourmet"} },
    { item="Base.Squid",              price=30,  tags={"SeafoodStall", "SushiBar", "Raw"} },
    { item="Base.SushiFish",          price=45,  tags={"SushiBar", "PreparedFood"} },
    { item="Base.ShrimpDumpling",     price=25,  tags={"SushiBar", "Asian", "Snack"} },
})

-- 3. SHELLFISH & SMALL CATCHES
RegisterFood({
    { item="Base.Shrp",               price=20,  tags={"SeafoodStall", "SushiBar", "Raw"}, id="BuyShrimp" }, -- Base.Shrimp
    { item="Base.Crayfish",           price=12,  tags={"Fisherman", "SeafoodStall", "Raw"} },
    { item="Base.Mussels",            price=15,  tags={"SeafoodStall", "Shellfish", "Raw"} },
    { item="Base.Oysters",            price=18,  tags={"SeafoodStall", "Shellfish", "Raw"} },
    { item="Base.BaitFish",           price=5,   tags={"Fisherman", "Bait", "Budget"} },
})

-- 4. PREPARED & FRIED SEAFOOD (Stall/Diner)
RegisterFood({
    { item="Base.FishFried",          price=40,  tags={"SeafoodStall", "Diner", "PreparedFood"} },
    { item="Base.ShrimpFried",        price=30,  tags={"SeafoodStall", "Diner", "Snack"} },
    { item="Base.ShrimpFriedCraft",   price=28,  tags={"SeafoodStall", "Diner", "Snack"} },
    { item="Base.OystersFried",       price=35,  tags={"SeafoodStall", "Gourmet"} },
    { item="Base.SquidCalamari",      price=32,  tags={"SeafoodStall", "Snack"} },
    { item="Base.FishFingers",        price=15,  tags={"Diner", "Budget", "Childhood"} },
    { item="Base.Frozen_FishFingers", price=80,  tags={"Diner", "Bulk", "Frozen"}, min=1, max=3 },
    { item="Base.FishFillet",         price=25,  tags={"Fisherman", "Butcher", "Raw"} },
})

-- 5. FISH BYPRODUCTS (Scavenger/Bait)
RegisterFood({
    { item="Base.FishGuts",           price=2,   tags={"Fisherman", "Scavenger", "Bait", "Junk"} },
    { item="Base.FishRoeSac",         price=8,   tags={"Fisherman", "Bait"} },
})


-- ==========================================================
-- DYNAMIC TRADING: EGGS & EGG PRODUCTS
-- Inner Workings & Balancing:
-- 1. UTILITY: Raw eggs are priced as essential cooking ingredients. 
--    Prepared versions (Scrambled, Omelette) are priced higher for labor and 
--    the high hunger reduction (-20).
-- 2. BULK SAVINGS: The Egg Carton is priced at a volume discount (~12% cheaper 
--    than buying 12 individual eggs).
-- 3. MERCHANT TAGS:
--    - "Farmer": Primary source for raw eggs and cartons.
--    - "Breakfast": Tag for diner-style morning foods.
--    - "Bakery": Eggs are a core requirement for baking recipes.
--    - "Diner": Ready-to-eat egg meals.
--    - "Foraged": For wild variants found by survivalists.
-- ==========================================================

RegisterFood({
    -- Raw Ingredients
    { item="Base.Egg",           price=8,  tags={"Farmer", "Bakery", "Breakfast", "Fresh"} },
    { item="Base.TurkeyEgg",     price=10, tags={"Farmer", "Rare", "Fresh"} },
    { item="Base.WildEggs",      price=8,  tags={"Foraged", "Survivalist", "Fresh"} },
    
    -- Bulk Packaging
    { item="Base.EggCarton",     price=85, tags={"Farmer", "Bulk", "Bakery"}, min=1, max=3 },
    
    -- Prepared Breakfast (Diner Focus)
    { item="Base.EggBoiled",     price=12, tags={"Diner", "Breakfast", "PreparedFood"} },
    { item="Base.EggPoached",    price=12, tags={"Diner", "Breakfast", "PreparedFood"} },
    { item="Base.EggScrambled",  price=22, tags={"Diner", "Breakfast", "PreparedFood"} },
    { item="Base.EggOmelette",   price=22, tags={"Diner", "Breakfast", "PreparedFood"} },
})


-- ==========================================================
-- DYNAMIC TRADING: INSECTS & CREEPY CRAWLIES
-- Inner Workings & Balancing:
-- 1. UTILITY: Primarily valued as Fishing Bait rather than food.
-- 2. BAIT PREMIUM: Worms, Crickets, and Grasshoppers are priced slightly higher (3) 
--    as they are the most effective/common bait types in vanilla.
-- 3. EDIBILITY: High Unhappiness/Boredom penalties (20+) and low hunger reduction (-1) 
--    keep these at a very low price floor.
-- 4. MERCHANT TAGS:
--    - "Fishing" / "Bait": Core usage for fisherman archetypes.
--    - "Scavenger": For "junk" items found in trash or under logs.
--    - "Survivalist" / "Foraged": Natural resources found in the wild.
--    - "Exotic": For "street food" or unusual snack stalls.
-- ==========================================================

-- 1. FISHING BAIT (Premium Insects)
RegisterFood({
    { item="Base.Worm",            price=3, tags={"Fishing", "Bait", "Foraged", "Survivalist"} },
    { item="Base.Cricket",         price=3, tags={"Fishing", "Bait", "Foraged", "Exotic"} },
    { item="Base.Grasshopper",     price=3, tags={"Fishing", "Bait", "Foraged", "Exotic"} },
})

-- 2. CATERPILLARS (Standard Foraged Items)
RegisterFood({
    { item="Base.AmericanLadyCaterpillar",  price=2, tags={"Foraged", "Bait", "Entomology"} },
    { item="Base.BandedWoolyBearCaterpillar", price=2, tags={"Foraged", "Bait", "Entomology"} },
    { item="Base.MonarchCaterpillar",       price=2, tags={"Foraged", "Bait", "Entomology"} },
    { item="Base.SawflyLarva",              price=2, tags={"Foraged", "Bait", "Entomology"} },
    { item="Base.SilkMothCaterpillar",      price=2, tags={"Foraged", "Bait", "Entomology"} },
    { item="Base.SwallowtailCaterpillar",   price=2, tags={"Foraged", "Bait", "Entomology"} },
})

-- 3. GASTROPODS & CRAWLERS (The "Meaty" Bugs)
RegisterFood({
    { item="Base.Snail",           price=4, tags={"Exotic", "Foraged", "FrenchFood"} },
    { item="Base.Slug",            price=4, tags={"Exotic", "Foraged", "Bait"} },
    { item="Base.Slug2",           price=4, tags={"Exotic", "Foraged", "Bait"} },
    { item="Base.Centipede",       price=2, tags={"Scavenger", "Bait", "Survivalist"} },
    { item="Base.Centipede2",      price=2, tags={"Scavenger", "Bait", "Survivalist"} },
    { item="Base.Millipede",       price=2, tags={"Scavenger", "Bait", "Survivalist"} },
    { item="Base.Millipede2",      price=2, tags={"Scavenger", "Bait", "Survivalist"} },
    { item="Base.Leech",           price=3, tags={"Fishing", "Bait", "Medical"} },
})

-- 4. PESTS & TINY INSECTS (Bottom Tier)
RegisterFood({
    { item="Base.Cockroach",       price=1, tags={"Scavenger", "Junk", "PestControl"} },
    { item="Base.Maggots",         price=1, tags={"Scavenger", "Bait", "Medical"} },
    { item="Base.Termites",        price=1, tags={"Scavenger", "Bait", "PestControl"} },
    { item="Base.Pillbug",         price=1, tags={"Scavenger", "Foraged", "Bait"} },
    { item="Base.Ladybug",         price=1, tags={"Foraged", "Exotic", "Gardening"} },
})

-- ==========================================================
-- DYNAMIC TRADING: FRUITS & BERRIES
-- Inner Workings & Balancing:
-- 1. SHELF LIFE: Non-perishable items (Dried Apricots, Rose Hips) command a 
--    premium due to their value as emergency winter rations.
-- 2. THIRST QUENCHING: High-moisture fruits (Watermelon, Pineapple, Grapefruit) 
--    are priced higher for their dual Hunger/Thirst utility.
-- 3. MERCHANT TAGS:
--    - "Farmer": Primary source for fresh orchard fruits.
--    - "Foraged": For berries and wild-found hips/cherries.
--    - "Healthy": Assigned to all vitamins/fiber-rich produce.
--    - "Barista": Citrus fruits (Lemon, Lime) used for flavoring drinks.
--    - "Dessert": Sweet fruits used in baking (Apple, Peach, Cherry).
-- 4. BULK VS SLICED: Whole Watermelons are heavy but cost-efficient compared 
--    to buying individual slices or chunks.
-- ==========================================================

-- 1. FRESH ORCHARD FRUITS (Farmer/Dessert Focus)
RegisterFood({
    { item="Base.Apple",           price=15, tags={"Farmer", "Fresh", "Healthy", "Dessert"} },
    { item="Base.Banana",          price=12, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Peach",           price=14, tags={"Farmer", "Fresh", "Healthy", "Dessert"} },
    { item="Base.Pear",            price=14, tags={"Farmer", "Fresh", "Healthy", "Dessert"} },
    { item="Base.Orange",          price=10, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Grapes",          price=18, tags={"Farmer", "Fresh", "Healthy", "Snack"} },
    { item="Base.Cherry",          price=6,  tags={"Foraged", "Fresh", "Snack", "Dessert"} },
    { item="Base.Strewberrie",     price=12, tags={"Farmer", "Fresh", "Healthy", "Snack"} },
})

-- 2. TROPICAL & HIGH-THIRST FRUITS
RegisterFood({
    { item="Base.Pineapple",       price=35, tags={"Farmer", "Fresh", "Healthy", "Thirst"} },
    { item="Base.Mango",           price=28, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Grapefruit",      price=22, tags={"Farmer", "Fresh", "Healthy", "Thirst"} },
    { item="Base.Watermelon",      price=65, tags={"Farmer", "Fresh", "Heavy", "Thirst"}, min=1, max=3 },
    { item="Base.WatermelonSliced", price=12, tags={"Healthy", "Snack", "Thirst"} },
    { item="Base.WatermelonSmashed", price=18, tags={"Healthy", "Canteen", "Thirst"} },
})

-- 3. CITRUS (Barista & Health Focus)
RegisterFood({
    { item="Base.Lemon",           price=8,  tags={"Barista", "Farmer", "Fresh", "Healthy"} },
    { item="Base.Lime",            price=8,  tags={"Barista", "Farmer", "Fresh", "Healthy"} },
})

-- 4. NON-PERISHABLE & MEDICINAL (Survivalist Focus)
RegisterFood({
    { item="Base.DriedApricots",   price=45, tags={"NonPerishable", "Survivalist", "Prepper", "Healthy"}, min=1, max=4 },
    { item="Base.Rosehips",        price=12, tags={"NonPerishable", "Foraged", "Survivalist", "Medical"} },
})

-- 5. FORAGED BERRIES (Gatherer Focus)
RegisterFood({
    { item="Base.BerryBlack",      price=5,  tags={"Foraged", "Survivalist", "Fresh"} },
    { item="Base.BerryBlue",       price=5,  tags={"Foraged", "Survivalist", "Fresh"} },
    { item="Base.BeautyBerry",     price=4,  tags={"Foraged", "Survivalist", "Fresh"} },
    { item="Base.HollyBerry",      price=2,  tags={"Foraged", "Survivalist", "Poisonous"} },
    { item="Base.WinterBerry",     price=2,  tags={"Foraged", "Survivalist", "Poisonous"} },
    { item="Base.BerryGeneric1",   price=3,  tags={"Foraged", "Fresh"} },
    { item="Base.BerryGeneric2",   price=3,  tags={"Foraged", "Fresh"} },
    { item="Base.BerryGeneric3",   price=3,  tags={"Foraged", "Fresh"} },
    { item="Base.BerryGeneric4",   price=3,  tags={"Foraged", "Fresh"} },
    { item="Base.BerryGeneric5",   price=3,  tags={"Foraged", "Fresh"} },
    { item="Base.BerryPoisonIvy",  price=1,  tags={"Foraged", "Poisonous", "Junk"} },
})

-- ==========================================================
-- DYNAMIC TRADING: VEGETABLES, LEGUMES & PREPARED SIDES
-- Inner Workings & Balancing:
-- 1. DRIED GOODS PREMIUM: Large bags of dried beans/lentils (2.0 weight, -60 Hunger) 
--    are priced high (75+) as they are the ultimate non-perishable survival food.
-- 2. SHELF LIFE: Root vegetables (Potatoes, Turnips, Carrots) are priced higher 
--    than leafy greens (Lettuce, Cabbage) due to their superior storage time.
-- 3. MERCHANT TAGS:
--    - "Mexican": Avocado, Black Beans, Jalapenos, Habaneros, Refried Beans.
--    - "Asian": Daikon, Edamame, Soybeans, Tofu.
--    - "Diner": Fries, Onion Rings, Tato Dots (Happiness/Boredom focus).
--    - "Farmer": Standard fresh crops and seeds.
--    - "Canteen": Bulk squash, pumpkin, and bean bowls.
--    - "Vegetarian/Healthy": Kale, Spinach, Broccoli, Tofu.
-- 4. SEEDS: Tiny weight but high value for sustainable farming.
-- ==========================================================

-- 1. BULK DRIED LEGUMES (Non-Perishable Gold)
RegisterFood({
    { item="Base.DriedBlackBeans",    price=75, tags={"Mexican", "Prepper", "NonPerishable", "Bulk"} },
    { item="Base.DriedKidneyBeans",   price=75, tags={"Mexican", "Prepper", "NonPerishable", "Bulk"} },
    { item="Base.DriedLentils",       price=70, tags={"Canteen", "Prepper", "NonPerishable", "Bulk"} },
    { item="Base.DriedChickpeas",     price=70, tags={"MiddleEastern", "Prepper", "NonPerishable", "Bulk"} },
    { item="Base.DriedSplitPeas",     price=65, tags={"Canteen", "Prepper", "NonPerishable", "Bulk"} },
    { item="Base.DriedWhiteBeans",    price=65, tags={"Canteen", "Prepper", "NonPerishable", "Bulk"} },
})

-- 2. FRESH COMMON PRODUCE (Farmer & Greengrocer)
RegisterFood({
    { item="Base.Cabbage",            price=12, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Carrots",            price=15, tags={"Farmer", "Fresh", "Healthy", "Root"} },
    { item="Base.Corn",               price=18, tags={"Farmer", "Fresh", "Diner"} },
    { item="Base.Tomato",             price=14, tags={"Farmer", "Fresh", "Italian", "Mexican"} },
    { item="Base.Lettuce",            price=10, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.BellPepper",         price=15, tags={"Farmer", "Fresh", "Healthy", "Mexican"} },
    { item="Base.Cucumber",           price=12, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Onion",              price=15, tags={"Farmer", "Fresh", "Cooking"} },
    { item="Base.Broccoli",           price=14, tags={"Farmer", "Fresh", "Healthy"} },
    { item="Base.Cauliflower",        price=14, tags={"Farmer", "Fresh", "Healthy"} },
})

-- 3. LONG-LIFE ROOTS & SQUASHES (Survival Favorites)
RegisterFood({
    { item="Base.Potato",             price=22, tags={"Farmer", "Fresh", "Root", "Storage"} },
    { item="Base.SweetPotato",        price=25, tags={"Farmer", "Fresh", "Root", "Storage"} },
    { item="Base.Turnip",             price=20, tags={"Farmer", "Fresh", "Root", "Storage"} },
    { item="Base.Pumpkin",            price=45, tags={"Farmer", "Fresh", "Heavy", "Canteen"} },
    { item="Base.Squash",             price=35, tags={"Farmer", "Fresh", "Canteen"} },
    { item="Base.Eggplant",           price=18, tags={"Farmer", "Fresh", "Vegetarian"} },
    { item="Base.Zucchini",           price=16, tags={"Farmer", "Fresh", "Vegetarian"} },
})

-- 4. SPECIALIZED STALL ITEMS (Mexican / Asian / Healthy)
RegisterFood({
    { item="Base.Avocado",            price=22, tags={"Mexican", "Fresh", "Gourmet", "Healthy"} },
    { item="Base.RefriedBeans",       price=20, tags={"Mexican", "PreparedFood"} },
    { item="Base.Blackbeans",         price=18, tags={"Mexican", "Protein"} },
    { item="Base.PepperJalapeno",     price=10, tags={"Mexican", "Spicy"} },
    { item="Base.PepperHabanero",     price=12, tags={"Mexican", "Spicy"} },
    { item="Base.Tofu",               price=25, tags={"Asian", "Vegetarian", "Protein"} },
    { item="Base.TofuFried",          price=30, tags={"Asian", "Vegetarian", "Diner"} },
    { item="Base.Edamame",            price=15, tags={"Asian", "Healthy", "Snack"} },
    { item="Base.Daikon",             price=18, tags={"Asian", "Root"} },
    { item="Base.Soybeans",           price=12, tags={"Asian", "Healthy"} },
    { item="Base.Kale",               price=18, tags={"Vegetarian", "Healthy", "Superfood"} },
    { item="Base.Spinach",            price=14, tags={"Vegetarian", "Healthy"} },
})

-- 5. DINER SIDES & FROZEN GOODS
RegisterFood({
    { item="Base.FrenchFries",        price=18, tags={"Diner", "JunkFood", "Snack"} },
    { item="Base.TatoDots",           price=18, tags={"Diner", "JunkFood", "Snack"} },
    { item="Base.FriedOnionRings",    price=15, tags={"Diner", "JunkFood", "Snack"} },
    { item="Base.CornFrozen",         price=25, tags={"Diner", "Frozen", "Vegetable"} },
    { item="Base.Peas",               price=22, tags={"Diner", "Frozen", "Vegetable"} },
    { item="Base.MixedVegetables",    price=28, tags={"Diner", "Frozen", "Healthy"} },
})

-- 6. FORAGED & SMALL ITEMS (Bait/Seeds/Condiments)
RegisterFood({
    { item="Base.MushroomGeneric1",   price=8,  tags={"Foraged", "Survivalist"} }, -- Generic Mushroom
    { item="Base.MushroomsButton",    price=12, tags={"Greengrocer", "Fresh", "Cooking"} },
    { item="Base.Dandelions",         price=4,  tags={"Foraged", "Healthy"} },
    { item="Base.GrapeLeaves",        price=6,  tags={"Foraged", "Cooking"} },
    { item="Base.Peanuts",            price=15, tags={"Snack", "Protein", "NonPerishable"} },
    { item="Base.Olives",             price=12, tags={"Italian", "Snack", "NonPerishable"} },
    { item="Base.Capers",             price=10, tags={"Gourmet", "Italian", "NonPerishable"} },
    { item="Base.CornSeed",           price=8,  tags={"Farmer", "Seeds"} },
    { item="Base.SoybeansSeed",       price=6,  tags={"Farmer", "Seeds"} },
    { item="Base.GreenpeasSeed",      price=6,  tags={"Farmer", "Seeds"} },
})

-- ==========================================================
-- DYNAMIC TRADING: PRESERVED JARS (CANNING)
-- Inner Workings & Balancing:
-- 1. PRESERVATION PREMIUM: Sealed jars represent high-tier food security. 
--    They are priced higher than standard tin cans due to superior hunger reduction 
--    and the "home-preserved" quality.
-- 2. OPEN VS SEALED: Open jars lose ~65-75% of their value. They are heavy (0.8) 
--    and spoil rapidly, making them poor for long-term trade but good for immediate meals.
-- 3. GOURMET ROE: Canned Fish Roe is a top-tier luxury item. It has a massive 
--    unhappiness reduction and extreme shelf life, commanding a premium price.
-- 4. MERCHANT TAGS:
--    - "Farmer": Primary merchant for preserved produce jars.
--    - "Prepper": Survival-focused tag for long-term food storage.
--    - "Gourmet": Specialized tag for high-end delicacies like Roe.
--    - "Healthy": Applied to vegetable jars (Broccoli, Peppers).
--    - "Italian": Specific to tomatoes and peppers for specialty stalls.
-- ==========================================================

-- 1. SEALED PRESERVED JARS (High Value / Survival Tier)
RegisterFood({
    { item="Base.CannedBellPepper",  price=55, tags={"Farmer", "Prepper", "Healthy", "Mexican", "Italian"} },
    { item="Base.CannedBroccoli",     price=50, tags={"Farmer", "Prepper", "Healthy", "Vegetarian"} },
    { item="Base.CannedCabbage",      price=55, tags={"Farmer", "Prepper", "Healthy", "Canteen"} },
    { item="Base.CannedCarrots",      price=45, tags={"Farmer", "Prepper", "Healthy", "Root"} },
    { item="Base.CannedEggplant",     price=55, tags={"Farmer", "Prepper", "Vegetarian", "Italian"} },
    { item="Base.CannedLeek",         price=55, tags={"Farmer", "Prepper", "Healthy", "Cooking"} },
    { item="Base.CannedPotato",       price=55, tags={"Farmer", "Prepper", "Root", "Storage"} },
    { item="Base.CannedRedRadish",    price=50, tags={"Farmer", "Prepper", "Root"} },
    { item="Base.CannedTomato",       price=55, tags={"Farmer", "Prepper", "Italian", "Mexican"} },
    { item="Base.CannedRoe",          price=130, tags={"Gourmet", "SushiBar", "Fisherman", "Luxury"}, min=0, max=2 },
})

-- 2. OPENED JARS (Budget / Immediate Consumption)
RegisterFood({
    { item="Base.CannedBellPepper_Open", price=18, tags={"Scavenger", "Budget", "Mexican"} },
    { item="Base.CannedBroccoli_Open",    price=15, tags={"Scavenger", "Budget", "Healthy"} },
    { item="Base.CannedCabbage_Open",     price=18, tags={"Scavenger", "Budget", "Canteen"} },
    { item="Base.CannedCarrots_Open",     price=14, tags={"Scavenger", "Budget", "Healthy"} },
    { item="Base.CannedEggplant_Open",    price=18, tags={"Scavenger", "Budget", "Vegetarian"} },
    { item="Base.CannedLeek_Open",        price=18, tags={"Scavenger", "Budget", "Cooking"} },
    { item="Base.CannedPotato_Open",      price=18, tags={"Scavenger", "Budget", "Root"} },
    { item="Base.CannedRedRadish_Open",   price=15, tags={"Scavenger", "Budget", "Root"} },
    { item="Base.CannedTomato_Open",      price=18, tags={"Scavenger", "Budget", "Italian"} },
    { item="Base.CannedRoe_Open",         price=45, tags={"Gourmet", "SushiBar", "Scavenger"} },
})

-- ==========================================================
-- DYNAMIC TRADING: HERBS, SEASONINGS & MEDICINAL PLANTS
-- Inner Workings & Balancing:
-- 1. SEASONING JARS: Items with -20 Hunger (Seasoning_Basil, etc.) represent 
--    concentrated, high-quality culinary jars. They are priced as premium items 
--    due to their potency and infinite shelf life.
-- 2. MEDICINAL UTILITY: Lemongrass, Chamomile, and Black Sage are valued for 
--    their ability to treat sickness and stress, making them vital for Pharmacist types.
-- 3. PERISHABILITY: Fresh herbs are cheap but spoil quickly. Dried variants 
--    command a "storage premium."
-- 4. MERCHANT TAGS:
--    - "Barista": Mint, Lavender, Chamomile, Cinnamon (Tea/Coffee flavoring).
--    - "Herbalist": Lemongrass, Black Sage, Common Mallow, Garlic (Medicinal).
--    - "Italian": Basil, Oregano, Rosemary, Parsley, Garlic.
--    - "Mexican": Cilantro, Garlic.
--    - "Farmer": All fresh herbs and seeds.
-- ==========================================================

-- 1. PREMIUM CULINARY SEASONING JARS (High Potency)
RegisterFood({
    { item="Base.Seasoning_Basil",    price=30, tags={"Italian", "Gourmet", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Chives",   price=25, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Cilantro", price=30, tags={"Mexican", "Gourmet", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Oregano",  price=30, tags={"Italian", "Gourmet", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Parsley",  price=25, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Rosemary", price=30, tags={"Italian", "Gourmet", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Sage",     price=25, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.Seasoning_Thyme",    price=25, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.Cinnamon",           price=20, tags={"Barista", "Bakery", "Sweet", "NonPerishable"} },
})

-- 2. DRIED HERBS & MEDICINAL LEAVES (Storage Stable)
RegisterFood({
    { item="Base.BasilDried",         price=12, tags={"Italian", "Cooking", "NonPerishable"} },
    { item="Base.CilantroDried",      price=12, tags={"Mexican", "Cooking", "NonPerishable"} },
    { item="Base.OreganoDried",       price=12, tags={"Italian", "Cooking", "NonPerishable"} },
    { item="Base.RosemaryDried",      price=12, tags={"Italian", "Cooking", "NonPerishable"} },
    { item="Base.SageDried",          price=10, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.ThymeDried",         price=10, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.ParsleyDried",       price=10, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.ChivesDried",        price=10, tags={"Diner", "Cooking", "NonPerishable"} },
    { item="Base.BlackSageDried",     price=15, tags={"Herbalist", "Medical", "NonPerishable"} },
    { item="Base.ChamomileDried",     price=18, tags={"Barista", "Herbalist", "Medical", "NonPerishable"} },
    { item="Base.LavenderPetalsDried", price=15, tags={"Barista", "Herbalist", "Medical", "NonPerishable"} },
    { item="Base.MintHerbDried",      price=12, tags={"Barista", "Herbalist", "NonPerishable"} },
    { item="Base.WildGarlicDried",    price=12, tags={"Herbalist", "Cooking", "NonPerishable"} },
    { item="Base.CommonMallowDried",  price=8,  tags={"Herbalist", "Survivalist", "NonPerishable"} },
    { item="Base.MarigoldDried",      price=8,  tags={"Herbalist", "NonPerishable"} },
    { item="Base.RosePetalsDried",    price=15, tags={"Barista", "Gourmet", "NonPerishable"} },
})

-- 3. FRESH HERBS & WILD PLANTS (Perishable/Foraged)
RegisterFood({
    { item="Base.Garlic",             price=15, tags={"Italian", "Mexican", "Herbalist", "Fresh"} },
    { item="Base.GreenOnions",        price=10, tags={"Farmer", "Asian", "Fresh"} },
    { item="Base.Basil",              price=5,  tags={"Italian", "Farmer", "Fresh"} },
    { item="Base.Cilantro",           price=5,  tags={"Mexican", "Farmer", "Fresh"} },
    { item="Base.Oregano",            price=5,  tags={"Italian", "Farmer", "Fresh"} },
    { item="Base.Parsley",            price=4,  tags={"Diner", "Farmer", "Fresh"} },
    { item="Base.Rosemary",           price=6,  tags={"Italian", "Farmer", "Fresh"} },
    { item="Base.Sage",               price=4,  tags={"Diner", "Farmer", "Fresh"} },
    { item="Base.Thyme",              price=4,  tags={"Diner", "Farmer", "Fresh"} },
    { item="Base.Chives",             price=4,  tags={"Diner", "Farmer", "Fresh"} },
    { item="Base.MintHerb",           price=6,  tags={"Barista", "Herbalist", "Fresh"} },
    { item="Base.LemonGrass",         price=20, tags={"Herbalist", "Medical", "Survivalist"} },
    { item="Base.BlackSage",          price=8,  tags={"Herbalist", "Medical", "Foraged"} },
    { item="Base.Chamomile",          price=10, tags={"Barista", "Herbalist", "Medical", "Foraged"} },
    { item="Base.Lavender",           price=8,  tags={"Barista", "Herbalist", "Medical", "Foraged"} },
    { item="Base.CommonMallow",       price=4,  tags={"Herbalist", "Foraged"} },
    { item="Base.Marigold",           price=4,  tags={"Herbalist", "Foraged"} },
    { item="Base.WildGarlic2",        price=6,  tags={"Herbalist", "Foraged"} },
    { item="Base.Nettles",            price=5,  tags={"Survivalist", "Foraged", "Cooking"} },
    { item="Base.Thistle",            price=5,  tags={"Survivalist", "Foraged", "Cooking"} },
    { item="Base.Roses",              price=12, tags={"Barista", "Gourmet", "Fresh"} },
    { item="Base.FourLeafClover",     price=50, tags={"Scavenger", "Rare", "Lucky"} },
})

-- 4. SEEDS & REPRODUCTION
RegisterFood({
    { item="Base.CilantroSeed",       price=10, tags={"Farmer", "Seeds"} },
})

-- ==========================================================
-- DYNAMIC TRADING: HARVESTED CROPS & INDUSTRIAL PLANTS
-- Inner Workings & Balancing:
-- 1. SHELF LIFE: Dried sheaves (Wheat, Rye, Barley) command a premium over 
--    fresh ones as they are non-perishable "wealth" that can be stored for winters.
-- 2. INDUSTRIAL UTILITY: Hemp and Flax are priced as high-value raw materials 
--    for cloth and rope production (Fiber merchant logic).
-- 3. STIMULANTS & MEDICINAL: Tobacco, Hops, and Poppies are luxury crops. 
--    Poppies specifically are valued for their medical potential (Painkillers).
-- 4. MERCHANT TAGS:
--    - "Farmer": Primary merchant for all sheaves and sunflower heads.
--    - "Brewing": Hops and Barley (Alcohol production).
--    - "Bakery": Wheat and Rye (Flour production).
--    - "Fiber": Hemp and Flax (Textiles/Ropes).
--    - "Smoking": Tobacco.
--    - "Herbalist": Poppies, Comfrey, and Plantain (Medicinal).
--    - "AnimalFeed": Hay and Grass (Livestock maintenance).
-- ==========================================================

-- 1. GRAIN SHEAVES (Bakery & Brewing)
RegisterFood({
    { item="Base.WheatSheaf",        price=12, tags={"Farmer", "Bakery", "Fresh"} },
    { item="Base.WheatSheafDried",   price=20, tags={"Farmer", "Bakery", "Prepper", "NonPerishable"} },
    { item="Base.RyeSheaf",          price=12, tags={"Farmer", "Bakery", "Fresh"} },
    { item="Base.RyeSheafDried",     price=20, tags={"Farmer", "Bakery", "Prepper", "NonPerishable"} },
    { item="Base.BarleySheaf",       price=15, tags={"Farmer", "Brewing", "Fresh"} },
    { item="Base.BarleySheafDried",  price=22, tags={"Farmer", "Brewing", "NonPerishable"} },
})

-- 2. INDUSTRIAL FIBER CROPS
RegisterFood({
    { item="Base.HempBundle",        price=18, tags={"Farmer", "Fiber", "Industrial", "Fresh"} },
    { item="Base.HempBundleDried",   price=30, tags={"Farmer", "Fiber", "Industrial", "NonPerishable"} },
    { item="Base.Flax",              price=15, tags={"Farmer", "Fiber", "Fresh"} },
    { item="Base.FlaxRippled",       price=25, tags={"Farmer", "Fiber", "NonPerishable"} },
})

-- 3. LUXURY & MEDICINAL CROPS
RegisterFood({
    { item="Base.Tobacco",           price=40, tags={"Smoking", "Luxury", "Farmer", "Rare"} },
    { item="Base.Hops",              price=15, tags={"Brewing", "Farmer", "Fresh"} },
    { item="Base.HopsDried",         price=25, tags={"Brewing", "Farmer", "NonPerishable"} },
    { item="Base.Poppies",           price=15, tags={"Herbalist", "Medical", "Fresh"} },
    { item="Base.PoppyPods",         price=20, tags={"Herbalist", "Medical", "Fresh"} },
    { item="Base.PoppyPodsDried",    price=35, tags={"Herbalist", "Medical", "NonPerishable", "Rare"} },
    { item="Base.ComfreyDried",      price=12, tags={"Herbalist", "Medical", "NonPerishable"} },
    { item="Base.PlantainDried",     price=12, tags={"Herbalist", "Medical", "NonPerishable"} },
})

-- 4. SEEDS, HEADS & FORAGE
RegisterFood({
    { item="Base.SunflowerHead",     price=10, tags={"Farmer", "Snack", "Fresh"} },
    { item="Base.SunflowerHeadDried", price=18, tags={"Farmer", "Snack", "NonPerishable"} },
    { item="Base.Acorn",             price=8,  tags={"Foraged", "Survivalist", "Storage", "Healthy"} },
    { item="Base.GrassTuft",         price=2,  tags={"AnimalFeed", "Junk"} },
    { item="Base.HayTuft",           price=5,  tags={"AnimalFeed", "Storage", "Farmer"} },
})

-- ==========================================================
-- DYNAMIC TRADING: PANTRY STAPLES, CONDIMENTS & INGREDIENTS
-- Inner Workings & Balancing:
-- 1. BULK STAPLES: Flour, Cornflour, and Sugar are priced as high-value long-term 
--    essentials for Bakery and Canteen production.
-- 2. SPECIALTY CONDIMENTS: Soy Sauce, Sesame Oil, and Wasabi are tagged for Asian 
--    stalls, while Salsa and Nacho Cheese are tagged for Mexican stalls.
-- 3. FATS & OILS: Olive Oil and Lard are high-calorie, non-perishable cooking 
--    foundations, commanding a premium for Preppers and Italian merchants.
-- 4. SWEETENERS: Maple Syrup and Honey have extreme happiness/hunger efficiency, 
--    priced as luxury items for Baristas and Bakers.
-- 5. MERCHANT TAGS:
--    - "Bakery": Flour, Sugars, Honey, Butter, Yeast/Seeds.
--    - "Barista": Honey, Maple Syrup, Sugar packets/cubes, Cinnamon.
--    - "Mexican": Hot Sauce, Salsa, Nacho Cheese, Cornmeal.
--    - "Asian": Soy Sauce, Wasabi, Ginger, Rice Vinegar, Seaweed.
--    - "Diner": Ketchup, Mustard, Mayo, BBQ, Ranch.
--    - "Prepper": Oils, Salt, Flour, Bouillon (Long shelf life).
-- ==========================================================

-- 1. BULK BAKING & COOKING STAPLES
RegisterFood({
    { item="Base.Flour2",             price=50, tags={"Bakery", "Prepper", "Canteen", "NonPerishable"} },
    { item="Base.Cornflour2",         price=50, tags={"Bakery", "Prepper", "NonPerishable"} },
    { item="Base.Cornmeal2",          price=40, tags={"Mexican", "Bakery", "Prepper"} },
    { item="Base.Sugar",              price=35, tags={"Bakery", "Barista", "Prepper"} }, -- White Sugar
    { item="Base.SugarBrown",         price=38, tags={"Bakery", "Barista", "Gourmet"} },
    { item="Base.Honey",              price=45, tags={"Barista", "Bakery", "Healthy", "NonPerishable"} },
    { item="Base.MapleSyrup",         price=55, tags={"Barista", "Bakery", "Luxury", "NonPerishable"} },
})

-- 2. ASIAN CUISINE & SUSHI BAR
RegisterFood({
    { item="Base.Soysauce",           price=25, tags={"Asian", "SushiBar", "Cooking"} },
    { item="Base.SesameOil",          price=30, tags={"Asian", "SushiBar", "Gourmet"} },
    { item="Base.RiceVinegar",        price=22, tags={"Asian", "SushiBar", "Italian"} },
    { item="Base.Wasabi",             price=28, tags={"Asian", "SushiBar", "Spicy"} },
    { item="Base.GingerRoot",         price=15, tags={"Asian", "Herbalist", "Healthy"} },
    { item="Base.GingerPickled",      price=20, tags={"Asian", "SushiBar", "NonPerishable"} },
    { item="Base.Seaweed",            price=18, tags={"Asian", "SushiBar", "Healthy"} },
})

-- 3. DINER & MEXICAN CONDIMENTS
RegisterFood({
    { item="Base.Ketchup",            price=15, tags={"Diner", "FastFood", "Kids"} },
    { item="Base.Mustard",            price=15, tags={"Diner", "FastFood"} },
    { item="Base.BBQSauce",           price=18, tags={"Diner", "Butcher", "Cooking"} },
    { item="Base.MayonnaiseFull",     price=20, tags={"Diner", "Deli", "Sandwich"} },
    { item="Base.Hotsauce",           price=22, tags={"Mexican", "Diner", "Spicy"} },
    { item="Base.Dip_Salsa",          price=20, tags={"Mexican", "Snack"} },
    { item="Base.Dip_NachoCheese",    price=22, tags={"Mexican", "Snack", "Diner"} },
    { item="Base.Dip_Ranch",          price=18, tags={"Diner", "Snack", "Salad"} },
    { item="Base.SourCream",          price=15, tags={"Mexican", "Diner", "Dairy"} },
    { item="Base.RemouladeFull",      price=22, tags={"SeafoodStall", "Deli"} },
})

-- 4. OILS, FATS & DAIRY
RegisterFood({
    { item="Base.OilOlive",           price=45, tags={"Italian", "Gourmet", "Prepper", "Healthy"} },
    { item="Base.OilVegetable",       price=35, tags={"Diner", "Cooking", "Prepper"} },
    { item="Base.Lard",               price=30, tags={"Butcher", "Cooking", "Prepper"} },
    { item="Base.Butter",             price=25, tags={"Bakery", "Diner", "Breakfast"} },
    { item="Base.Margarine",          price=20, tags={"Bakery", "Diner", "Budget"} },
    { item="Base.BalsamicVinegar",    price=30, tags={"Italian", "Gourmet", "Healthy"} },
})

-- 5. SPICES, SEASONINGS & PACKETS
RegisterFood({
    { item="Base.Salt",               price=10, tags={"Prepper", "General", "Cooking"} },
    { item="Base.Pepper",             price=12, tags={"Prepper", "General", "Cooking"} },
    { item="Base.SeasoningSalt",      price=15, tags={"Diner", "Butcher", "Cooking"} },
    { item="Base.PowderedGarlic",     price=18, tags={"Italian", "Mexican", "Prepper"} },
    { item="Base.PowderedOnion",      price=18, tags={"Diner", "Prepper", "Cooking"} },
    { item="Base.BouillonCube",       price=12, tags={"Prepper", "Canteen", "Survivalist"} },
    { item="Base.SugarCubes",         price=15, tags={"Barista"} },
    { item="Base.SugarPacket",        price=2,  tags={"Barista", "FastFood", "Budget"} },
})

-- 6. SEEDS & SMALL PANTRY ITEMS
RegisterFood({
    { item="Base.PumpkinSeed",        price=12, tags={"Healthy", "Snack", "Farmer"} },
    { item="Base.SunflowerSeeds",     price=10, tags={"Healthy", "Snack", "Farmer"} },
    { item="Base.FlaxSeed",           price=10, tags={"Healthy", "Farmer", "Fiber"} },
    { item="Base.PoppySeed",          price=8,  tags={"Bakery", "Farmer", "Herbalist"} },
    { item="Base.Pickles",            price=15, tags={"Deli", "Diner", "Snack"} },
    { item="Base.TomatoPaste",        price=18, tags={"Italian", "Cooking", "Canned"} },
    { item="Base.Marinara",           price=25, tags={"Italian", "Cooking"} },
    { item="Base.Ginseng",            price=25, tags={"Herbalist", "Medical", "Healthy"} },
    { item="Base.Violets",            price=8,  tags={"Herbalist", "Foraged", "Healthy"} },
})

-- ==========================================================
-- DYNAMIC TRADING: GRAINS, PASTA & DRY STAPLES
-- Inner Workings & Balancing:
-- 1. NON-PERISHABLE STAPLES: Rice, Pasta, and Macaroni are the highest tier survival foods. 
--    At 2.0 weight and -60 Hunger, they are priced as premium "Base Foundation" items 
--    for long-term survival and base building.
-- 2. DRY RAMEN: Valued for its weight-to-calorie ratio. Extremely lightweight (0.2), 
--    making it a staple for Scavengers and Scavenger-type merchants.
-- 3. BAKERY & DINER BUNS: Priced for immediate utility in Sandwich and Burger recipes. 
--    Packs offer a bulk discount compared to individual unit prices.
-- 4. MERCHANT TAGS:
--    - "Prepper": Essential long-term dry storage (Rice, Pasta, Macaroni).
--    - "Asian": Rice and Ramen for specialized stalls.
--    - "Italian": Pasta and Macaroni for specialized stalls.
--    - "Bakery": Bread and Buns.
--    - "Diner": Hamburger/Hotdog buns and Macaroni (for Mac & Cheese).
--    - "Budget": Ramen and individual buns.
-- ==========================================================

RegisterFood({
    -- Dry Bulk Staples (High Tier Survival)
    { item="Base.Rice",             price=75, tags={"Prepper", "Asian", "Canteen", "NonPerishable", "Bulk"} },
    { item="Base.Pasta",            price=70, tags={"Prepper", "Italian", "Canteen", "NonPerishable", "Bulk"} },
    { item="Base.Macaroni",         price=70, tags={"Prepper", "Italian", "Diner", "NonPerishable", "Bulk"} },
    { item="Base.Ramen",            price=15, tags={"Prepper", "Asian", "Budget", "NonPerishable", "Scavenger"} },

    -- Fresh Bread & Buns (Bakery/Diner)
    { item="Base.Bread",            price=20, tags={"Bakery", "Diner", "Sandwich", "Fresh"} },
    { item="Base.BunsHamburger",    price=30, tags={"Diner", "Bakery", "Bulk", "Fresh"} },
    { item="Base.BunsHotdog",       price=25, tags={"Diner", "Bakery", "Bulk", "Fresh"} },
    { item="Base.BunsHotdog_single",price=6,  tags={"Diner", "Bakery", "Fresh", "Budget"} },
})

-- ==========================================================
-- DYNAMIC TRADING: CONFECTIONERY & SWEETS
-- Inner Workings & Balancing:
-- 1. SANITY PREMIUM: Candies are valued primarily for their -10 Unhappiness reduction. 
--    In Project Zomboid, managing depression is vital, making these high-value items.
-- 2. CALORIC EFFICIENCY: Chocolate bars (Butterchunkers, Smirkers, etc.) provide 
--    the most calories and hunger reduction (-20), commanding the highest price in the category.
-- 3. WEIGHT TO VALUE: Small candies (Gummy Bears, Jellybeans) are extremely lightweight (0.1), 
--    making them perfect trade goods for Scavengers.
-- 4. SPOILAGE: Only the Candied Apple is perishable; all others are non-perishable "apocalypse gold."
-- 5. MERCHANT TAGS:
--    - "CandyShop": All sugar-based items.
--    - "GasStation": Standard chocolate bars and bagged candies.
--    - "Cinema": Small snacks like Gum, Hard Candies, and Lollipops.
--    - "Seasonal": Holiday/Event items (Candy Cane, Candy Corn, Halloween Candy).
--    - "Diner": Hand-crafted treats like Candied Apples.
-- ==========================================================

-- 1. PREMIUM CHOCOLATE BARS (-20 Hunger, -10 Unhappiness)
RegisterFood({
    { item="Base.Chocolate",                price=30, tags={"GasStation", "CandyShop", "Snack"} }, -- Milk Chocolate
    { item="Base.Chocolate_Butterchunkers", price=32, tags={"GasStation", "CandyShop", "Snack"} },
    { item="Base.Chocolate_Crackle",        price=32, tags={"GasStation", "CandyShop", "Snack"} },
    { item="Base.Chocolate_Deux",           price=32, tags={"GasStation", "CandyShop", "Snack"} },
    { item="Base.Chocolate_GalacticDairy",  price=32, tags={"GasStation", "CandyShop", "Snack"} },
    { item="Base.Chocolate_RoysPBPucks",    price=35, tags={"GasStation", "CandyShop", "Snack", "Gourmet"} },
    { item="Base.Chocolate_Smirkers",       price=32, tags={"GasStation", "CandyShop", "Snack"} },
    { item="Base.Chocolate_SnikSnak",       price=32, tags={"GasStation", "CandyShop", "Snack"} },
})

-- 2. BAGGED & SPECIALTY CANDIES (-5 to -10 Hunger, -10 Unhappiness)
RegisterFood({
    { item="Base.CandyPackage",             price=85, tags={"CandyShop", "Bulk", "GasStation"}, min=1, max=3 },
    { item="Base.CandiedApple",             price=22, tags={"Diner", "CandyShop", "Fresh"} },
    { item="Base.Allsorts",                 price=18, tags={"CandyShop", "Cinema"} },
    { item="Base.CandyFruitSlices",         price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.CandyCaramels",            price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.Chocolate_Candy",          price=18, tags={"CandyShop", "GasStation"} },
    { item="Base.GummyBears",               price=15, tags={"CandyShop", "Cinema", "GasStation"} },
    { item="Base.CandyGummyfish",           price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.GummyWorms",               price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.HardCandies",              price=12, tags={"CandyShop", "Cinema"} },
    { item="Base.JellyBeans",               price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.Jujubes",                  price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.CandyNovapops",            price=15, tags={"CandyShop", "Cinema"} },
    { item="Base.RockCandy",                price=18, tags={"CandyShop", "Gourmet"} },
    { item="Base.Lollipop",                 price=8,  tags={"CandyShop", "Cinema", "Budget"} },
})

-- 3. SEASONAL & HOLIDAY SWEETS
RegisterFood({
    { item="Base.Candycane",                price=15, tags={"Seasonal", "CandyShop", "Christmas"} },
    { item="Base.CandyCorn",                price=12, tags={"Seasonal", "CandyShop", "Halloween"} },
    { item="Base.CandyMolasses",            price=12, tags={"Seasonal", "CandyShop", "Halloween"} }, -- Halloween Candy
})

-- 4. MINOR SNACKS & BREATH FRESHENERS
RegisterFood({
    { item="Base.Gum",                      price=5,  tags={"Cinema", "GasStation", "Budget"} },
    { item="Base.MintCandy",                price=6,  tags={"Cinema", "GasStation", "Budget"} },
    { item="Base.LicoriceBlack",            price=10, tags={"CandyShop", "Cinema"} },
    { item="Base.LicoriceRed",              price=10, tags={"CandyShop", "Cinema"} },
})


-- ==========================================================
-- DYNAMIC TRADING: MISCELLANEOUS FOODS, BAKERY & SPECIALTY
-- Inner Workings & Balancing:
-- 1. UTILITY PREMIUM: Items that reduce Fatigue (Coffee, Tea, Chocolate Coffee Beans) 
--    and Stress/Unhappiness (Pies, Cakes, Smokes) are priced higher due to their 
--    high value in managing survivor mood and stamina.
-- 2. BULK FROZEN: Bags of Fries, Nuggets, and Tato Dots are mid-range bulk items 
--    that offer high caloric value but require power/freezers to maintain.
-- 3. PET ECONOMY: Pet food bags (2.0 weight) are high-calorie emergency rations 
--    or essential for pet mods, priced for high-volume storage.
-- 4. RENEWABILITY: Seeds are priced as investments. While they offer no immediate 
--    calories, they provide long-term sustainable farming.
-- 5. MERCHANT TAGS:
--    - "Bakery": Pies, Cakes, Donuts, Pastries, Dough.
--    - "Barista": Coffee, Tea, Cocoa, Cinnamon Rolls.
--    - "Diner": Corndogs, Fried Chicken, Fries, TV Dinners.
--    - "PetStore": Dog/Cat food bags and treats.
--    - "SushiBar": Egg Sushi, Ramen, Spring Rolls, Noodle Soup.
--    - "SmokingStall": Can pipes and Smoking pipes with tobacco.
--    - "GasStation": Crisps (Chips), Granola bars, Popcorn.
--    - "Farmer": Wheat, Rye, and Barley seeds.
-- ==========================================================

-- 1. BAKERY & DESSERT STALL (High Mood/Happiness)
RegisterFood({
    { item="Base.PieApple",            price=22, tags={"Bakery", "Dessert", "Fruit"} },
    { item="Base.PieBlueberry",        price=22, tags={"Bakery", "Dessert", "Fruit"} },
    { item="Base.PieKeyLime",          price=25, tags={"Bakery", "Dessert", "Fruit"} },
    { item="Base.PieLemonMeringue",    price=25, tags={"Bakery", "Dessert", "Fruit"} },
    { item="Base.PiePumpkin",          price=20, tags={"Bakery", "Dessert", "Vegetable"} },
    { item="Base.CakeChocolate",       price=24, tags={"Bakery", "Dessert", "Sweet"} },
    { item="Base.CakeBlackForest",     price=26, tags={"Bakery", "Dessert", "Gourmet"} },
    { item="Base.CakeCarrot",          price=20, tags={"Bakery", "Dessert", "Vegetable"} },
    { item="Base.CakeCheeseCake",      price=24, tags={"Bakery", "Dessert", "Dairy"} },
    { item="Base.CakeRedVelvet",       price=24, tags={"Bakery", "Dessert", "Gourmet"} },
    { item="Base.CakeStrawberryShortcake", price=24, tags={"Bakery", "Dessert", "Fruit"} },
    { item="Base.DoughnutPlain",       price=12, tags={"Bakery", "Dessert", "Snack"} },
    { item="Base.DoughnutChocolate",   price=15, tags={"Bakery", "Dessert", "Snack"} },
    { item="Base.DoughnutFrosted",     price=15, tags={"Bakery", "Dessert", "Snack"} },
    { item="Base.DoughnutJelly",       price=18, tags={"Bakery", "Dessert", "Snack"} },
    { item="Base.Croissant",           price=16, tags={"Bakery", "Breakfast"} },
    { item="Base.Danish",              price=16, tags={"Bakery", "Breakfast"} },
    { item="Base.Painauchocolat",      price=18, tags={"Bakery", "Dessert", "Breakfast"} },
    { item="Base.JellyRoll",           price=18, tags={"Bakery", "Dessert"} },
    { item="Base.Cupcake",             price=15, tags={"Bakery", "Dessert", "Snack"} },
    { item="Base.Chocolate_HeartBox",  price=65, tags={"Bakery", "Dessert", "Rare", "Gift"} },
})

-- 2. BARISTA & CAFFEINE (Fatigue Management)
RegisterFood({
    { item="Base.Coffee2",             price=50, tags={"Barista", "Caffeine", "Survivalist"} },
    { item="Base.Teabag2",             price=40, tags={"Barista", "Caffeine", "Healthy"} },
    { item="Base.ChocolateCoveredCoffeeBeans", price=35, tags={"Barista", "Caffeine", "Snack"} },
    { item="Base.CocoaPowder",         price=30, tags={"Barista", "Bakery", "Cooking"} },
    { item="Base.CinnamonRoll",        price=18, tags={"Barista", "Bakery", "Breakfast"} },
    { item="Base.HotDrinkRed",         price=20, tags={"Barista", "Warm"} },
    { item="Base.TestHotDrink",        price=20, tags={"Barista", "Warm"} },
})

-- 3. DINER & FROZEN BULK
RegisterFood({
    { item="Base.Frozen_ChickenNuggets", price=65, tags={"Diner", "Frozen", "Bulk"} },
    { item="Base.Frozen_FrenchFries",    price=55, tags={"Diner", "Frozen", "Bulk"} },
    { item="Base.Frozen_TatoDots",       price=55, tags={"Diner", "Frozen", "Bulk"} },
    { item="Base.TVDinner",              price=35, tags={"Diner", "Frozen", "Budget"} },
    { item="Base.ChickenFried",          price=25, tags={"Diner", "Meat"} },
    { item="Base.Corndog",               price=15, tags={"Diner", "Snack"} },
    { item="Base.Fries",                 price=12, tags={"Diner", "Snack"} },
    { item="Base.PotatoPancakes",        price=18, tags={"Diner", "Breakfast"} },
    { item="Base.Cornbread",             price=12, tags={"Diner", "Bakery"} },
    { item="Base.Macandcheese",          price=25, tags={"Diner", "Canteen", "NonPerishable"} },
})

-- 4. SUSHI BAR & ASIAN STALL
RegisterFood({
    { item="Base.SushiEgg",            price=30, tags={"SushiBar", "PreparedFood"} },
    { item="Base.RamenBowl",           price=25, tags={"SushiBar", "Asian", "Warm"} },
    { item="Base.NoodleSoup",          price=25, tags={"SushiBar", "Asian", "Warm"} },
    { item="Base.Springroll",          price=22, tags={"SushiBar", "Asian", "Snack"} },
    { item="Base.MeatSteamBun",        price=25, tags={"SushiBar", "Asian", "Meat"} },
    { item="Base.RicePaper",           price=10, tags={"SushiBar", "Cooking"} },
})

-- 5. PET STORE (Survival Rations/Pet Mods)
RegisterFood({
    { item="Base.CatFoodBag",          price=60, tags={"PetStore", "Prepper", "Bulk"} },
    { item="Base.DogFoodBag",          price=60, tags={"PetStore", "Prepper", "Bulk"} },
    { item="Base.CatTreats",           price=15, tags={"PetStore", "Snack"} },
})

-- 6. SMOKING STALL
RegisterFood({
    { item="Base.CanPipe_Tobacco",     price=45, tags={"SmokingStall", "Survivalist"} },
    { item="Base.SmokingPipe_Tobacco", price=60, tags={"SmokingStall", "Luxury"} },
})

-- 7. GAS STATION SNACKS & CANDY
RegisterFood({
    { item="Base.Crisps",              price=12, tags={"GasStation", "Snack", "JunkFood"} },
    { item="Base.Crisps2",             price=12, tags={"GasStation", "Snack", "JunkFood"} },
    { item="Base.Crisps3",             price=12, tags={"GasStation", "Snack", "JunkFood"} },
    { item="Base.Crisps4",             price=12, tags={"GasStation", "Snack", "JunkFood"} },
    { item="Base.TortillaChips",       price=12, tags={"GasStation", "Mexican", "Snack"} },
    { item="Base.Popcorn",             price=10, tags={"GasStation", "Cinema", "Snack"} },
    { item="Base.GranolaBar",          price=15, tags={"GasStation", "Healthy", "Snack"} },
    { item="Base.ChocoCakes",          price=18, tags={"GasStation", "Bakery"} },
    { item="Base.CrispyRiceSquare",    price=15, tags={"GasStation", "Bakery"} },
    { item="Base.GranolaBar",          price=15, tags={"GasStation", "Healthy", "Snack"} },
    { item="Base.Plonkies",            price=15, tags={"GasStation", "Snack"} },
    { item="Base.HiHis",               price=15, tags={"GasStation", "Snack"} },
    { item="Base.QuaggaCakes",         price=15, tags={"GasStation", "Snack"} },
    { item="Base.SnoGlobes",           price=15, tags={"GasStation", "Snack"} },
})

-- 8. PANTRY & SURVIVAL ESSENTIALS
RegisterFood({
    { item="Base.WaterRationCan",      price=45, tags={"Prepper", "Survivalist", "Drink"} },
    { item="Base.OatsRaw",             price=30, tags={"Canteen", "Breakfast", "NonPerishable"} },
    { item="Base.Cereal",              price=35, tags={"Diner", "Breakfast", "NonPerishable"} },
    { item="Base.DehydratedMeatStick", price=25, tags={"Survivalist", "Snack", "NonPerishable"} },
    { item="Base.Cheese",              price=28, tags={"Deli", "Cooking", "Dairy"} },
    { item="Base.Processedcheese",     price=15, tags={"Deli", "Budget", "Dairy"} },
    { item="Base.JamFruit",            price=30, tags={"Bakery", "Breakfast", "NonPerishable"} },
    { item="Base.JamMarmalade",        price=30, tags={"Bakery", "Breakfast", "NonPerishable"} },
    { item="Base.PeanutButter",        price=45, tags={"Prepper", "Snack", "NonPerishable"} },
    { item="Base.Dough",               price=15, tags={"Bakery", "Cooking"} },
    { item="Base.SeedPaste",           price=15, tags={"Healthy", "Cooking"} },
    { item="Base.SeedPasteBowl",       price=20, tags={"Healthy", "PreparedFood"} },
})

-- 9. REFINING & INDUSTRIAL (Sugar Beet Processing)
RegisterFood({
    { item="Base.SugarBeetPulpPot",    price=20, tags={"Farmer", "AnimalFeed"} },
    { item="Base.SugarBeetSyrupPot",   price=35, tags={"Farmer", "Refining", "Sweetener"} },
    { item="Base.SugarBeetSugarPot",   price=45, tags={"Farmer", "Refining", "Bakery"} },
})

-- 10. FARMER SEEDS (Investment)
RegisterFood({
    { item="Base.WheatSeed",           price=20, tags={"Farmer", "Seeds"} },
    { item="Base.RyeSeed",             price=18, tags={"Farmer", "Seeds"} },
    { item="Base.BarleySeed",          price=18, tags={"Farmer", "Seeds"} },
})

-- 11. MISC TREATS & FORAGED
RegisterFood({
    { item="Base.Icecream",            price=35, tags={"Diner", "Dairy", "Frozen"} },
    { item="Base.IcecreamMelted",      price=15, tags={"Diner", "Dairy"} },
    { item="Base.IcecreamSandwich",    price=20, tags={"Diner", "Snack", "Frozen"} },
    { item="Base.Popsicle",            price=15, tags={"Diner", "Snack", "Frozen"} },
    { item="Base.Yoghurt",             price=18, tags={"Healthy", "Breakfast", "Dairy"} },
    { item="Base.Tadpole",             price=5,  tags={"Foraged", "Bait", "Exotic"} },
    { item="Base.ChickenFoot",         price=8,  tags={"Butcher", "Exotic", "Cooking"} },
    { item="Base.Gingerbreadman",      price=12, tags={"Bakery", "Seasonal"} },
    { item="Base.Smore",               price=15, tags={"Bakery", "Camping"} },
    { item="Base.Marshmallows",        price=12, tags={"GasStation", "Camping"} },
})

-- ==========================================================
-- DYNAMIC TRADING: QUALITY-BASED MEATS & GAME
-- Inner Workings & Balancing:
-- 1. QUALITY SCALING: Prices are strictly tied to Hunger reduction. 
--    Prime cuts (-240) are 3x the price of Poor cuts (-80) due to their 
--    massive efficiency in high-level cooking recipes and nutrition.
-- 2. RARITY PREMIUM: Wild game (Venison) and large poultry (Turkey) are priced 
--    higher than farmed livestock (Beef/Pork) to reflect hunting difficulty.
-- 3. MERCHANT TAGS:
--    - "Butcher": Standard raw meat merchant.
--    - "Luxury": Assigned to Prime cuts for high-end "Gourmet" stalls.
--    - "Budget": Assigned to Poor cuts for "Scavenger" or "Canteen" filler.
--    - "Hunter": Wild game like Venison and Rabbit.
--    - "Poultry": Chicken and Turkey specialists.
-- 4. UNIQUE IDs: Since multiple items share the same Base ID, I've appended 
--    Quality suffixes (Prime/Avg/Poor) to the unique ID to prevent overwriting.
-- ==========================================================

-- 1. BEEF & STEAK (Cattle)
RegisterFood({
    { item="Base.Beef",           price=250, tags={"Butcher", "Luxury", "Raw", "Heavy"}, id="BuyBeefPrime" },
    { item="Base.Beef",           price=160, tags={"Butcher", "Raw", "Heavy"},           id="BuyBeefAverage" },
    { item="Base.Beef",           price=75,  tags={"Butcher", "Budget", "Raw"},          id="BuyBeefPoor" },
    { item="Base.Steak",          price=130, tags={"Butcher", "Luxury", "Raw", "Diner"}, id="BuySteakPrime" },
    { item="Base.Steak",          price=85,  tags={"Butcher", "Raw", "Diner"},           id="BuySteakAverage" },
    { item="Base.Steak",          price=40,  tags={"Butcher", "Budget", "Raw"},          id="BuySteakPoor" },
})

-- 2. PORK & CHOPS (Swine)
RegisterFood({
    { item="Base.Pork",           price=190, tags={"Butcher", "Luxury", "Raw", "Heavy"}, id="BuyPorkPrime" },
    { item="Base.Pork",           price=125, tags={"Butcher", "Raw", "Heavy"},           id="BuyPorkAverage" },
    { item="Base.Pork",           price=60,  tags={"Butcher", "Budget", "Raw"},          id="BuyPorkPoor" },
    { item="Base.PorkChop",       price=95,  tags={"Butcher", "Luxury", "Raw"},          id="BuyPorkChopPrime" },
    { item="Base.PorkChop",       price=65,  tags={"Butcher", "Raw"},                   id="BuyPorkChopAverage" },
    { item="Base.PorkChop",       price=30,  tags={"Butcher", "Budget", "Raw"},          id="BuyPorkChopPoor" },
})

-- 3. POULTRY (Avian)
RegisterFood({
    { item="Base.TurkeyWhole",    price=230, tags={"Butcher", "Poultry", "Hunter", "Rare", "Heavy"} },
    { item="Base.ChickenWhole",   price=160, tags={"Butcher", "Poultry", "Raw", "Heavy"} },
})

-- 4. MUTTON (Sheep)
RegisterFood({
    { item="Base.MuttonChop",     price=100, tags={"Butcher", "Luxury", "Raw"},          id="BuyMuttonPrime" },
    { item="Base.MuttonChop",     price=65,  tags={"Butcher", "Raw"},                   id="BuyMuttonAverage" },
    { item="Base.MuttonChop",     price=35,  tags={"Butcher", "Budget", "Raw"},          id="BuyMuttonPoor" },
})

-- 5. WILD GAME (Deer & Rabbit)
RegisterFood({
    { item="Base.Venison",        price=280, tags={"Hunter", "Luxury", "Raw", "Rare"},   id="BuyVenisonPrime" },
    { item="Base.Venison",        price=180, tags={"Hunter", "Raw", "Rare"},            id="BuyVenisonAverage" },
    { item="Base.Venison",        price=85,  tags={"Hunter", "Budget", "Raw"},           id="BuyVenisonPoor" },
    { item="Base.Rabbitmeat",     price=95,  tags={"Hunter", "Luxury", "WildMeat"},      id="BuyRabbitPrime" },
    { item="Base.Rabbitmeat",     price=65,  tags={"Hunter", "WildMeat"},               id="BuyRabbitAverage" },
    { item="Base.Rabbitmeat",     price=30,  tags={"Hunter", "Budget", "WildMeat"},      id="BuyRabbitPoor" },
    { item="Base.Smallanimalmeat", price=15, tags={"Hunter", "Scavenger", "Budget"},    id="BuyRodentMeat" },
})