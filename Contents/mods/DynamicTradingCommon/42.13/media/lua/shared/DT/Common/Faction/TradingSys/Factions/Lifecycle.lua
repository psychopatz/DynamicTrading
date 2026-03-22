-- ==============================================================================
-- Factions/Lifecycle.lua
-- Logic: Faction Initialization, Creation, and Roster Generation.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/Templates/BaseSpawn/DT_FactionLocationManager"
require "DT/Common/Faction/Templates/FactionNames/DT_FactionNames"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"

local Lifecycle = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function Lifecycle.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end

    local data = ModData.get(MOD_DATA_KEY)
    
    -- 1. Create the nomadic failsafe faction if it doesn't exist
    if not data["Independent"] then
        DynamicTrading_Factions.CreateFaction("Independent", {
            memberCount = 10,
            isNomadic = true
        })
    end

    -- 2. Check if we need to repopulate towns
    -- We do this if ONLY "Independent" exists or if there are NO town factions
    local townFactionCount = 0
    for id, f in pairs(data) do
        if id ~= "Independent" then
            townFactionCount = townFactionCount + 1
        end
    end

    if townFactionCount == 0 then
        DynamicTrading.Log("DTCommons", "Init", "Faction", "No town factions found, triggering initial population")
        DynamicTrading_Factions.RepopulateTowns()
    end

    -- 3. Data Integrity: Ensure proper data types for existing factions
    for id, f in pairs(data) do
        -- Fallback: ensure reputation is a table
        if type(f.reputation) ~= "table" then
            f.reputation = {}
        end
        
        if type(f.wealth) ~= "number" then
            f.wealth = 1000
        end

        -- Phase-A schema prep: support new list format while keeping legacy field for compatibility.
        if type(f.ActiveFlashEvents) ~= "table" then
            f.ActiveFlashEvents = {}
        end

        -- Migrate legacy single-event field into list once.
        if f.ActiveFlashEvent and f.ActiveFlashEvent.id and #f.ActiveFlashEvents == 0 then
            table.insert(f.ActiveFlashEvents, {
                id = f.ActiveFlashEvent.id,
                expires = f.ActiveFlashEvent.expires or 0,
                targetCasualties = f.ActiveFlashEvent.targetCasualties or 0
            })
        end

        -- Keep legacy field in sync for existing systems until full multi-flash runtime is merged.
        local first = f.ActiveFlashEvents[1]
        f.ActiveFlashEvent = {
            id = first and first.id or nil,
            expires = first and (first.expires or 0) or 0,
            targetCasualties = first and (first.targetCasualties or 0) or 0
        }

        if not f.consecutiveStableDays then
            f.consecutiveStableDays = 0
        end

        if f.playerOwned then
            f.leaderUsername = f.leaderUsername or "local"
            f.leadershipState = f.leadershipState or "Active"
            f.regencyReason = f.regencyReason or nil
            f.controlMode = f.controlMode or "HybridManual"
            f.linkedWorkerIDs = type(f.linkedWorkerIDs) == "table" and f.linkedWorkerIDs or {}
            f.tradeEligibleWorkerIDs = type(f.tradeEligibleWorkerIDs) == "table" and f.tradeEligibleWorkerIDs or {}
            f.activeTradeWorkerIDs = type(f.activeTradeWorkerIDs) == "table" and f.activeTradeWorkerIDs or {}
            f.tradeWorkerSouls = type(f.tradeWorkerSouls) == "table" and f.tradeWorkerSouls or {}
            f.createdDay = tonumber(f.createdDay) or 0
        end
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.RefreshAllPlayerFactions then
        DynamicTrading_Factions.RefreshAllPlayerFactions()
    end

    ModData.transmit(MOD_DATA_KEY)
end

function Lifecycle.RepopulateTowns()
     if DT_FactionLocations then
        for townName, _ in pairs(DT_FactionLocations) do
            local maxFactions = SandboxVars.DynamicTrading.MaxFactionsPerTown or 2
            for i=1, maxFactions do
                -- We generate unique IDs for each faction instance
                local factionID = townName .. "_" .. tostring(100000 + ZombRand(900000))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars.DynamicTrading.FactionStartPop or 3
                })
            end
        end
    end
