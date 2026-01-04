-- =============================================================================
--  HOW TO ADD CUSTOM EVENTS (USER GUIDE)
-- =============================================================================
--  You can add your own events by following this template.
--  Copy-paste an example below and change the ID and values.
--
--  DynamicTrading.Events.Register("MyUniqueEventID", {
--      name = "My Custom Event",
--      description = "Flavor text shown in the Global Info UI.",
--
--      -- TYPE:
--      -- "flash" = Random temporary event (e.g., Airdrop). Respects 'Max Simultaneous Events' limit.
--      -- "meta"  = Permanent/World condition (e.g., Winter). Ignores limits. Requires 'condition' function.
--      type = "flash",
--
--      -- SPAWN LOGIC:
--      -- For "flash": return true/false based on Sandbox vars or chance.
--      canSpawn = function() return true end,
--
--      -- For "meta": return true (Start Event) or false (End Event) based on game state.
--      -- condition = function() return ClimateManager:getInstance():getSeasonName() == "Winter" end,
--
--      -- SYSTEM MODIFIERS (Global Effects):
--      -- traderLimit: Multiplier for Daily Trader Cap (0.5 = Half traders, 2.0 = Double traders).
--      -- globalStock: Multiplier for ALL items in ALL shops (1.5 = +50% loot everywhere).
--      -- scanChance:  Multiplier for radio scan success rate (0.5 = Harder to find signals).
--      system = {
--          traderLimit = 1.0, 
--          globalStock = 1.0,
--          scanChance = 1.0
--      },
--
--      -- TAG EFFECTS (Specific Items):
--      -- price: Multiplier (> 1.0 is Expensive, < 1.0 is Cheap).
--      -- vol:   Stock Quantity (> 1.0 is Abundant, < 1.0 is Scarce).
--      effects = {
--          ["Food"]   = { price = 2.0, vol = 0.5 }, -- Food is 2x price, half stock
--          ["Weapon"] = { price = 0.5, vol = 2.0 }  -- Weapons are half price, double stock
--      },
--
--      -- INJECTIONS (Guaranteed Items):
--      -- Force specific tags to appear even if the Trader doesn't usually sell them.
--      inject = { ["Medical"] = 5 }
--  })
-- =============================================================================
require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = {}
DynamicTrading.Events.Registry = {}
DynamicTrading.Events.ActiveEvents = {} 

-- =============================================================================
-- 1. REGISTRATION API
-- =============================================================================
function DynamicTrading.Events.Register(id, data)
    if not id or not data then return end
    -- Default to "flash" if not explicitly set to "meta"
    if not data.type then data.type = "flash" end
    DynamicTrading.Events.Registry[id] = data
end

-- =============================================================================
-- 2. ECONOMY HOOKS (GETTERS)
-- =============================================================================

-- Used by Economy to adjust prices based on ALL active events (Meta + Flash)
function DynamicTrading.Events.GetPriceModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].price then
                    multiplier = multiplier * event.effects[tag].price
                end
            end
        end
    end
    return multiplier
end

-- Used by Economy to adjust stock quantity based on active events
function DynamicTrading.Events.GetVolumeModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].vol then
                    multiplier = multiplier * event.effects[tag].vol
                end
            end
        end
    end
    return multiplier
end

-- [NEW] Used by Manager/Economy/Server to get system-wide changes
-- Valid Keys: "traderLimit", "globalStock", "scanChance"
function DynamicTrading.Events.GetSystemModifier(key)
    local multiplier = 1.0
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.system and event.system[key] then
            multiplier = multiplier * event.system[key]
        end
    end
    return multiplier
end

-- Used by Economy to force specific items into stock (e.g., Winter Clothes)
function DynamicTrading.Events.GetInjections()
    local injections = {}
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.inject then
            for tag, count in pairs(event.inject) do
                injections[tag] = (injections[tag] or 0) + count
            end
        end
    end
    return injections
end

-- Used by Manager to build the lottery pool for RANDOM events only
function DynamicTrading.Events.GetFlashCandidates()
    local candidates = {}
    for id, event in pairs(DynamicTrading.Events.Registry) do
        -- Only Flash events are eligible for the RNG lottery
        if event.type == "flash" then
            -- Use pcall to prevent script errors in custom conditions
            local success, shouldSpawn = pcall(function()
                if event.canSpawn then return event.canSpawn() end
                return true -- If no condition defined, it's always eligible
            end)
            
            if success and shouldSpawn == true then
                table.insert(candidates, id)
            end
        end
    end
    return candidates
