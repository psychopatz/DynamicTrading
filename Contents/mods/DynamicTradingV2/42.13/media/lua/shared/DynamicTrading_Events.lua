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

-- #############################################################################
-- META POSITIVE
-- (Permanent/Seasonal conditions that benefit the player)
-- #############################################################################

-- [POSITIVE] Cheap food.
DynamicTrading.Events.Register("Harvest", {
    name = "Harvest Season",
    type = "meta",
    description = "Farms are overflowing. Produce is cheap.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Autumn" 
    end,
    effects = {
        ["Vegetable"] = { price = 0.4, vol = 3.0 },
        ["Fruit"] = { price = 0.5, vol = 2.0 },
        ["Farming"] = { price = 1.5, vol = 0.5 },
        ["Pickle"] = { price = 0.8, vol = 2.0 }
    },
    inject = { ["Vegetable"] = 5, ["Pickle"] = 2 }
})

-- =============================================================================
-- SEASONAL: SPRING THAW
-- =============================================================================
-- Concept: Winter is over. It's raining constantly. Time to plant.
DynamicTrading.Events.Register("Spring", {
    name = "Spring Thaw ",
    type = "meta",
    description = "The frost has melted. Rain is frequent, and planting season has begun.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Spring" 
    end,
    effects = {
        ["Farming"] = { price = 2.0, vol = 0.5 },   -- Everyone needs seeds NOW
        ["Water"] = { price = 0.2, vol = 3.0 },     -- Rain collectors are full
        ["Fish"] = { price = 0.8, vol = 2.0 },      -- Rivers are active
        ["Clothing"] = { price = 1.2 }              -- Waterproof gear needed
    },
    inject = { ["Farming"] = 5 }
})

-- =============================================================================
-- ERA: NATURE'S RECLAMATION (Starts ~100 Days)
-- =============================================================================
-- Concept: Erosion is setting in. Wood is everywhere, but clearing paths is hard.
DynamicTrading.Events.Register("NatureReclamation", {
    name = "Overgrowth",
    type = "meta",
    description = "Vegetation is reclaiming the cities. Wood is abundant; clear paths are not.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 100
    end,
    effects = {
        ["Wood"] = { price = 0.2, vol = 5.0 },      -- Trees are everywhere
        ["Blade"] = { price = 1.5 },                -- Machetes needed to clear vines
        ["Herb"] = { price = 0.5, vol = 3.0 },      -- Foraging is easier
        ["Game"] = { vol = 1.5 }                    -- Animals entering cities
    }
})


-- #############################################################################
-- META NEGATIVE
-- (Permanent/Seasonal conditions that challenge the player, Sorted by Start Time)
-- #############################################################################

-- [NEGATIVE] Winter season. Fresh food is rare, heat is expensive.
DynamicTrading.Events.Register("Winter", {
    name = "Deep Freeze",
    type = "meta",
    description = "It's freezing. Warm clothes and heat sources are essential.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Winter" 
    end,
    effects = {
        ["Fresh"] = { price = 3.0, vol = 0.1 },
        ["Fuel"] = { price = 1.5 }, 
        ["Winter"] = { price = 2.5, vol = 1.0 },
        ["Material"] = { price = 1.5 },
        ["Camping"] = { price = 1.2 }
    },
    inject = { ["Winter"] = 3, ["Survival"] = 2 }
})

-- [NEGATIVE] Summer drought. Water expensive, winter clothes useless.
DynamicTrading.Events.Register("Heatwave", {
    name = "Severe Drought",
    type = "meta",
    description = "A scorching heatwave. Hydration is key.",
    condition = function() 
        if not SandboxVars.DynamicTrading.AllowSeasonalEvents then return false end
        return ClimateManager:getInstance():getSeasonName() == "Summer" 
    end,
    effects = {
        ["Water"] = { price = 2.0 }, 
        ["Drink"] = { price = 1.5 },
        ["Clothing"] = { price = 0.5 },
        ["Winter"] = { price = 0.1, vol = 0.0 }
    }
})

