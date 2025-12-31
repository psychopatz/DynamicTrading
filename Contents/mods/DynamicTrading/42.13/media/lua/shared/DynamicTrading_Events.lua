-- ==========================================================
-- File: Contents\mods\DynamicTrading\42.13\media\lua\shared\DynamicTrading_Events.lua
-- ==========================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = {}
DynamicTrading.Events.Registry = {}

print("[DynamicTrading] Loading Meta Events System...")

-- =================================================
-- API: REGISTER EVENT
-- =================================================
-- Allows you (or other modders) to add new market events.
--
-- id: Unique String Identifier (e.g., "Winter")
-- data: Table containing:
--    name      = Display Name (for Debug)
--    rumor     = String shown in the Shop UI when active
--    condition = Function returning true/false
--    effects   = Table of Tag-based modifiers
--
-- Example Effect Format:
-- effects = {
--    TagName = { price = 1.5, volume = 0.5 } 
-- }
function DynamicTrading.Events.Register(id, data)
    if not id or not data then return end
    DynamicTrading.Events.Registry[id] = data
    print("[DynamicTrading] Event Registered: " .. id)
end

-- =================================================
-- LOGIC: GET STACKED MODIFIERS
-- =================================================
-- Checks all registered events. If their condition is true, 
-- combines their effects multiplicatively.
--
-- Input: tags (Table/Array of strings) - The tags of the item being checked
-- Returns: { price = float, volume = float, rumors = {string, string...} }
function DynamicTrading.Events.GetActiveState(tags)
    local result = { price = 1.0, volume = 1.0, rumors = {} }
    local activeEvents = {}

    -- 1. Identify Active Events First
    -- We loop through the registry to find what is currently happening in the world.
    for id, event in pairs(DynamicTrading.Events.Registry) do
        -- Execute the condition function safely
        local isActive = false
        if event.condition then
            local status, retval = pcall(event.condition)
            if status and retval then isActive = true end
        end

        if isActive then
            table.insert(activeEvents, event)
            
            -- Collect Rumor Text
            if event.rumor then
                local exists = false
                for _, r in ipairs(result.rumors) do 
                    if r == event.rumor then exists = true break end 
                end
                if not exists then table.insert(result.rumors, event.rumor) end
            end
        end
    end

    -- 2. Calculate Modifiers based on Tags
    -- If no tags are provided (e.g. just checking for rumors), skip this.
    if tags and #tags > 0 then
        for _, event in ipairs(activeEvents) do
            if event.effects then
                for _, tag in ipairs(tags) do
                    if event.effects[tag] then
                        local mod = event.effects[tag]
                        
                        -- Apply Price Multiplier
                        if mod.price then 
                            result.price = result.price * mod.price 
                        end
                        
                        -- Apply Volume (Stock/Demand) Multiplier
                        if mod.volume then 
                            result.volume = result.volume * mod.volume 
                        end
                    end
                end
            end
        end
    end

    -- 3. Safety Clamps
    -- Prevent the economy from crashing to 0 or exploding to infinity due to stacking.
    if result.price < 0.1 then result.price = 0.1 end
    if result.price > 10.0 then result.price = 10.0 end
    
    if result.volume < 0.1 then result.volume = 0.1 end
    if result.volume > 10.0 then result.volume = 10.0 end

    return result
end

-- =================================================
-- DEFAULT EVENTS DEFINITION
-- =================================================
-- These are the built-in events.
local function InitDefaultEvents()
    local CM = ClimateManager:getInstance()
    local GT = GameTime:getInstance()

    -- 1. EVENT: HARSH WINTER
    -- Logic: Standard Season Check
    DynamicTrading.Events.Register("Winter", {
        name = "Harsh Winter",
        rumor = "It's freezing outside. Food and fuel are becoming scarce.",
        condition = function() 
            return CM:getSeasonName() == "Winter" 
        end,
        effects = {
            Fresh = { price = 1.5, volume = 0.5 }, -- Fresh food is rare and expensive
            Crop  = { price = 1.5, volume = 0.5 },
            Warm  = { price = 1.2, volume = 2.0 }, -- Warm clothes: High Demand (Vol), Price up slightly
            Fuel  = { price = 1.3, volume = 1.5 }, -- Fuel: High Demand, Price up
        }
    })

    -- 2. EVENT: POWER OUTAGE
    -- Logic: Checks if days survived > sandbox shutdown setting
    DynamicTrading.Events.Register("PowerOutage", {
        name = "Grid Failure",
        rumor = "The grid has failed. Generators are worth their weight in gold.",
        condition = function() 
            local shut = SandboxVars.ElecShutModifier or 14
            -- Check if electricity is actually shut off
            return (GT:getNightsSurvived() > shut) and (shut > -1)
        end,
        effects = {
            Fuel = { price = 1.8, volume = 2.5 },      -- Panic buying of fuel
            Generator = { price = 2.5, volume = 2.0 }, -- Generators skyrocket
            Cold = { price = 0.2, volume = 0.1 },      -- Meltable food (Ice cream) is worthless
            Electronics = { price = 1.2, volume = 1.2 }, -- Batteries etc.
        }
    })

    -- 3. EVENT: FUEL SHORTAGE (Monthly)
    -- Logic: Active every 4th week (Days 21-28, 49-56, etc.)
    DynamicTrading.Events.Register("FuelShortage", {
        name = "Fuel Shortage",
        rumor = "Supply lines are cut. There's no gas coming into the sector.",
        condition = function()
            local day = GT:getDaysSurvived()
            local week = math.floor(day / 7)
            -- Modulo 4 means it happens every 4 weeks. 
            -- We check if the current week index is a multiple of 4.
            return (week > 0) and ((week % 4) == 0)
        end,
        effects = {
            Fuel = { price = 2.5, volume = 3.0 }, -- Extreme demand
            Car  = { price = 0.6, volume = 0.5 }, -- Cars are useless without gas
        }
    })
    
    -- 4. EVENT: HORDE MIGRATION (Random/Periodic)
    -- Logic: Uses a pseudo-random seed based on the Day ID to ensure
    -- the event stays active for the whole day (doesn't flicker on/off).
    DynamicTrading.Events.Register("HordeMigration", {
        name = "Horde Migration",
        rumor = "Massive herds reported nearby. Stock up on ammunition.",
        condition = function()
            local day = math.floor(GT:getDaysSurvived())
            -- Deterministic Random: Seed using the Day number
            local rnd = ZombRandFloat(day * 0.123, (day + 1) * 0.123) 
            
            -- 15% chance of occurring on any given day
            return rnd < 0.15 
        end,
        effects = {
            Ammo = { price = 1.5, volume = 2.0 },    -- High Price, High Demand
            Gun = { price = 1.3, volume = 1.5 },
            Medical = { price = 1.4, volume = 1.5 }, -- Prepare for injury
            Weapon = { price = 1.2, volume = 1.2 },
        }
    })
    
    print("[DynamicTrading] Default Events Initialized.")
end

-- Initialize events when the game boots up
Events.OnGameBoot.Add(InitDefaultEvents)