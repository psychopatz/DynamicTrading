DTCorpseLootRuntime = DTCorpseLootRuntime or {}

if DTCorpseLootRuntime._bootstrapped == true then
    return
end

local Runtime = DTCorpseLootRuntime

Runtime.Pending = Runtime.Pending or {}
Runtime.TickCounter = Runtime.TickCounter or 0
Runtime.NextID = Runtime.NextID or 0
Runtime.PROCESS_INTERVAL = Runtime.PROCESS_INTERVAL or 3
Runtime.DEFAULT_TTL_TICKS = Runtime.DEFAULT_TTL_TICKS or 300
Runtime.DEFAULT_SEARCH_RADIUS = Runtime.DEFAULT_SEARCH_RADIUS or 1

local function isAuthoritativeRuntime()
    return not (isClient and isClient() and not (isServer and isServer()))
end

local function shouldSendContainerPackets()
    return sendAddItemToContainer ~= nil and isServer and isServer()
end

local function floorNumber(value)
    return math.floor(tonumber(value) or 0)
end

local function nextKey(prefix)
    Runtime.NextID = math.max(0, floorNumber(Runtime.NextID)) + 1
    local timeValue = getTimeInMillis and getTimeInMillis() or 0
    return tostring(prefix or "corpse") .. ":" .. tostring(timeValue) .. ":" .. tostring(Runtime.NextID)
end

local function getEntryRadius(entry)
    return math.max(0, floorNumber(entry and entry.radius or Runtime.DEFAULT_SEARCH_RADIUS))
end

local function getEntryTTL(entry)
    return math.max(1, floorNumber(entry and entry.ttlTicks or Runtime.DEFAULT_TTL_TICKS))
end

local function visitNearbyCorpses(centerX, centerY, centerZ, radius, callback)
    local cell = getCell and getCell() or nil
    if not cell or type(callback) ~= "function" then
        return
    end

    for x = centerX - radius, centerX + radius do
        for y = centerY - radius, centerY + radius do
            local square = cell:getGridSquare(x, y, centerZ)
            local objects = square and square.getStaticMovingObjects and square:getStaticMovingObjects() or nil
            if objects then
                for index = 0, objects:size() - 1 do
                    local corpse = objects:get(index)
                    if corpse and instanceof and instanceof(corpse, "IsoDeadBody") then
                        callback(corpse, x, y, centerZ)
                    end
                end
            end
        end
    end
end

function Runtime.CanRun()
    return isAuthoritativeRuntime()
end

function Runtime.EnsureCorpseToken(zombie, prefix)
    if not zombie or not zombie.getModData then
        return nil
    end

    local modData = zombie:getModData()
    if not modData then
        return nil
    end

    local existing = modData.DTCorpseLootToken
    if existing and tostring(existing) ~= "" then
        modData.DTCorpseLootToken = tostring(existing)
        return tostring(existing)
    end

    local token = nextKey(prefix or "corpse_token")
    modData.DTCorpseLootToken = token
    return token
end

function Runtime.MatchCorpseByToken(token, corpseModData)
    if not token or not corpseModData then
        return false
    end

    local corpseToken = corpseModData.DTCorpseLootToken
    return tostring(corpseToken or "") == tostring(token)
end

function Runtime.ContainerHasItemType(container, fullType)
    if not container or not fullType or fullType == "" then
        return false
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return false
    end

    local expected = tostring(fullType)
    for index = 0, items:size() - 1 do
        local item = items:get(index)
        local itemType = item and item.getFullType and item:getFullType() or nil
        if itemType and tostring(itemType) == expected then
            return true
        end
    end

    return false
end

function Runtime.AddItemToContainer(container, fullType, configureItem)
    if not container or not fullType then
        return nil
    end

    local item = container:AddItem(fullType)
    if not item then
        return nil
    end

    if type(configureItem) == "function" then
        local ok = pcall(configureItem, item)
        if not ok then
            if container.DoRemoveItem then
                container:DoRemoveItem(item)
            end
            return nil
        end
    end

    if shouldSendContainerPackets() then
        if item.syncItemFields then
            pcall(function()
                item:syncItemFields()
            end)
        end
        if item.transmitModData then
            pcall(function()
                item:transmitModData()
            end)
        end
        sendAddItemToContainer(container, item)
    end

    return item
