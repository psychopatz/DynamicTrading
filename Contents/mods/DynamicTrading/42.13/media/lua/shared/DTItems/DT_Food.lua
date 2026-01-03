require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. FRESH MEAT & PROTEIN (High Nutrition, Low Shelf Life)
-- =============================================================================
{ item="Base.Beef", basePrice=16, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Steak", basePrice=18, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Pork", basePrice=14, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.PorkChop", basePrice=12, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.MuttonChop", basePrice=12, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Venison", basePrice=18, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.ChickenWhole", basePrice=20, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=4} }, -- Whole bird
{ item="Base.ChickenFillet", basePrice=8, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Chicken", basePrice=6, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} }, -- Leg
{ item="Base.ChickenWings", basePrice=5, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.TurkeyWhole", basePrice=30, tags={"Food", "Meat", "Fresh"}, stockRange={min=0, max=2} }, -- Massive hunger reduction
{ item="Base.TurkeyFillet", basePrice=12, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.TurkeyLegs", basePrice=10, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.TurkeyWings", basePrice=8, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.Rabbitmeat", basePrice=10, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Smallanimalmeat", basePrice=4, tags={"Food", "Meat", "Fresh"}, stockRange={min=5, max=20} }, -- Rodent
{ item="Base.Smallbirdmeat", basePrice=4, tags={"Food", "Meat", "Fresh"}, stockRange={min=5, max=20} },
{ item="Base.FrogMeat", basePrice=3, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
-- Processed Meats (Longer lasting or cured)
{ item="Base.Bacon",            basePrice=12, tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.BaconBits",        basePrice=4,  tags={"Food", "Meat"}, stockRange={min=5, max=15} },
{ item="Base.BaconRashers",     basePrice=5,  tags={"Food", "Meat"}, stockRange={min=5, max=15} },
{ item="Base.Ham",              basePrice=25, tags={"Food", "Meat"}, stockRange={min=1, max=3} }, -- Whole ham
{ item="Base.HamSlice",         basePrice=6,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.Sausage",          basePrice=8,  tags={"Food", "Meat"}, stockRange={min=2, max=15} },
{ item="Base.Pepperoni",        basePrice=10, tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.Salami",           basePrice=10, tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.SalamiSlice",      basePrice=2,  tags={"Food", "Meat"}, stockRange={min=5, max=20} },
{ item="Base.Baloney",          basePrice=15, tags={"Food", "Meat"}, stockRange={min=1, max=5} },
{ item="Base.BaloneySlice",     basePrice=3,  tags={"Food", "Meat"}, stockRange={min=5, max=20} },
{ item="Base.MeatPatty",        basePrice=5,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.MincedMeat",       basePrice=8,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.ChickenNuggets",   basePrice=6,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.MeatDumpling",     basePrice=5,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.Hotdog_single",    basePrice=3,  tags={"Food", "Meat"}, stockRange={min=5, max=20} },
{ item="Base.HotdogPack",       basePrice=12, tags={"Food", "Meat"}, stockRange={min=2, max=8} },

-- =============================================================================
-- 2. SEAFOOD (Fresh Fish)
-- =============================================================================
-- Prices vary by size/utility
{ item="Base.FishFillet",       basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=2, max=10} },
{ item="Base.Salmon",           basePrice=12, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Trout",            basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Bass",             basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Catfish",          basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Perch",            basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Crappie",          basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Panfish",          basePrice=6,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Pike",             basePrice=14, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Sunfish",          basePrice=6,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.AligatorGar",      basePrice=15, tags={"Food", "Meat", "Fish"}, stockRange={min=0, max=2} },
{ item="Base.BlackCrappie",     basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.BlueCatfish",      basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Bluegill",         basePrice=6,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.ChannelCatfish",   basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.FlatheadCatfish",  basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.FreshwaterDrum",   basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.GreenSunfish",     basePrice=6,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.LargemouthBass",   basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Muskellunge",      basePrice=14, tags={"Food", "Meat", "Fish"}, stockRange={min=0, max=2} },
{ item="Base.Paddlefish",       basePrice=12, tags={"Food", "Meat", "Fish"}, stockRange={min=0, max=2} },
{ item="Base.RedearSunfish",    basePrice=6,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Sauger",           basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.SmallmouthBass",   basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.SpottedBass",      basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.StripedBass",      basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.Walleye",          basePrice=10, tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.WhiteBass",        basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.WhiteCrappie",     basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.YellowPerch",      basePrice=8,  tags={"Food", "Meat", "Fish"}, stockRange={min=1, max=5} },
{ item="Base.BaitFish",         basePrice=2,  tags={"Food", "Meat", "Fish", "Bait"}, stockRange={min=5, max=20} },

-- Shellfish & Misc Seafood
{ item="Base.Lobster",          basePrice=25, tags={"Food", "Meat", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.Crayfish",         basePrice=5,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.Shrimp",           basePrice=5,  tags={"Food", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.Oysters",          basePrice=8,  tags={"Food", "Meat", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.Mussels",          basePrice=6,  tags={"Food", "Meat"}, stockRange={min=1, max=5} },
{ item="Base.Squid",            basePrice=10, tags={"Food", "Meat"}, stockRange={min=1, max=5} },
{ item="Base.FishRoe",          basePrice=15, tags={"Food", "Meat", "Luxury"}, stockRange={min=0, max=2} },
{ item="Base.Caviar",           basePrice=50, tags={"Food", "Meat", "Luxury", "Canned"}, stockRange={min=0, max=1} }, -- Ultra luxury

-- =============================================================================
-- 3. GAME & DEAD ANIMALS (Butchering Supplies)
-- =============================================================================
{ item="Base.DeadRabbit",       basePrice=8,  tags={"Food", "Game"}, stockRange={min=1, max=5} },
{ item="Base.DeadSquirrel",     basePrice=5,  tags={"Food", "Game"}, stockRange={min=1, max=5} },
{ item="Base.DeadBird",         basePrice=5,  tags={"Food", "Game"}, stockRange={min=1, max=5} },
{ item="Base.DeadRat",          basePrice=2,  tags={"Food", "Game"}, stockRange={min=1, max=10} },
{ item="Base.DeadMouse",        basePrice=1,  tags={"Food", "Game"}, stockRange={min=1, max=10} },
{ item="Base.RatKing",          basePrice=20, tags={"Food", "Game", "Rare"}, stockRange={min=0, max=1} }, -- Rare gross item

-- =============================================================================
-- 4. CANNED GOODS (Non-Perishable / Stable Currency)
-- =============================================================================
-- Closed Cans (High Value)
{ item="Base.TinnedBeans",          basePrice=10, tags={"Food", "Canned"}, stockRange={min=5, max=20} },
{ item="Base.CannedChili",          basePrice=12, tags={"Food", "Canned"}, stockRange={min=5, max=15} },
{ item="Base.CannedCornedBeef",     basePrice=15, tags={"Food", "Canned", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.CannedSardines",       basePrice=8,  tags={"Food", "Canned", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.TunaTin",              basePrice=9,  tags={"Food", "Canned", "Meat"}, stockRange={min=2, max=10} },
{ item="Base.CannedBolognese",      basePrice=14, tags={"Food", "Canned"}, stockRange={min=2, max=10} },
{ item="Base.CannedCarrots2",       basePrice=8,  tags={"Food", "Canned", "Vegetable"}, stockRange={min=2, max=10} },
{ item="Base.CannedCorn",           basePrice=8,  tags={"Food", "Canned", "Vegetable"}, stockRange={min=2, max=10} },
{ item="Base.CannedPeas",           basePrice=8,  tags={"Food", "Canned", "Vegetable"}, stockRange={min=2, max=10} },
{ item="Base.CannedPotato2",        basePrice=8,  tags={"Food", "Canned", "Vegetable"}, stockRange={min=2, max=10} },
{ item="Base.CannedTomato2",        basePrice=8,  tags={"Food", "Canned", "Vegetable"}, stockRange={min=2, max=10} },
{ item="Base.CannedFruitBeverage",  basePrice=6,  tags={"Food", "Canned", "Drink"}, stockRange={min=2, max=10} },
{ item="Base.CannedFruitCocktail",  basePrice=10, tags={"Food", "Canned", "Fruit"}, stockRange={min=2, max=10} },
{ item="Base.CannedPeaches",        basePrice=10, tags={"Food", "Canned", "Fruit"}, stockRange={min=2, max=10} },
{ item="Base.CannedPineapple",      basePrice=10, tags={"Food", "Canned", "Fruit"}, stockRange={min=2, max=10} },
{ item="Base.CannedMushroomSoup",   basePrice=10, tags={"Food", "Canned"}, stockRange={min=2, max=10} },
{ item="Base.TinnedSoup",           basePrice=10, tags={"Food", "Canned"}, stockRange={min=2, max=10} },
{ item="Base.Dogfood",              basePrice=5,  tags={"Food", "Canned"}, stockRange={min=5, max=15} },
{ item="Base.CannedMilk",           basePrice=12, tags={"Food", "Canned", "Drink"}, stockRange={min=2, max=8} },
{ item="Base.MysteryCan",           basePrice=5,  tags={"Food", "Canned"}, stockRange={min=1, max=5} },
{ item="Base.DentedCan",            basePrice=3,  tags={"Food", "Canned"}, stockRange={min=1, max=5} },

-- Opened Cans (Low Value - Spoil Fast)
{ item="Base.OpenBeans",            basePrice=1, tags={"Food", "Canned"}, stockRange={min=0, max=2} },
{ item="Base.CannedChiliOpen",      basePrice=1, tags={"Food", "Canned"}, stockRange={min=0, max=2} },
{ item="Base.TunaTinOpen",          basePrice=1, tags={"Food", "Canned"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. PRODUCE - VEGETABLES (Seasonal Value)
-- =============================================================================
{ item="Base.Avocado",          basePrice=8,  tags={"Food", "Vegetable", "Fresh", "HighCalorie"}, stockRange={min=1, max=5} },
{ item="Base.BellPepper",       basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Broccoli",         basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Cabbage",          basePrice=3,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=20} }, -- Easy to grow
{ item="Base.Carrots",          basePrice=3,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Corn",             basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Eggplant",         basePrice=5,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Leek",             basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Lettuce",          basePrice=3,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Onion",            basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Potato",           basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=10, max=30} }, -- Staple
{ item="Base.Pumpkin",          basePrice=10, tags={"Food", "Vegetable", "Fresh"}, stockRange={min=1, max=3} },
{ item="Base.Radish",           basePrice=3,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Tomato",           basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Zucchini",         basePrice=4,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Mushrooms",        basePrice=5,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.GingerRoot",       basePrice=6,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.Garlic",           basePrice=5,  tags={"Food", "Vegetable", "Fresh"}, stockRange={min=1, max=5} },

-- Dried/Preserved Veg
{ item="Base.DriedBlackBeans",  basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.DriedChickpeas",   basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.DriedKidneyBeans", basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.DriedLentils",     basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.DriedWhiteBeans",  basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.DriedSplitPeas",   basePrice=15, tags={"Food", "Vegetable", "Grain"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 6. PRODUCE - FRUITS
-- =============================================================================
{ item="Base.Apple",            basePrice=5,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Banana",           basePrice=8,  tags={"Food", "Fruit", "Fresh", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.BerryBlack",       basePrice=2,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=5, max=20} },
{ item="Base.BerryBlue",        basePrice=2,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=5, max=20} },
{ item="Base.Cherry",           basePrice=2,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=5, max=20} },
{ item="Base.Grapes",           basePrice=6,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Grapefruit",       basePrice=8,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.Lemon",            basePrice=5,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Lime",             basePrice=5,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Mango",            basePrice=10, tags={"Food", "Fruit", "Fresh", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Orange",           basePrice=8,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Peach",            basePrice=6,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Pear",             basePrice=6,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Pineapple",        basePrice=12, tags={"Food", "Fruit", "Fresh", "Luxury"}, stockRange={min=1, max=3} },
{ item="Base.Strawberries",     basePrice=4,  tags={"Food", "Fruit", "Fresh"}, stockRange={min=5, max=15} },
{ item="Base.Watermelon",       basePrice=15, tags={"Food", "Fruit", "Fresh"}, stockRange={min=1, max=3} },
{ item="Base.DriedApricots",    basePrice=12, tags={"Food", "Fruit", "Luxury"}, stockRange={min=2, max=8} }, -- Long life

-- =============================================================================
-- 7. PANTRY GRAINS & STAPLES
-- =============================================================================
{ item="Base.Bread",            basePrice=5,  tags={"Food", "Grain", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.BagelPlain",       basePrice=3,  tags={"Food", "Grain", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.BaguetteDough",    basePrice=4,  tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.BunsHamburger",    basePrice=4,  tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Cereal",           basePrice=10, tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Cornmeal2",        basePrice=8,  tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Flour2",           basePrice=10, tags={"Food", "Grain", "Material"}, stockRange={min=2, max=10} },
{ item="Base.Macaroni",         basePrice=12, tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.OatsRaw",          basePrice=8,  tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Pasta",            basePrice=12, tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Rice",             basePrice=12, tags={"Food", "Grain"}, stockRange={min=2, max=10} },
{ item="Base.Ramen",            basePrice=5,  tags={"Food", "Grain"}, stockRange={min=5, max=20} },
{ item="Base.Yeast",            basePrice=5,  tags={"Food", "Grain", "Material"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 8. SPICES, OILS & LUXURIES
-- =============================================================================
{ item="Base.Salt",             basePrice=5,  tags={"Food", "Spice"}, stockRange={min=5, max=20} },
{ item="Base.Pepper",           basePrice=5,  tags={"Food", "Spice"}, stockRange={min=5, max=20} },
{ item="Base.Sugar",            basePrice=8,  tags={"Food", "Spice", "Luxury"}, stockRange={min=5, max=15} },
{ item="Base.SugarBrown",       basePrice=8,  tags={"Food", "Spice", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.Honey",            basePrice=20, tags={"Food", "Spice", "Luxury"}, stockRange={min=2, max=8} },
{ item="Base.MapleSyrup",       basePrice=15, tags={"Food", "Spice", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.Butter",           basePrice=12, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=8} },
{ item="Base.Margarine",        basePrice=10, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=8} },
{ item="Base.Lard",             basePrice=10, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=8} },
{ item="Base.OilOlive",         basePrice=15, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=6} },
{ item="Base.OilVegetable",     basePrice=15, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=6} },
{ item="Base.MayonnaiseFull",   basePrice=12, tags={"Food", "Spice", "HighCalorie"}, stockRange={min=2, max=6} },
{ item="Base.PeanutButter",     basePrice=25, tags={"Food", "HighCalorie"}, stockRange={min=2, max=8} }, -- Survival Gold
{ item="Base.Ketchup",          basePrice=8,  tags={"Food", "Spice"}, stockRange={min=2, max=8} },
{ item="Base.Mustard",          basePrice=6,  tags={"Food", "Spice"}, stockRange={min=2, max=8} },
{ item="Base.Marinara",         basePrice=8,  tags={"Food", "Spice"}, stockRange={min=2, max=8} },
{ item="Base.Hotsauce",         basePrice=6,  tags={"Food", "Spice"}, stockRange={min=2, max=8} },
{ item="Base.SoySauce",         basePrice=8,  tags={"Food", "Spice"}, stockRange={min=2, max=8} },
{ item="Base.Coffee2",          basePrice=20, tags={"Food", "Drink", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.TeaBag2",          basePrice=15, tags={"Food", "Drink", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.CocoaPowder",      basePrice=15, tags={"Food", "Drink", "Luxury"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 9. CANDY & SNACKS (Happiness)
-- =============================================================================
{ item="Base.Chocolate",                basePrice=8, tags={"Food", "Sweets", "Luxury"}, stockRange={min=5, max=20} },
{ item="Base.Chocolate_Butterchunkers", basePrice=8, tags={"Food", "Sweets", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.Chocolate_Crackle",        basePrice=8, tags={"Food", "Sweets", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.Crisps",                   basePrice=5, tags={"Food", "Junk"}, stockRange={min=5, max=15} },
{ item="Base.Crisps2",                  basePrice=5, tags={"Food", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.Crisps3",                  basePrice=5, tags={"Food", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.Crisps4",                  basePrice=5, tags={"Food", "Junk"}, stockRange={min=2, max=10} },
{ item="Base.BeefJerky",                basePrice=22,tags={"Food", "Meat", "Luxury"}, stockRange={min=2, max=8} },
{ item="Base.Lollipop",                 basePrice=2, tags={"Food", "Sweets"}, stockRange={min=10, max=30} },
{ item="Base.CandyPackage",             basePrice=10,tags={"Food", "Sweets", "Luxury"}, stockRange={min=1, max=5} },
{ item="Base.GummyBears",               basePrice=4, tags={"Food", "Sweets"}, stockRange={min=5, max=15} },
{ item="Base.JellyBeans",               basePrice=4, tags={"Food", "Sweets"}, stockRange={min=5, max=15} },
{ item="Base.HardCandies",              basePrice=3, tags={"Food", "Sweets"}, stockRange={min=5, max=20} },
{ item="Base.MintCandy",                basePrice=2, tags={"Food", "Sweets"}, stockRange={min=5, max=20} },
{ item="Base.Modjeska",                 basePrice=6, tags={"Food", "Sweets", "Luxury"}, stockRange={min=2, max=10} },
{ item="Base.Peppermint",               basePrice=2, tags={"Food", "Sweets"}, stockRange={min=5, max=20} },

-- =============================================================================
-- 10. PREPARED FOOD (Bakery/Meals)
-- =============================================================================
{ item="Base.CakeSlice",        basePrice=6,  tags={"Food", "Sweets"}, stockRange={min=0, max=5} },
{ item="Base.PieApple",         basePrice=10, tags={"Food", "Sweets"}, stockRange={min=0, max=2} },
{ item="Base.Pizza",            basePrice=8,  tags={"Food", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Burger",           basePrice=10, tags={"Food", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Fries",            basePrice=5,  tags={"Food", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Burrito",          basePrice=8,  tags={"Food", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Taco",             basePrice=6,  tags={"Food", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Sandwich",         basePrice=5,  tags={"Food", "Fresh"}, stockRange={min=0, max=5} },
{ item="Base.CookieChocolateChip",basePrice=3,tags={"Food", "Sweets"}, stockRange={min=5, max=20} },
{ item="Base.Cupcake",          basePrice=4,  tags={"Food", "Sweets"}, stockRange={min=2, max=10} },
{ item="Base.DonutPlain",       basePrice=3,  tags={"Food", "Sweets"}, stockRange={min=2, max=10} },
{ item="Base.Croissant",        basePrice=4,  tags={"Food", "Sweets"}, stockRange={min=2, max=8} },

-- Frozen/Packaged
{ item="Base.Icecream",         basePrice=15, tags={"Food", "Sweets", "Luxury", "Frozen"}, stockRange={min=0, max=5} },
{ item="Base.TVDinner",         basePrice=8,  tags={"Food", "Frozen"}, stockRange={min=0, max=5} },
{ item="Base.CornFrozen",       basePrice=6,  tags={"Food", "Frozen", "Vegetable"}, stockRange={min=0, max=5} },
{ item="Base.Peas",             basePrice=6,  tags={"Food", "Frozen", "Vegetable"}, stockRange={min=0, max=5} }, -- Bag of peas
{ item="Base.MixedVegetables",  basePrice=6,  tags={"Food", "Frozen", "Vegetable"}, stockRange={min=0, max=5} },

-- =============================================================================
-- 11. PICKLED FOOD (Preserved Veg)
-- =============================================================================
{ item="Base.Pickles",              basePrice=8,  tags={"Food", "Pickle"}, stockRange={min=2, max=10} },
{ item="Base.CannedBellPepper",     basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedBroccoli",       basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedCabbage",        basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedCarrots",        basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedEggplant",       basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedLeek",           basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedPotato",         basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedRedRadish",      basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },
{ item="Base.CannedTomato",         basePrice=12, tags={"Food", "Pickle"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 12. HERBS & MEDICINAL PLANTS
-- =============================================================================
{ item="Base.Basil",            basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Chives",           basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Cilantro",         basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Garlic",           basePrice=5, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Oregano",          basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Parsley",          basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Rosemary",         basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Sage",             basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Thyme",            basePrice=2, tags={"Food", "Spice", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Ginseng",          basePrice=10,tags={"Food", "Medical", "Rare"}, stockRange={min=1, max=5} },
{ item="Base.LemonGrass",       basePrice=8, tags={"Food", "Spice", "Medical"}, stockRange={min=1, max=5} },

-- Dried Herbs (Better Value/Life)
{ item="Base.BasilDried",       basePrice=5, tags={"Food", "Spice"}, stockRange={min=2, max=10} },
{ item="Base.OreganoDried",     basePrice=5, tags={"Food", "Spice"}, stockRange={min=2, max=10} },

-- =============================================================================
-- 14. INSECTS (Bait)
-- =============================================================================
{ item="Base.Worm",             basePrice=0.5, tags={"Food", "Bait"}, stockRange={min=10, max=50} },
{ item="Base.Cricket",          basePrice=0.5, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Cockroach",        basePrice=0.2, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Grasshopper",      basePrice=0.5, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Centipede",        basePrice=0.2, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Millipede",        basePrice=0.2, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Maggots",          basePrice=0.1, tags={"Food", "Bait"}, stockRange={min=10, max=50} },
{ item="Base.Slug",             basePrice=0.2, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Snail",            basePrice=0.5, tags={"Food", "Bait"}, stockRange={min=5, max=20} },
{ item="Base.Leech",            basePrice=0.2, tags={"Food", "Bait"}, stockRange={min=5, max=20} },

-- =============================================================================
-- 15. EGGS
-- =============================================================================
{ item="Base.Egg",              basePrice=2,  tags={"Food", "Fresh", "Protein"}, stockRange={min=6, max=24} },
{ item="Base.EggCarton",        basePrice=20, tags={"Food", "Fresh", "Protein"}, stockRange={min=1, max=5} },
{ item="Base.WildEggs",         basePrice=1,  tags={"Food", "Fresh", "Protein"}, stockRange={min=5, max=15} },
{ item="Base.TurkeyEgg",        basePrice=3,  tags={"Food", "Fresh", "Protein"}, stockRange={min=2, max=10} }
})