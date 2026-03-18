-- =============================================================================
-- DT V2 Event System Verification
-- =============================================================================

function DT_TestDailySim()
    DynamicTrading.Log("DTV2", "Debug", "Sim", "DEBUG: Manually triggering DT Daily Simulation...")
    if DynamicTrading_Engine and DynamicTrading_Engine.RunDailySimulation then
        DynamicTrading_Engine.RunDailySimulation()
    else
        DynamicTrading.Log("DTV2", "Debug", "Error", "ERROR: DynamicTrading_Engine not found!")
    end
end

function DT_CheckFactionEvents()
    local data = ModData.get("DynamicTrading_Factions")
    if not data then DynamicTrading.Log("DTV2", "Debug", "Error", "ERROR: No Faction data found!") return end
    
    DynamicTrading.Log("DTV2", "Debug", "Status", "--- Faction Event Status ---")
    for id, f in pairs(data) do
        local flashEvents = f.ActiveFlashEvents or {}
        if #flashEvents == 0 and f.ActiveFlashEvent and f.ActiveFlashEvent.id then
            flashEvents = { { id = f.ActiveFlashEvent.id } }
        end
        local event = "None"
        if #flashEvents > 0 then
            local ids = {}
            for _, entry in ipairs(flashEvents) do
                if entry and entry.id then table.insert(ids, tostring(entry.id)) end
            end
            event = table.concat(ids, ", ")
        end
        local stable = f.consecutiveStableDays or 0
        DynamicTrading.Log("DTV2", "Debug", "Status", string.format("[%s] State: %s | Active Event: %s | Stable Days: %d", id, f.state, event, stable))
    end
end

function DT_TestGlobalEvent()
    local engineData = DynamicTrading_Engine.GetEngineData()
    if not engineData then return end
    
    DynamicTrading.Log("DTV2", "Debug", "Status", "--- Global Event Status ---")
    if engineData.EventSystem and engineData.EventSystem.activeEvents then
        for id, info in pairs(engineData.EventSystem.activeEvents) do
            DynamicTrading.Log("DTV2", "Debug", "Status", "Active Global Event: " .. id)
        end
    else
        DynamicTrading.Log("DTV2", "Debug", "Status", "No Global Events Active.")
    end
end

DynamicTrading.Log("DTV2", "System", "Init", "DT Verification Script Loaded. Use DT_TestDailySim(), DT_CheckFactionEvents(), DT_TestGlobalEvent() in Lua console.")