end

function Runtime.AddItemsToContainer(container, fullType, count, configureItem)
    local results = {}
    local quantity = math.max(1, floorNumber(count or 1))

    for _ = 1, quantity do
        local item = Runtime.AddItemToContainer(container, fullType, configureItem)
        if item then
            results[#results + 1] = item
        end
    end

    return results
end

function Runtime.FindMatchingCorpse(entry)
    if type(entry) ~= "table" then
        return nil, nil
    end

    local centerX = floorNumber(entry.x)
    local centerY = floorNumber(entry.y)
    local centerZ = floorNumber(entry.z)
    local radius = getEntryRadius(entry)
    local matcher = entry.matcher
    local bestCorpse = nil
    local bestContainer = nil
    local bestDistanceSq = nil

    visitNearbyCorpses(centerX, centerY, centerZ, radius, function(corpse, x, y, z)
        local container = corpse and corpse.getContainer and corpse:getContainer() or nil
        if not container then
            return
        end

        local corpseModData = corpse.getModData and corpse:getModData() or nil
        local matches = true
        if type(matcher) == "function" then
            local ok, result = pcall(matcher, corpse, corpseModData, x, y, z)
            matches = ok and result == true or false
        end

        if not matches then
            return
        end

        local dx = x - centerX
        local dy = y - centerY
        local dz = z - centerZ
        local distanceSq = (dx * dx) + (dy * dy) + (dz * dz * 16)
        if not bestCorpse or distanceSq < bestDistanceSq then
            bestCorpse = corpse
            bestContainer = container
            bestDistanceSq = distanceSq
        end
    end)

    return bestCorpse, bestContainer
end

function Runtime.TryProcessEntry(entry)
    if not Runtime.CanRun() or type(entry) ~= "table" or type(entry.apply) ~= "function" then
        return false
    end

    local corpse, container = Runtime.FindMatchingCorpse(entry)
    if not corpse or not container then
        return false
    end

    local ok, applied = pcall(entry.apply, corpse, container)
    if not ok then
        return false
    end

    return applied == true
end

function Runtime.QueueCorpseMutation(entry)
    if not Runtime.CanRun() or type(entry) ~= "table" or type(entry.apply) ~= "function" then
        return nil, false
    end

    local queuedEntry = entry
    queuedEntry.key = queuedEntry.key or nextKey(queuedEntry.label or "corpse_entry")
    queuedEntry.createdAtTick = floorNumber(Runtime.TickCounter)
    queuedEntry.expiresAtTick = queuedEntry.createdAtTick + getEntryTTL(queuedEntry)
    Runtime.Pending[queuedEntry.key] = queuedEntry

    if Runtime.TryProcessEntry(queuedEntry) then
        Runtime.Pending[queuedEntry.key] = nil
        return queuedEntry.key, true
    end

    return queuedEntry.key, false
end

function Runtime.ProcessPending()
    if not Runtime.CanRun() then
        return
    end

    for key, entry in pairs(Runtime.Pending) do
        if floorNumber(entry and entry.expiresAtTick) <= floorNumber(Runtime.TickCounter) then
            Runtime.Pending[key] = nil
            if type(entry.onExpired) == "function" then
                pcall(entry.onExpired, entry)
            end
        elseif Runtime.TryProcessEntry(entry) then
            Runtime.Pending[key] = nil
        end
    end
end

local function onTick()
    if not Runtime.CanRun() then
        return
    end

    Runtime.TickCounter = floorNumber(Runtime.TickCounter) + 1
    if (Runtime.TickCounter % math.max(1, floorNumber(Runtime.PROCESS_INTERVAL))) ~= 0 then
        return
    end

    Runtime.ProcessPending()
end

if Events and Events.OnTick and Runtime._eventsRegistered ~= true then
    Events.OnTick.Add(onTick)
    Runtime._eventsRegistered = true
end

Runtime._bootstrapped = true
