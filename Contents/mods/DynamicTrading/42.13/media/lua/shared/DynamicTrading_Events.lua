require "DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = {}
DynamicTrading.Events.Registry = {}
DynamicTrading.Events.ActiveEvents = {} -- Stores currently active event IDs

-- =============================================================================
-- 1. REGISTRATION API
-- =============================================================================
-- id: Unique String (e.g., "Harvest")
-- data: {
--    name = "Harvest Season",
--    condition = function() return ... end,
--    effects = { ["Tag"] = {price=0.5, vol=2.0} },
--    inject = { ["Tag"] = count } -- Force these items into shops
-- }
function DynamicTrading.Events.Register(id, data)
    if not id or not data then return end
    DynamicTrading.Events.Registry[id] = data
    print("[DynamicTrading] Event Registered: " .. id)
end

-- =============================================================================
-- 2. STATE MANAGER (Update Loop)
-- =============================================================================
-- Call this once per day (from Manager) to update what events are running.
function DynamicTrading.Events.CheckEvents()
    DynamicTrading.Events.ActiveEvents = {}
    
    for id, event in pairs(DynamicTrading.Events.Registry) do
        local isActive = false
        
        -- Run the condition function
        if event.condition then
            -- Wrap in pcall to prevent crashes if a condition errors out
            local ok, result = pcall(event.condition)
            if ok and result then isActive = true end
        end
        
        if isActive then
            table.insert(DynamicTrading.Events.ActiveEvents, event)
            -- print("[DynamicTrading] Active Event: " .. (event.name or id))
        end
    end
end

-- =============================================================================
-- 3. ECONOMY HOOKS (Getters)
-- =============================================================================

-- CALCULATE PRICE MULTIPLIER
-- Returns a float (e.g., 1.5) based on all active events for these tags.
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

-- CALCULATE VOLUME MULTIPLIER (Stock Quantity)
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

-- GET INJECTIONS (For Stock Generator)
-- Returns a table of tags that MUST be added to the shop.
-- e.g., { ["Crop"] = 5, ["Turkey"] = 2 }
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

-- =============================================================================
-- 4. DEFAULT EVENTS
-- =============================================================================
local function InitEvents()
    local CM = ClimateManager:getInstance()
    local GT = GameTime:getInstance()

    -- EVENT: HARVEST SEASON (Autumn)
    -- Logic: Crops are cheap and abundant. Shops are forced to stock them.
    DynamicTrading.Events.Register("Harvest", {
        name = "Harvest Season",
        condition = function()
            local season = ClimateManager:getInstance():getSeasonName()
            return season == "Autumn"
        end,
        effects = {
            ["Food"] = { price = 0.8 },      -- All food slightly cheaper
            ["Vegetable"] = { price = 0.5, vol = 3.0 }, -- Veggies dirt cheap
            ["Seed"] = { price = 1.5 }       -- Seeds expensive (saving for next year)
        },
        inject = {
            ["Vegetable"] = 5, -- Force 5 slots of Veggies in EVERY shop
            ["Pickle"] = 2
        }
    })

    -- EVENT: HARSH WINTER
    -- Logic: Fresh food is rare/expensive. Fuel is gold.
    DynamicTrading.Events.Register("Winter", {
        name = "Harsh Winter",
        condition = function()
            return ClimateManager:getInstance():getSeasonName() == "Winter"
        end,
        effects = {
            ["Fresh"] = { price = 2.0, vol = 0.2 }, -- Fresh food scarce
            ["Fuel"] = { price = 1.5, vol = 1.5 },  -- High demand for heating
            ["Warm"] = { price = 1.5, vol = 1.0 }   -- Warm clothes expensive
        },
        inject = {
            ["Winter"] = 2 -- Force specific "Winter" tagged items (Parkas, Heaters)
        }
    })

    -- EVENT: HYPER INFLATION (Random Chaos)
    -- Logic: 5% chance any day to spike prices.
    DynamicTrading.Events.Register("Inflation", {
        name = "Market Panic",
        condition = function()
            local day = math.floor(GameTime:getInstance():getDaysSurvived())
            -- Deterministic random based on day ID (so it stays all day)
            local rnd = ZombRandFloat(day * 0.5, (day + 1) * 0.5) 
            return rnd < 0.05
        end,
        effects = {
            ["Food"] = { price = 1.5 },
            ["Ammo"] = { price = 2.0 },
            ["Weapon"] = { price = 2.0 }
        }
    })
    
    print("[DynamicTrading] Default Events Initialized.")
end

Events.OnGameBoot.Add(InitEvents)