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
local deferredBootstrapPending = false
local deferredBootstrapTickCounter = 0
local deferredTownQueue = {}
local EXPLORATION_DATA_KEY = "DynamicTrading_Exploration"
local townVisitTickCounter = 0

if IS_SERVER_RUNTIME then
    require "DT/Common/GeolocatorSystem/DT_GeolocatorSystem"
    require "DT/Common/Faction/Templates/BaseSpawn/DT_FactionLocationManager"
    require "DT/Common/Faction/Templates/FactionNames/DT_FactionNames"
end

local function buildTownFactionID(townName)
    local prefix = tostring(townName or "Town")
    prefix = prefix:gsub("%s+", "")
    prefix = prefix:gsub("[^%w_]", "")
    if prefix == "" then
        prefix = "Town"
    end
    return prefix .. "_" .. tostring(100000 + ZombRand(900000))
end

local function normalizeTownKey(value)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    if value == nil then
        return nil
    end

    local normalized = tostring(value):lower()
    normalized = normalized:gsub(",%s*ky$", "")
    normalized = normalized:gsub("%s+ky$", "")
    normalized = normalized:gsub("[^%w]", "")
    if normalized == "" then
        return nil
    end

    return normalized
end

local function ensureGeolocatorReady()
    return IS_SERVER_RUNTIME
        and DT_GeolocatorSystem
        and DT_GeolocatorSystem.EnsureBuildingsLoaded
        and DT_GeolocatorSystem.EnsureBuildingsLoaded(true, true)
end

local function getConfiguredColonyWealth()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.ColonyWealth) or nil
    if configured == nil then
        return 10000
    end
    return math.max(0, math.floor(configured))
end

local function collectSpatialAnchorPlayers()
    local players = {}
    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil

    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getX and player.getY then
                players[#players + 1] = player
            end
        end
    end

    if #players == 0 then
        local localPlayer = nil
        if getSpecificPlayer then
            localPlayer = getSpecificPlayer(0)
        elseif getPlayer then
            localPlayer = getPlayer()
        end

        if localPlayer and localPlayer.getX and localPlayer.getY then
            players[#players + 1] = localPlayer
        end
    end

    return players
end

local function sortDeferredTownQueue()
    table.sort(deferredTownQueue, function(left, right)
        if left.priority ~= right.priority then
            return left.priority > right.priority
        end
        return tostring(left.spawnTown) < tostring(right.spawnTown)
    end)
end

local function ensureExplorationData()
    if not ModData.exists(EXPLORATION_DATA_KEY) then
        ModData.add(EXPLORATION_DATA_KEY, {
            visitedTowns = {},
            playerLastTown = {},
        })
    end

    local data = ModData.get(EXPLORATION_DATA_KEY) or {}
    data.visitedTowns = type(data.visitedTowns) == "table" and data.visitedTowns or {}
    data.playerLastTown = type(data.playerLastTown) == "table" and data.playerLastTown or {}
    return data
end

local function buildExistingTownCounts(data)
    local counts = {}

    for id, faction in pairs(data or {}) do
        if id ~= "Independent" and type(faction) == "table" then
            local key = normalizeTownKey(faction.town)
            if key then
                counts[key] = (counts[key] or 0) + 1
            end
        end
    end

    return counts
end

local function collectPriorityTownKeys()
    local keys = {}
    if not DT_GeolocatorSystem or not DT_GeolocatorSystem.GetLocation then
        return keys
    end

    for _, player in ipairs(collectSpatialAnchorPlayers()) do
        local location = DT_GeolocatorSystem.GetLocation(math.floor(player:getX()), math.floor(player:getY()))
        if location then
            local locationKey = normalizeTownKey(location.shortName or location.id)
            if locationKey then
                keys[locationKey] = true
            end
        end
    end

    return keys
end

local function scheduleMissingTownPopulation(data)
    for index = #deferredTownQueue, 1, -1 do
        deferredTownQueue[index] = nil
    end

    if type(DT_FactionLocations) ~= "table" then
        return 0, 0
    end

    local existingCounts = buildExistingTownCounts(data)
    local priorityTownKeys = collectPriorityTownKeys()
    local maxFactions = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.MaxFactionsPerTown) or 2
    local memberCount = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.FactionStartPop) or 3
    local priorityCount = 0

    for townID, townData in pairs(DT_FactionLocations) do
        local spawnTown = (type(townData) == "table" and townData.name) or townID
        local factionSeed = (type(townData) == "table" and townData.id) or townID
        local townKey = normalizeTownKey(spawnTown) or normalizeTownKey(townID)
        local existing = townKey and (existingCounts[townKey] or 0) or 0
        local missing = math.max(0, maxFactions - existing)
        local priority = townKey and priorityTownKeys[townKey] or false

        for _ = 1, missing do
            deferredTownQueue[#deferredTownQueue + 1] = {
                spawnTown = spawnTown,
                townKey = townKey,
                factionSeed = factionSeed,
                memberCount = memberCount,
                priority = priority and 1 or 0,
                queueSource = priority and "startup-near-player" or "startup-deferred",
            }
            if priority then
                priorityCount = priorityCount + 1
            end
        end
    end

    sortDeferredTownQueue()

    return #deferredTownQueue, priorityCount
