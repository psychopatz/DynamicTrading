-- =============================================================================
-- DT_EventManagerGlobal_UpdateLogic.lua
-- =============================================================================
-- Global event tick processing and cache management.
-- =============================================================================

function DynamicTrading.Events.Tick(data)
    if not data or not data.EventSystem then
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Events", "Global", "Tick: invalid engine data")
        end
        return
    end

    local eventSystem = data.EventSystem
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived())
    local changed = false

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Global", "=== GLOBAL TICK START === (Day: " .. currentDay .. ")")
    end

    local expiredCount = 0
    for id, eventData in pairs(eventSystem.activeEvents) do
        if eventData.expires ~= -1 and currentDay >= eventData.expires then
            local def = DynamicTrading.Events.Registry[id]
            local name = def and def.name or id

            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Events", "Global", "Event expired: " .. tostring(name) .. " (day " .. currentDay .. ")")
            end

            if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddRadioEvent then
                DynamicTrading.GameplayLogs.AddRadioEvent(DynamicTrading.GameplayEvents.SIGNAL_RELEASED, {"Event Ended: " .. name, "info"})
            end

            if DynamicTrading.CooldownManager and DynamicTrading.CooldownManager.SetEventCooldown then
                DynamicTrading.CooldownManager.SetEventCooldown(id, currentDay + 14)
            end

            eventSystem.activeEvents[id] = nil
            changed = true
            expiredCount = expiredCount + 1
        end
    end

    if DynamicTrading.Debug and expiredCount > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Cleanup: Removed " .. expiredCount .. " expired events")
    end

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local allowMeta = sandbox.AllowMetaEvents ~= false
    local allowSeasonal = sandbox.AllowSeasonalEvents ~= false

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Sandbox state: AllowMeta=" .. tostring(allowMeta) .. " AllowSeasonal=" .. tostring(allowSeasonal))
    end

    local forceClearedCount = 0
    for id, _ in pairs(eventSystem.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then
            local disableMeta = def.type == "meta" and not allowMeta
            local disableSeasonal = def.type == "seasonal" and not allowSeasonal
            if disableMeta or disableSeasonal then
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Events", "Global", "Force-clearing disabled event: " .. tostring(def.name) .. " (type=" .. def.type .. ")")
                end
                eventSystem.activeEvents[id] = nil
                changed = true
                forceClearedCount = forceClearedCount + 1
            end
        end
    end

    if DynamicTrading.Debug and forceClearedCount > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Force-cleared " .. forceClearedCount .. " sandbox-disabled events")
    end

    local metaSeasonalChanged = 0
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if (def.type == "meta" or def.type == "seasonal") and def.condition then
            local isActive = eventSystem.activeEvents[id] ~= nil
            local isEnabled = (def.type == "meta" and allowMeta) or (def.type == "seasonal" and allowSeasonal)
            local shouldBeActive = isEnabled and def.condition()

            if shouldBeActive and not isActive then
                eventSystem.activeEvents[id] = { expires = -1 }

                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    DynamicTrading.Log("DTCommons", "Events", "Global", prefix .. " event ACTIVATED: " .. tostring(def.name))
                end

                local logPrefix = def.type == "seasonal" and "SEASONAL: " or "WORLD ALERT: "
                if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddRadioEvent then
                    DynamicTrading.GameplayLogs.AddRadioEvent(DynamicTrading.GameplayEvents.SIGNAL_ACQUIRED, {logPrefix .. def.name, "event"})
                end
                if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                    DynamicTrading.NetworkLogs.AddLog(logPrefix .. def.name, "event")
                end
                changed = true
                metaSeasonalChanged = metaSeasonalChanged + 1
            elseif not shouldBeActive and isActive then
                eventSystem.activeEvents[id] = nil

                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    DynamicTrading.Log("DTCommons", "Events", "Global", prefix .. " event CLEARED: " .. tostring(def.name) .. " (condition no longer met)")
                end

                if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddRadioEvent then
                    DynamicTrading.GameplayLogs.AddRadioEvent(DynamicTrading.GameplayEvents.SIGNAL_RELEASED, {"Condition Cleared: " .. def.name, "info"})
                end
                changed = true
                metaSeasonalChanged = metaSeasonalChanged + 1
            end
        end
    end

    if DynamicTrading.Debug and metaSeasonalChanged > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Meta/Seasonal changes: " .. metaSeasonalChanged)
    end

    if changed then
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Events", "Global", "Change detected, transmitting engine data and rebuilding cache")
        end
        if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
        DynamicTrading.Events.RebuildActiveCache(data)
    end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Global", "=== GLOBAL TICK END ===")
    end
end

function DynamicTrading.Events.RebuildActiveCache(data)
    DynamicTrading.Events.ActiveEvents = {}
    if not data or not data.EventSystem or not data.EventSystem.activeEvents then return end

    local count = 0
    for id, _ in pairs(data.EventSystem.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then
            table.insert(DynamicTrading.Events.ActiveEvents, def)
            count = count + 1
        end
    end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Cache rebuilt: " .. count .. " active global events")
        for index, def in ipairs(DynamicTrading.Events.ActiveEvents) do
            DynamicTrading.Log("DTCommons", "Events", "Global", "  [" .. index .. "] " .. tostring(def.name) .. " (type=" .. tostring(def.type) .. ")")
        end
    end
end

function DynamicTrading.Events.GetActiveGlobalEventDefs(engineData)
    local list = {}

    if not engineData and DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData then
        engineData = DynamicTrading_Engine.GetEngineData()
    end

    local activeMap = engineData and engineData.EventSystem and engineData.EventSystem.activeEvents
    if type(activeMap) ~= "table" then return list end

    for id, _ in pairs(activeMap) do
        local def = DynamicTrading.Events.Registry[id]
        if def and def.type ~= "flash" then
            table.insert(list, def)
        end
    end

    if DynamicTrading.Debug and #list > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "GetActiveGlobalEventDefs returned " .. #list .. " events")
    end

    return list
end