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
    DynamicTrading.Events.Registry[id] = data
end

-- =============================================================================
-- 2. ECONOMY HOOKS (GETTERS)
-- =============================================================================

-- Used by Economy to adjust prices based on active events
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

-- [NEW] Used by Manager to build the lottery pool for today
function DynamicTrading.Events.GetValidCandidates()
    local candidates = {}
    for id, event in pairs(DynamicTrading.Events.Registry) do
        -- Use pcall to prevent a script error in one event from crashing the whole system
        local success, shouldSpawn = pcall(function()
            if event.canSpawn then
                return event.canSpawn()
            end
            return true -- If no condition is defined, it is always a candidate
        end)

        if success and shouldSpawn == true then
            table.insert(candidates, id)
        end
    end
    return candidates
end

-- =============================================================================
-- 3. EVENT DEFINITIONS
-- =============================================================================
local function InitEvents()
    -- ==========================================================
    -- CATEGORY: SEASONAL
    -- ==========================================================
    
    -- [AUTUMN] THE HARVEST
    DynamicTrading.Events.Register("Harvest", {
        name = "Harvest Season",
        description = "Farms are overflowing with crops. Vegetable prices have crashed due to oversupply.",
        canSpawn = function() 
            -- Only happens in Autumn, and only if Seasonal Events are enabled
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

    -- [WINTER] THE DEEP FREEZE
    DynamicTrading.Events.Register("Winter", {
        name = "Deep Freeze",
        description = "Temperatures have plummeted. Fresh food is gone, and fuel is liquid gold.",
        canSpawn = function() 
            if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
            return ClimateManager:getInstance():getSeasonName() == "Winter" 
        end,
        effects = {
            ["Fresh"] = { price = 3.0, vol = 0.1 },
            ["Fuel"] = { price = 2.5, vol = 0.5 },
            ["Warm"] = { price = 2.0, vol = 0.5 }, -- Custom tag for heaters/parkas
            ["Material"] = { price = 1.5 }
        },
        inject = { ["Winter"] = 2 }
    })

    -- [SUMMER] HEATWAVE
    DynamicTrading.Events.Register("Heatwave", {
        name = "Severe Drought",
        description = "A scorching heatwave has dried up wells. Water is becoming the new currency.",
        canSpawn = function() 
            if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
            return ClimateManager:getInstance():getSeasonName() == "Summer" 
        end,
        effects = {
            ["Water"] = { price = 4.0, vol = 0.2 },
            ["Drink"] = { price = 2.0, vol = 0.5 },
            ["Clothing"] = { price = 0.5 }
        },
        inject = { ["Water"] = 1 }
    })

    -- ==========================================================
    -- CATEGORY: MILITARY & CONFLICT
    -- ==========================================================

    -- [BAD] FACTION WAR
    DynamicTrading.Events.Register("Warzone", {
        name = "Faction Conflict",
        description = "War has broken out between major settlements. Weapons and ammo are being hoarded.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Weapon"] = { price = 2.5, vol = 0.5 },
            ["Ammo"] = { price = 3.0, vol = 0.3 },
            ["Medical"] = { price = 1.5 }
        }
    })

    -- [GOOD] MILITARY SURPLUS
    DynamicTrading.Events.Register("Surplus", {
        name = "Military Surplus",
        description = "A hidden military bunker was opened. High-grade tactical gear is flooding the market.",
        canSpawn = function() return true end,
        effects = {
            ["Weapon"] = { price = 0.6, vol = 2.0 },
            ["Ammo"] = { price = 0.5, vol = 3.0 },
            ["Clothing"] = { price = 0.8 }
        },
        inject = { ["Ammo"] = 5, ["Weapon"] = 2 }
    })

    -- ==========================================================
    -- CATEGORY: HEALTH & DISEASE
    -- ==========================================================

    -- [BAD] PANDEMIC
    DynamicTrading.Events.Register("Outbreak", {
        name = "Viral Outbreak",
        description = "A new strain of the infection is spreading. Medical supplies are critical.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Medical"] = { price = 3.5, vol = 0.2 },
            ["Clean"] = { price = 2.5 },
            ["Food"] = { price = 1.2 }
        }
    })

    -- [GOOD] HUMANITARIAN AID
    DynamicTrading.Events.Register("HospitalFound", {
        name = "Medical Supply Drop",
        description = "A hospital supply line has been restored. Meds are abundant and cheap.",
        canSpawn = function() return true end,
        effects = {
            ["Medical"] = { price = 0.3, vol = 5.0 },
            ["Clean"] = { price = 0.5, vol = 2.0 }
        },
        inject = { ["Medical"] = 8 }
    })

    -- ==========================================================
    -- CATEGORY: CONSTRUCTION & INFRASTRUCTURE
    -- ==========================================================

    DynamicTrading.Events.Register("Fortification", {
        name = "Horde Migration",
        description = "Massive herds are moving through. Everyone is buying nails and planks to board up.",
        canSpawn = function() return true end,
        effects = {
            ["Material"] = { price = 2.5, vol = 0.2 },
            ["Tool"] = { price = 1.8 },
            ["Ammo"] = { price = 1.2 }
        }
    })

    DynamicTrading.Events.Register("SalvageOp", {
        name = "Urban Salvage",
        description = "Scavengers cleared a city block. Building materials and scrap are dirt cheap.",
        canSpawn = function() return true end,
        effects = {
            ["Material"] = { price = 0.5, vol = 4.0 },
            ["Junk"] = { price = 0.1, vol = 5.0 },
            ["Electronics"] = { price = 0.8 }
        },
        inject = { ["Material"] = 5 }
    })

    -- ==========================================================
    -- CATEGORY: TECHNOLOGY & ENERGY
    -- ==========================================================

    DynamicTrading.Events.Register("Blackout", {
        name = "Grid Failure",
        description = "A solar storm has fried local electronics. Spare parts and generators are rare.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Electronics"] = { price = 4.0, vol = 0.1 },
            ["Fuel"] = { price = 2.0 },
            ["Communication"] = { price = 3.0 }
        }
    })

    DynamicTrading.Events.Register("TechBoom", {
        name = "Tech Discovery",
        description = "An electronics warehouse was found. Components are available for cheap.",
        canSpawn = function() return true end,
        effects = {
            ["Electronics"] = { price = 0.4, vol = 3.0 },
            ["Communication"] = { price = 0.5, vol = 2.0 }
        },
        inject = { ["Electronics"] = 4 }
    })

    -- ==========================================================
    -- CATEGORY: INDUSTRY & FUEL
    -- ==========================================================

    DynamicTrading.Events.Register("FuelCrisis", {
        name = "Fuel Crisis",
        description = "A refinery explosion halted production. Gas prices are skyrocketing.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Fuel"] = { price = 4.0, vol = 0.1 },
            ["CarPart"] = { price = 0.5 }
        }
    })

    DynamicTrading.Events.Register("IndustryBoom", {
        name = "Industrial Restart",
        description = "A local factory came back online. Tools and materials are flowing.",
        canSpawn = function() return true end,
        effects = {
            ["Material"] = { price = 0.5, vol = 3.0 },
            ["Tool"] = { price = 0.6, vol = 2.0 },
            ["Electronics"] = { price = 0.7 }
        }
    })

    -- ==========================================================
    -- CATEGORY: UNDERGROUND
    -- ==========================================================

    DynamicTrading.Events.Register("Smugglers", {
        name = "Black Market Surge",
        description = "Smugglers are in town. Alcohol, tobacco, and luxury goods are cheap.",
        canSpawn = function() return true end,
        effects = {
            ["Alcohol"] = { price = 0.6, vol = 2.0 },
            ["Tobacco"] = { price = 0.6, vol = 2.0 },
            ["Jewelry"] = { price = 0.5 }
        }
    })
    
    -- ==========================================================
    -- CATEGORY: FOOD SUPPLY
    -- ==========================================================

    DynamicTrading.Events.Register("Famine", {
        name = "Crop Blight",
        description = "Crops across the region have failed. Food is scarce and expensive.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Food"] = { price = 2.5, vol = 0.3 },
            ["Seed"] = { price = 3.0 },
            ["Canned"] = { price = 2.0 }
        }
    })

    DynamicTrading.Events.Register("AidDrop", {
        name = "Relief Shipment",
        description = "Humanitarian aid packages were dropped nearby. Free food and meds.",
        canSpawn = function() return true end,
        effects = {
            ["Medical"] = { price = 0.2, vol = 4.0 },
            ["Canned"] = { price = 0.5, vol = 3.0 },
            ["Water"] = { price = 0.5, vol = 2.0 }
        },
        inject = { ["Medical"] = 6, ["Canned"] = 4 }
    })

    -- ==========================================================
    -- CATEGORY: MACRO ECONOMICS
    -- ==========================================================

    DynamicTrading.Events.Register("Inflation", {
        name = "Market Panic",
        description = "Currency is losing value rapidly. Everything costs double.",
        canSpawn = function() 
            return SandboxVars.DynamicTrading.AllowHardcoreEvents 
        end,
        effects = {
            ["Misc"] = { price = 2.0 },
            ["Luxury"] = { price = 0.1 }
        }
    })

    DynamicTrading.Events.Register("FireSale", {
        name = "Liquidation Event",
        description = "Traders are leaving the area and selling stock at half price.",
        canSpawn = function() return true end,
        effects = {
            ["Misc"] = { price = 0.5, vol = 1.5 },
            ["Luxury"] = { price = 1.5 }
        }
    })

    print("[DynamicTrading] Events Initialized.")
end

Events.OnGameBoot.Add(InitEvents)