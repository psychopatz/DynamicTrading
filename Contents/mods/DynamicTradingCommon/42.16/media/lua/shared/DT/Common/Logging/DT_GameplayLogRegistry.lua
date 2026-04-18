DynamicTrading = DynamicTrading or {}
DynamicTrading.GameplayLogRegistry = DynamicTrading.GameplayLogRegistry or {}

local Registry = DynamicTrading.GameplayLogRegistry

Registry.ModuleList = Registry.ModuleList or {
    "DT/Common/Logging/Registry/DT_GameplayLogEvents_Faction",
    "DT/Common/Logging/Registry/DT_GameplayLogEvents_Radio"
}

function DynamicTrading.RegisterGameplayLogModule(path)
    if not path or path == "" then
        return
    end

    local modules = Registry.ModuleList
    for _, existingPath in ipairs(modules) do
        if existingPath == path then
            return
        end
    end

    modules[#modules + 1] = path
end

function DynamicTrading.LoadGameplayLogRegistry()
    if Registry.loaded then
        return
    end

    local loadedCount = 0
    for _, path in ipairs(Registry.ModuleList or {}) do
        local ok, err = pcall(require, path)
        if ok then
            loadedCount = loadedCount + 1
        elseif DynamicTrading and DynamicTrading.Log then
            DynamicTrading.Log("DTCommons", "GameplayLogs", "Error", "Failed to load gameplay-log registry module " .. tostring(path) .. ": " .. tostring(err))
        end
    end

    Registry.loaded = true
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "GameplayLogs", "Init", "Loaded gameplay-log registry modules: " .. tostring(loadedCount))
    end
end

return Registry