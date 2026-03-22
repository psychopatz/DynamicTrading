require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"

local PlayerOwnership = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

local function getFactionData()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end
    return ModData.get(MOD_DATA_KEY)
end

local function getOwnerUsername(ownerUsername)
    local config = DT_Labour and DT_Labour.Config
    if config and config.GetOwnerUsername then
        return config.GetOwnerUsername(ownerUsername)
    end
    return tostring(ownerUsername or "local")
end

local function trimName(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function sanitizeID(value)
    local text = string.lower(tostring(value or "local"))
    text = string.gsub(text, "[^%w_]+", "_")
    text = string.gsub(text, "_+", "_")
    text = string.gsub(text, "^_+", "")
    text = string.gsub(text, "_+$", "")
    if text == "" then
        text = "local"
    end
    return text
end

local function getWorkerRegistry()
    return DT_Labour and DT_Labour.Registry or nil
end

local function getWorkerSummary(worker)
    local registry = getWorkerRegistry()
    if registry and registry.GetWorkerSummary then
        return registry.GetWorkerSummary(worker)
    end
    return worker
end

local function getDeadState()
    local config = DT_Labour and DT_Labour.Config
    return tostring(config and config.States and config.States.Dead or "Dead")
end

local function isWorkerLiving(worker)
    return worker and tostring(worker.state or "") ~= getDeadState()
end

local function findWorkerByID(ownerUsername, workerID)
    local registry = getWorkerRegistry()
    if registry and registry.GetWorkerForOwner then
        return registry.GetWorkerForOwner(ownerUsername, workerID)
    end
    return nil
end

local function getWorkersForOwner(ownerUsername)
    local registry = getWorkerRegistry()
    if registry and registry.GetWorkersForOwner then
        return registry.GetWorkersForOwner(ownerUsername) or {}
    end
    return {}
end

local function appendUnique(array, value)
    if not value then
        return
    end
    for _, existing in ipairs(array) do
        if existing == value then
            return
        end
    end
    table.insert(array, value)
end

local function syncLinkedWorkersFromOwner(faction, owner)
    if not faction then
        return
    end

    faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
    local ownerWorkers = getWorkersForOwner(owner)

    for _, worker in ipairs(ownerWorkers) do
        if worker and worker.workerID and isWorkerLiving(worker) then
            appendUnique(faction.linkedWorkerIDs, worker.workerID)
        end
    end
end

local function removeValue(array, value)
    if type(array) ~= "table" then
        return false
    end

    local removed = false
    for index = #array, 1, -1 do
        if array[index] == value then
            table.remove(array, index)
            removed = true
        end
    end
    return removed
end

local function buildFactionHome(player, workers)
    local x = nil
    local y = nil
    local z = 0

    if player and player.getX and player.getY then
        x = math.floor(player:getX())
        y = math.floor(player:getY())
        z = math.floor((player.getZ and player:getZ()) or 0)
    elseif workers and workers[1] then
        local worker = workers[1]
        x = math.floor(tonumber(worker.homeX) or tonumber(worker.workX) or 0)
        y = math.floor(tonumber(worker.homeY) or tonumber(worker.workY) or 0)
        z = math.floor(tonumber(worker.homeZ) or tonumber(worker.workZ) or 0)
    end

    if x == nil or y == nil then
        x, y, z = 0, 0, 0
    end

    local town = "Unknown"
    if DTM and DTM.GetTownName then
        local resolvedTown = DTM.GetTownName(x, y)
        if resolvedTown and resolvedTown ~= "" then
            town = resolvedTown
        end
    end

    return {
        name = "Player HQ",
        x = x,
        y = y,
        z = z,
        town = town
    }
end

local function updateSoulFromWorker(uuid, worker, faction)
    if not uuid or not worker then
        return nil
    end

    local soul = DynamicTrading_Roster.GetSoul(uuid)
    if not soul then
        return nil
    end

    soul.name = worker.name or soul.name
    soul.isFemale = worker.isFemale
    soul.identitySeed = worker.identitySeed or soul.identitySeed
    soul.archetypeID = worker.archetypeID or soul.archetypeID or worker.profession or "General"
    soul.factionID = faction and faction.id or soul.factionID
    soul.homeCoords = {
        x = worker.homeX or (faction and faction.homeCoords and faction.homeCoords.x) or 0,
        y = worker.homeY or (faction and faction.homeCoords and faction.homeCoords.y) or 0,
        z = worker.homeZ or (faction and faction.homeCoords and faction.homeCoords.z) or 0
    }
    soul.linkedWorkerID = worker.workerID
    soul.ownerUsername = worker.ownerUsername
    soul.isPlayerFactionTrader = true
    if soul.status == nil then
        soul.status = "Resting"
    end

    DynamicTrading_Roster.SaveSoul(uuid, soul)
    return soul
end

local function getCurrentHours()
    local gameTime = getGameTime and getGameTime() or GameTime and GameTime:getInstance() or nil
    return gameTime and gameTime:getWorldAgeHours() or 0
end

local function getWalkHours()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    return tonumber(sandbox and sandbox.NPCTradingWalkHours) or 2
end

local function rollRadioStayHours()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local minHours = tonumber(sandbox and sandbox.TraderStayHoursMin) or 6
    local maxHours = tonumber(sandbox and sandbox.TraderStayHoursMax) or 24
    if minHours > maxHours then
        minHours = maxHours
    end
    return ZombRand(minHours, maxHours + 1)
end

local function isTradeSoulActive(uuid)
    if not uuid then
        return false
    end
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    return soul and (soul.status == "Away" or soul.status == "Trading") or false
end

local function isV2TradeBackendActive()
    return DTNPCManager
        and DTNPCManager.StartTradeMission
        and DTNPCManager.SetNPCStatus
        and DTNPCManager.ProcessTradeCycles
end

local function startTradeMission(uuid)
    if isV2TradeBackendActive() then
        DTNPCManager.StartTradeMission(uuid)
        return {
            backend = "V2",
            traderID = uuid,
            discoverTrader = false
        }
    end

    DynamicTrading_Roster.UpdateSoulStatus(uuid, "Trading", getCurrentHours() + rollRadioStayHours(), "Away")
    return {
        backend = "V1",
        traderID = uuid,
        discoverTrader = true
    }
end

local function recallTradeMission(uuid)
    local travelHours = getWalkHours()
    if isV2TradeBackendActive() then
        DTNPCManager.SetNPCStatus(uuid, "Away", getCurrentHours() + travelHours, "Resting")
        return "V2"
    end

    DynamicTrading_Roster.UpdateSoulStatus(uuid, "Away", getCurrentHours() + travelHours, "Resting")
    return "V1"
end

local function clearWorkerTradeLink(faction, workerID, removeSoul)
    if not faction or not workerID then
        return
    end

    faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}

    faction.tradeEligibleWorkerIDs[workerID] = nil
    faction.activeTradeWorkerIDs[workerID] = nil

    local uuid = faction.tradeWorkerSouls[workerID]
    if removeSoul and uuid then
        if DTNPCManager and DTNPCManager.SetNPCStatus then
            pcall(DTNPCManager.SetNPCStatus, uuid, "Away", getGameTime():getWorldAgeHours() + 0.01, "Resting")
        end
        if DynamicTrading_Roster and DynamicTrading_Roster.RemoveSpecificSoul then
            DynamicTrading_Roster.RemoveSpecificSoul(uuid)
        end
    end

    faction.tradeWorkerSouls[workerID] = nil
