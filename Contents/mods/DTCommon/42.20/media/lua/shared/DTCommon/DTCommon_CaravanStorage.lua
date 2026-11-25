-- Mod-agnostic caravan capacity and distributed member storage contract.
-- Works identically for standalone DTAbstract (abstract member/backpack records)
-- and DTHoomans (live ProjectHoomans NPC + equipped backpack containers) without
-- any cross-mod dependency on ProjectHoomans. Kahlua2-safe Lua 5.1.

DTCommon = DTCommon or {}
DTCommon.CaravanStorage = DTCommon.CaravanStorage or {}

local Storage = DTCommon.CaravanStorage
Storage.VERSION = 1
Storage.Providers = Storage.Providers or {}

local DEFAULT_ROOT_CAPACITY = 16

local function safeNum(value, fallback)
    local n = tonumber(value)
    if n == nil or n ~= n or n == math.huge or n == -math.huge then
        return fallback or 0
    end
    return n
end

local function normReduction(value)
    local r = safeNum(value, 0)
    if r > 1 then r = r / 100 end
    if r < 0 then return 0 end
    if r > 0.95 then return 0.95 end
    return r
end

function Storage.RegisterProvider(providerID, adapter)
    if type(providerID) ~= "string" or providerID == "" or type(adapter) ~= "table" then
        return false, "invalid_provider"
    end
    Storage.Providers[providerID] = adapter
    Storage.ActiveProviderID = providerID
    return true
end

function Storage.GetProvider(providerID)
    if providerID and Storage.Providers[providerID] then
        return Storage.Providers[providerID]
    end
    if Storage.ActiveProviderID and Storage.Providers[Storage.ActiveProviderID] then
        return Storage.Providers[Storage.ActiveProviderID]
    end
    return nil
end

-- Ensure compact distributed-storage state exists on a trader record.
-- Works standalone for DTAbstract without requiring ProjectHoomans.
function Storage.EnsureState(traderRecord)
    if type(traderRecord) ~= "table" then return nil end
    local cs = type(traderRecord.cs) == "table" and traderRecord.cs or {}
    traderRecord.cs = cs
    cs.members = type(cs.members) == "table" and cs.members or {}
    cs.carried = type(cs.carried) == "table" and cs.carried or {}
    return cs
end

-- Register or update an abstract/live caravan member's carry profile.
-- `bags` is a list of equipped bags: { { id, maxWeight, weightReduction, usedWeight }, ... }.
function Storage.SetMemberProfile(traderRecord, memberID, profile)
    local cs = Storage.EnsureState(traderRecord)
    if not cs or not memberID then return false end
    local id = tostring(memberID)
    profile = type(profile) == "table" and profile or {}
    cs.members[id] = {
        id = id,
        alive = profile.alive ~= false,
        rootMax = math.max(1, safeNum(profile.rootMax, DEFAULT_ROOT_CAPACITY)),
        rootUsed = math.max(0, safeNum(profile.rootUsed, 0)),
        bags = type(profile.bags) == "table" and profile.bags or {},
    }
    cs.carried[id] = type(cs.carried[id]) == "table" and cs.carried[id] or {}
    return true
end

-- Compute summed effective carry capacity across all living caravan members
-- (root capacity + equipped/worn backpacks factoring weightReduction).
function Storage.ComputeEffectiveCapacity(members)
    if type(members) ~= "table" then return 0, 0, {} end
    local totalUsed = 0
    local totalMax = 0
    local slots = {}

    for _, m in pairs(members) do
        if type(m) == "table" and m.alive ~= false then
            local rootMax = math.max(0, safeNum(m.rootMax, DEFAULT_ROOT_CAPACITY))
            local rootUsed = math.max(0, safeNum(m.rootUsed, 0))
            totalUsed = totalUsed + rootUsed
            totalMax = totalMax + rootMax
            slots[#slots + 1] = {
                memberID = tostring(m.id or ""),
                containerID = "root",
                used = rootUsed,
                max = rootMax,
                free = math.max(0, rootMax - rootUsed),
                weightReduction = 0,
            }
            if type(m.bags) == "table" then
                for i = 1, #m.bags do
                    local bag = m.bags[i]
                    if type(bag) == "table" and bag.equipped ~= false then
                        local bMax = math.max(0, safeNum(bag.maxWeight, 0))
                        local bUsed = math.max(0, safeNum(bag.usedWeight, 0))
                        local red = normReduction(bag.weightReduction)
                        if bMax > 0 then
                            local effMax = bMax * (1 + red)
                            totalUsed = totalUsed + (bUsed * (1 - red))
                            totalMax = totalMax + effMax
                            slots[#slots + 1] = {
                                memberID = tostring(m.id or ""),
                                containerID = tostring(bag.id or ("bag_" .. tostring(i))),
                                used = bUsed,
                                max = bMax,
                                free = math.max(0, bMax - bUsed),
                                weightReduction = red,
                            }
                        end
                    end
                end
            end
        end
    end

    return totalUsed, totalMax, slots
end

function Storage.GetCapacity(traderRecord, providerID)
    local provider = Storage.GetProvider(providerID)
    if provider and type(provider.CollectMembers) == "function" then
        local members = provider.CollectMembers(traderRecord)
        if type(members) == "table" and #members > 0 then
            return Storage.ComputeEffectiveCapacity(members)
        end
    end
    local cs = type(traderRecord) == "table" and traderRecord.cs or nil
    if cs and type(cs.members) == "table" then
        return Storage.ComputeEffectiveCapacity(cs.members)
    end
    return nil
