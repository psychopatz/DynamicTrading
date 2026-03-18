require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Registry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/DT_Labour_Nutrition"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Nutrition = DT_Labour.Nutrition
local Sim = DT_Labour.Sim
local Presentation = DT_Labour.Presentation
local Network = DT_Labour.Network

local function sendResponse(player, module, command, args)
    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(player, module, command, args)
        return
    end

    if isServer() then
        sendServerCommand(player, module, command, args)
    else
        triggerEvent("OnServerCommand", module, command, args)
    end
end

local function removeInventoryItem(item)
    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.RemoveItem then
        DynamicTrading.ServerHelpers.RemoveItem(item)
        return
    end

    if not item then return end
    local container = item:getContainer()
    if container then
        container:DoRemoveItem(item)
    end
end

local function addInventoryItem(container, fullType, count)
    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.AddItem then
        return DynamicTrading.ServerHelpers.AddItem(container, fullType, count)
    end

    if not container or not fullType then return nil end
    return container:AddItems(fullType, count or 1)
end

local function canUseDebugRecruit(player)
    if DynamicTrading and DynamicTrading.Debug then
        return true
    end

    if isDebugEnabled and isDebugEnabled() then
        return true
    end

    if player and player.getAccessLevel then
        local accessLevel = player:getAccessLevel()
        if accessLevel and accessLevel ~= "" and accessLevel ~= "None" then
            return true
        end
    end

    return false
end

local function getPlayerByOwner(ownerUsername)
    local targetOwner = Config.GetOwnerUsername(ownerUsername)
    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for i = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(i)
            if player and Config.GetOwnerUsername(player) == targetOwner then
                return player
            end
        end
    end
    return Config.GetPlayerObject()
end

local function syncWorkerList(player)
    local owner = Config.GetOwnerUsername(player)
    sendResponse(player, Config.COMMAND_MODULE, "SyncPlayerWorkers", {
        workers = Registry.GetWorkerSummariesForOwner(owner)
    })
end

local function syncWorkerDetail(player, workerID)
    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerDetailsForOwner(owner, workerID)
    sendResponse(player, Config.COMMAND_MODULE, "SyncWorkerDetails", {
        worker = worker
    })
end

local function findInventoryItemRecursive(container, itemID)
    if not container or not itemID then return nil end
    local items = container:getItems()
    if not items then return nil end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and item:getID() == itemID then
            return item
        end
        if item and instanceof(item, "InventoryContainer") then
            local subContainer = item:getItemContainer()
            local found = findInventoryItemRecursive(subContainer, itemID)
            if found then return found end
        end
    end

    return nil
end

local function getInventoryItemByID(player, itemID)
    if not player or not itemID then return nil end
    return findInventoryItemRecursive(player:getInventory(), itemID)
end

local function clampReputation(value)
    local rep = tonumber(value) or 0
    if rep > 100 then return 100 end
    if rep < -100 then return -100 end
    return math.floor(rep + (rep >= 0 and 0.5 or -0.5))
end

local function sanitizeReputationKey(text)
    return tostring(text or "unknown"):gsub("[^%w_%-]", "_")
end

local function getReputationCharacterKey(player)
    if not player then return nil end

    local modData = player:getModData()
    if modData and modData.DT_ReputationCharacterKey and modData.DT_ReputationCharacterKey ~= "" then
        return modData.DT_ReputationCharacterKey
    end

    local desc = player.getDescriptor and player:getDescriptor() or nil
    local first = desc and desc:getForename() or "Survivor"
    local last = desc and desc:getSurname() or "Unknown"
    local username = (player.getUsername and player:getUsername()) or "local"
    local steamID = "0"
    if player.getSteamID then
        local rawSteamID = player:getSteamID()
        if rawSteamID and rawSteamID ~= 0 and rawSteamID ~= "0" then
            if type(rawSteamID) == "number" then
                steamID = string.format("%.0f", rawSteamID)
            else
                steamID = tostring(rawSteamID)
            end
        end
    end

    local mode = isServer() and "MP" or ((isClient() and not isServer()) and "MP" or "SP")
    return table.concat({
        mode,
        sanitizeReputationKey(username),
        sanitizeReputationKey(steamID),
        sanitizeReputationKey(first),
        sanitizeReputationKey(last),
    }, "_")