-- [NEGATIVE] Municipal water shutoff. Water becomes expensive. (~14 Days)
DynamicTrading.Events.Register("WaterFail", {
    name = "Drought (Water Shutoff)",
    type = "meta", 
    description = "Municipal water is gone. Bottled water is liquid gold.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.WaterShutModifier or 14)
    end,
    effects = {
        ["Water"] = { price = 5.0, vol = 0.2 },
        ["Drink"] = { price = 2.0 },
        ["Hygiene"] = { price = 1.5 }
    }
})

-- [NEGATIVE] Grid collapse. Fuel/Generators become expensive. (~14 Days)
DynamicTrading.Events.Register("PowerFail", {
    name = "Grid Collapse",
    type = "meta", 
    description = "The power grid is dead. Generators and fuel are critical.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.ElecShutModifier or 14)
    end,
    effects = {
        ["Electronics"] = { price = 2.0 },
        ["Fuel"] = { price = 3.0, vol = 0.5 },
        ["Light"] = { price = 1.5 },
        ["Generator"] = { price = 4.0, vol = 0.1 },
        ["Battery"] = { price = 2.5 }
    }
})

-- =============================================================================
-- ERA: THE GREAT ROT (Starts ~1 Month / 30 Days)
-- =============================================================================
-- Concept: The power is definitely out. All perishable food in the world has rotted.
DynamicTrading.Events.Register("GreatRot", {
    name = "The Great Rot",
    type = "meta",
    description = "Refrigeration is a memory. Scavenging fresh food is no longer possible.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 30
    end,
    effects = {
        ["Fresh"] = { price = 5.0, vol = 0.05 },    -- Traders almost never have it
        ["Rotten"] = { price = 0.0 },               -- Worthless
        ["Salt"] = { price = 2.0 },                 -- If item exists (Spice)
        ["Spice"] = { price = 1.5 }                 -- To mask the taste of bad meat
    }
})

-- =============================================================================
-- ERA: HYGIENE COLLAPSE (Starts ~2 Months / 60 Days)
-- =============================================================================
-- Concept: Manufactured soap and bleach have run out. Infection risk is high.
DynamicTrading.Events.Register("HygieneCollapse", {
    name = "Sanitation Failure",
    type = "meta",
    description = "Soap supplies are exhausted. Infection risks are rising.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 60
    end,
    effects = {
        ["Hygiene"] = { price = 4.0, vol = 0.1 },   -- Soap is incredibly expensive
        ["Clean"] = { price = 3.0 },                -- Bleach
        ["Medical"] = { price = 1.2 },              -- Antibiotics demand up
        ["Chemical"] = { price = 2.0 }              -- To make homemade soap
    }
})

-- =============================================================================
-- ERA 1: BALLISTIC EXHAUSTION (Starts ~3 Months / 90 Days)
-- =============================================================================
-- Concept: Factory-made ammo is drying up. Guns are becoming clubs.
DynamicTrading.Events.Register("BallisticExhaustion", {
    name = "Ballistic Exhaustion",
    type = "meta",
    description = "The world's ammo reserves are running dry. Bullets are a luxury.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 90 
    end,
    effects = {
        ["Ammo"] = { price = 4.0, vol = 0.3 },      -- Extremely expensive and rare
        ["Gun"] = { price = 0.4 },                  -- Useless without ammo
        ["Gunrunner"] = { price = 0.5 },            -- Losing business
        ["Spear"] = { price = 1.5, vol = 2.0 },     -- Primitive weapons rise
        ["Blade"] = { price = 1.5, vol = 2.0 },
        ["Heavy"] = { price = 1.5 }                 -- Blunt weapons
    }
})

