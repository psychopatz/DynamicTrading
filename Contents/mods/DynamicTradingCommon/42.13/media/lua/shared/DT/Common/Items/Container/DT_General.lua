-- =============================================================================
-- DYNAMIC TRADING: CONTAINER - GENERAL
-- =============================================================================
-- Root Category: Container
-- Sub Category: General
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Bag_BirthdayBasket",           basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },
    { item="Base.Bag_BowlingBallBag",           basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },
    { item="Base.Bag_Dancer",                   basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Bag_DeadMice",                 basePrice=10,  tags={"Container.General"}, stockRange={min=0, max=1} },
    { item="Base.Bag_DeadRats",                 basePrice=10,  tags={"Container.General"}, stockRange={min=0, max=1} },
    { item="Base.Bag_DeadRoaches",              basePrice=5,   tags={"Container.General"}, stockRange={min=0, max=1} },
    { item="Base.Bag_GardenBasket",             basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=8} },
    { item="Base.Bag_Laundry",                  basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },
    { item="Base.Bag_LaundryHospital",          basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },
    { item="Base.Bag_LaundryLinen",             basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=15} },
    { item="Base.Bag_TrashBag",                 basePrice=2,   tags={"Container.General", "Quality.Waste"}, stockRange={min=10, max=50} },
    { item="Base.Bag_TreasureBag",              basePrice=50,  tags={"Container.General", "Rarity.Rare"}, stockRange={min=0, max=1} },
    { item="Base.DiceBag",                      basePrice=2,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Garbagebag",                   basePrice=2,   tags={"Container.General", "Quality.Waste"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBag1",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBag2",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBag3",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBag4",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBag5",                  basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.GroceryBagGourmet",            basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Handbag",                      basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=10} },
    { item="Base.PaperBag",                     basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Paperbag_Jays",                basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Paperbag_Spiffos",             basePrice=0.2, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Plasticbag",                   basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Plasticbag_Bags",              basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.Plasticbag_Clothing",          basePrice=0.5, tags={"Container.General"}, stockRange={min=10, max=50} },
    { item="Base.ProduceBox_ExtraLarge",        basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.ProduceBox_ExtraSmall",        basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.ProduceBox_Large",             basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.ProduceBox_Medium",            basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.ProduceBox_Small",             basePrice=1,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Purse",                        basePrice=5,   tags={"Container.General"}, stockRange={min=2, max=10} },
    { item="Base.SeedBag",                      basePrice=2,   tags={"Container.General", "Theme.Farming"}, stockRange={min=5, max=20} },
    { item="Base.SeedBag_Farming",              basePrice=2,   tags={"Container.General", "Theme.Farming"}, stockRange={min=5, max=20} },
    { item="Base.TakeoutBox_Chinese",           basePrice=0.5, tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.TakeoutBox_Styrofoam",         basePrice=0.5, tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Tote",                         basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Tote_Bags",                    basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
    { item="Base.Tote_Clothing",                basePrice=5,   tags={"Container.General"}, stockRange={min=5, max=20} },
})

print("[DynamicTrading] Container/General Registry Loaded.")
