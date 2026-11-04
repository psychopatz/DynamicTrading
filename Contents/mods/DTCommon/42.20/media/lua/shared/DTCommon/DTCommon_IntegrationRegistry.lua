-- Optional adopter integration seams for DTCommon.
-- Common domain code asks for bounded capabilities; it never reaches directly
-- into optional adopter implementation globals.

DTCommon = DTCommon or {}
DTCommon.Integrations = DTCommon.Integrations or {}

local Registry = DTCommon.Integrations

Registry.TraderAdapters = Registry.TraderAdapters or {}
Registry.MAX_ADAPTERS = 16

local function cleanID(value)
    value = tostring(value or "")
    if value == "" then return nil end
    if #value > 96 then value = string.sub(value, 1, 96) end
    return value
end

local function adapterCount()
    local total = 0
    for _ in pairs(Registry.TraderAdapters) do total = total + 1 end
    return total
end

function Registry.RegisterTraderAdapter(id, adapter)
    id = cleanID(id)
    if not id or type(adapter) ~= "table" then
        return false, "invalid_trader_adapter"
    end
    if not Registry.TraderAdapters[id]
        and adapterCount() >= Registry.MAX_ADAPTERS
    then
        return false, "trader_adapter_capacity_exceeded"
    end
    local existing = Registry.TraderAdapters[id] or {}
    local merged = {}
    for key, value in pairs(existing) do merged[key] = value end
    for key, value in pairs(adapter) do merged[key] = value end
    merged.id = id
    merged.priority = tonumber(merged.priority) or 0
    Registry.TraderAdapters[id] = merged
    return true, existing.id and "trader_adapter_updated"
        or "trader_adapter_registered"
end

function Registry.UnregisterTraderAdapter(id)
    id = cleanID(id)
    if not id or not Registry.TraderAdapters[id] then return false end
    Registry.TraderAdapters[id] = nil
    return true
end

function Registry.ListTraderAdapters()
    local output = {}
    for _, adapter in pairs(Registry.TraderAdapters) do
        output[#output + 1] = adapter
    end
    table.sort(output, function(left, right)
        if left.priority ~= right.priority then
            return left.priority > right.priority
        end
        return tostring(left.id) < tostring(right.id)
    end)
    return output
end

local function matches(adapter, record)
    if type(adapter.matches) ~= "function" then return true end
    local ok, value = pcall(adapter.matches, record)
    return ok and value == true
end

function Registry.FindTraderAdapter(record, capability)
    for _, adapter in ipairs(Registry.ListTraderAdapters()) do
        if matches(adapter, record)
            and (not capability or type(adapter[capability]) == "function")
        then
            return adapter
        end
    end
    return nil
end

function Registry.ApplyCapacity(record, store)
    local adapter = Registry.FindTraderAdapter(record, "getCapacity")
    if not adapter then return nil, nil, "unhandled" end
    local ok, used, maximum = pcall(adapter.getCapacity, record, store)
    if not ok then return nil, nil, tostring(used) end
    return tonumber(used), tonumber(maximum), "handled"
end

function Registry.ResolveDisplayName(record)
    local adapter = Registry.FindTraderAdapter(record, "displayName")
    if not adapter then return nil, "unhandled" end
    local ok, value = pcall(adapter.displayName, record)
    if not ok then return nil, tostring(value) end
    if type(value) ~= "string" or value == "" then
        return nil, "unresolved"
    end
    return value, "handled"
end

-- Returns handled, allowed, reason. A matching adopter is responsible for
-- complete physical validation (body, role, faction, distance, etc.).
function Registry.ValidateTraderAccess(player, record, mode, actorID)
    local adapter = Registry.FindTraderAdapter(record, "validateAccess")
    if not adapter then return false, false, "unhandled" end
    local ok, allowed, reason = pcall(
        adapter.validateAccess, player, record, mode, actorID)
    if not ok then return true, false, tostring(allowed) end
    return true, allowed == true, reason
end

function Registry.ResolvePhysicalBody(record)
    local adapter = Registry.FindTraderAdapter(record, "resolveBody")
    if not adapter then return nil, "unhandled" end
    local ok, body = pcall(adapter.resolveBody, record)
    if not ok then return nil, tostring(body) end
    return body, body and "handled" or "body_unavailable"
end

return Registry
