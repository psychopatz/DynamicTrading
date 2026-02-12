-- =============================================================================
-- DT V2 Event System Verification
-- =============================================================================

function DT_TestDailySim()
    print("DEBUG: Manually triggering DT Daily Simulation...")
    if DynamicTrading_Engine and DynamicTrading_Engine.RunDailySimulation then
        DynamicTrading_Engine.RunDailySimulation()
    else
        print("ERROR: DynamicTrading_Engine not found!")
    end
end

function DT_CheckFactionEvents()
    local data = ModData.get("DynamicTrading_Factions")
    if not data then print("ERROR: No Faction data found!") return end
    
    print("--- Faction Event Status ---")
    for id, f in pairs(data) do
        local event = f.ActiveFlashEvent and f.ActiveFlashEvent.id or "None"
        local stable = f.consecutiveStableDays or 0
        print(string.format("[%s] State: %s | Active Event: %s | Stable Days: %d", id, f.state, event, stable))
    end
end

function DT_TestGlobalEvent()
    local engineData = DynamicTrading_Engine.GetEngineData()
    if not engineData then return end
    
    print("--- Global Event Status ---")
    if engineData.EventSystem and engineData.EventSystem.activeEvents then
        for id, info in pairs(engineData.EventSystem.activeEvents) do
            print("Active Global Event: " .. id)
        end
    else
        print("No Global Events Active.")
    end
end

print("DT Verification Script Loaded. Use DT_TestDailySim(), DT_CheckFactionEvents(), DT_TestGlobalEvent() in Lua console.")
