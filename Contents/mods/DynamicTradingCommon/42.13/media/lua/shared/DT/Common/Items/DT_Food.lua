require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. FRESH MEAT & PROTEIN (High Nutrition, Low Shelf Life)
-- =============================================================================
{ item="Base.Beef", basePrice=40, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 16
{ item="Base.Steak", basePrice=45, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 18
{ item="Base.Pork", basePrice=35, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 14
{ item="Base.PorkChop", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 12
{ item="Base.MuttonChop", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 12
{ item="Base.Venison", basePrice=45, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 18
{ item="Base.ChickenWhole", basePrice=50, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 20
{ item="Base.ChickenFillet", basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 8
{ item="Base.Chicken", basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 6
{ item="Base.ChickenWings", basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 5
{ item="Base.TurkeyWhole", basePrice=75, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=1} }, -- Hung: 30
{ item="Base.TurkeyFillet", basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 12
{ item="Base.TurkeyLegs", basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 10
{ item="Base.TurkeyWings", basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 8
{ item="Base.Rabbitmeat", basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 10
{ item="Base.Smallanimalmeat", basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 4
{ item="Base.Smallbirdmeat", basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 4
{ item="Base.FrogMeat", basePrice=7, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 3
-- Processed Meats (Longer lasting or cured)
{ item="Base.Bacon",            basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 12
{ item="Base.BaconBits",        basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 4
{ item="Base.BaconRashers",     basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 5
{ item="Base.Ham",              basePrice=62, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=1} }, -- Hung: 25
{ item="Base.HamSlice",         basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Sausage",          basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Pepperoni",        basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Salami",           basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.SalamiSlice",      basePrice=10, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 4
{ item="Base.Baloney",          basePrice=37, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 15
{ item="Base.BaloneySlice",     basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 5
{ item="Base.MeatPatty",        basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 5
{ item="Base.MincedMeat",       basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.ChickenNuggets",   basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.MeatDumpling",     basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 5
{ item="Base.Hotdog_single",    basePrice=7,  tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 3
{ item="Base.HotdogPack",       basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 12

-- =============================================================================
-- 2. SEAFOOD (Fresh Fish)
-- =============================================================================
-- Prices vary by size/utility
{ item="Base.FishFillet",       basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Salmon",           basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 12
{ item="Base.AligatorGar",      basePrice=37, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 15
{ item="Base.BlackCrappie",     basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.BlueCatfish",      basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.Bluegill",         basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 6
{ item="Base.ChannelCatfish",   basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.FlatheadCatfish",  basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.FreshwaterDrum",   basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.GreenSunfish",     basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 6
{ item="Base.LargemouthBass",   basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.Muskellunge",      basePrice=35, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 14
{ item="Base.Paddlefish",       basePrice=30, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 12
{ item="Base.RedearSunfish",    basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 6
{ item="Base.Sauger",           basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.SmallmouthBass",   basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.SpottedBass",      basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.StripedBass",      basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.Walleye",          basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.WhiteBass",        basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.WhiteCrappie",     basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.YellowPerch",      basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.BaitFish",         basePrice=5,  tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} },

-- Shellfish & Misc Seafood
{ item="Base.Lobster",          basePrice=62, tags={"Food.Perishable.Meat", "Quality.Luxury"}, stockRange={min=0, max=1} }, -- Hung: 25
{ item="Base.Crayfish",         basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 5
{ item="Base.Shrimp",           basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 5
{ item="Base.Oysters",          basePrice=20, tags={"Food.Perishable.Meat", "Quality.Luxury"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.Mussels",          basePrice=15, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 6
{ item="Base.Squid",            basePrice=25, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.FishRoe",          basePrice=37, tags={"Food.Perishable.Meat", "Quality.Luxury"}, stockRange={min=0, max=2} }, -- Hung: 15
{ item="Base.Caviar",           basePrice=125, tags={"Food.NonPerishable.Meat", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=0, max=1} }, -- Hung: 25, Manual Rare upgrade

-- =============================================================================
-- 3. GAME & DEAD ANIMALS (Butchering Supplies)
-- =============================================================================
{ item="Base.DeadRabbit",       basePrice=20, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 8
{ item="Base.DeadSquirrel",     basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 5
{ item="Base.DeadBird",         basePrice=12, tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 5
{ item="Base.DeadRat",          basePrice=5,  tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 2
{ item="Base.DeadMouse",        basePrice=2,  tags={"Food.Perishable.Meat", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 1
{ item="Base.RatKing",          basePrice=150, tags={"Food.Perishable.Meat", "Rarity.Rare"}, stockRange={min=0, max=1} }, -- Hung: 20, Manual Rare upgrade

-- =============================================================================
-- 4. CANNED GOODS (Non-Perishable / Stable Currency)
-- =============================================================================
-- Closed Cans (High Value)
{ item="Base.TinnedBeans",          basePrice=25, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.CannedChili",          basePrice=30, tags={"Food.NonPerishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 12
{ item="Base.CannedCornedBeef",     basePrice=37, tags={"Food.NonPerishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 15
{ item="Base.CannedSardines",       basePrice=20, tags={"Food.NonPerishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.TunaTin",              basePrice=22, tags={"Food.NonPerishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 9
{ item="Base.CannedBolognese",      basePrice=35, tags={"Food.NonPerishable.Meat", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 14
{ item="Base.CannedCarrots2",       basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.CannedCorn",           basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.CannedPeas",           basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.CannedPotato2",        basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.CannedTomato2",        basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.CannedFruitBeverage",  basePrice=15, tags={"Food.NonPerishable.Fruit", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 6
{ item="Base.CannedFruitCocktail",  basePrice=25, tags={"Food.NonPerishable.Fruit", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.CannedPeaches",        basePrice=25, tags={"Food.NonPerishable.Fruit", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.CannedPineapple",      basePrice=25, tags={"Food.NonPerishable.Fruit", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.CannedMushroomSoup",   basePrice=25, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.TinnedSoup",           basePrice=25, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 10
{ item="Base.Dogfood",              basePrice=12, tags={"Food.NonPerishable.Meat", "Quality.Waste"}, stockRange={min=5, max=25} },
{ item="Base.CannedMilk",           basePrice=30, tags={"Food.NonPerishable.Drink", "Rarity.Common"}, stockRange={min=5, max=25} },
{ item="Base.MysteryCan",           basePrice=12, tags={"Food.NonPerishable.Unknown", "Rarity.Common"}, stockRange={min=2, max=12} },
{ item="Base.DentedCan",            basePrice=7,  tags={"Food.NonPerishable.Unknown", "Quality.Waste"}, stockRange={min=2, max=12} },

-- Opened Cans (Low Value - Spoil Fast)
{ item="Base.OpenBeans",            basePrice=5,  tags={"Food.Perishable.Canned", "Quality.Waste"}, stockRange={min=0, max=2} },
{ item="Base.CannedChiliOpen",      basePrice=5,  tags={"Food.Perishable.Canned", "Quality.Waste"}, stockRange={min=0, max=2} },
{ item="Base.TunaTinOpen",          basePrice=5,  tags={"Food.Perishable.Canned", "Quality.Waste"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. PRODUCE - VEGETABLES (Seasonal Value)
-- =============================================================================
{ item="Base.Avocado",          basePrice=40, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 16
{ item="Base.BellPepper",       basePrice=20, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Broccoli",         basePrice=22, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 9
{ item="Base.Cabbage",          basePrice=60, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 24
{ item="Base.Carrots",          basePrice=20, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Corn",             basePrice=25, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Eggplant",         basePrice=30, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 12
{ item="Base.Leek",             basePrice=20, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Lettuce",          basePrice=15, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.Onion",            basePrice=25, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Potato",           basePrice=45, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 18
{ item="Base.Pumpkin",          basePrice=75, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 30
{ item="Base.RedRadish",        basePrice=15, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.Tomato",           basePrice=30, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 12
{ item="Base.Zucchini",         basePrice=25, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 10
{ item="Base.GingerRoot",       basePrice=12, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 5
{ item="Base.Garlic",           basePrice=12, tags={"Food.Perishable.Vegetable", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 5

-- Dried/Preserved Veg
{ item="Base.DriedBlackBeans",  basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60
{ item="Base.DriedChickpeas",   basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60
{ item="Base.DriedKidneyBeans", basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60
{ item="Base.DriedLentils",     basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60
{ item="Base.DriedWhiteBeans",  basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60
{ item="Base.DriedSplitPeas",   basePrice=150, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=8, max=20} }, -- Hung: 60

-- =============================================================================
-- 6. PRODUCE - FRUITS
-- =============================================================================
{ item="Base.Apple",            basePrice=20, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Banana",           basePrice=30, tags={"Food.Perishable.Fruit", "Quality.Luxury"}, stockRange={min=1, max=7} }, -- Hung: 12
{ item="Base.BerryBlack",       basePrice=5,  tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2
{ item="Base.BerryBlue",        basePrice=5,  tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2
{ item="Base.Cherry",           basePrice=5,  tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2
{ item="Base.Grapes",           basePrice=25, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Grapefruit",       basePrice=30, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 12
{ item="Base.Lemon",            basePrice=12, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 5
{ item="Base.Lime",             basePrice=12, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 5
{ item="Base.Mango",            basePrice=37, tags={"Food.Perishable.Fruit", "Quality.Luxury"}, stockRange={min=0, max=2} }, -- Hung: 15
{ item="Base.Orange",           basePrice=25, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 10
{ item="Base.Peach",            basePrice=20, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 8
{ item="Base.Pear",             basePrice=20, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 8
{ item="Base.Pineapple",        basePrice=50, tags={"Food.Perishable.Fruit", "Quality.Luxury"}, stockRange={min=0, max=2} }, -- Hung: 20
{ item="Base.Watermelon",       basePrice=75, tags={"Food.Perishable.Fruit", "Rarity.Common"}, stockRange={min=0, max=2} }, -- Hung: 30
{ item="Base.DriedApricots",    basePrice=30, tags={"Food.NonPerishable.Fruit", "Quality.Luxury", "Rarity.Uncommon"}, stockRange={min=1, max=5} }, -- Hung: 12, Long life

-- =============================================================================
-- 7. PANTRY GRAINS & STAPLES
-- =============================================================================
{ item="Base.Bread",            basePrice=12, tags={"Food.Perishable.Grain", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 5
{ item="Base.BagelPlain",       basePrice=7,  tags={"Food.Perishable.Grain", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 3
{ item="Base.BaguetteDough",    basePrice=10, tags={"Food.Perishable.Grain", "Rarity.Common"}, stockRange={min=1, max=7} }, -- Hung: 4
{ item="Base.BunsHamburger",    basePrice=10, tags={"Food.Perishable.Grain", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 4
{ item="Base.Cereal",           basePrice=25, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 10
{ item="Base.Cornmeal2",        basePrice=20, tags={"Food.NonPerishable.Grain", "Theme.Survival"}, stockRange={min=4, max=10} }, -- Hung: 8
{ item="Base.Flour2",           basePrice=25, tags={"Food.NonPerishable.Grain", "Resource.Cooking"}, stockRange={min=4, max=10} }, -- Hung: 10
{ item="Base.Macaroni",         basePrice=30, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 12
{ item="Base.OatsRaw",          basePrice=20, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 8
{ item="Base.Pasta",            basePrice=30, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 12
{ item="Base.Rice",             basePrice=30, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 12
{ item="Base.Ramen",            basePrice=25, tags={"Food.NonPerishable.Grain", "Rarity.Common"}, stockRange={min=20, max=50} }, -- Hung: 10
{ item="Base.Yeast",            basePrice=12, tags={"Food.NonPerishable.Grain", "Resource.Cooking"}, stockRange={min=2, max=12} }, -- Hung: 5

-- =============================================================================
-- 8. SPICES, OILS & LUXURIES
-- =============================================================================
{ item="Base.Salt",             basePrice=12, tags={"Food.NonPerishable.Spice", "Rarity.Rare"}, stockRange={min=4, max=10} }, -- Hung: 5, Rare
{ item="Base.Pepper",           basePrice=12, tags={"Food.NonPerishable.Spice", "Rarity.Rare"}, stockRange={min=4, max=10} }, -- Hung: 5, Rare
{ item="Base.Sugar",            basePrice=20, tags={"Food.NonPerishable.Spice", "Rarity.Rare"}, stockRange={min=4, max=10} }, -- Hung: 8, Rare
{ item="Base.SugarBrown",       basePrice=20, tags={"Food.NonPerishable.Spice", "Rarity.Rare"}, stockRange={min=2, max=8} }, -- Hung: 8, Rare
{ item="Base.Honey",            basePrice=50, tags={"Food.NonPerishable.Spice", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 20
{ item="Base.MapleSyrup",       basePrice=37, tags={"Food.NonPerishable.Spice", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 15
{ item="Base.Butter",           basePrice=30, tags={"Food.Perishable.Cooking", "Quality.Luxury"}, stockRange={min=2, max=8} }, -- Hung: 12
{ item="Base.Margarine",        basePrice=25, tags={"Food.Perishable.Cooking", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.Lard",             basePrice=25, tags={"Food.Perishable.Cooking", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 10
{ item="Base.OilOlive",         basePrice=37, tags={"Food.NonPerishable.Cooking", "Quality.Luxury"}, stockRange={min=2, max=6} }, -- Hung: 15
{ item="Base.OilVegetable",     basePrice=37, tags={"Food.NonPerishable.Cooking", "Rarity.Common"}, stockRange={min=2, max=6} }, -- Hung: 15
{ item="Base.MayonnaiseFull",   basePrice=30, tags={"Food.Perishable.Cooking", "Rarity.Common"}, stockRange={min=2, max=6} }, -- Hung: 12
{ item="Base.PeanutButter",     basePrice=62, tags={"Food.NonPerishable.Cooking", "Theme.Survival"}, stockRange={min=2, max=8} }, -- Hung: 25, Survival Gold
{ item="Base.Ketchup",          basePrice=20, tags={"Food.NonPerishable.Spice", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Mustard",          basePrice=15, tags={"Food.NonPerishable.Spice", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.Marinara",         basePrice=20, tags={"Food.NonPerishable.Cooking", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Hotsauce",         basePrice=15, tags={"Food.NonPerishable.Spice", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.Coffee2",          basePrice=50, tags={"Food.NonPerishable.Drink", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=4} }, -- Hung: 20
{ item="Base.CocoaPowder",      basePrice=37, tags={"Food.NonPerishable.Drink", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=4} }, -- Hung: 15

-- =============================================================================
-- 9. CANDY & SNACKS (Happiness)
-- =============================================================================
{ item="Base.Chocolate",                basePrice=20, tags={"Food.NonPerishable.Sweets", "Quality.Luxury"}, stockRange={min=5, max=25} }, -- Hung: 8
{ item="Base.Chocolate_Butterchunkers", basePrice=20, tags={"Food.NonPerishable.Sweets", "Quality.Luxury"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Chocolate_Crackle",        basePrice=20, tags={"Food.NonPerishable.Sweets", "Quality.Luxury"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.Crisps",                   basePrice=12, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=5, max=15} },
{ item="Base.Crisps2",                  basePrice=12, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=2, max=12} },
{ item="Base.Crisps3",                  basePrice=12, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=2, max=12} },
{ item="Base.Crisps4",                  basePrice=12, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=2, max=12} },
{ item="Base.BeefJerky",                basePrice=25, tags={"Food.NonPerishable.Meat", "Theme.Survival"}, stockRange={min=4, max=10} }, -- Hung: 10
{ item="Base.Lollipop",                 basePrice=5,  tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2
{ item="Base.CandyPackage",             basePrice=25, tags={"Food.NonPerishable.Sweets", "Quality.Luxury"}, stockRange={min=1, max=7} }, -- Hung: 10
{ item="Base.GummyBears",               basePrice=10, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 4
{ item="Base.JellyBeans",               basePrice=10, tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 4
{ item="Base.HardCandies",              basePrice=7,  tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 3
{ item="Base.MintCandy",                basePrice=5,  tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2
{ item="Base.Modjeska",                 basePrice=15, tags={"Food.NonPerishable.Sweets", "Quality.Luxury"}, stockRange={min=2, max=12} }, -- Hung: 6
{ item="Base.Peppermint",               basePrice=5,  tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 2

-- =============================================================================
-- 10. PREPARED FOOD (Bakery/Meals)
-- =============================================================================
{ item="Base.CakeSlice",        basePrice=17, tags={"Food.Perishable.Sweets", "Quality.Luxury"}, stockRange={min=0, max=5} }, -- Hung: 7
{ item="Base.PieApple",         basePrice=25, tags={"Food.Perishable.Sweets", "Quality.Luxury"}, stockRange={min=0, max=2} }, -- Hung: 10
{ item="Base.Pizza",            basePrice=20, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=0, max=5} },
{ item="Base.Burger",           basePrice=25, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=0, max=5} },
{ item="Base.Fries",            basePrice=12, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=0, max=5} },
{ item="Base.Burrito",          basePrice=20, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=0, max=5} },
{ item="Base.Taco",             basePrice=15, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=0, max=5} },
{ item="Base.Sandwich",         basePrice=25, tags={"Food.Perishable.Cooking", "Rarity.Common"}, stockRange={min=0, max=5} }, -- Hung: 10
{ item="Base.CookieChocolateChip",basePrice=7,tags={"Food.NonPerishable.Sweets", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 3
{ item="Base.Cupcake",          basePrice=10, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 4
{ item="Base.Croissant",        basePrice=10, tags={"Food.Perishable.Sweets", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 4

-- Frozen/Packaged
{ item="Base.Icecream",         basePrice=37, tags={"Food.Perishable.Sweets", "Quality.Luxury"}, stockRange={min=0, max=5} }, -- Hung: 15
{ item="Base.TVDinner",         basePrice=20, tags={"Food.NonPerishable.Cooking", "Rarity.Common"}, stockRange={min=0, max=5} }, -- Hung: 8
{ item="Base.CornFrozen",       basePrice=15, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=0, max=5} }, -- Hung: 6
{ item="Base.Peas",             basePrice=15, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=0, max=5} }, -- Hung: 6
{ item="Base.MixedVegetables",  basePrice=15, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=0, max=5} }, -- Hung: 6

-- =============================================================================
-- 11. PICKLED FOOD (Preserved Veg)
-- =============================================================================
{ item="Base.Pickles",              basePrice=20, tags={"Food.NonPerishable.Vegetable", "Rarity.Common"}, stockRange={min=2, max=12} }, -- Hung: 8
{ item="Base.CannedBellPepper",     basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48, Large Jar
{ item="Base.CannedBroccoli",       basePrice=112, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 45
{ item="Base.CannedCabbage",        basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48
{ item="Base.CannedCarrots",        basePrice=100, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 40
{ item="Base.CannedEggplant",       basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48
{ item="Base.CannedLeek",           basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48
{ item="Base.CannedPotato",         basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48
{ item="Base.CannedRedRadish",      basePrice=112, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 45
{ item="Base.CannedTomato",         basePrice=120, tags={"Food.NonPerishable.Vegetable", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 48

-- =============================================================================
-- 12. HERBS & MEDICINAL PLANTS
-- =============================================================================
{ item="Base.Basil",            basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Chives",           basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Cilantro",         basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Garlic",           basePrice=12, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Oregano",          basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Parsley",          basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Rosemary",         basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Sage",             basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Thyme",            basePrice=5, tags={"Food.Perishable.Spice", "Origin.Healthcare"}, stockRange={min=2, max=12} },
{ item="Base.Ginseng",          basePrice=25, tags={"Food.Perishable.Medical", "Quality.Luxury", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 10
{ item="Base.LemonGrass",       basePrice=20, tags={"Food.Perishable.Medical", "Rarity.Rare"}, stockRange={min=1, max=5} }, -- Hung: 8

-- Dried Herbs (Better Value/Life)
{ item="Base.BasilDried",       basePrice=12, tags={"Food.NonPerishable.Spice", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 5
{ item="Base.OreganoDried",     basePrice=12, tags={"Food.NonPerishable.Spice", "Rarity.Common"}, stockRange={min=4, max=10} }, -- Hung: 5

-- =============================================================================
-- 14. INSECTS (Bait)
-- =============================================================================
{ item="Base.Worm",             basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=10, max=50} }, -- Hung: 1
{ item="Base.Cricket",          basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 1
{ item="Base.Cockroach",        basePrice=1, tags={"Food.Perishable.Bait", "Quality.Waste"}, stockRange={min=5, max=25} },
{ item="Base.Grasshopper",      basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} },
{ item="Base.Centipede",        basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} },
{ item="Base.Millipede",        basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} },
{ item="Base.Maggots",          basePrice=1, tags={"Food.Perishable.Bait", "Quality.Waste"}, stockRange={min=10, max=50} },
{ item="Base.Slug",             basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 1
{ item="Base.Snail",            basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 1
{ item="Base.Leech",            basePrice=2, tags={"Food.Perishable.Bait", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 1

-- =============================================================================
-- 15. EGGS
-- =============================================================================
{ item="Base.Egg",              basePrice=17, tags={"Food.Perishable.Protein", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 7
{ item="Base.EggCarton",        basePrice=200, tags={"Food.Perishable.Protein", "Rarity.Common"}, stockRange={min=1, max=5} }, -- Hung: 84 (approx)
{ item="Base.WildEggs",         basePrice=17, tags={"Food.Perishable.Protein", "Rarity.Common"}, stockRange={min=5, max=25} }, -- Hung: 7
{ item="Base.TurkeyEgg",        basePrice=25, tags={"Food.Perishable.Protein", "Rarity.Common"}, stockRange={min=2, max=12} } -- Hung: 10
})

print("[DynamicTrading] Food Registry Complete \n.")
