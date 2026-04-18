-- ==============================================================================
-- Factions/Lifecycle.lua
-- Logic: Faction Initialization, Creation, and Roster Generation.
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
local BuildingInit = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingInit"

local Lifecycle = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"
local IS_SERVER_RUNTIME = (not isClient()) or isServer()

if IS_SERVER_RUNTIME then
    require "DT/Common/Faction/Templates/BaseSpawn/DT_FactionLocationManager"
    require "DT/Common/Faction/Templates/FactionNames/DT_FactionNames"
end

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function Lifecycle.Init()
    if not IS_SERVER_RUNTIME then
        return
    end

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
        
        if type(f.wealth) == "number" and not f.ColonyWealth then
            f.ColonyWealth = f.wealth
            f.wealth = nil
        end
        if type(f.ColonyWealth) ~= "number" then
            f.ColonyWealth = 1000
        end

        if not f.CollapseDays then
            f.CollapseDays = 0
        end

        if not f.factionType then
            if f.playerOwned then
                f.factionType = "player"
            elseif id == "Independent" or f.isNomadic then
                f.factionType = "independent"
            else
                f.factionType = "town"
            end
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
            f.leadershipState = f.leadershipState or "Active"
            local existingLeader = tostring(f.leaderUsername or "")
            if existingLeader == "" then
                f.leaderUsername = ""
                f.leadershipState = "AdminReview"
            else
                f.leaderUsername = existingLeader
            end
            f.regencyReason = f.regencyReason or nil
            f.controlMode = f.controlMode or "HybridManual"
            if f.leadershipState == "AdminReview" then
                f.controlMode = "AdminReview"
            end
            f.previousLeaderUsername = f.previousLeaderUsername or nil
            f.memberUsernames = type(f.memberUsernames) == "table" and f.memberUsernames or {}
            f.inviteUsernames = type(f.inviteUsernames) == "table" and f.inviteUsernames or {}
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
    if not IS_SERVER_RUNTIME then
        return
    end

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
            if DT_FactionNames and DT_FactionNames.Generate then
                displayName = DT_FactionNames.Generate()
            else
                displayName = tostring(initialData.name or factionID)
            end
            -- Ask the location manager for a physical base
            if DT_FactionLocationManager and DT_FactionLocationManager.AssignHome then
                assignedHome = DT_FactionLocationManager.AssignHome(factionID, initialData.town)
            end
        end

        -- B. Construct the Faction Object
        data[factionID] = {
            id = factionID,
            name = displayName, -- The "flavor" name (The Iron Vanguard)
            town = initialData.town, -- Keep track of which town this faction belongs to
            homeCoords = assignedHome, -- The "physical" base (Rosewood Fire Station)
            stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25, water = 150, materials = 30 },
            state = initialData.state or "Stable",
            memberCount = initialData.memberCount or math.max(8, SandboxVars.DynamicTrading.FactionStartPop or 10),
            ColonyWealth = initialData.ColonyWealth or initialData.wealth or 1000, -- Stores the total economic power of the colony
            CollapseDays = 0,
            factionType = initialData.playerOwned and "player" or (factionID == "Independent" or initialData.isNomadic) and "independent" or "town",
            reputation = initialData.reputation or {}, -- [Username] = Integer
            starvationDays = 0, -- Track days without food
            shortageDays = { water = 0, meds = 0, ammo = 0, fuel = 0, materials = 0 },
            penalties = { dehydrated = false, sick = false, vulnerable = false, isolated = false, decaying = false },
            buildings = {},
            consecutiveStableDays = 0, -- Track how long they've been stable (for wildcard triggers)
            ActiveFlashEvents = {}, -- list of faction flash events (Phase-A schema)
            ActiveFlashEvent = { id = nil, expires = 0, targetCasualties = 0 }, -- legacy compatibility mirror
            playerOwned = initialData.playerOwned == true,
            leaderUsername = initialData.leaderUsername,
            leadershipState = initialData.leadershipState or "Active",
            regencyReason = initialData.regencyReason,
            previousLeaderUsername = initialData.previousLeaderUsername,
            controlMode = initialData.controlMode or (initialData.playerOwned and "HybridManual" or nil),
            memberUsernames = initialData.memberUsernames or {},
            inviteUsernames = initialData.inviteUsernames or {},
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
        
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.FACTION_FOUNDED, {displayName})
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
        if not DynamicTrading.IsArchetypeAllowedForFaction
            or DynamicTrading.IsArchetypeAllowedForFaction(id, factionID) then
            table.insert(archetypes, id)
        end
    end
    
    if #archetypes == 0 then
        table.insert(archetypes, "General")
    end

    local requiredArchetypes = {}
    if DynamicTrading.GetRosterPoolEntriesForFaction then
        local rosterEntries = DynamicTrading.GetRosterPoolEntriesForFaction(factionID)
        for _, entry in ipairs(rosterEntries) do
            if DynamicTrading.Archetypes and DynamicTrading.Archetypes[entry.archetypeID] then
                for _ = 1, entry.minCount do
                    table.insert(requiredArchetypes, entry.archetypeID)
                end
            end
        end
    end

    if faction.factionType == "town" then
        -- Enforce minimum requirement of 2 Farmers and 2 Carpenters
        for _ = 1, 2 do table.insert(requiredArchetypes, "Farmer") end
        for _ = 1, 2 do table.insert(requiredArchetypes, "Carpenter") end
    end

    local totalMembers = math.max(tonumber(faction.memberCount) or 0, #requiredArchetypes)
    if totalMembers < 1 then
        totalMembers = 1
    end
    faction.memberCount = totalMembers
    
    local home = faction.homeCoords
    local scatterRange = 10 -- +/- 10 tiles

    for i=1, totalMembers do
        local randomArch = requiredArchetypes[i] or archetypes[ZombRand(#archetypes) + 1]
        
        -- Scattered Home logic
        local scatteredHome = nil
        if home and home.x then
            scatteredHome = {
                x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                z = home.z or 0
            }
        end
        
        DynamicTrading_Roster.AddSoul(factionID, randomArch, scatteredHome, { suppressRecruitLog = true })
    end
    
    BuildingInit.InitializeStarterBuildings(faction)
    
    ModData.transmit(MOD_DATA_KEY)
end

return Lifecycle
