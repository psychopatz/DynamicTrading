-- ==============================================================================
-- DTNPC_ManagerRespawn_BanditRoam.lua
-- Dedicated house-roamer lifecycle for true Bandits faction members.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

local BANDIT_FACTION_ID = "Bandits"
local BANDIT_ROAM_RETURN_STATUS = "BanditRoam"
local BANDIT_ROAM_CHECK_INTERVAL_HOURS = 6.0
local DEFAULT_BANDIT_ROAM_AGGRO_RADIUS = 4.5
local HASH_MOD = 2147483647

local function getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

local function hashString(value)
    local text = tostring(value or "")
    local hash = 5381
    for index = 1, #text do
        hash = ((hash * 33) + string.byte(text, index)) % HASH_MOD
    end
    return hash
end

local function buildSeed(...)
    local parts = { ... }
    for index = 1, #parts do
        parts[index] = tostring(parts[index] or "")
    end
    return hashString(table.concat(parts, "|"))
end

local function clampPercent(value)
    local percent = math.floor(tonumber(value) or 0)
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end
    return percent
end

local function getCountFromPercent(totalCount, percent)
    local safePercent = clampPercent(percent)
    if totalCount <= 0 or safePercent <= 0 then
        return 0
    end

    local count = math.floor((totalCount * safePercent) / 100)
    if count <= 0 then
        count = 1
    end
    if count > totalCount then
        count = totalCount
    end
    return count
end

local function getCurrentHours()
    local gt = getGameTime and getGameTime() or nil
    return gt and gt:getWorldAgeHours() or 0
end

local function getTradingDay(currentHours)
    local hours = tonumber(currentHours)
    if hours == nil then
        hours = getCurrentHours()
    end
    return math.floor((hours - 5) / 24)
end

local function getRadiusRange()
    local sandbox = getSandbox()
    local minRadius = tonumber(sandbox.BanditHouseRoamerRadiusMin) or 80
    local maxRadius = tonumber(sandbox.BanditHouseRoamerRadiusMax) or 220
    if maxRadius < minRadius then
        maxRadius = minRadius
    end
    return minRadius, maxRadius
end

local function sortUUIDsBySeed(uuids, currentHours)
    local tradingDay = getTradingDay(currentHours)
    table.sort(uuids, function(left, right)
        local leftRank = buildSeed(BANDIT_FACTION_ID, tradingDay, "bandit_roam", left)
        local rightRank = buildSeed(BANDIT_FACTION_ID, tradingDay, "bandit_roam", right)
        if leftRank == rightRank then
            return tostring(left or "") < tostring(right or "")
        end
        return leftRank < rightRank
    end)
end

function DTNPCManager.GetBanditHouseRoamTravelHours()
    local sandbox = getSandbox()
    return tonumber(sandbox.BanditHouseRoamerTravelHours) or 0.75
end

function DTNPCManager.GetBanditHouseRoamStayHours()
    local sandbox = getSandbox()
    return tonumber(sandbox.BanditHouseRoamerStayHours) or 6.0
end

function DTNPCManager.IsBanditHouseRoamReturnStatus(returnStatus)
    return tostring(returnStatus or "") == BANDIT_ROAM_RETURN_STATUS
end

function DTNPCManager.IsBanditHouseRoamActive(npcData)
    return type(npcData) == "table" and npcData.banditRoamActive == true
end

function DTNPCManager.ClearBanditHouseRoamState(npcData)
    if type(npcData) ~= "table" then
        return npcData
    end

    npcData.banditRoamActive = nil
    npcData.banditRoamSite = nil
    npcData.banditRoamStartedAt = nil
    npcData.banditRoamEndsAt = nil
    npcData.banditRoamReturnStatus = nil
    npcData.banditRoamEncounterMode = nil
    npcData.banditRoamAggroRadius = nil
    return npcData
end

local function isBanditRoamSoul(soul)
    return type(soul) == "table"
        and soul.status ~= "Dead"
        and tostring(soul.factionID or "") == BANDIT_FACTION_ID
end