end

-- Dynamically spread incoming items across all living caravan members' storage
-- (preferring equipped backpacks with higher weight reduction & free space).
-- Returns a placement list: { { memberID, containerID, fullType, qty }, ... }.
function Storage.DistributeStock(traderRecord, items, opts)
    local cs = Storage.EnsureState(traderRecord)
    if not cs or type(items) ~= "table" then return {} end
    local provider = Storage.GetProvider(opts and opts.providerID)
    local members = (provider and type(provider.CollectMembers) == "function"
        and provider.CollectMembers(traderRecord)) or cs.members
    local _, _, slots = Storage.ComputeEffectiveCapacity(members)
    if #slots == 0 then return {} end

    local placements = {}
    for i = 1, #items do
        local entry = items[i]
        local fullType = type(entry) == "table" and tostring(entry.fullType or entry.type or "") or ""
        local remaining = math.max(0, math.floor(safeNum(entry and entry.qty, 1)))
        local unitWeight = math.max(0.05, safeNum(entry and entry.weight, 0.5))
        if fullType ~= "" and remaining > 0 then
            table.sort(slots, function(a, b)
                if a.weightReduction ~= b.weightReduction then
                    return a.weightReduction > b.weightReduction
                end
                if a.free ~= b.free then return a.free > b.free end
                return a.memberID < b.memberID
            end)
            for s = 1, #slots do
                if remaining <= 0 then break end
                local slot = slots[s]
                local canFit = math.floor((slot.free + 0.0001) / unitWeight)
                if canFit > 0 then
                    local take = math.min(remaining, canFit)
                    slot.free = math.max(0, slot.free - (take * unitWeight))
                    slot.used = slot.used + (take * unitWeight)
                    remaining = remaining - take
                    local bagMap = cs.carried[slot.memberID] or {}
                    cs.carried[slot.memberID] = bagMap
                    bagMap[fullType] = (tonumber(bagMap[fullType]) or 0) + take
                    placements[#placements + 1] = {
                        memberID = slot.memberID,
                        containerID = slot.containerID,
                        fullType = fullType,
                        qty = take,
                    }
                    if provider and type(provider.PlaceItem) == "function" then
                        provider.PlaceItem(traderRecord, slot.memberID, slot.containerID, fullType, take)
                    end
                end
            end
        end
    end
    return placements
end

-- Pull items from the specific caravan member(s) carrying them (e.g. player buy
-- or trader self-use of bandages/food/upgrades).
function Storage.PullStock(traderRecord, fullType, qty, opts)
    local cs = Storage.EnsureState(traderRecord)
    if not cs or type(fullType) ~= "string" or fullType == "" then return 0, {} end
    local need = math.max(0, math.floor(safeNum(qty, 1)))
    local provider = Storage.GetProvider(opts and opts.providerID)
    local preferredMember = opts and opts.memberID and tostring(opts.memberID) or nil
    local pulled = 0
    local sources = {}

    local order = {}
    if preferredMember and cs.carried[preferredMember] then
        order[#order + 1] = preferredMember
    end
    for memberID, _ in pairs(cs.carried) do
        if memberID ~= preferredMember then
            order[#order + 1] = memberID
        end
    end
    table.sort(order)

    for i = 1, #order do
        if pulled >= need then break end
        local memberID = order[i]
        local map = cs.carried[memberID]
        local have = math.max(0, math.floor(safeNum(map and map[fullType], 0)))
        if have > 0 then
            local take = math.min(need - pulled, have)
            local left = have - take
            map[fullType] = left > 0 and left or nil
            pulled = pulled + take
            sources[#sources + 1] = { memberID = memberID, fullType = fullType, qty = take }
            if provider and type(provider.RemoveItem) == "function" then
                provider.RemoveItem(traderRecord, memberID, fullType, take)
            end
        end
    end

    -- Also decrement sellable stock table `traderRecord.s` when requested.
    if pulled > 0 and (not opts or opts.syncSellableStock ~= false)
        and type(traderRecord.s) == "table" and traderRecord.s[fullType] ~= nil
    then
        local cur = math.max(0, math.floor(safeNum(traderRecord.s[fullType], 0)))
        local nextQty = math.max(0, cur - pulled)
        traderRecord.s[fullType] = nextQty > 0 and nextQty or nil
    end
    return pulled, sources
end

-- When a caravan member dies, deduct ONLY the items that specific member was
-- carrying from the caravan's sellable stock. In DTHoomans those physical items
-- stay on the corpse to loot; in DTAbstract they are cleanly lost from stock.
function Storage.OnMemberDied(traderRecord, memberID)
    local cs = Storage.EnsureState(traderRecord)
    if not cs or not memberID then return {} end
    local id = tostring(memberID)
    if type(cs.members[id]) == "table" then
        cs.members[id].alive = false
    end
    local lost = {}
    local carried = cs.carried[id]
    if type(carried) == "table" then
        for fullType, qty in pairs(carried) do
            local count = math.max(0, math.floor(safeNum(qty, 0)))
            if count > 0 then
                lost[fullType] = count
                if type(traderRecord.s) == "table" and traderRecord.s[fullType] ~= nil then
                    local cur = math.max(0, math.floor(safeNum(traderRecord.s[fullType], 0)))
                    local nextQty = math.max(0, cur - count)
                    traderRecord.s[fullType] = nextQty > 0 and nextQty or nil
                end
            end
        end
        cs.carried[id] = nil
    end
    return lost
end

return Storage