end

-- ==========================================================
-- 2. FACTION CREATION
-- ==========================================================
function Lifecycle.CreateFaction(factionID, initialData)
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end
    local data = ModData.get(MOD_DATA_KEY)
    initialData = initialData or {}
    
    if not data[factionID] then
        local displayName = ""
        local assignedHome = nil

        -- A. Handle Naming & Home Assignment
        if initialData.playerOwned then
            displayName = tostring(initialData.name or factionID)
            assignedHome = initialData.homeCoords
        elseif factionID == "Independent" or initialData.isNomadic then
            displayName = "Independent Traders"
            assignedHome = nil -- Nomads have no home base
        else
            -- Use our new dynamic naming engine
            displayName = DT_FactionNames.Generate()
            -- Ask the location manager for a physical base
            assignedHome = DT_FactionLocationManager.AssignHome(factionID, initialData.town)
        end

        -- B. Construct the Faction Object
        data[factionID] = {
            id = factionID,
            name = displayName, -- The "flavor" name (The Iron Vanguard)
            town = initialData.town, -- Keep track of which town this faction belongs to
            homeCoords = assignedHome, -- The "physical" base (Rosewood Fire Station)
            stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25 },
            state = initialData.state or "Stable",
            memberCount = initialData.memberCount or (SandboxVars.DynamicTrading.FactionStartPop or 10),
            wealth = initialData.wealth or 1000, -- Stores the total money of all the traders in the faction
            reputation = initialData.reputation or {}, -- [Username] = Integer
            starvationDays = 0, -- Track days without food
            consecutiveStableDays = 0, -- Track how long they've been stable (for wildcard triggers)
            ActiveFlashEvents = {}, -- list of faction flash events (Phase-A schema)
            ActiveFlashEvent = { id = nil, expires = 0, targetCasualties = 0 }, -- legacy compatibility mirror
            playerOwned = initialData.playerOwned == true,
            leaderUsername = initialData.leaderUsername,
            leadershipState = initialData.leadershipState or "Active",
            regencyReason = initialData.regencyReason,
            controlMode = initialData.controlMode or (initialData.playerOwned and "HybridManual" or nil),
            linkedWorkerIDs = initialData.linkedWorkerIDs or {},
            tradeEligibleWorkerIDs = initialData.tradeEligibleWorkerIDs or {},
            activeTradeWorkerIDs = initialData.activeTradeWorkerIDs or {},
            tradeWorkerSouls = initialData.tradeWorkerSouls or {},
            createdDay = tonumber(initialData.createdDay) or 0
        }

        -- Generate Initial Roster in DynamicTrading_Roster
        if not initialData.playerOwned then
            DynamicTrading_Factions.GenerateRoster(factionID)
        end

        ModData.transmit(MOD_DATA_KEY)
        
        local homeLog = assignedHome and ("at " .. assignedHome.name) or "Nomadic"
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Created Faction [" .. factionID .. "] Known as '" .. displayName .. "' " .. homeLog)
    else
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction ID [" .. factionID .. "] already exists in database.")
    end
end

-- ==========================================================
-- 2.1 HELPER: ROSTER GENERATION
-- ==========================================================
function Lifecycle.GenerateRoster(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    local faction = data[factionID]
    if not faction then return end
    
    -- Clear any existing souls if we are generating fresh
    DynamicTrading_Roster.ClearSouls(factionID)
    
    local archetypes = {} 
    for id, _ in pairs(DynamicTrading.Archetypes) do
        table.insert(archetypes, id)
    end
    
    if #archetypes == 0 then return end
    
    local home = faction.homeCoords
    local scatterRange = 10 -- +/- 10 tiles

    for i=1, faction.memberCount do
        local randomArch = archetypes[ZombRand(#archetypes) + 1]
        
        -- Scattered Home logic
        local scatteredHome = nil
        if home and home.x then
            scatteredHome = {
                x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                z = home.z or 0
            }
        end
        
        DynamicTrading_Roster.AddSoul(factionID, randomArch, scatteredHome)
    end
end

return Lifecycle