-- =============================================================================
-- ERA 2: THE MANUFACTURING HALT (Starts ~4 Months / 120 Days)
-- =============================================================================
-- Concept: Supermarket canned goods are gone. Preservation is life.
DynamicTrading.Events.Register("ManufacturingHalt", {
    name = "Supply Chain Collapse",
    type = "meta",
    description = "Canned goods are no longer 'common'. Preservation supplies are vital.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 120
    end,
    effects = {
        ["Canned"] = { price = 2.5, vol = 0.4 },    -- Rare luxury
        ["Farming"] = { price = 0.8, vol = 2.0 },   -- Everyone is farming now
        ["Spice"] = { price = 3.0 },                -- Salt/Vinegar for jars
        ["Preservation"] = { price = 3.0, vol = 0.5 }, -- Jars/Lids
        ["Fresh"] = { price = 1.0 }                 -- Normal price, but demand is high
    },
    inject = { ["Farming"] = 4 } -- Traders stock seeds to survive
})

-- =============================================================================
-- ERA: THE KNOWLEDGE GAP (Starts ~6 Months / 180 Days)
-- =============================================================================
-- Concept: Books are rotting or have been burned for fuel. Education is dying.
DynamicTrading.Events.Register("KnowledgeGap", {
    name = "Literacy Crisis",
    type = "meta",
    description = "Technical manuals are degrading or lost. Knowledge is becoming the ultimate currency.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 180
    end,
    effects = {
        ["SkillBook"] = { price = 3.5, vol = 0.2 }, -- Extremely rare/expensive
        ["Literature"] = { price = 2.0 },           -- Entertainment is precious
        ["Paper"] = { price = 1.5 },                -- For writing new notes
        ["Scholastic"] = { price = 2.5 }
    }
})

-- =============================================================================
-- ERA 3: THE IRON AGE (Starts ~8 Months / 240 Days)
-- =============================================================================
-- Concept: High-quality steel tools are breaking. Repair items are crucial.
DynamicTrading.Events.Register("IronAge", {
    name = "Tool Scarcity",
    type = "meta",
    description = "Refined steel tools are breaking down. Repairs and smithing are essential.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 240
    end,
    effects = {
        ["Tool"] = { price = 2.0, vol = 0.6 },      -- Hard to find good tools
        ["Heavy"] = { price = 3.0, vol = 0.2 },     -- Sledgehammers are mythical
        ["Repair"] = { price = 3.0, vol = 1.5 },    -- Glue, Duct Tape
        ["Smithing"] = { price = 1.5, vol = 2.0 },  -- Blacksmithing rises
        ["Junk"] = { price = 0.5 }                  -- Scrap is everywhere, but useless without skill
    }
})

-- =============================================================================
-- ERA 4: THE FUEL CRISIS (Starts ~1 Year / 365 Days)
-- =============================================================================
-- Concept: Gas stations are dry or degraded. The age of the automobile is ending.
DynamicTrading.Events.Register("FuelCrisis", {
    name = "The Fuel Crisis",
    type = "meta",
    description = "Gasoline reserves have degraded. Combustion engines are becoming obsolete.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 365
    end,
    effects = {
        ["Fuel"] = { price = 5.0, vol = 0.1 },      -- Liquid Gold
        ["CarPart"] = { price = 0.5 },              -- Useless without gas
        ["Generator"] = { price = 0.5 },            -- Useless without gas
        ["Battery"] = { price = 2.5, vol = 1.5 },   -- Solar/Electric becomes king
        ["Electronics"] = { price = 1.5 }           -- For repairing batteries/solar
    }
})

-- =============================================================================
-- ERA 5: SIGNAL DECAY (Starts ~1 Year / 365 Days)
-- =============================================================================
-- Concept: The trader network is fracturing. Finding a trader is harder, but they are richer.
DynamicTrading.Events.Register("SignalDecay", {
    name = "Network Fragmentation",
    type = "meta",
    description = "Repeater towers are failing. Signals are rare, but survivors are veterans.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 365
    end,
    system = {
        scanChance = 0.7,   -- -30% Chance to find a signal
        traderLimit = 0.8,  -- -20% Total Traders
        globalStock = 1.5   -- But the traders you find have +50% loot (Veterans)
    },
    effects = {
        ["Communication"] = { price = 2.0 },        -- High quality radios needed
        ["Luxury"] = { price = 1.5 }                -- Veterans trade in high value items
    }
})


