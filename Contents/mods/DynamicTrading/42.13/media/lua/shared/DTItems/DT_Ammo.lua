require "DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
    -- ==========================================================
    -- BOXED AMMO (High Value)
    -- ==========================================================
    
    -- CIVILIAN / POLICE (Standard Stock)
    { 
        item="Base.Bullets9mmBox",     
        basePrice=40,  
        tags={"Ammo", "Common"}, 
        stockRange={min=2, max=6} 
    },
    { 
        item="Base.ShotgunShellsBox",  
        basePrice=50,  
        tags={"Ammo", "Common"}, 
        stockRange={min=2, max=5} 
    },
    { 
        item="Base.Bullets38Box",      
        basePrice=35,  
        tags={"Ammo", "Common"}, 
        stockRange={min=1, max=4} 
    },

    -- HUNTING / HEAVY (Uncommon)
    { 
        item="Base.Bullets45Box",      
        basePrice=55,  
        tags={"Ammo", "Uncommon", "Gun"}, 
        stockRange={min=1, max=3} 
    },
    { 
        item="Base.Bullets308Box",     
        basePrice=75,  
        tags={"Ammo", "Uncommon", "Hunting"}, 
        stockRange={min=1, max=2} 
    },

    -- MILITARY / MAGNUM (Rare)
    -- These will disappear in "Insane" difficulty due to negative rarity bonus
    { 
        item="Base.Bullets44Box", 
        basePrice=90, 
        tags={"Ammo", "Rare", "Gun"}, 
        stockRange={min=1, max=1}, 
        chance=5 
    },
    { 
        item="Base.556Box", 
        basePrice=120, 
        tags={"Ammo", "Rare", "Military"}, 
        stockRange={min=1, max=2}, 
        chance=3 
    },

    -- ==========================================================
    -- LOOSE ROUNDS (Fillers)
    -- ==========================================================
    -- Good for "The Scavenger" or "General Store" to have cheap stock
    { item="Base.Bullets9mm",        basePrice=2,   tags={"Ammo", "Junk"}, stockRange={min=10, max=30} },
    { item="Base.ShotgunShells",     basePrice=3,   tags={"Ammo", "Junk"}, stockRange={min=5, max=15} },
    { item="Base.Bullets308",        basePrice=5,   tags={"Ammo", "Junk"}, stockRange={min=2, max=8} }
})