end

local function promoteTownQueueEntries(townName, priority)
    local townKey = normalizeTownKey(townName)
    if not townKey then
        return 0
    end

    local promoted = 0
    for _, entry in ipairs(deferredTownQueue) do
        local entryTownKey = entry.townKey or normalizeTownKey(entry.spawnTown)
        if entryTownKey == townKey then
            local targetPriority = tonumber(priority) or 2
            if (tonumber(entry.priority) or 0) < targetPriority then
                entry.priority = targetPriority
                entry.queueSource = "player-exploration"
            end
            promoted = promoted + 1
        end
    end

    if promoted > 0 then
        sortDeferredTownQueue()
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Queue",
            "Prioritized deferred town queue for " .. tostring(townName)
                .. "; promotedEntries=" .. tostring(promoted)
                .. "; queueSize=" .. tostring(#deferredTownQueue)
        )
    end

    return promoted
end

local function handleVisitedTown(player, townName, reason)
    local normalizedTown = normalizeTownKey(townName)
    if not normalizedTown then
        return 0
    end

    local explorationData = ensureExplorationData()
    local visitedBefore = explorationData.visitedTowns[normalizedTown] == true
    if not visitedBefore then
        explorationData.visitedTowns[normalizedTown] = true
        ModData.transmit(EXPLORATION_DATA_KEY)
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Exploration",
            "Town discovered through exploration: " .. tostring(townName)
                .. " by " .. tostring(player and player.getUsername and player:getUsername() or "unknown-player")
        )
    end

    local promoted = promoteTownQueueEntries(townName, 2)
    if promoted <= 0 then
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Exploration",
            "Town visit did not change queue state for " .. tostring(townName)
                .. "; no deferred factions remain for that town."
        )
        return 0
    end

    if not ensureGeolocatorReady() then
        deferredBootstrapPending = true
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Exploration",
            "Queued town " .. tostring(townName)
                .. " as high-priority exploration target while geolocator finishes preparing."
        )
        return 0
    end

    DynamicTrading.Log(
        "DTCommons",
        "Faction",
        "Exploration",
        "Town " .. tostring(townName)
            .. " moved to the front of the deferred simulation queue during " .. tostring(reason or "exploration")
            .. "; it will now mature through normal queue processing instead of spawning instantly."
    )
    return promoted
end

