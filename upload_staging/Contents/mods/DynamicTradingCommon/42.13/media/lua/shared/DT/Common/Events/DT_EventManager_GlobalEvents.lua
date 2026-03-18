-- =============================================================================
-- DT_EventManager_GlobalEvents.lua
-- =============================================================================
-- Global event tick processing and global modifier calculations.
-- =============================================================================

function DynamicTrading.Events.Tick(data)
    if not data or not data.EventSystem then 
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Events", "Global", "Tick: invalid engine data")
        end
        return 
    end
    
    local es = data.EventSystem
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived()) 
    local changed = false

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Events", "Global", "=== GLOBAL TICK START === (Day: " .. currentDay .. ")")
    end

    -- A: CLEANUP & COOLDOWN SETTING
    local expiredCount = 0
    for id, eventData in pairs(es.activeEvents) do
        if eventData.expires ~= -1 and currentDay >= eventData.expires then
            local def = DynamicTrading.Events.Registry[id]
            local name = def and def.name or id
            
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Events", "Global", "Event expired: " .. tostring(name) .. " (day " .. currentDay .. ")")
            end
            
            if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                DynamicTrading.NetworkLogs.AddLog("Event Ended: " .. name, "info")
            end
            
            -- Set Cooldown: Current Day + 14 Days (prevents immediate repeat)
            if DynamicTrading.CooldownManager and DynamicTrading.CooldownManager.SetEventCooldown then
                DynamicTrading.CooldownManager.SetEventCooldown(id, currentDay + 14)
            end
            
            es.activeEvents[id] = nil
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

    -- B: FORCE-CLEAR META/SEASONAL WHEN DISABLED BY SANDBOX
    local forceClearedCount = 0
    for id, _ in pairs(es.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then
            local disableMeta = def.type == "meta" and not allowMeta
            local disableSeasonal = def.type == "seasonal" and not allowSeasonal
            if disableMeta or disableSeasonal then
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Events", "Global", "Force-clearing disabled event: " .. tostring(def.name) .. " (type=" .. def.type .. ")")
                end
                es.activeEvents[id] = nil
                changed = true
                forceClearedCount = forceClearedCount + 1
            end
        end
    end

    if DynamicTrading.Debug and forceClearedCount > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Force-cleared " .. forceClearedCount .. " sandbox-disabled events")
    end

    -- C: META & SEASONAL EVENTS (Always Active if Conditions Met)
    local metaSeasonalChanged = 0
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if (def.type == "meta" or def.type == "seasonal") and def.condition then
            local isActive = es.activeEvents[id] ~= nil
            local isEnabled = (def.type == "meta" and allowMeta) or (def.type == "seasonal" and allowSeasonal)
            local shouldBeActive = isEnabled and def.condition()
            
            if shouldBeActive and not isActive then
                es.activeEvents[id] = { expires = -1 }
                
                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    DynamicTrading.Log("DTCommons", "Events", "Global", prefix .. " event ACTIVATED: " .. tostring(def.name))
                end

                if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                    local logPrefix = def.type == "seasonal" and "SEASONAL: " or "WORLD ALERT: "
                    DynamicTrading.NetworkLogs.AddLog(logPrefix .. def.name, "event")
                end
                changed = true
                metaSeasonalChanged = metaSeasonalChanged + 1
            elseif not shouldBeActive and isActive then
                es.activeEvents[id] = nil
                
                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    DynamicTrading.Log("DTCommons", "Events", "Global", prefix .. " event CLEARED: " .. tostring(def.name) .. " (condition no longer met)")
                end

                if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                    DynamicTrading.NetworkLogs.AddLog("Condition Cleared: " .. def.name, "info")
                end
                changed = true
                metaSeasonalChanged = metaSeasonalChanged + 1
            end
        end
    end

    if DynamicTrading.Debug and metaSeasonalChanged > 0 then
        DynamicTrading.Log("DTCommons", "Events", "Global", "Meta/Seasonal changes: " .. metaSeasonalChanged)
    end

    -- D: FLASH EVENTS
    -- Intentionally disabled at global-engine scope.
    -- Flash events are faction-scoped and managed by DynamicTrading.Events.UpdateFaction.

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
        for i, def in ipairs(DynamicTrading.Events.ActiveEvents) do
            DynamicTrading.Log("DTCommons", "Events", "Global", "  [" .. i .. "] " .. tostring(def.name) .. " (type=" .. tostring(def.type) .. ")")
        end
    end
end

-- Returns normalized global active event definitions (meta/seasonal only) from engine state.
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

-- =============================================================================
-- GLOBAL EVENT MODIFIERS
-- =============================================================================

function DynamicTrading.Events.GetPriceModifier(itemTags, verbose)
    local multiplier = 1.0
    if not itemTags then return 1.0 end
    verbose = verbose or DynamicTrading.Debug
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.effects then
            for _, tag in ipairs(itemTags) do
                if event.effects[tag] and event.effects[tag].price then
                    local mult = event.effects[tag].price
                    if verbose and mult ~= 1.0 then
                        DynamicTrading.Log("DTCommons", "Events", "Global", "Price modifier [" .. tostring(event.id or "event") .. "] tag=" .. tag .. " mult=" .. mult)
                    end
                    multiplier = multiplier * mult
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
            local mult = event.system[key]
            if DynamicTrading.Debug and mult ~= 1.0 then
                DynamicTrading.Log("DTCommons", "Events", "Global", "System modifier [" .. tostring(event.id or "event") .. "] key=" .. key .. " mult=" .. mult)
            end
            multiplier = multiplier * mult
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetDemographicsModifier(key)
    local modifier = nil -- Using nil for multiplicative (1.0) and additive (0) distinction
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.demographics and event.demographics[key] then
            if key:find("Mult") then
                modifier = (modifier or 1.0) * event.demographics[key]
            else
                modifier = (modifier or 0) + event.demographics[key]
            end
        end
    end
    
    -- Final defaults
    if key:find("Mult") then return modifier or 1.0 end
    return modifier or 0
end

function DynamicTrading.Events.GetWorldModifier(key, subKey)
    local modifier = nil
    
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.world then
            local val = event.world[key]
            if type(val) == "table" and subKey then
                val = val[subKey]
            end
            
            if val then
                if key:find("Mult") or (type(event.world[key]) == "table" and key:find("Mults")) then
                    modifier = (modifier or 1.0) * val
                else
                    modifier = (modifier or 0) + val
                end
            end
        end
    end
    
    if key:find("Mult") or key:find("Mults") then return modifier or 1.0 end
    return modifier or 0
end

function DynamicTrading.Events.GetInjections()
    local injections = {}
    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.inject then
            for tag, count in pairs(event.inject) do
                injections[tag] = (injections[tag] or 0) + count
            end
        end
    end
    return injections
end

DynamicTrading.Log("DTCommons", "Events", "Global", "Module Loaded.")