local function getBanditRoamBuildingTarget(player, minRadius, maxRadius)
    if not player then
        return nil, nil, 0, nil
    end

    if (not DTM or not DTM.Buildings) and DTM and DTM.LoadBuildings then
        DTM.LoadBuildings()
    end

    local playerX = player:getX()
    local playerY = player:getY()
    local targetBuilding = nil

    if DTM and DTM.Buildings then
        local validBuildings = {}
        for _, building in ipairs(DTM.Buildings) do
            local bx = tonumber(building and building.cx) or nil
            local by = tonumber(building and building.cy) or nil
            if bx ~= nil and by ~= nil then
                local dx = playerX - bx
                local dy = playerY - by
                local dist = math.sqrt((dx * dx) + (dy * dy))
                if dist >= minRadius and dist <= maxRadius then
                    validBuildings[#validBuildings + 1] = building
                end
            end
        end

        if #validBuildings > 0 then
            targetBuilding = validBuildings[ZombRand(#validBuildings) + 1]
            return targetBuilding.cx, targetBuilding.cy, tonumber(targetBuilding.cz) or 0, targetBuilding
        end
    end

    local angle = ZombRandFloat(0, math.pi * 2)
    local dist = ZombRandFloat(minRadius, maxRadius)
    return playerX + math.cos(angle) * dist, playerY + math.sin(angle) * dist, player:getZ() or 0, nil
end

function DTNPCManager.PlanBanditHouseRoamDestination(uuid, registry)
    if not DynamicTrading_Roster then
        return nil
    end

    local npcData = DynamicTrading_Roster.GetSoul(uuid)
    if not npcData then
        return nil
    end

    local cachedSite = npcData.banditRoamSite
    if type(cachedSite) == "table" and cachedSite.x ~= nil and cachedSite.y ~= nil then
        return cachedSite.x, cachedSite.y, cachedSite.z or 0
    end

    local players = DTNPCManager.GetActivePlayers and DTNPCManager.GetActivePlayers() or {}
    if #players <= 0 then
        return nil
    end

    local player = players[ZombRand(#players) + 1]
    local minRadius, maxRadius = getRadiusRange()
    local targetX, targetY, targetZ, building = getBanditRoamBuildingTarget(player, minRadius, maxRadius)
    if targetX == nil or targetY == nil then
        return nil
    end

    npcData.banditRoamSite = {
        x = targetX,
        y = targetY,
        z = targetZ or 0,
        name = building and (building.name or building.title) or "Nearby House",
        town = building and (building.town or building.county) or nil,
        buildingID = building and (building.id or building.name) or nil,
    }
    npcData.banditRoamEncounterMode = "bribe_only"
    npcData.banditRoamAggroRadius = tonumber(npcData.banditRoamAggroRadius) or DEFAULT_BANDIT_ROAM_AGGRO_RADIUS
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
    return targetX, targetY, targetZ or 0
end

function DTNPCManager.EnterBanditHouseRoamSite(uuid, npcData, currentHours)
    if not uuid or type(npcData) ~= "table" then
        return false
    end

    local site = type(npcData.banditRoamSite) == "table" and npcData.banditRoamSite or nil
    if not site or site.x == nil or site.y == nil then
        return false
    end

    local nowHours = tonumber(currentHours) or getCurrentHours()
    local stayHours = DTNPCManager.GetBanditHouseRoamStayHours()

    npcData.banditRoamActive = true
    npcData.banditRoamStartedAt = tonumber(npcData.banditRoamStartedAt) or nowHours
    npcData.banditRoamEndsAt = nowHours + stayHours
    npcData.banditRoamReturnStatus = "Resting"
    npcData.banditRoamEncounterMode = "bribe_only"
    npcData.banditRoamAggroRadius = tonumber(npcData.banditRoamAggroRadius) or DEFAULT_BANDIT_ROAM_AGGRO_RADIUS
    npcData.status = "Trading"
    npcData.state = "Stay"
    npcData.returnTime = npcData.banditRoamEndsAt
    npcData.returnStatus = "Away"
    npcData.travelTarget = nil
    npcData.lastX = site.x
    npcData.lastY = site.y
    npcData.lastZ = site.z or 0
    npcData.anchorX = site.x
    npcData.anchorY = site.y
    npcData.anchorZ = site.z or 0
    npcData.stationaryPostX = site.x
    npcData.stationaryPostY = site.y
    npcData.stationaryPostZ = site.z or 0
    npcData.stationaryPostState = "Trading"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.isHostile = false
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    npcData.tradeCycleMode = nil
    npcData.tradeCycleDemandEligible = nil
    npcData.tradeCycleAggroRadius = nil
    npcData.tradeCycleTargetPlayerUsername = nil
    npcData.tradeCycleTargetPlayerOnlineID = nil
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
    return true
end

function DTNPCManager.StartBanditHouseRoam(uuid, forceImmediate)
    if not DynamicTrading_Roster or not uuid then
        return false
    end

    local sandbox = getSandbox()
    if sandbox.EnableBanditHouseRoamers == false then
        return false
    end

    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if not isBanditRoamSoul(soul) or tostring(soul.status or "") ~= "Resting" then
        return false
    end

    local targetX, targetY, targetZ = DTNPCManager.PlanBanditHouseRoamDestination(uuid, soul)
    if targetX == nil or targetY == nil then
        return false
    end

    local currentHours = getCurrentHours()
    local travelHours = DTNPCManager.GetBanditHouseRoamTravelHours()
    if forceImmediate == true then
        travelHours = 0.02
    end

    local liveSoul = DynamicTrading_Roster.GetSoul(uuid)
    if not liveSoul then
        return false
    end

    if DTNPCManager.ClearTradeCycleEncounterState then
        DTNPCManager.ClearTradeCycleEncounterState(liveSoul)
    end

    liveSoul.banditRoamActive = true
    liveSoul.banditRoamStartedAt = currentHours
    liveSoul.banditRoamEndsAt = nil
    liveSoul.banditRoamReturnStatus = "Resting"
    liveSoul.banditRoamEncounterMode = "bribe_only"
    liveSoul.banditRoamAggroRadius = tonumber(liveSoul.banditRoamAggroRadius) or DEFAULT_BANDIT_ROAM_AGGRO_RADIUS
    liveSoul.banditDemandStarted = nil
    liveSoul.banditDemandStartedAt = nil
    liveSoul.banditDemandResolved = nil
    liveSoul.banditLeaving = nil
    liveSoul.banditGroupID = nil
    liveSoul.banditTargetUsername = nil
    liveSoul.banditTargetOnlineID = nil
    liveSoul.hostileNegotiationGroupID = nil
    DynamicTrading_Roster.SaveSoul(uuid, liveSoul)

    if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayEvents
        and DynamicTrading.GameplayLogs.AddFactionEvent then
        local factionID = tostring(liveSoul.factionID or BANDIT_FACTION_ID)
        local raiderName = tostring(liveSoul.name or uuid)
        DynamicTrading.GameplayLogs.AddFactionEvent(
            factionID,
            DynamicTrading.GameplayEvents.BANDIT_RAID_STARTED,
            { raiderName }
        )
    end

    if targetX and targetY and DTNPCManager.TryStartLiveDeparture
        and DTNPCManager.TryStartLiveDeparture(uuid, BANDIT_ROAM_RETURN_STATUS, travelHours, targetX, targetY, targetZ or 0) then
        return true
    end

    DTNPCManager.SetNPCStatus(uuid, "Away", currentHours + travelHours, BANDIT_ROAM_RETURN_STATUS)
    return true
end

function DTNPCManager.ProcessBanditHouseRoamers()
    if not DynamicTrading_Roster then
        return
    end

    local sandbox = getSandbox()
    if sandbox.EnableBanditHouseRoamers == false then
        return
    end

    local currentHours = getCurrentHours()
    if currentHours - (DTNPCManager.LastBanditHouseRoamCheckHour or -99999) < BANDIT_ROAM_CHECK_INTERVAL_HOURS then
        return
    end
    DTNPCManager.LastBanditHouseRoamCheckHour = currentHours

    local rosterData = ModData.get("DynamicTrading_Roster")
    local souls = rosterData and rosterData.Souls or nil
    local members = rosterData and rosterData.FactionMembers and rosterData.FactionMembers[BANDIT_FACTION_ID] or nil
    if type(souls) ~= "table" or type(members) ~= "table" or #members <= 0 then
        return
    end

    local allEntries = {}
    local activeCount = 0
    local activeSet = {}
    for _, uuid in ipairs(members) do
        local registry = souls[uuid]
        if isBanditRoamSoul(registry) then
            allEntries[#allEntries + 1] = uuid
            if registry.banditRoamActive == true and (registry.status == "Away" or registry.status == "Trading") then
                activeCount = activeCount + 1
                activeSet[uuid] = true
            end
        end
    end

    if #allEntries <= 0 then
        return
    end

    sortUUIDsBySeed(allEntries, currentHours)

    local eligibleLimit = getCountFromPercent(#allEntries, sandbox.BanditHouseRoamerEligiblePercent or 50)
    if eligibleLimit <= 0 then
        return
    end

    local maxConcurrentCount = getCountFromPercent(#allEntries, sandbox.BanditHouseRoamerPopPercent or 20)
    if maxConcurrentCount <= 0 or activeCount >= maxConcurrentCount then
        return
    end

    local chance = tonumber(sandbox.BanditHouseRoamerChance) or 25.0
    if chance <= 0 then
        return
    end
    if chance < 100 and ZombRand(10000) >= math.floor(chance * 100) then
        return
    end

    for index = 1, eligibleLimit do
        local uuid = allEntries[index]
        local registry = uuid and souls[uuid] or nil
        local liveSoul = uuid and DynamicTrading_Roster.GetSoul(uuid) or nil
        local isDeparting = liveSoul and liveSoul.state == "Departure"
        if uuid
            and not activeSet[uuid]
            and registry
            and registry.status == "Resting"
            and not isDeparting
            and DTNPCManager.StartBanditHouseRoam(uuid, false) then
            return
        end
    end
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded bandit house-roamer lifecycle")