-- #############################################################################
-- FLASH POSITIVE
-- (Temporary events that benefit the player)
-- #############################################################################

-- [POSITIVE] Cheap military gear.
DynamicTrading.Events.Register("Surplus", {
    name = "Military Surplus",
    type = "flash",
    description = "A military bunker was raided. Gear is everywhere.",
    canSpawn = function() return true end,
    system = { globalStock = 1.5 },
    effects = {
        ["Gun"] = { price = 0.6, vol = 2.0 },
        ["Ammo"] = { price = 0.5, vol = 3.0 },
        ["Military"] = { price = 0.7, vol = 2.0 },
        ["Tactical"] = { price = 0.7 }
    },
    inject = { ["Ammo"] = 5, ["Military"] = 3 }
})

-- [POSITIVE] Cheap meds.
DynamicTrading.Events.Register("HospitalFound", {
    name = "Pharmacy Raid",
    type = "flash",
    description = "A hospital was looted. Meds are cheap.",
    canSpawn = function() return true end,
    effects = {
        ["Medical"] = { price = 0.3, vol = 5.0 },
        ["Pill"] = { price = 0.4, vol = 4.0 },
        ["Sterile"] = { price = 0.5 }
    },
    inject = { ["Medical"] = 8 }
})

-- [POSITIVE] Cheap fish.
DynamicTrading.Events.Register("FishingTourney", {
    name = "Salmon Run",
    type = "flash",
    description = "Fish are biting like crazy!",
    canSpawn = function() return true end,
    effects = {
        ["Fish"] = { price = 0.5, vol = 3.0 },
        ["Bait"] = { price = 1.5, vol = 0.5 },
        ["Food"] = { price = 0.9 }
    },
    inject = { ["Fish"] = 5 }
})

-- [POSITIVE] Cheap meat.
DynamicTrading.Events.Register("HuntingSeason", {
    name = "Migration",
    type = "flash",
    description = "Wild game is migrating through the area.",
    canSpawn = function() return true end,
    effects = {
        ["Game"] = { price = 0.5, vol = 3.0 },
        ["Meat"] = { price = 0.6, vol = 2.0 },
        ["Trapping"] = { price = 1.5 },
        ["Leather"] = { price = 0.5 }
    },
    inject = { ["Game"] = 4, ["Trapping"] = 2 }
})

-- [POSITIVE] High demand for materials (Good for selling).
DynamicTrading.Events.Register("ConstructionBoom", {
    name = "Fortification Effort",
    type = "flash",
    description = "Everyone is reinforcing their bases.",
    canSpawn = function() return true end,
    effects = {
        ["Material"] = { price = 2.0, vol = 0.5 },
        ["Wood"] = { price = 1.8 },
        ["Build"] = { price = 1.8 },
        ["Tool"] = { price = 1.5 },
        ["Heavy"] = { price = 1.5 }
    }
})

-- [POSITIVE] Cheap materials and junk.
DynamicTrading.Events.Register("SalvageOp", {
    name = "Urban Salvage",
    type = "flash",
    description = "Scavengers cleared a warehouse.",
    canSpawn = function() return true end,
    effects = {
        ["Material"] = { price = 0.5, vol = 4.0 },
        ["Junk"] = { price = 0.1, vol = 5.0 },
        ["Electronics"] = { price = 0.8 },
        ["Metal"] = { price = 0.6 }
    },
    inject = { ["Material"] = 5 }
})

-- [POSITIVE] High sell price for Gold/Jewelry.
DynamicTrading.Events.Register("GoldRush", {
    name = "Gold Panic",
    type = "flash",
    description = "Survivors are hoarding precious metals.",
    canSpawn = function() return true end,
    effects = {
        ["Gold"] = { price = 3.0 },
        ["Silver"] = { price = 2.5 },
        ["Jewelry"] = { price = 2.0 },
        ["Luxury"] = { price = 1.5 }
    }
})