end

local function buildFactionWorkerSummaries(faction)
    local summaries = {}
    if not faction or not faction.playerOwned then
        return summaries
    end

    local owner = getOwnerUsername(faction.leaderUsername)
    faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
    faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}

    for _, workerID in ipairs(faction.linkedWorkerIDs) do
        local worker = findWorkerByID(owner, workerID)
        if worker then
            local summary = getWorkerSummary(worker)
            local tradeSoulUUID = faction.tradeWorkerSouls[workerID]
            local tradeSoul = tradeSoulUUID and DynamicTrading_Roster.GetSoulRegistry(tradeSoulUUID) or nil
            local tradeActive = faction.activeTradeWorkerIDs[workerID] == true
            if tradeSoul then
                tradeActive = tradeSoul.status == "Away" or tradeSoul.status == "Trading"
            end
            summary.tradeEligible = faction.tradeEligibleWorkerIDs[workerID] == true
            summary.tradeActive = tradeActive
            summary.tradeStatus = tradeSoul and tradeSoul.status or nil
            summary.tradeSoulUUID = tradeSoulUUID
            summary.isLinkedFactionMember = true
            summaries[#summaries + 1] = summary
        end
    end

    table.sort(summaries, function(a, b)
        return tostring(a.name or a.workerID) < tostring(b.name or b.workerID)
    end)

    return summaries
end

local function collapseFaction(factionID, reason)
    local data = getFactionData()
    local faction = data[factionID]
    if not faction then
        return false
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls then
        DynamicTrading_Roster.ClearSouls(factionID)
    end

    data[factionID] = nil
    ModData.transmit(MOD_DATA_KEY)

    DynamicTrading.Log(
        "DTCommons",
        "Faction",
        "Logic",
        "Collapsed player faction [" .. tostring(factionID) .. "] reason=" .. tostring(reason or "unknown")
    )

    return true
end

function PlayerOwnership.IsPlayerFaction(faction)
    return type(faction) == "table" and faction.playerOwned == true
end

function PlayerOwnership.GetPlayerFactionID(ownerUsername)
    local owner = getOwnerUsername(ownerUsername)
    local data = getFactionData()

    for factionID, faction in pairs(data) do
        if faction.playerOwned and getOwnerUsername(faction.leaderUsername) == owner then
            return factionID
        end
    end

    return nil
end

function PlayerOwnership.GetPlayerFaction(ownerUsername)
    local factionID = PlayerOwnership.GetPlayerFactionID(ownerUsername)
    if not factionID then
        return nil
    end
    return getFactionData()[factionID]
end

function PlayerOwnership.ValidateFactionName(rawName, ignoreFactionID)
    local name = trimName(rawName)
    if name == "" then
        return false, "Faction name cannot be empty."
    end
    if #name > 32 then
        return false, "Faction name must be 32 characters or less."
    end

    local lowerName = string.lower(name)
    for factionID, faction in pairs(getFactionData()) do
        if factionID ~= ignoreFactionID and string.lower(tostring(faction.name or "")) == lowerName then
            return false, "That faction name is already in use."
        end
    end

    return true, name
end

function PlayerOwnership.RefreshPlayerFaction(factionID)
    local data = getFactionData()
    local faction = data[factionID]
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return faction
    end

    local owner = getOwnerUsername(faction.leaderUsername)
    faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
    faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
    faction.controlMode = faction.controlMode or "HybridManual"
    faction.leadershipState = faction.leadershipState or "Active"
    syncLinkedWorkersFromOwner(faction, owner)

    local livingCount = 0
    local staleIDs = {}

    for _, workerID in ipairs(faction.linkedWorkerIDs) do
        local worker = findWorkerByID(owner, workerID)
        if not worker then
            staleIDs[#staleIDs + 1] = workerID
        elseif isWorkerLiving(worker) then
            livingCount = livingCount + 1
            local tradeUUID = faction.tradeWorkerSouls[workerID]
            if tradeUUID then
                local soul = DynamicTrading_Roster.GetSoulRegistry(tradeUUID)
                if soul then
                    updateSoulFromWorker(tradeUUID, worker, faction)
                    if soul.status == "Away" or soul.status == "Trading" then
                        faction.activeTradeWorkerIDs[workerID] = true
                    else
                        faction.activeTradeWorkerIDs[workerID] = nil
                    end
                else
                    faction.tradeWorkerSouls[workerID] = nil
                    faction.activeTradeWorkerIDs[workerID] = nil
                end
            else
                faction.activeTradeWorkerIDs[workerID] = nil
            end
        else
            faction.activeTradeWorkerIDs[workerID] = nil
        end
    end

    for _, workerID in ipairs(staleIDs) do
        removeValue(faction.linkedWorkerIDs, workerID)
        clearWorkerTradeLink(faction, workerID, true)
    end

    faction.memberCount = livingCount

    if livingCount <= 0 then
        collapseFaction(factionID, "no_linked_workers")
        return nil
    end

    ModData.transmit(MOD_DATA_KEY)
    return faction
end

function PlayerOwnership.RefreshAllPlayerFactions()
    local data = getFactionData()
    local ids = {}

    for factionID, faction in pairs(data) do
        if faction.playerOwned then
            ids[#ids + 1] = factionID
        end
    end

    for _, factionID in ipairs(ids) do
        PlayerOwnership.RefreshPlayerFaction(factionID)
    end
end

function PlayerOwnership.GetLivingWorkersForFaction(factionID)
    local faction = getFactionData()[factionID]
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return {}
    end

    local owner = getOwnerUsername(faction.leaderUsername)
    local workers = {}

    for _, workerID in ipairs(faction.linkedWorkerIDs or {}) do
        local worker = findWorkerByID(owner, workerID)
        if isWorkerLiving(worker) then
            workers[#workers + 1] = worker
        end
    end

    return workers
end

function PlayerOwnership.ApplyCasualties(factionID, count, cause)
    local faction = PlayerOwnership.RefreshPlayerFaction(factionID)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return 0
    end

    local livingWorkers = PlayerOwnership.GetLivingWorkersForFaction(factionID)
    local casualties = 0
    local target = math.max(0, math.floor(tonumber(count) or 0))

    while target > 0 and #livingWorkers > 0 do
        local index = ZombRand(#livingWorkers) + 1
        local worker = table.remove(livingWorkers, index)
        if worker then
            worker.state = getDeadState()
            worker.hp = 0
            worker.jobEnabled = false
            worker.presenceState = DT_Labour
                and DT_Labour.Config
                and DT_Labour.Config.PresenceStates
                and DT_Labour.Config.PresenceStates.Home
                or worker.presenceState
            worker.deathCause = tostring(cause or "Faction casualty")
            clearWorkerTradeLink(faction, worker.workerID, true)
            casualties = casualties + 1
            target = target - 1
        end
    end

    if getWorkerRegistry() and getWorkerRegistry().Save then
        getWorkerRegistry().Save()
    end

    PlayerOwnership.RefreshPlayerFaction(factionID)
    return casualties
end

function PlayerOwnership.BuildOwnedFactionStatus(ownerUsername)
    local owner = getOwnerUsername(ownerUsername)
    local workers = getWorkersForOwner(owner)
    local livingWorkers = {}

    for _, worker in ipairs(workers) do
        if isWorkerLiving(worker) then
            livingWorkers[#livingWorkers + 1] = worker
        end
    end

    local faction = PlayerOwnership.GetPlayerFaction(owner)
    if faction then
        faction = PlayerOwnership.RefreshPlayerFaction(faction.id) or nil
    end

    return {
        ownerUsername = owner,
        canCreate = faction == nil and #livingWorkers >= 1,
        workerCount = #livingWorkers,
        faction = faction,
        linkedWorkers = faction and buildFactionWorkerSummaries(faction) or {},
        createBlockedReason = faction and "already_has_faction" or (#livingWorkers < 1 and "needs_recruit" or nil)
    }
end

function PlayerOwnership.EnsureTradeSoul(factionID, workerID)
    local faction = PlayerOwnership.RefreshPlayerFaction(factionID)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return nil, "Faction not found."
    end

    local owner = getOwnerUsername(faction.leaderUsername)
    local worker = findWorkerByID(owner, workerID)
    if not worker then
        return nil, "Worker not found."
    end
    if not isWorkerLiving(worker) then
        return nil, "Worker is dead."
    end

    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
    local uuid = faction.tradeWorkerSouls[workerID]
    if uuid then
        local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
        if soul then
            updateSoulFromWorker(uuid, worker, faction)
            return uuid, nil
        end
        faction.tradeWorkerSouls[workerID] = nil
    end

    uuid = DynamicTrading_Roster.AddSoul(factionID, worker.archetypeID or worker.profession or "General", {
        x = worker.homeX or (faction.homeCoords and faction.homeCoords.x) or 0,
        y = worker.homeY or (faction.homeCoords and faction.homeCoords.y) or 0,
        z = worker.homeZ or (faction.homeCoords and faction.homeCoords.z) or 0
    })

    faction.tradeWorkerSouls[workerID] = uuid
    updateSoulFromWorker(uuid, worker, faction)
    ModData.transmit(MOD_DATA_KEY)
    return uuid, nil
end

function PlayerOwnership.CreatePlayerFaction(player, rawName)
    local owner = getOwnerUsername(player)
    if PlayerOwnership.GetPlayerFaction(owner) then
        return false, "You already control a faction.", nil
    end

    local isValid, nameOrReason = PlayerOwnership.ValidateFactionName(rawName)
    if not isValid then
        return false, nameOrReason, nil
    end

    local workers = getWorkersForOwner(owner)
    local linkedWorkerIDs = {}
    for _, worker in ipairs(workers) do
        if isWorkerLiving(worker) then
            linkedWorkerIDs[#linkedWorkerIDs + 1] = worker.workerID
        end
    end

    if #linkedWorkerIDs < 1 then
        return false, "You need at least one living recruit before founding a faction.", nil
    end

    local factionID = "player_" .. sanitizeID(owner)
    local homeCoords = buildFactionHome(player, workers)

    DynamicTrading_Factions.CreateFaction(factionID, {
        playerOwned = true,
        leaderUsername = owner,
        leadershipState = "Active",
        regencyReason = nil,
        controlMode = "HybridManual",
        name = nameOrReason,
        town = homeCoords.town,
        homeCoords = homeCoords,
        memberCount = #linkedWorkerIDs,
        linkedWorkerIDs = linkedWorkerIDs,
        tradeEligibleWorkerIDs = {},
        activeTradeWorkerIDs = {},
        tradeWorkerSouls = {},
        createdDay = getGameTime() and getGameTime():getDaysSurvived() or 0
    })

    local faction = PlayerOwnership.RefreshPlayerFaction(factionID)
    return faction ~= nil, faction and "Faction founded." or "Faction creation failed.", faction
end

function PlayerOwnership.OnLabourWorkerCreated(ownerUsername, worker)
    if not worker or not worker.workerID then
        return nil
    end

    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return nil
    end

    faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
    appendUnique(faction.linkedWorkerIDs, worker.workerID)
    faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
    faction.tradeEligibleWorkerIDs[worker.workerID] = faction.tradeEligibleWorkerIDs[worker.workerID] == true
    faction.activeTradeWorkerIDs[worker.workerID] = nil

    PlayerOwnership.RefreshPlayerFaction(faction.id)
    return faction
end

function PlayerOwnership.OnLabourWorkerRemoved(ownerUsername, workerID)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return nil
    end

    removeValue(faction.linkedWorkerIDs, workerID)
    clearWorkerTradeLink(faction, workerID, true)
    PlayerOwnership.RefreshPlayerFaction(faction.id)
    return faction
end

function PlayerOwnership.SetWorkerTradeEligibility(ownerUsername, workerID, enabled)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return false, "Player faction not found.", nil
    end
    if faction.leadershipState == "Regency" then
        return false, "Manual control is locked during regency.", faction
    end

    local owner = getOwnerUsername(ownerUsername)
    local worker = findWorkerByID(owner, workerID)
    if not worker then
        return false, "Worker not found.", faction
    end
    if not isWorkerLiving(worker) then
        return false, "Dead workers cannot trade.", faction
    end

    local linked = false
    for _, linkedWorkerID in ipairs(faction.linkedWorkerIDs or {}) do
        if linkedWorkerID == workerID then
            linked = true
            break
        end
    end
    if not linked then
        return false, "Worker is not linked to this faction.", faction
    end

    faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}

    if enabled then
        faction.tradeEligibleWorkerIDs[workerID] = true
        PlayerOwnership.EnsureTradeSoul(faction.id, workerID)
    else
        clearWorkerTradeLink(faction, workerID, true)
    end

    PlayerOwnership.RefreshPlayerFaction(faction.id)
    ModData.transmit(MOD_DATA_KEY)
    return true, enabled and "Worker can now trade." or "Worker trade access revoked.", faction
end

function PlayerOwnership.DispatchTrade(ownerUsername, workerID, allowRegency)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return false, "Player faction not found.", nil, nil
    end
    if faction.leadershipState == "Regency" and allowRegency ~= true then
        return false, "Manual control is locked during regency.", faction, nil
    end
    if faction.tradeEligibleWorkerIDs[workerID] ~= true then
        return false, "That worker is not trade-approved.", faction, nil
    end

    local uuid, err = PlayerOwnership.EnsureTradeSoul(faction.id, workerID)
    if not uuid then
        return false, err or "Unable to prepare trader.", faction, nil
    end

    if isTradeSoulActive(uuid) then
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.activeTradeWorkerIDs[workerID] = true
        ModData.transmit(MOD_DATA_KEY)
        return false, "That trader is already active.", faction, {
            backend = isV2TradeBackendActive() and "V2" or "V1",
            traderID = uuid,
            discoverTrader = not isV2TradeBackendActive()
        }
    end

    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    faction.activeTradeWorkerIDs[workerID] = true

    local details = startTradeMission(uuid)

    ModData.transmit(MOD_DATA_KEY)
    return true, "Trade mission dispatched.", faction, details
end

function PlayerOwnership.RecallTrade(ownerUsername, workerID, allowRegency)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return false, "Player faction not found.", nil, nil
    end
    if faction.leadershipState == "Regency" and allowRegency ~= true then
        return false, "Manual control is locked during regency.", faction, nil
    end

    faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
    local uuid = faction.tradeWorkerSouls and faction.tradeWorkerSouls[workerID] or nil
    faction.activeTradeWorkerIDs[workerID] = nil

    if uuid then
        local backend = recallTradeMission(uuid)
        ModData.transmit(MOD_DATA_KEY)
        return true, "Trader recalled.", faction, {
            backend = backend,
            traderID = uuid,
            discoverTrader = false
        }
    end

    ModData.transmit(MOD_DATA_KEY)
    return true, "Trader recalled.", faction, nil
end

function PlayerOwnership.EnterRegency(ownerUsername)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return nil
    end

    faction.leadershipState = "Regency"
    faction.regencyReason = "leader_dead"
    ModData.transmit(MOD_DATA_KEY)
    return faction
end

function PlayerOwnership.ResumeLeadership(ownerUsername)
    local faction = PlayerOwnership.GetPlayerFaction(ownerUsername)
    if not PlayerOwnership.IsPlayerFaction(faction) then
        return nil
    end

    if type(ownerUsername) ~= "string" and ownerUsername and ownerUsername.isDead and ownerUsername:isDead() then
        return faction
    end

    faction.leadershipState = "Active"
    faction.regencyReason = nil
    ModData.transmit(MOD_DATA_KEY)
    return faction
end

local function onPlayerDeath(player)
    if not player or (isClient() and not isServer()) then
        return
    end
    PlayerOwnership.EnterRegency(player)
end

if not isClient() or isServer() then
    if Events.OnPlayerDeath then
        Events.OnPlayerDeath.Add(onPlayerDeath)
    end
    Events.OnInitGlobalModData.Add(PlayerOwnership.RefreshAllPlayerFactions)
end

return PlayerOwnership