end

-- =============================================================================
-- 3. EVENT DEFINITIONS
-- =============================================================================

-- ==========================================================
-- GROUP A: META EVENTS (Permanent / World State)
-- These DO NOT count towards the Event Limit.
-- ==========================================================

-- 1. WATER FAILURE
DynamicTrading.Events.Register("WaterFail", {
    name = "Drought (Water Shutoff)",
    type = "meta", 
    description = "The municipal water supply has failed. Clean water is now a luxury commodity.",
    condition = function() 
        -- Checks if the world age is past the sandbox shutdown setting
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.WaterShutModifier or 14)
    end,
    effects = {
        ["Water"] = { price = 5.0, vol = 0.2 },
        ["Drink"] = { price = 2.0 },
    }
})

-- 2. GRID FAILURE
DynamicTrading.Events.Register("PowerFail", {
    name = "Grid Collapse (Power Shutoff)",
    type = "meta", 
    description = "The power grid is dead. Generators, fuel, and batteries are in extreme demand.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.ElecShutModifier or 14)
    end,
    effects = {
        ["Electronics"] = { price = 2.0 },
        ["Fuel"] = { price = 3.0, vol = 0.5 },
        ["LightSource"] = { price = 1.5 }
    }
})

-- 3. SEASONAL: WINTER
DynamicTrading.Events.Register("Winter", {
    name = "Deep Freeze",
    type = "meta",
    description = "Temperatures have plummeted. Fresh food is gone, and fuel is liquid gold.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Winter" 
    end,
    effects = {
        ["Fresh"] = { price = 3.0, vol = 0.1 },
        ["Fuel"] = { price = 1.5 }, -- Stacks with PowerFail for massive price hike
        ["Warm"] = { price = 2.0, vol = 0.5 }, 
        ["Material"] = { price = 1.5 }
    },
    inject = { ["Winter"] = 2 }
})

-- 4. SEASONAL: HARVEST (Autumn)
DynamicTrading.Events.Register("Harvest", {
    name = "Harvest Season",
    type = "meta",
    description = "Farms are overflowing. Vegetable prices have crashed.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Autumn" 
    end,
    effects = {
        ["Vegetable"] = { price = 0.4, vol = 3.0 },
        ["Fruit"] = { price = 0.5, vol = 2.0 },
        ["Seed"] = { price = 1.5, vol = 0.5 }
    },
    inject = { ["Vegetable"] = 5, ["Pickle"] = 2 }
})

-- 5. SEASONAL: HEATWAVE (Summer)
DynamicTrading.Events.Register("Heatwave", {
    name = "Severe Drought",
    type = "meta",
    description = "A scorching heatwave. Water is becoming the new currency.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Summer" 
    end,
    effects = {
        ["Water"] = { price = 2.0 }, -- Stacks with WaterFail
        ["Drink"] = { price = 1.5 },
        ["Clothing"] = { price = 0.5 }
    }
})


-- ==========================================================
-- GROUP B: FLASH EVENTS (RNG / Temporary)
-- These respect the "Max Simultaneous Events" limit.
-- ==========================================================

-- [BAD] FACTION WAR
DynamicTrading.Events.Register("Warzone", {
    name = "Faction Conflict",
    type = "flash",
    description = "War has broken out. Traders are hiding, and ammo is scarce.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        traderLimit = 0.5 -- 50% Fewer traders appear today
    },
    effects = {
        ["Weapon"] = { price = 2.5, vol = 0.5 },
        ["Ammo"] = { price = 3.0, vol = 0.3 },
        ["Medical"] = { price = 1.5 }
    }
})

-- [GOOD] MILITARY SURPLUS
DynamicTrading.Events.Register("Surplus", {
    name = "Military Surplus",
    type = "flash",
    description = "A hidden military bunker was opened. The market is flooded with gear.",
    canSpawn = function() return true end,
    system = {
        globalStock = 1.5 -- Every shop has 50% more items
    },
    effects = {
        ["Weapon"] = { price = 0.6, vol = 2.0 },
        ["Ammo"] = { price = 0.5, vol = 3.0 },
        ["Clothing"] = { price = 0.8 }
    },
    inject = { ["Ammo"] = 5, ["Weapon"] = 2 }
})

-- [BAD] PANDEMIC
DynamicTrading.Events.Register("Outbreak", {
    name = "Viral Outbreak",
    type = "flash",
    description = "A new strain is spreading. Medical supplies are critical.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Medical"] = { price = 3.5, vol = 0.2 },
        ["Clean"] = { price = 2.5 },
        ["Food"] = { price = 1.2 }
    }
})