local function updateExplorationDrivenTownGeneration()
    if not IS_SERVER_RUNTIME or not DT_GeolocatorSystem or not DT_GeolocatorSystem.GetLocation then
        return 0
    end

    if #deferredTownQueue == 0 then
        return 0
    end

    local explorationData = ensureExplorationData()
    local processed = 0

    for _, player in ipairs(collectSpatialAnchorPlayers()) do
        local username = player.getUsername and player:getUsername() or tostring(player)
        local location = DT_GeolocatorSystem.GetLocation(math.floor(player:getX()), math.floor(player:getY()))
        local townName = location and (location.shortName or location.id) or nil
        local townKey = normalizeTownKey(townName)
        local lastTownKey = explorationData.playerLastTown[username]

        if townKey and townKey ~= lastTownKey then
            explorationData.playerLastTown[username] = townKey
            processed = processed + handleVisitedTown(player, townName, "player-visit")
        elseif not townKey and lastTownKey ~= nil then
            explorationData.playerLastTown[username] = nil
        end
    end

    return processed
end

local function processDeferredTownQueue(reason, maxEntries, randomize)
    if #deferredTownQueue == 0 then
        return 0
    end

    local limit = math.max(1, tonumber(maxEntries) or 1)
    local processed = 0

    while processed < limit and #deferredTownQueue > 0 do
        local index = randomize and (ZombRand(#deferredTownQueue) + 1) or 1
        local entry = table.remove(deferredTownQueue, index)
        if entry then
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Queue",
                "Processing deferred town entry town=" .. tostring(entry.spawnTown)
                    .. " priority=" .. tostring(entry.priority)
                    .. " source=" .. tostring(entry.queueSource or "unknown")
                    .. " reason=" .. tostring(reason or "deferred")
            )
            local factionID = tostring(entry.factionSeed) .. "_" .. tostring(100000 + ZombRand(900000))
            Lifecycle.CreateFaction(factionID, {
                town = entry.spawnTown,
                memberCount = entry.memberCount,
            })
            processed = processed + 1
        end
    end

    if processed > 0 then
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Logic",
            "Processed " .. tostring(processed) .. " deferred town spawns during " .. tostring(reason or "deferred")
                .. "; remaining=" .. tostring(#deferredTownQueue)
        )
    end

    return processed
end

local function hasValidHomeCoords(homeCoords)
    return type(homeCoords) == "table"
        and tonumber(homeCoords.x) ~= nil
        and tonumber(homeCoords.y) ~= nil
end

local function buildSpatialFallbackHome(factionID, faction)
    if not DT_GeolocatorSystem or not DT_GeolocatorSystem.CreateSpatialHome then
        return nil
    end

    local label = nil
    if type(faction) == "table" then
        label = faction.name
    end
    if not label or label == "" then
        if factionID == "Independent" or (type(faction) == "table" and faction.factionType == "independent") then
            label = "Independent Route"
        else
            label = tostring(factionID or "Nomadic Route") .. " Route"
        end
    end

    return DT_GeolocatorSystem.CreateSpatialHome(label, {
        town = faction and faction.town or nil,
        factionID = factionID,
        preferUsableRange = true,
    })
end

local function countTownFactions(data)
    local count = 0
    for id, _ in pairs(data or {}) do
        if id ~= "Independent" then
            count = count + 1
        end
    end
    return count
end

local function repairMissingFactionHomes(data)
    local repairedCount = 0

    if not IS_SERVER_RUNTIME then
        return repairedCount
    end

    for id, faction in pairs(data or {}) do
        if not faction.playerOwned and not hasValidHomeCoords(faction.homeCoords) then
            local repairedHome = nil

            if id == "Independent" or faction.factionType == "independent" then
                repairedHome = buildSpatialFallbackHome(id, faction)
            elseif DT_FactionLocationManager and DT_FactionLocationManager.AssignHome then
                repairedHome = DT_FactionLocationManager.AssignHome(id, faction.town)
                if not repairedHome then
                    repairedHome = buildSpatialFallbackHome(id, faction)
                end
            else
                repairedHome = buildSpatialFallbackHome(id, faction)
            end

            if repairedHome then
                faction.homeCoords = repairedHome
                faction.town = repairedHome.town or faction.town
                repairedCount = repairedCount + 1
            end
        end
    end

    return repairedCount
end

local function tryFinalizeFactionBootstrap(reason)
    if not ensureGeolocatorReady() then
        deferredBootstrapPending = true
        return false
    end

    if DT_FactionLocationManager and DT_FactionLocationManager.RegisterDynamicTowns then
        DT_FactionLocationManager.RegisterDynamicTowns()
    end

    local data = ModData.get(MOD_DATA_KEY) or {}
    local queuedCount, priorityCount = scheduleMissingTownPopulation(data)
    local repairedCount = repairMissingFactionHomes(data)
    if repairedCount > 0 then
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Repaired " .. tostring(repairedCount) .. " faction homes during " .. tostring(reason or "bootstrap"))
        ModData.transmit(MOD_DATA_KEY)
    end

    if deferredBootstrapPending and queuedCount > 0 then
        deferredBootstrapPending = false
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Completing deferred town population during " .. tostring(reason or "bootstrap"))
        processDeferredTownQueue(reason or "bootstrap", math.max(priorityCount, 1), false)
        return true
    end

    deferredBootstrapPending = false
    return repairedCount > 0 or queuedCount > 0
end

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function Lifecycle.Init()
    if not IS_SERVER_RUNTIME then
        return
    end

    ensureExplorationData()

    if DT_FactionLocationManager and DT_FactionLocationManager.RegisterDynamicTowns then
        DT_FactionLocationManager.RegisterDynamicTowns()
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
    local townFactionCount = countTownFactions(data)
    local geolocatorReady = ensureGeolocatorReady()

    if geolocatorReady then
        scheduleMissingTownPopulation(data)
    end

    if townFactionCount == 0 then
        if geolocatorReady then
            DynamicTrading.Log("DTCommons", "Init", "Faction", "No town factions found, triggering initial population")
            DynamicTrading_Factions.RepopulateTowns()
            townFactionCount = countTownFactions(data)
        else
            deferredBootstrapPending = true
            DynamicTrading.Log("DTCommons", "Init", "Faction", "No town factions found, but geolocator is not ready yet. Deferring initial population.")
        end
    end

    -- 3. Data Integrity: Ensure proper data types for existing factions
    local needsHomeRepair = false
    for id, f in pairs(data) do
        -- Fallback: ensure reputation is a table
        if type(f.reputation) ~= "table" then
            f.reputation = {}
        end
        
        if type(f.wealth) == "number" and not f.ColonyWealth then
            f.ColonyWealth = f.wealth
            f.wealth = nil
        end
        f.ColonyWealth = getConfiguredColonyWealth()

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

        if DT_GeolocatorSystem and DT_GeolocatorSystem.ResolveLocationName and type(f.town) == "string" and f.town ~= "" then
            f.town = DT_GeolocatorSystem.ResolveLocationName(f.town)
        end

        if IS_SERVER_RUNTIME
            and not f.playerOwned
            and not hasValidHomeCoords(f.homeCoords) then
            needsHomeRepair = true
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

    if needsHomeRepair and not tryFinalizeFactionBootstrap("init") then
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "Deferred faction home repair until geolocator data becomes available.")
    end

    ModData.transmit(MOD_DATA_KEY)
