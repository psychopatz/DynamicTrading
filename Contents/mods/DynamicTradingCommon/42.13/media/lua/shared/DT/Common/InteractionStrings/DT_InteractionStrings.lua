require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.InteractionStrings = DynamicTrading.InteractionStrings or {}

local InteractionStrings = DynamicTrading.InteractionStrings

InteractionStrings.Registry = InteractionStrings.Registry or {}
InteractionStrings.ModuleList = InteractionStrings.ModuleList or {
    "DT/Common/InteractionStrings/Labour/Locations/DT_InteractionStrings_Labour_Locations_Common",
    "DT/Common/InteractionStrings/Labour/Progress/DT_InteractionStrings_Labour_Progress_Common",
    "DT/Common/InteractionStrings/Labour/Progress/DT_InteractionStrings_Labour_Progress_Scavenge",
    "DT/Common/InteractionStrings/Labour/Progress/DT_InteractionStrings_Labour_Progress_Fish",
    "DT/Common/InteractionStrings/Labour/Progress/DT_InteractionStrings_Labour_Progress_Farm",
    "DT/Common/InteractionStrings/Labour/Progress/DT_InteractionStrings_Labour_Progress_Builder",
    "DT/Common/InteractionStrings/Labour/Outcome/DT_InteractionStrings_Labour_Outcome_Common",
    "DT/Common/InteractionStrings/Labour/Outcome/DT_InteractionStrings_Labour_Outcome_Scavenge",
    "DT/Common/InteractionStrings/Labour/Outcome/DT_InteractionStrings_Labour_Outcome_Fish",
    "DT/Common/InteractionStrings/Labour/Outcome/DT_InteractionStrings_Labour_Outcome_Farm"
}

local function mergeNestedTables(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return source
    end

    for key, value in pairs(source) do
        local existing = target[key]
        if type(existing) == "table" and type(value) == "table" and not existing[1] and not value[1] then
            mergeNestedTables(existing, value)
        else
            target[key] = value
        end
    end

    return target
end

local function pathExists(path)
    local fullPath = "media/lua/shared/" .. path .. ".lua"
    local checked = false
    local exists = false

    if getZomboidFileSystem then
        local fs = getZomboidFileSystem()
        if fs then
            local file = fs:getFile(fullPath)
            exists = file and file:exists() or false
            checked = true
        end
    elseif ZomboidFileSystem and ZomboidFileSystem.instance then
        local file = ZomboidFileSystem.instance:getFile(fullPath)
        exists = file and file:exists() or false
        checked = true
    elseif _G.fileExists then
        exists = _G.fileExists(fullPath) or false
        checked = true
    end

    if not checked then
        exists = true
    end

    return exists
end

local function getNestedValue(source, keyPath)
    local current = source
    for token in string.gmatch(tostring(keyPath or ""), "[^%.]+") do
        if type(current) ~= "table" then
            return nil
        end
        current = current[token]
    end
    return current
end

function DynamicTrading.RegisterInteractionStrings(systemID, partID, data)
    if not systemID or not partID or type(data) ~= "table" then
        return
    end

    InteractionStrings.Registry[systemID] = InteractionStrings.Registry[systemID] or {}
    InteractionStrings.Registry[systemID][partID] = InteractionStrings.Registry[systemID][partID] or {}
    mergeNestedTables(InteractionStrings.Registry[systemID][partID], data)
end

function DynamicTrading.GetInteractionStrings(systemID, partID)
    local systemTable = InteractionStrings.Registry[tostring(systemID or "")]
    if type(systemTable) ~= "table" then
        return nil
    end
    return systemTable[tostring(partID or "")]
end

function DynamicTrading.ResolveInteractionString(systemID, partID, keyPath)
    local source = DynamicTrading.GetInteractionStrings(systemID, partID)
    if not keyPath or keyPath == "" then
        return source
    end
    return getNestedValue(source, keyPath)
end

function DynamicTrading.FormatInteractionString(template, tokens)
    local text = tostring(template or "")
    return (string.gsub(text, "{(.-)}", function(token)
        local value = getNestedValue(tokens or {}, token)
        if value == nil then
            return "{" .. tostring(token) .. "}"
        end
        return tostring(value)
    end))
end

function DynamicTrading.LoadInteractionStrings()
    if InteractionStrings.loaded then
        return
    end

    local loadedCount = 0
    for _, path in ipairs(InteractionStrings.ModuleList or {}) do
        if pathExists(path) then
            local ok, err = pcall(require, path)
            if ok then
                loadedCount = loadedCount + 1
            else
                DynamicTrading.Log("DTCommons", "InteractionStrings", "Error", "Failed to load module " .. tostring(path) .. ": " .. tostring(err))
            end
        end
    end

    InteractionStrings.loaded = true
    DynamicTrading.Log("DTCommons", "InteractionStrings", "Init", "Loaded InteractionStrings modules: " .. tostring(loadedCount))
end

DynamicTrading.LoadInteractionStrings()

return InteractionStrings
