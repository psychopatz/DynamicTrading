DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Nutrition = DT_Labour.Nutrition
local Warehouse = DT_Labour.Warehouse
local Network = DT_Labour.Network
local Internal = Network.Internal or {}
local Shared = (Network.Workers or {}).Shared or {}

Network.Handlers = Network.Handlers or {}

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

    Shared.saveAndRefreshProcessed(player, worker)
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

    Shared.saveAndRefreshProcessed(player, worker)
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

    Shared.saveAndRefreshProcessed(player, worker)
end

return Network
