require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- MELEE
    { item="Base.BaseballBat",  basePrice=25,  tags={"Weapon", "Blunt"},    stockRange={min=1, max=3} },
    { item="Base.KitchenKnife", basePrice=10,  tags={"Weapon", "Blade"},    stockRange={min=2, max=5} },
    { item="Base.HuntingKnife", basePrice=35,  tags={"Weapon", "Blade", "Rare"}, stockRange={min=1, max=2} },

    -- GUNS (High Rarity)
    { 
        item="Base.Pistol", 
        basePrice=150, 
        tags={"Weapon", "Gun", "Rare"}, 
        stockRange={min=1, max=1},
        chance=5 
    },
    { 
        item="Base.Shotgun", 
        basePrice=250, 
        tags={"Weapon", "Gun", "Rare"}, 
        stockRange={min=1, max=1},
        chance=3
    },

    -- AMMO
    { item="Base.Bullets9mmBox",     basePrice=40, tags={"Ammo"}, stockRange={min=1, max=3} },
    { item="Base.ShotgunShellsBox",  basePrice=60, tags={"Ammo"}, stockRange={min=1, max=2} }
})