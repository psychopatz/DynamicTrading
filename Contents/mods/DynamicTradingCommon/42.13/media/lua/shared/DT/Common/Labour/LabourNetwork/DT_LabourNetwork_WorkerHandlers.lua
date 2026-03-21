require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
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
local Internal = Network.Internal or {}

Network.Internal = Internal
Network.Handlers = Network.Handlers or {}

Network.Handlers.AssignWorkerSite = function(player, args)
    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local x = args.x or (player and player:getX()) or nil
    local y = args.y or (player and player:getY()) or nil
    local z = args.z or (player and player:getZ()) or 0
    Sites.AssignSiteForWorker(worker, x, y, z, args.radius)
    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.AssignWorkerToolset = function(player, args)
    if not args or not args.workerID or not args.itemID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local invItem = Internal.getInventoryItemByID(player, args.itemID)
    if not worker or not invItem then return end

    local tags = Config.FindItemTags(invItem:getFullType())
    if not Config.HasMatchingTag(tags, "Tool") then return end

    Registry.AddToolEntry(worker, {
        fullType = invItem:getFullType(),
        displayName = invItem:getDisplayName(),
        tags = tags
    })
    Internal.removeInventoryItem(invItem)
    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
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
        local invItem = Internal.getInventoryItemByID(player, itemID)
        if invItem then
            local entry = Nutrition.BuildEntryFromItem(invItem)
            if entry then
                Registry.AddNutritionEntry(worker, entry)
                Internal.removeInventoryItem(invItem)
            end
        end
    end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.GiveWorkerMoney = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local amount = math.max(0, math.floor(tonumber(args.amount) or 0))

    if not worker then
        Internal.syncNotice(player, "That worker could not be found.", "error")
        return
    end

    if amount <= 0 then
        Internal.syncNotice(player, "Enter a valid amount of money to give.", "error")
        return
    end

    if not Internal.removePlayerMoney(player, amount) then
        Internal.syncNotice(player, "You do not have enough money for that transfer.", "error")
        return
    end

    Registry.AddMoney(worker, amount)
    Registry.Save()
    Internal.syncNotice(player, "Gave $" .. tostring(amount) .. " to " .. tostring(worker.name or worker.workerID) .. ".", "success")
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
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
                Internal.addInventoryItem(inventory, entry.fullType, entry.qty)
            end
        end
    end

    Registry.Save()
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.SetWorkerJobEnabled = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    Registry.SetWorkerJobEnabled(worker, args.enabled == true)
    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.SetWorkerJobType = function(player, args)
    if not args or not args.workerID or not args.jobType then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    Registry.SetWorkerJobType(worker, args.jobType)
    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

return Network