-- [POSITIVE] Vices available cheap.
DynamicTrading.Events.Register("Smugglers", {
    name = "Black Market Surge",
    type = "flash",
    description = "The underground market is active.",
    canSpawn = function() return true end,
    effects = {
        ["Alcohol"] = { price = 0.6, vol = 2.0 },
        ["Tobacco"] = { price = 0.6, vol = 2.0 },
        ["Jewelry"] = { price = 0.5 },
        ["Illegal"] = { price = 0.5, vol = 2.0 }
    }
})

-- [POSITIVE] Party items cheap.
DynamicTrading.Events.Register("Celebration", {
    name = "New World Festival",
    type = "flash",
    description = "Survivors are gathering to party.",
    canSpawn = function() return true end,
    effects = {
        ["Alcohol"] = { price = 2.0, vol = 0.2 },
        ["Sweets"] = { price = 2.0 },
        ["Music"] = { price = 2.0 },
        ["Fun"] = { price = 2.0 },
        ["Cosmetic"] = { price = 1.5 }
    }
})

-- [POSITIVE] Books and paper.
DynamicTrading.Events.Register("SchoolStart", {
    name = "Education Initiative",
    type = "flash",
    description = "Communities are rebuilding schools.",
    canSpawn = function() return true end,
    effects = {
        ["Scholastic"] = { price = 2.5, vol = 0.2 },
        ["Literature"] = { price = 1.5 },
        ["SkillBook"] = { price = 1.5 },
        ["Paper"] = { price = 2.0 }
    },
    inject = { ["Scholastic"] = 4 }
})

-- [POSITIVE] Cheap Electronics.
DynamicTrading.Events.Register("TechBoom", {
    name = "Old World Cache",
    type = "flash",
    description = "A shipment of electronics was found.",
    canSpawn = function() return true end,
    effects = {
        ["Electronics"] = { price = 0.4, vol = 3.0 },
        ["Common"] = { price = 0.5, vol = 2.0 }, -- Generic parts
        ["Communication"] = { price = 0.5, vol = 2.0 }
    },
    inject = { ["Electronics"] = 4 }
})

-- [POSITIVE] Car parts.
DynamicTrading.Events.Register("MechanicFair", {
    name = "Auto Meet",
    type = "flash",
    description = "Mechanics are trading parts freely.",
    canSpawn = function() return true end,
    effects = {
        ["CarPart"] = { price = 0.6, vol = 3.0 },
        ["Mechanic"] = { price = 0.8, vol = 2.0 },
        ["Tool"] = { price = 0.9 },
        ["Fuel"] = { price = 1.2 }
    },
    inject = { ["CarPart"] = 5 }
})

-- [POSITIVE] Cheap items across the board.
DynamicTrading.Events.Register("FireSale", {
    name = "Liquidation",
    type = "flash",
    description = "Traders are offloading stock cheap.",
    canSpawn = function() return true end,
    effects = {
        ["Misc"] = { price = 0.5, vol = 1.5 },
        ["Luxury"] = { price = 1.5 },
        ["Junk"] = { price = 0.1 }
    }
})

-- [POSITIVE] Massive boost to finding traders.
DynamicTrading.Events.Register("CaravanArrival", {
    name = "Trader Caravan",
    type = "flash",
    description = "A massive convoy of traders is passing through the region.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 2.0, -- Double the daily limit
        scanChance = 1.2   -- +20% Scan chance
    },
    effects = {
        ["General"] = { price = 0.8, vol = 2.0 },
        ["Food"] = { vol = 1.5 },
        ["Material"] = { vol = 1.5 }
    }
})

-- [POSITIVE] High scan chance.
DynamicTrading.Events.Register("AtmosphericClear", {
    name = "Ionospheric Clarity",
    type = "flash",
    description = "Perfect atmospheric conditions. Radio signals are crystal clear.",
    canSpawn = function() return true end,
    system = {
        scanChance = 2.0, -- Double scan chance (Easy mode)
    },
    effects = {
        ["Communication"] = { price = 1.2 }, -- Good radios in demand to use the clear air
        ["Electronics"] = { price = 1.1 }
    }
})