-- [GOOD] HOSPITAL FOUND
DynamicTrading.Events.Register("HospitalFound", {
    name = "Medical Supply Drop",
    type = "flash",
    description = "A hospital supply line restored. Meds are abundant.",
    canSpawn = function() return true end,
    effects = {
        ["Medical"] = { price = 0.3, vol = 5.0 },
        ["Clean"] = { price = 0.5, vol = 2.0 }
    },
    inject = { ["Medical"] = 8 }
})

DynamicTrading.Events.Register("Fortification", {
    name = "Horde Migration",
    type = "flash",
    description = "Massive herds moving through. Everyone needs construction mats.",
    canSpawn = function() return true end,
    effects = {
        ["Material"] = { price = 2.5, vol = 0.2 },
        ["Tool"] = { price = 1.8 },
        ["Ammo"] = { price = 1.2 }
    }
})

DynamicTrading.Events.Register("SalvageOp", {
    name = "Urban Salvage",
    type = "flash",
    description = "Scavengers cleared a city block. Materials are dirt cheap.",
    canSpawn = function() return true end,
    effects = {
        ["Material"] = { price = 0.5, vol = 4.0 },
        ["Junk"] = { price = 0.1, vol = 5.0 },
        ["Electronics"] = { price = 0.8 }
    },
    inject = { ["Material"] = 5 }
})

-- [TECH EVENTS]
DynamicTrading.Events.Register("TechBoom", {
    name = "Tech Discovery",
    type = "flash",
    description = "An electronics warehouse was found.",
    canSpawn = function() return true end,
    effects = {
        ["Electronics"] = { price = 0.4, vol = 3.0 },
        ["Communication"] = { price = 0.5, vol = 2.0 }
    },
    inject = { ["Electronics"] = 4 }
})

DynamicTrading.Events.Register("FuelCrisis", {
    name = "Fuel Crisis",
    type = "flash",
    description = "A refinery explosion halted production.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Fuel"] = { price = 4.0, vol = 0.1 },
        ["CarPart"] = { price = 0.5 }
    }
})

-- [UNDERGROUND]
DynamicTrading.Events.Register("Smugglers", {
    name = "Black Market Surge",
    type = "flash",
    description = "Smugglers are in town.",
    canSpawn = function() return true end,
    effects = {
        ["Alcohol"] = { price = 0.6, vol = 2.0 },
        ["Tobacco"] = { price = 0.6, vol = 2.0 },
        ["Jewelry"] = { price = 0.5 }
    }
})

-- [FOOD]
DynamicTrading.Events.Register("Famine", {
    name = "Crop Blight",
    type = "flash",
    description = "Crops have failed. Food is scarce.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Food"] = { price = 2.5, vol = 0.3 },
        ["Seed"] = { price = 3.0 },
        ["Canned"] = { price = 2.0 }
    }
})

DynamicTrading.Events.Register("AidDrop", {
    name = "Relief Shipment",
    type = "flash",
    description = "Humanitarian aid packages dropped.",
    canSpawn = function() return true end,
    effects = {
        ["Medical"] = { price = 0.2, vol = 4.0 },
        ["Canned"] = { price = 0.5, vol = 3.0 },
        ["Water"] = { price = 0.5, vol = 2.0 }
    },
    inject = { ["Medical"] = 6, ["Canned"] = 4 }
})

-- [ECONOMY]
DynamicTrading.Events.Register("Inflation", {
    name = "Market Panic",
    type = "flash",
    description = "Currency is losing value rapidly.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Misc"] = { price = 2.0 },
        ["Luxury"] = { price = 0.1 }
    }
})

DynamicTrading.Events.Register("FireSale", {
    name = "Liquidation Event",
    type = "flash",
    description = "Traders are selling stock at half price.",
    canSpawn = function() return true end,
    effects = {
        ["Misc"] = { price = 0.5, vol = 1.5 },
        ["Luxury"] = { price = 1.5 }
    }
})

-- [COMMUNICATION]
DynamicTrading.Events.Register("SolarFlare", {
    name = "Solar Flare Interference",
    type = "flash",
    description = "Atmospheric interference makes radio contact extremely difficult.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.5, -- 50% Harder to find signals
        traderLimit = 0.8
    },
    effects = {
        ["Communication"] = { price = 3.0 }
    }
})

print("[DynamicTrading] Events Initialized.")