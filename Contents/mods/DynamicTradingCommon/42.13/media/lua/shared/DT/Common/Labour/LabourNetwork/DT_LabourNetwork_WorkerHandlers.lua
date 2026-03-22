require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Labour/Warehouse/DT_LabourWarehouse"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites
local Nutrition = DT_Labour.Nutrition
local Sim = DT_Labour.Sim
local Presentation = DT_Labour.Presentation
local Warehouse = DT_Labour.Warehouse
local Network = DT_Labour.Network
local Internal = Network.Internal or {}

Network.Internal = Internal
Network.Handlers = Network.Handlers or {}

local function normalizeLedgerIndexes(args)
    local indexes = {}
    local seen = {}

    for _, index in ipairs(args and args.ledgerIndexes or {}) do
        local normalized = math.floor(tonumber(index) or 0)
        if normalized > 0 and not seen[normalized] then
            seen[normalized] = true
            indexes[#indexes + 1] = normalized
        end
    end

    if args and args.ledgerIndex then
        local normalized = math.floor(tonumber(args.ledgerIndex) or 0)
        if normalized > 0 and not seen[normalized] then
            indexes[#indexes + 1] = normalized
        end
    end

    table.sort(indexes, function(a, b)
        return a > b
    end)

    return indexes
end

local function withdrawWorkerNutritionEntries(worker, inventory, indexes)
    local moved = 0
    table.sort(indexes or {}, function(a, b)
        return (tonumber(a) or 0) > (tonumber(b) or 0)
    end)
    for _, index in ipairs(indexes or {}) do
        local entry = worker and worker.nutritionLedger and worker.nutritionLedger[index] or nil
        if entry and entry.fullType then
            Internal.addInventoryItem(inventory, entry.fullType, 1)
            table.remove(worker.nutritionLedger, index)
            moved = moved + 1
        end
    end
    if moved > 0 then
        DT_Labour.Registry.Internal.MarkNutritionCacheDirty(worker)
    end
    return moved
end

local function withdrawWarehouseNutritionEntries(ownerUsername, inventory, indexes)
    local moved = 0
    for _, entry in ipairs(Warehouse.TakeProvisionEntries(ownerUsername, indexes) or {}) do
        if entry and entry.fullType then
            Internal.addInventoryItem(inventory, entry.fullType, 1)
            moved = moved + 1
        end
    end
    return moved
end

local function withdrawWorkerToolEntries(worker, inventory, indexes)
    local moved = 0
    table.sort(indexes or {}, function(a, b)
        return (tonumber(a) or 0) > (tonumber(b) or 0)
    end)
    for _, index in ipairs(indexes or {}) do
        local entry = worker and worker.toolLedger and worker.toolLedger[index] or nil
        if entry and entry.fullType then
            Internal.addInventoryItem(inventory, entry.fullType, 1)
            table.remove(worker.toolLedger, index)
            moved = moved + 1
        end
    end
    if moved > 0 then
        DT_Labour.Registry.Internal.MarkToolCacheDirty(worker)
    end
    return moved
end

local function withdrawWarehouseToolEntries(ownerUsername, inventory, indexes)
    local moved = 0
    for _, entry in ipairs(Warehouse.TakeEquipmentEntries(ownerUsername, indexes) or {}) do
        if entry and entry.fullType then
            Internal.addInventoryItem(inventory, entry.fullType, 1)
            moved = moved + 1
        end
    end
    return moved
end

local function withdrawWorkerOutputEntries(worker, inventory, indexes)
    local moved = 0
    table.sort(indexes or {}, function(a, b)
        return (tonumber(a) or 0) > (tonumber(b) or 0)
    end)
    for _, index in ipairs(indexes or {}) do
        local entry = worker and worker.outputLedger and worker.outputLedger[index] or nil
        if entry and entry.fullType and (tonumber(entry.qty) or 0) > 0 then
            Internal.addInventoryItem(inventory, entry.fullType, entry.qty)
            table.remove(worker.outputLedger, index)
            moved = moved + 1
        end
    end
    if moved > 0 then
        DT_Labour.Registry.Internal.MarkOutputCacheDirty(worker)
    end
    return moved
end

local function withdrawWarehouseOutputEntries(ownerUsername, inventory, indexes)
    local moved = 0
    for _, entry in ipairs(Warehouse.TakeOutputEntries(ownerUsername, indexes) or {}) do
        if entry and entry.fullType and (tonumber(entry.qty) or 0) > 0 then
            Internal.addInventoryItem(inventory, entry.fullType, entry.qty)
            moved = moved + 1
        end
    end
    return moved
end

local function buildNaturalList(values)
    local count = #(values or {})
    if count <= 0 then
        return ""
    end
    if count == 1 then
        return tostring(values[1])
    end
    if count == 2 then
        return tostring(values[1]) .. " and " .. tostring(values[2])
    end
    return tostring(values[1]) .. ", " .. tostring(values[2]) .. ", and " .. tostring(count - 2) .. " more"
end

local function dropWorkerHaulEntries(worker, indexes)
    local droppedCount = 0
    local droppedWeight = 0
    local sampleNames = {}
    local hiddenNames = 0

    table.sort(indexes or {}, function(a, b)
        return (tonumber(a) or 0) > (tonumber(b) or 0)
    end)

    for _, index in ipairs(indexes or {}) do
        local entry = worker and worker.haulLedger and worker.haulLedger[index] or nil
        if entry and entry.fullType then
            local qty = math.max(1, tonumber(entry.qty) or 1)
            local displayName = Registry.Internal.GetDisplayNameForFullType(entry.fullType) or tostring(entry.fullType)
            local unitWeight = math.max(0, tonumber(Config.GetItemWeight and Config.GetItemWeight(entry.fullType)) or 0)
            local entryName = qty > 1 and (displayName .. " x" .. tostring(qty)) or displayName
            droppedCount = droppedCount + qty
            droppedWeight = droppedWeight + (unitWeight * qty)
            if #sampleNames < 2 then
                sampleNames[#sampleNames + 1] = entryName
            else
                hiddenNames = hiddenNames + 1
            end
            table.remove(worker.haulLedger, index)
        end
    end

    return droppedCount, droppedWeight, sampleNames, hiddenNames
end

local function canTransferWithWorkerStorage(worker)
    if not worker then
        return false
    end

    local normalizedJob = Config.NormalizeJobType and Config.NormalizeJobType(worker.jobType) or tostring(worker.jobType or "")
    if normalizedJob == ((Config.JobTypes or {}).Scavenge) then
        return tostring(worker.presenceState or (Config.PresenceStates or {}).Home) == tostring((Config.PresenceStates or {}).Home)
    end

    return true
end

Network.Handlers.AssignWorkerSite = function(player, args)
    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local x = args.x or (player and player:getX()) or nil
    local y = args.y or (player and player:getY()) or nil
    local z = args.z or (player and player:getZ()) or 0
    Sites.AssignSiteForWorker(worker, x, y, z, args.radius)
    if worker.homeX == nil or worker.homeY == nil then
        Registry.SetWorkerHome(worker, player and player:getX() or x, player and player:getY() or y, player and player:getZ() or z)
    end
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

    local fullType = invItem:getFullType()
    local tags = Config.GetItemCombinedTags and Config.GetItemCombinedTags(fullType) or Config.FindItemTags(fullType)
    if not Config.IsLabourToolFullType or not Config.IsLabourToolFullType(fullType) then return end

    Registry.AddToolEntry(worker, {
        fullType = fullType,
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

Network.Handlers.AssignWarehouseToolset = function(player, args)
    if not args or not args.workerID or not args.itemID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local invItem = Internal.getInventoryItemByID(player, args.itemID)
    if not worker or not invItem then return end

    local fullType = invItem:getFullType()
    local tags = Config.GetItemCombinedTags and Config.GetItemCombinedTags(fullType) or Config.FindItemTags(fullType)
    if not Config.IsLabourToolFullType or not Config.IsLabourToolFullType(fullType) then return end

    local stored = Warehouse.DepositEquipmentEntry(owner, {
        fullType = fullType,
        displayName = invItem:getDisplayName(),
        tags = tags
    })
    if not stored then
        Internal.syncNotice(player, "Warehouse is full. No space for that equipment.", "error")
        return
    end

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

Network.Handlers.DepositWarehouseSupplies = function(player, args)
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
            if entry and Warehouse.DepositProvisionEntry(owner, entry) then
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

Network.Handlers.DepositWarehouseOutput = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local itemIDs = args.itemIDs or {}
    if args.itemID then
        itemIDs[#itemIDs + 1] = args.itemID
    end

    local eligibleCount = 0
    local movedCount = 0
    for _, itemID in ipairs(itemIDs) do
        local invItem = Internal.getInventoryItemByID(player, itemID)
        if invItem then
            local fullType = invItem:getFullType()
            local nutritionInternal = Nutrition and Nutrition.Internal or nil
            local calories, hydration = 0, 0
            if nutritionInternal and nutritionInternal.GetExpectedStaticNutritionForFullType then
                calories, hydration = nutritionInternal.GetExpectedStaticNutritionForFullType(fullType)
            end
            if math.max(0, tonumber(calories) or 0) <= 0
                and math.max(0, tonumber(hydration) or 0) <= 0
                and not (Config.IsLabourToolFullType and Config.IsLabourToolFullType(fullType)) then
                eligibleCount = eligibleCount + 1
                local movedQty = Warehouse.DepositOutputEntry(owner, {
                    fullType = fullType,
                    qty = 1
                })
                if movedQty > 0 then
                    Internal.removeInventoryItem(invItem)
                    movedCount = movedCount + movedQty
                end
            end
        end
    end

    if movedCount <= 0 then
        if eligibleCount <= 0 then
            Internal.syncNotice(player, "No eligible storage items could be stored from that selection.", "error")
        else
            Internal.syncNotice(player, "Warehouse storage is full. No items could be stored.", "error")
        end
        return
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

    if not canTransferWithWorkerStorage(worker) then
        Internal.syncNotice(player, tostring(worker.name or worker.workerID) .. " is away from home and cannot receive supplies right now.", "error")
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

Network.Handlers.WithdrawWorkerMoney = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local amount = math.max(0, math.floor(tonumber(args.amount) or 0))

    if not worker then
        Internal.syncNotice(player, "That worker could not be found.", "error")
        return
    end

    if not canTransferWithWorkerStorage(worker) then
        Internal.syncNotice(player, tostring(worker.name or worker.workerID) .. " is away from home and cannot hand over supplies right now.", "error")
        return
    end

    if amount <= 0 then
        Internal.syncNotice(player, "Enter a valid amount of money to withdraw.", "error")
        return
    end

    local removed = Registry.RemoveMoney(worker, amount)
    if removed <= 0 then
        Internal.syncNotice(player, tostring(worker.name or worker.workerID) .. " does not have enough stored cash.", "error")
        return
    end

    if not Internal.addPlayerMoney(player, removed) then
        Registry.AddMoney(worker, removed)
        Internal.syncNotice(player, "Unable to return the cash to your inventory.", "error")
        return
    end

    Registry.Save()
    Internal.syncNotice(player, "Withdrew $" .. tostring(removed) .. " from " .. tostring(worker.name or worker.workerID) .. ".", "success")
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

Network.Handlers.CollectWarehouseOutput = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local collected = Warehouse.CollectAllOutput(owner)
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

Network.Handlers.WithdrawWorkerSupplies = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWorkerNutritionEntries(worker, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.WithdrawWarehouseSupplies = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWarehouseNutritionEntries(owner, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.WithdrawWorkerTools = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWorkerToolEntries(worker, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.WithdrawWarehouseTools = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWarehouseToolEntries(owner, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.WithdrawWorkerOutput = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWorkerOutputEntries(worker, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.WithdrawWarehouseOutput = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    local inventory = player and player:getInventory() or nil
    if not worker or not inventory then return end

    local moved = withdrawWarehouseOutputEntries(owner, inventory, normalizeLedgerIndexes(args))
    if moved <= 0 then return end

    Registry.Save()
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

Network.Handlers.DropWorkerHaulEntries = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then return end

    local normalizedJob = Config.NormalizeJobType and Config.NormalizeJobType(worker.jobType) or tostring(worker.jobType or "")
    if normalizedJob ~= ((Config.JobTypes or {}).Scavenge) then
        return
    end

    local droppedCount, droppedWeight, sampleNames, hiddenNames = dropWorkerHaulEntries(worker, normalizeLedgerIndexes(args))
    if droppedCount <= 0 then
        return
    end

    local logText = "Dropped " .. tostring(droppedCount) .. " hauled item" .. (droppedCount == 1 and "" or "s")
        .. " (" .. string.format("%.2f", math.max(0, droppedWeight)) .. " weight)"
    local nameText = buildNaturalList(sampleNames)
    if hiddenNames > 0 then
        if nameText ~= "" then
            nameText = nameText .. ", and " .. tostring(hiddenNames) .. " more"
        else
            nameText = tostring(hiddenNames) .. " more"
        end
    end
    if nameText ~= "" then
        logText = logText .. ": " .. nameText .. "."
    else
        logText = logText .. "."
    end
    Registry.Internal.AppendActivityLog(worker, logText, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour(), "haul")

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID, false)
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

Network.Handlers.DeleteDeadWorker = function(player, args)
    if not args or not args.workerID then return end

    local owner = Config.GetOwnerUsername(player)
    local worker = Registry.GetWorkerForOwner(owner, args.workerID)
    if not worker then
        Internal.syncNotice(player, "That worker could not be found.", "error")
        return
    end

    if worker.state ~= Config.States.Dead then
        Internal.syncNotice(player, tostring(worker.name or worker.workerID) .. " is not dead.", "error")
        return
    end

    local workerID = worker.workerID
    local workerName = tostring(worker.name or worker.workerID)
    if Presentation and Presentation.RemoveProjection then
        Presentation.RemoveProjection(worker)
    end

    Registry.RemoveWorkerForOwner(owner, workerID)
    Internal.sendResponse(player, Config.COMMAND_MODULE, "SyncWorkerDetails", {
        workerID = workerID
    })
    Internal.syncNotice(player, "Removed deceased worker " .. workerName .. ".", "success")
    Internal.syncWorkerList(player)
end

return Network