end

function Lifecycle.RepopulateTowns()
    if not IS_SERVER_RUNTIME then
        return
    end

    DynamicTrading.Log("DTCommons", "Faction", "Logic", "Starting Town Repopulation...")

    local hasLocations = false
    if type(DT_FactionLocations) == "table" then
        for _ in pairs(DT_FactionLocations) do
            hasLocations = true
            break
        end
    end

    if not hasLocations then
        DynamicTrading.Log("DTCommons", "Faction", "Warn", "RepopulateTowns: No town locations available! Faction spawning aborted.")
        return
    end

    local data = ModData.get(MOD_DATA_KEY) or {}
    local queuedCount, priorityCount = scheduleMissingTownPopulation(data)
    if queuedCount == 0 then
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Town population already satisfies configured limits.")
        return
    end

    local immediateBudget = math.max(priorityCount, 1)
    DynamicTrading.Log(
        "DTCommons",
        "Faction",
        "Logic",
        "Queued " .. tostring(queuedCount) .. " missing town faction spawns; processing " .. tostring(immediateBudget) .. " immediately."
    )
    processDeferredTownQueue("startup", immediateBudget, false)
end

local function onLifecycleServerStarted()
    tryFinalizeFactionBootstrap("server-start")
end

local function onLifecycleTick()
    townVisitTickCounter = townVisitTickCounter + 1
    if townVisitTickCounter >= 60 then
        townVisitTickCounter = 0
        updateExplorationDrivenTownGeneration()
    end

    if not deferredBootstrapPending then
        return
    end

    deferredBootstrapTickCounter = deferredBootstrapTickCounter + 1
    if deferredBootstrapTickCounter < 300 then
        return
    end

    deferredBootstrapTickCounter = 0
    tryFinalizeFactionBootstrap("deferred-retry")