-- [POSITIVE] More traders, specific to Ham Radios.
DynamicTrading.Events.Register("RadioClub", {
    name = "Ham Radio Meetup",
    type = "flash",
    description = "The old Ham Radio operators are active tonight.",
    canSpawn = function() return true end,
    system = {
        scanChance = 1.5,
        traderLimit = 1.5
    },
    effects = {
        ["Communication"] = { price = 0.5, vol = 3.0 }, -- Radios are cheap
        ["Component"] = { vol = 2.0 },
        ["Battery"] = { vol = 2.0 }
    },
    inject = { ["Communication"] = 3 }
})

-- [POSITIVE] Emergency broadcast makes finding signals trivial.
DynamicTrading.Events.Register("EmergencyNet", {
    name = "Emergency Broadcast",
    type = "flash",
    description = "The automated emergency network is pinging all active stations.",
    canSpawn = function() return true end,
    system = {
        scanChance = 1.8,
        traderLimit = 1.2
    },
    effects = {
        ["Medical"] = { price = 0.8 },
        ["Safety"] = { price = 0.8 },
        ["Survival"] = { price = 0.8 }
    }
})

-- [POSITIVE] Economic boom.
DynamicTrading.Events.Register("FreeMarket", {
    name = "Free Market Day",
    type = "flash",
    description = "Traders are actively broadcasting to sell stock.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 1.8 -- Almost double traders
    },
    effects = {
        ["Luxury"] = { price = 1.2, vol = 1.5 },
        ["Money"] = { price = 1.5 }, -- If currency items exist
        ["General"] = { price = 0.9, vol = 1.5 }
    }
})


-- #############################################################################
-- FLASH NEGATIVE
-- (Temporary events that challenge the player)
-- #############################################################################

-- [NEGATIVE] War. Fewer traders, expensive guns/ammo.
DynamicTrading.Events.Register("Warzone", {
    name = "Faction Conflict",
    type = "flash",
    description = "War has broken out. Traders are hiding, ammo is scarce.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = { traderLimit = 0.5 },
    effects = {
        ["Gun"] = { price = 2.5, vol = 0.5 },
        ["Ammo"] = { price = 3.0, vol = 0.2 },
        ["Medical"] = { price = 1.5 },
        ["Armor"] = { price = 2.0 }
    }
})

-- [NEGATIVE] Sickness. Meds expensive, food expensive.
DynamicTrading.Events.Register("Outbreak", {
    name = "Viral Outbreak",
    type = "flash",
    description = "A sickness spreads. Medicine is critical.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Medical"] = { price = 3.5, vol = 0.2 },
        ["Pill"] = { price = 3.0 },
        ["Hygiene"] = { price = 2.5 },
        ["Food"] = { price = 1.2 }
    }
})

-- [NEGATIVE] Crop failure. Food very expensive.
DynamicTrading.Events.Register("Famine", {
    name = "Crop Blight",
    type = "flash",
    description = "Crops have died. Food prices skyrocket.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Food"] = { price = 2.5, vol = 0.3 },
        ["Farming"] = { price = 3.0 },
        ["Canned"] = { price = 2.0 },
        ["Fresh"] = { price = 4.0, vol = 0.1 }
    }
})

-- [NEGATIVE] No gas. Cars and generators useless.
DynamicTrading.Events.Register("FuelShortage", {
    name = "Refinery Explosion",
    type = "flash",
    description = "Fuel production has halted.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Fuel"] = { price = 4.0, vol = 0.1 },
        ["CarPart"] = { price = 0.5 },
        ["Generator"] = { price = 0.5 }
    }
})