end

local function getPlayerReputationEntry(player)
    local modData = player and player:getModData() or nil
    if not modData then return nil end

    local store = modData.DT_ReputationState
    if type(store) ~= "table" then
        return nil
    end

    local characterKey = getReputationCharacterKey(player)
    if not characterKey then return nil end

    local entry = store[characterKey]
    if type(entry) ~= "table" then
        return nil
    end

    return entry
end

local function getEffectiveRecruitReputation(player, traderUUID, factionID)
    local entry = getPlayerReputationEntry(player)
    if type(entry) ~= "table" then
        return 0
    end

    local personalRep = type(entry.personalRep) == "table" and (entry.personalRep[tostring(traderUUID or "")] or 0) or 0
    local factionBias = type(entry.factionBias) == "table" and (entry.factionBias[tostring(factionID or "")] or 0) or 0
    return clampReputation(personalRep + factionBias)
end

local function getCurrentDay()
    return math.floor((Config.GetCurrentHour() or 0) / Config.HOURS_PER_DAY)
end

local function syncRecruitAttemptResult(player, result)
    sendResponse(player, Config.COMMAND_MODULE, "SyncRecruitAttemptResult", result or {})
end

local function createWorkerFromRecruitArgs(owner, args)
    local archetypeID = Config.NormalizeArchetypeID(args.archetypeID or args.profession)
    local worker = Registry.CreateWorker(owner, {
        jobType = args.jobType or Config.GetDefaultJobForArchetype(archetypeID),
        profession = args.jobType or Config.GetDefaultJobForArchetype(archetypeID),
        archetypeID = archetypeID,
        name = args.name,
        isFemale = args.isFemale,
        identitySeed = args.identitySeed,
        sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil,
        sourceNPCType = args.sourceNPCType or "ConversationUI"
    })

    if args.x and args.y then
        Sites.AssignSiteForWorker(worker, args.x, args.y, args.z or 0, args.radius)
    end

    return worker
end

Network.Handlers = Network.Handlers or {}

function Network.HandleCommand(player, command, args)
    local handler = Network.Handlers[command]
    if handler then
        return handler(player, args or {})
    end
end

Network.Handlers.RequestPlayerWorkers = function(player, args)
    syncWorkerList(player)
end

Network.Handlers.RequestWorkerDetails = function(player, args)
    if not args or not args.workerID then return end
    syncWorkerDetail(player, args.workerID)
end