end

local function onLifecycleDailySimulation()
    if #deferredTownQueue == 0 then
        return
    end

    if ensureGeolocatorReady() then
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Queue",
            "Daily simulation advancing deferred town queue; pending=" .. tostring(#deferredTownQueue)
        )
        processDeferredTownQueue("daily-simulation", 1, false)
    end
end

if IS_SERVER_RUNTIME then
    Events.OnServerStarted.Add(onLifecycleServerStarted)
    Events.OnTick.Add(onLifecycleTick)
    Events.OnDynamicTradingDailySimulation.Add(onLifecycleDailySimulation)
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
        local resolvedTown = initialData.town

        if DT_GeolocatorSystem and DT_GeolocatorSystem.ResolveLocationName and resolvedTown then
            resolvedTown = DT_GeolocatorSystem.ResolveLocationName(resolvedTown)
        end

        -- A. Handle Naming & Home Assignment
        if initialData.playerOwned then
            displayName = tostring(initialData.name or factionID)
            assignedHome = initialData.homeCoords
        elseif factionID == "Independent" or initialData.isNomadic then
            displayName = "Independent Traders"
            assignedHome = buildSpatialFallbackHome(factionID, {
                name = displayName,
                town = resolvedTown,
                factionType = "independent"
            })
        else
            -- Use our new dynamic naming engine
            if DT_FactionNames and DT_FactionNames.Generate then
                displayName = DT_FactionNames.Generate()
            else
                displayName = tostring(initialData.name or factionID)
            end
            -- Ask the location manager for a physical base
            if DT_FactionLocationManager and DT_FactionLocationManager.AssignHome then
                assignedHome = DT_FactionLocationManager.AssignHome(factionID, resolvedTown)
            end
            if not assignedHome then
                assignedHome = buildSpatialFallbackHome(factionID, {
                    name = displayName,
                    town = resolvedTown,
                    factionType = initialData.playerOwned and "player" or "town"
                })
            end
        end

        if (not resolvedTown or resolvedTown == "" or resolvedTown == "Wilderness") and assignedHome and assignedHome.town then
            resolvedTown = assignedHome.town
        end

        -- B. Construct the Faction Object
        data[factionID] = {
            id = factionID,
            name = displayName, -- The "flavor" name (The Iron Vanguard)
            town = resolvedTown, -- Keep track of which town this faction belongs to
            homeCoords = assignedHome, -- The "physical" base (Rosewood Fire Station)
            stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25, water = 150, materials = 30 },
            state = initialData.state or "Stable",
            memberCount = initialData.memberCount or math.max(8, SandboxVars.DynamicTrading.FactionStartPop or 10),
            ColonyWealth = getConfiguredColonyWealth(), -- Stores the total economic power of the colony
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
