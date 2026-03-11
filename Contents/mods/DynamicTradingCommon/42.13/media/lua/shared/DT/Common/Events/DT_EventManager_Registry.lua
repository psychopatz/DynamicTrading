-- =============================================================================
-- DT_EventManager_Registry.lua
-- =============================================================================
-- Event registration and configuration helpers.
-- =============================================================================

function DynamicTrading.Events.Register(id, data)
    if not id or not data then 
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Events", "Registry", "WARN: Register called with invalid id or data")
        end
        return 
    end
    data.type = data.type or "flash"
    data.id = data.id or id
    DynamicTrading.Events.Registry[id] = data
    
    local sentiment = data.sentiment or "Neutral"
    DynamicTrading.Log("DTCommons", "Events", "Registry", "Registered event: " .. tostring(id) .. " | Type: " .. tostring(data.type) .. " | Sentiment: " .. sentiment)
end

function DynamicTrading.Events.GetFactionFlashSlotBounds()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local minActive = tonumber(sandbox.FactionFlashMinActive) or 1
    local maxActive = tonumber(sandbox.FactionFlashMaxActive) or 1

    if minActive < 0 then minActive = 0 end
    if maxActive < minActive then maxActive = minActive end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Registry", "Flash slot bounds: min=" .. minActive .. " max=" .. maxActive)
    end

    return minActive, maxActive
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
    
    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Registry", "Found " .. #candidates .. " flash event candidates")
    end
    
    return candidates
end

DynamicTrading.Log("DTCommons", "Events", "Registry", "Module Loaded.")