-- [NEGATIVE] Bandits. Weapons and Security needed.
DynamicTrading.Events.Register("CrimeWave", {
    name = "Looter Gangs",
    type = "flash",
    description = "Bandits are raiding. Locks and weapons needed.",
    canSpawn = function() return true end,
    effects = {
        ["Police"] = { price = 2.0, vol = 0.5 },
        ["Weapon"] = { price = 1.5 },
        ["Gun"] = { price = 1.5 },
        ["Safety"] = { price = 2.0 } -- Found in DT_Household
    }
})

-- [NEGATIVE] Hard to scan for traders.
DynamicTrading.Events.Register("SolarFlare", {
    name = "Solar Flare",
    type = "flash",
    description = "Atmospheric interference hits radios.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.4,
        traderLimit = 0.8
    },
    effects = {
        ["Communication"] = { price = 3.0 },
        ["Electronics"] = { price = 0.5 }
    }
})

-- [NEGATIVE] Money loses value. Prices double.
DynamicTrading.Events.Register("Inflation", {
    name = "Market Panic",
    type = "flash",
    description = "Currency is losing value rapidly.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    effects = {
        ["Misc"] = { price = 2.0 },
        ["Luxury"] = { price = 0.2 }
    }
})

-- [NEGATIVE] Very hard to scan.
DynamicTrading.Events.Register("SignalJamming", {
    name = "Military Jamming",
    type = "flash",
    description = "A rogue military signal is drowning out all traffic.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        scanChance = 0.3, -- -70% Chance to find anyone
        traderLimit = 0.8
    },
    effects = {
        ["Communication"] = { price = 3.0 }, -- Better radios needed to punch through
        ["Military"] = { price = 0.5 }, -- Maybe they are selling surplus?
        ["Electronics"] = { price = 2.0 }
    }
})

-- [NEGATIVE] Traders leave the network.
DynamicTrading.Events.Register("WitchHunt", {
    name = "Radio Silence",
    type = "flash",
    description = "Someone is hunting broadcasters. Traders have gone dark.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        traderLimit = 0.3, -- Only 30% of normal traders available
        scanChance = 0.8
    },
    effects = {
        ["Weapon"] = { price = 1.5 },
        ["Security"] = { price = 2.0 },
        ["Communication"] = { price = 0.5, vol = 0.2 } -- Dumping gear to hide
    }
})

-- [NEGATIVE] Weather interference.
DynamicTrading.Events.Register("ElectricalStorm", {
    name = "Thunderstorm Interference",
    type = "flash",
    description = "Heavy static makes long-range comms impossible.",
    canSpawn = function() return true end,
    system = {
        scanChance = 0.5
    },
    effects = {
        ["Battery"] = { price = 2.0 },
        ["Light"] = { price = 1.5 },
        ["Electronics"] = { price = 1.5 }
    }
})

-- [NEGATIVE] Traders are scarce due to logistics.
DynamicTrading.Events.Register("BridgeCollapse", {
    name = "Logistics Failure",
    type = "flash",
    description = "A major trade route collapsed. Fewer traders can reach range.",
    canSpawn = function() return true end,
    system = {
        traderLimit = 0.6,
        globalStock = 0.7 -- Less items overall too
    },
    effects = {
        ["Fuel"] = { price = 2.5 },
        ["Heavy"] = { price = 2.0 },
        ["CarPart"] = { price = 2.0 }
    }
})

-- [MIXED] Easier to find signals, but fewer traders (Crowded airwaves).
DynamicTrading.Events.Register("PanicBroadcast", {
    name = "Mass Panic",
    type = "flash",
    description = "Everyone is screaming over the radio. Signals are everywhere but chaotic.",
    canSpawn = function() return SandboxVars.DynamicTrading.AllowHardcoreEvents end,
    system = {
        scanChance = 1.5, -- Easy to hear *something*
        traderLimit = 0.5 -- Hard to find a *useful trader* amidst the noise
    },
    effects = {
        ["Weapon"] = { price = 2.0 },
        ["Food"] = { price = 2.0 },
        ["Medical"] = { price = 2.0 }
    }
})

print("[DynamicTrading] Events Initialized.")