Network.Handlers.AttemptRecruitWorker = function(player, args)
    if not player then return end
    args = args or {}

    local owner = Config.GetOwnerUsername(player)
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    if not sourceNPCID then
        syncRecruitAttemptResult(player, {
            success = false,
            reasonCode = "missing_target",
            message = "I can't sort out who you're trying to recruit right now."
        })
        return
    end

    local existingWorker = Registry.FindWorkerBySourceID(owner, sourceNPCID)
    if existingWorker then
        syncRecruitAttemptResult(player, {
            success = false,
            alreadyRecruited = true,
            sourceNPCID = sourceNPCID,
            workerID = existingWorker.workerID,
            reasonCode = "already_recruited",
            message = "I'm already part of your labour roster."
        })
        syncWorkerDetail(player, existingWorker.workerID)
        syncWorkerList(player)
        return
    end

    local reputation = getEffectiveRecruitReputation(player, args.traderUUID or sourceNPCID, args.factionID)
    if reputation < Config.RECRUIT_REQUIRED_REPUTATION then
        syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "low_reputation",
            reputation = reputation,
            requiredReputation = Config.RECRUIT_REQUIRED_REPUTATION,
            message = "We aren't close enough for that yet. Earn more trust first."
        })
        return
    end

    local currentDay = getCurrentDay()
    local attemptState = Registry.GetRecruitAttempt(owner, sourceNPCID)
    if attemptState and tonumber(attemptState.lastAttemptDay) == currentDay then
        syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "cooldown",
            reputation = reputation,
            currentDay = currentDay,
            nextAttemptDay = currentDay + 1,
            message = "I've already given you my answer for today. Ask me again tomorrow."
        })
        return
    end

    local chance = math.max(0, math.min(100, tonumber(Config.RECRUIT_DAILY_CHANCE) or 0))
    local roll = ZombRand(100)
    local succeeded = roll < chance

    Registry.SetRecruitAttempt(owner, sourceNPCID, {
        lastAttemptDay = currentDay,
        lastRoll = roll,
        lastChance = chance,
        lastSuccess = succeeded
    })

    if not succeeded then
        Registry.Save()
        syncRecruitAttemptResult(player, {
            success = false,
            sourceNPCID = sourceNPCID,
            reasonCode = "rolled_failed",
            reputation = reputation,
            chance = chance,
            roll = roll,
            currentDay = currentDay,
            nextAttemptDay = currentDay + 1,
            message = "Not today. Give me until tomorrow and ask again."
        })
        return
    end

    local worker = createWorkerFromRecruitArgs(owner, args)
    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncRecruitAttemptResult(player, {
        success = true,
        sourceNPCID = sourceNPCID,
        workerID = worker.workerID,
        reasonCode = "recruited",
        reputation = reputation,
        chance = chance,
        roll = roll,
        currentDay = currentDay,
        message = "Alright. I'll join your labour roster."
    })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.AssignWorkerSite = function(player, args)
    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local x = args.x or (player and player:getX()) or nil
    local y = args.y or (player and player:getY()) or nil
    local z = args.z or (player and player:getZ()) or 0
    Sites.AssignSiteForWorker(worker, x, y, z, args.radius)
    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.AssignWorkerToolset = function(player, args)
    if not args or not args.workerID or not args.itemID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local invItem = getInventoryItemByID(player, args.itemID)
    if not worker or not invItem then return end

    local tags = Config.FindItemTags(invItem:getFullType())
    if not Config.HasMatchingTag(tags, "Tool") then return end

    Registry.AddToolEntry(worker, {
        fullType = invItem:getFullType(),
        displayName = invItem:getDisplayName(),
        tags = tags
    })
    removeInventoryItem(invItem)
    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.DepositWorkerSupplies = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local itemIDs = args.itemIDs or {}
    if args.itemID then
        itemIDs[#itemIDs + 1] = args.itemID
    end

    for _, itemID in ipairs(itemIDs) do
        local invItem = getInventoryItemByID(player, itemID)
        if invItem then
            local entry = Nutrition.BuildEntryFromItem(invItem)
            if entry then
                Registry.AddNutritionEntry(worker, entry)
                removeInventoryItem(invItem)
            end
        end
    end

    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.CollectWorkerOutput = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local collected = Registry.CollectOutput(worker)
    local inventory = player and player:getInventory() or nil
    if inventory then
        for _, entry in ipairs(collected) do
            if entry.fullType and (entry.qty or 0) > 0 then
                addInventoryItem(inventory, entry.fullType, entry.qty)
            end
        end
    end

    Registry.Save()
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.SetWorkerJobEnabled = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    Registry.SetWorkerJobEnabled(worker, args.enabled == true)
    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.SetWorkerJobType = function(player, args)
    if not args or not args.workerID or not args.jobType then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    Registry.SetWorkerJobType(worker, args.jobType)
    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

Network.Handlers.DebugRecruitWorker = function(player, args)
    if not player or not canUseDebugRecruit(player) then return end
    args = args or {}

    local owner = Config.GetOwnerUsername(player)
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    local worker = sourceNPCID and Registry.FindWorkerBySourceID(owner, sourceNPCID) or nil

    if not worker then
        worker = createWorkerFromRecruitArgs(owner, args)
    end

    Registry.Save()
    Sim.ProcessWorker(worker, Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    syncWorkerDetail(player, worker.workerID)
    syncWorkerList(player)
end

return Network
