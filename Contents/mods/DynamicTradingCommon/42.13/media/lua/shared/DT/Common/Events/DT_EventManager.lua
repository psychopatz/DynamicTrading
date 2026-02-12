-- =============================================================================
--  DT_EventManager.lua
-- =============================================================================
--  Shared Event Manager for Dynamic Trading V1 and V2.
-- =============================================================================

-- Generic Global Initialization (Breaks circular dependency with Config.lua)
DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = DynamicTrading.Events or {}
DynamicTrading.Events.Registry = DynamicTrading.Events.Registry or {}
DynamicTrading.Events.ActiveEvents = DynamicTrading.Events.ActiveEvents or {} 

-- =============================================================================
-- 1. REGISTRATION API
-- =============================================================================
function DynamicTrading.Events.Register(id, data)
    if not id or not data then return end
    -- Default to "flash" if not explicitly set
    if not data.type then data.type = "flash" end
    DynamicTrading.Events.Registry[id] = data
    
    print("[DynamicTrading] [Events] Registered: " .. tostring(id) .. " (" .. tostring(data.type) .. ")")
end

-- =============================================================================
-- 2. ECONOMY HOOKS (GETTERS)
-- =============================================================================

function DynamicTrading.Events.GetPriceModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].price then
                    multiplier = multiplier * event.effects[tag].price
                    if DynamicTrading.Debug then
                        print("[DynamicTrading] [Events] Price Mod: " .. tostring(tag) .. " x" .. tostring(event.effects[tag].price) .. " (Total: " .. tostring(multiplier) .. ")")
                    end
                end
            end
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetVolumeModifier(itemTags)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].vol then
                    multiplier = multiplier * event.effects[tag].vol
                    if DynamicTrading.Debug then
                        print("[DynamicTrading] [Events] Volume Mod: " .. tostring(tag) .. " x" .. tostring(event.effects[tag].vol) .. " (Total: " .. tostring(multiplier) .. ")")
                    end
                end
            end
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetSystemModifier(key)
    local multiplier = 1.0
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.system and event.system[key] then
            multiplier = multiplier * event.system[key]
            if DynamicTrading.Debug then
                print("[DynamicTrading] [Events] System Mod: " .. tostring(key) .. " x" .. tostring(event.system[key]) .. " (Total: " .. tostring(multiplier) .. ")")
            end
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetInjections()
    local injections = {}
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.inject then
            for tag, count in pairs(event.inject) do
                injections[tag] = (injections[tag] or 0) + count
                if DynamicTrading.Debug then
                    print("[DynamicTrading] [Events] Injecting: " .. tostring(tag) .. " (+" .. tostring(count) .. ")")
                end
            end
        end
    end
    return injections
end

function DynamicTrading.Events.GetFlashCandidates()
    local candidates = {}
    for id, event in pairs(DynamicTrading.Events.Registry) do
        if event.type == "flash" then
            local success, shouldSpawn = pcall(function()
                if event.canSpawn then return event.canSpawn() end
                return true
            end)
            
            if success and shouldSpawn == true then
                table.insert(candidates, id)
            end
        end
    end
    return candidates
end

print("[DynamicTrading] Common Event Manager Initialized.")
