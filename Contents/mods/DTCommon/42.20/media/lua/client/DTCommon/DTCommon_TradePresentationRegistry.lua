-- Client-only optional trade presentation seam.
-- DTCommon owns transport/snapshots; adopters register how a trade is rendered.

DTCommon = DTCommon or {}
DTCommon.TradePresentations = DTCommon.TradePresentations or {}

local Registry = DTCommon.TradePresentations
Registry.ByID = Registry.ByID or {}
Registry.MAX_PRESENTATIONS = 16

local function cleanID(value)
    value = tostring(value or "")
    if value == "" then return nil end
    return #value > 96 and string.sub(value, 1, 96) or value
end

function Registry.Register(id, definition)
    id = cleanID(id)
    if not id or type(definition) ~= "table" then
        return false, "invalid_presentation"
    end
    local count = 0
    for _ in pairs(Registry.ByID) do count = count + 1 end
    if not Registry.ByID[id] and count >= Registry.MAX_PRESENTATIONS then
        return false, "presentation_capacity_exceeded"
    end
    definition.id = id
    definition.priority = tonumber(definition.priority) or 0
    Registry.ByID[id] = definition
    return true
end

function Registry.Unregister(id)
    id = cleanID(id)
    if not id or not Registry.ByID[id] then return false end
    Registry.ByID[id] = nil
    return true
end

function Registry.List()
    local output = {}
    for _, definition in pairs(Registry.ByID) do
        output[#output + 1] = definition
    end
    table.sort(output, function(left, right)
        if left.priority ~= right.priority then
            return left.priority > right.priority
        end
        return tostring(left.id) < tostring(right.id)
    end)
    return output
end

local function accepts(definition, context)
    if type(definition.canHandle) ~= "function" then return true end
    local ok, value = pcall(definition.canHandle, context)
    return ok and value == true
end

-- Returns handled, opened, reason.
function Registry.Open(context)
    for _, definition in ipairs(Registry.List()) do
        if accepts(definition, context)
            and type(definition.open) == "function"
        then
            local ok, opened, reason = pcall(definition.open, context)
            if not ok then return true, false, tostring(opened) end
            return true, opened == true, reason
        end
    end
    return false, false, "unhandled"
end

function Registry.UpdateSnapshot(context)
    for _, definition in ipairs(Registry.List()) do
        if type(definition.updateSnapshot) == "function" then
            local ok, handled = pcall(definition.updateSnapshot, context)
            if ok and handled == true then return true end
        end
    end
    return false
end

function Registry.HandleResult(context)
    for _, definition in ipairs(Registry.List()) do
        if type(definition.handleResult) == "function" then
            local ok, handled = pcall(definition.handleResult, context)
            if ok and handled == true then return true end
        end
    end
    return false
end

return Registry
