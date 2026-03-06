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
    data.type = data.type or "flash"
    data.id = data.id or id
    DynamicTrading.Events.Registry[id] = data
    
    local sentiment = data.sentiment or "Neutral"
    print("[DynamicTrading] [Events] Registered: " .. tostring(id) .. " | Type: " .. tostring(data.type) .. " | Sentiment: " .. sentiment)
end

-- Phase-A helper: shared clamp logic for faction flash slot bounds.
function DynamicTrading.Events.GetFactionFlashSlotBounds()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local minActive = tonumber(sandbox.FactionFlashMinActive) or 1
    local maxActive = tonumber(sandbox.FactionFlashMaxActive) or 1

    if minActive < 0 then minActive = 0 end
    if maxActive < minActive then maxActive = minActive end

    return minActive, maxActive
end

-- =============================================================================
-- 3. EVENT PROCESSING (Moved from Manager.lua)
-- =============================================================================

function DynamicTrading.Events.Tick(data)
    if not data or not data.EventSystem then return end
    
    local es = data.EventSystem
    local currentDay = math.floor(GameTime:getInstance():getDaysSurvived()) 
    local changed = false

    if DynamicTrading.Debug then
        print("[DynamicTrading] [Events] Hourly Tick - Processing Events (Day: " .. currentDay .. ")")
    end

    -- A: CLEANUP & COOLDOWN SETTING
    for id, eventData in pairs(es.activeEvents) do
        if eventData.expires ~= -1 and currentDay >= eventData.expires then
            local def = DynamicTrading.Events.Registry[id]
            local name = def and def.name or id
            
            if DynamicTrading.Debug then
                print("[DynamicTrading] [Events] Event Expired: " .. tostring(name))
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
        end
    end

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local allowMeta = sandbox.AllowMetaEvents ~= false
    local allowSeasonal = sandbox.AllowSeasonalEvents ~= false

    -- B: FORCE-CLEAR META/SEASONAL WHEN DISABLED BY SANDBOX
    for id, _ in pairs(es.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def then
            local disableMeta = def.type == "meta" and not allowMeta
            local disableSeasonal = def.type == "seasonal" and not allowSeasonal
            if disableMeta or disableSeasonal then
                es.activeEvents[id] = nil
                changed = true
            end
        end
    end

    -- C: META & SEASONAL EVENTS (Always Active if Conditions Met)
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if (def.type == "meta" or def.type == "seasonal") and def.condition then
            local isActive = es.activeEvents[id] ~= nil
            local isEnabled = (def.type == "meta" and allowMeta) or (def.type == "seasonal" and allowSeasonal)
            local shouldBeActive = isEnabled and def.condition()
            
            if shouldBeActive and not isActive then
                es.activeEvents[id] = { expires = -1 }
                
                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    print("[DynamicTrading] [Events] " .. prefix .. " Event ACTIVATED: " .. tostring(def.name))
                end

                if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                    local logPrefix = def.type == "seasonal" and "SEASONAL: " or "WORLD ALERT: "
                    DynamicTrading.NetworkLogs.AddLog(logPrefix .. def.name, "event")
                end
                changed = true
            elseif not shouldBeActive and isActive then
                es.activeEvents[id] = nil
                
                if DynamicTrading.Debug then
                    local prefix = def.type == "seasonal" and "Seasonal" or "Meta"
                    print("[DynamicTrading] [Events] " .. prefix .. " Event CLEARED: " .. tostring(def.name))
                end

                if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                    DynamicTrading.NetworkLogs.AddLog("Condition Cleared: " .. def.name, "info")
                end
                changed = true
            end
        end
    end

    -- D: FLASH EVENTS
    -- Intentionally disabled at global-engine scope.
    -- Flash events are faction-scoped and managed by DynamicTrading.Events.UpdateFaction.

    if changed then
        if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v2") end
        DynamicTrading.Events.RebuildActiveCache(data)
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

    if DynamicTrading.Debug and count > 0 then
        -- Silenced: [DynamicTrading] [Events] Active Cache Rebuilt
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

    return list
end


-- =============================================================================
-- 4. FACTION EVENT PROCESSING (Unified V2 Director Logic)
-- =============================================================================
local function ensureFactionFlashSchema(faction)
    faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}

    -- Migrate legacy single-event field if needed.
    if faction.ActiveFlashEvent and faction.ActiveFlashEvent.id and #faction.ActiveFlashEvents == 0 then
        table.insert(faction.ActiveFlashEvents, {
            id = faction.ActiveFlashEvent.id,
            expires = faction.ActiveFlashEvent.expires or 0,
            targetCasualties = faction.ActiveFlashEvent.targetCasualties or 0
        })
    end

    return faction.ActiveFlashEvents
end

local function syncLegacyActiveFlashMirror(faction)
    local first = faction.ActiveFlashEvents and faction.ActiveFlashEvents[1]
    faction.ActiveFlashEvent = {
        id = first and first.id or nil,
        expires = first and (first.expires or 0) or 0,
        targetCasualties = first and (first.targetCasualties or 0) or 0
    }
end

function DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    local defs = {}
    if not faction then return defs end

    local entries = ensureFactionFlashSchema(faction)
    for _, entry in ipairs(entries) do
        if entry and entry.id then
            local def = DynamicTrading.Events.Registry[entry.id]
            if def then table.insert(defs, def) end
        end
    end
    return defs
end

function DynamicTrading.Events.UpdateFaction(faction)
    if isClient() and not isServer() then return end
    if not faction then return end

    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local active = ensureFactionFlashSchema(faction)

    -- A. EXPIRE OLD EVENTS
    for i = #active, 1, -1 do
        local entry = active[i]
        if not entry or not entry.id then
            table.remove(active, i)
        elseif currentHour >= (entry.expires or 0) then
            if DynamicTrading.Debug then
                print("[DynamicTrading] [Events] Event [" .. tostring(entry.id) .. "] expired for faction " .. tostring(faction.id))
            end
            table.remove(active, i)
        end
    end

    -- B. STABILITY TRACKING
    if faction.state == "Stable" then
        faction.consecutiveStableDays = (faction.consecutiveStableDays or 0) + 1
    else
        faction.consecutiveStableDays = 0
    end

    local minSlots, maxSlots = DynamicTrading.Events.GetFactionFlashSlotBounds()
    local baseChance = tonumber(sandbox.EventChance) or 50
    local stabilityBonus = math.floor((faction.consecutiveStableDays or 0) / 7) * 10

    local function isAlreadyActive(id)
        for _, e in ipairs(active) do
            if e and e.id == id then return true end
        end
        return false
    end

    local function buildCandidatePools(roll)
        local candidates = {}
        local wildcardPool = {}

        for id, def in pairs(DynamicTrading.Events.Registry) do
            if def.type == "flash" and not isAlreadyActive(id) then
                local canSpawn = true
                if def.canSpawn then
                    local ok, result = pcall(def.canSpawn, faction)
                    canSpawn = ok and result
                end

                if canSpawn then
                    table.insert(candidates, id)
                    if def.sentiment == "Negative" or (roll and roll <= 5) then
                        table.insert(wildcardPool, id)
                    end
                end
            end
        end

        return candidates, wildcardPool
    end

    local function activateEvent(finalID)
        local minDur = tonumber(sandbox.V2_FlashEventMinDuration) or 24
        local maxDur = tonumber(sandbox.V2_FlashEventMaxDuration) or 72
        if maxDur < minDur then maxDur = minDur end

        local duration = minDur + ZombRand(maxDur - minDur + 1)
        local entry = {
            id = finalID,
            expires = currentHour + duration,
            targetCasualties = 0
        }

        local def = DynamicTrading.Events.Registry[finalID]
        if def and def.factionImpact and def.factionImpact.memberCountPct then
            local pct = def.factionImpact.memberCountPct
            local totalToKill = math.floor(math.abs((faction.memberCount or 0) * pct))
            if totalToKill == 1 and pct < 0 then totalToKill = 1 end
            entry.targetCasualties = totalToKill
        end

        table.insert(active, entry)

        if DynamicTrading.Debug then
            print("[DynamicTrading] [Events] Faction [" .. tostring(faction.id) .. "] triggered: " .. tostring(def and def.name or finalID))
        end

        if def and def.factionImpact then
            if def.factionImpact.wealthAdd then
                faction.wealth = (faction.wealth or 0) + def.factionImpact.wealthAdd
            end

            if def.factionImpact.stockpileAdd then
                faction.stockpile = faction.stockpile or {}
                for res, amt in pairs(def.factionImpact.stockpileAdd) do
                    faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
                end
            end

            if def.factionImpact.stabilityAdd then
                faction.consecutiveStableDays = math.max(0, (faction.consecutiveStableDays or 0) + def.factionImpact.stabilityAdd)
            end
        end

        if def and def.sentiment == "Negative" then
            faction.consecutiveStableDays = 0
        end
    end

    local function trySpawn(force)
        if #active >= maxSlots then return false end

        local roll = ZombRand(100) + 1
        local threshold = baseChance + stabilityBonus
        if not force and roll > threshold then
            return false
        end

        local candidates, wildcardPool = buildCandidatePools(roll)
        if #candidates == 0 and #wildcardPool == 0 then
            return false
        end

        local isWildcard = (not force) and ((faction.consecutiveStableDays or 0) > 14)
            and (ZombRand(100) < (faction.consecutiveStableDays or 0))

        local finalID = nil
        if isWildcard and #wildcardPool > 0 then
            finalID = wildcardPool[ZombRand(#wildcardPool) + 1]
        elseif #candidates > 0 then
            finalID = candidates[ZombRand(#candidates) + 1]
        end

        if finalID then
            activateEvent(finalID)
            return true
        end
        return false
    end

    -- C. GUARANTEE MIN SLOTS
    while #active < minSlots do
        if not trySpawn(true) then break end
    end

    -- D. OPTIONAL EXTRA SPAWN UP TO MAX SLOTS
    if #active < maxSlots then
        trySpawn(false)
    end

    syncLegacyActiveFlashMirror(faction)
end

-- 2. ECONOMY HOOKS (GETTERS)
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
                        print("[DynamicTrading] [Events] Global Price Multiplier [" .. tostring(event.id or "event") .. "] for tag [" .. tag .. "]: " .. mult)
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
                print("[DynamicTrading] [Events] Global System Multiplier [" .. tostring(event.id or "event") .. "] for key [" .. key .. "]: " .. mult)
            end
            multiplier = multiplier * mult
        end
    end
    return multiplier
end

function DynamicTrading.Events.GetFactionSystemModifier(faction, key)
    local multiplier = 1.0
    
    -- 1. Global
    if DynamicTrading.Events.GetSystemModifier then
        multiplier = multiplier * DynamicTrading.Events.GetSystemModifier(key)
    end
    
    -- 2. Faction (all active flash events)
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.system and def.system[key] then
            multiplier = multiplier * def.system[key]
        end
    end
    
    return multiplier
end


-- =============================================================================
-- FACTION SPECIFIC MODIFIERS (Previously Director)
-- =============================================================================

function DynamicTrading.Events.GetFactionPriceModifier(faction, itemTags, verbose)
    local multiplier = 1.0
    verbose = verbose or DynamicTrading.Debug

    -- 1. Apply Global Modifiers First
    if DynamicTrading.Events.GetPriceModifier then
        multiplier = multiplier * DynamicTrading.Events.GetPriceModifier(itemTags, verbose)
    end

    -- 2. Apply Faction Specific Logic (all active flash events)
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.effects then
            for _, tag in ipairs(itemTags or {}) do
                if def.effects[tag] and def.effects[tag].price then
                    local fMult = def.effects[tag].price
                    if verbose and fMult ~= 1.0 then
                        print("[DynamicTrading] [Events] Faction Event [" .. tostring(def.id or "event") .. "] Multiplier for tag [" .. tag .. "] for faction [" .. (faction.id or "unknown") .. "]: " .. fMult)
                    end
                    multiplier = multiplier * fMult
                end
            end
        end
    end
    
    if verbose and multiplier ~= 1.0 then
        print("[DynamicTrading] [Events] Final Unified Price Multiplier: " .. multiplier)
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

function DynamicTrading.Events.GetFactionVolumeModifier(faction, itemTags)
    local multiplier = 1.0
    
    -- 1. Global
    if DynamicTrading.Events.GetVolumeModifier then
        multiplier = multiplier * DynamicTrading.Events.GetVolumeModifier(itemTags)
    end
    
    -- 2. Faction (all active flash events)
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.stock and def.stock.volumeMult then
            multiplier = multiplier * def.stock.volumeMult
        end
    end
    
    return multiplier
end

function DynamicTrading.Events.GetFactionInjections(faction)
    local injections = {}
    
    -- 1. Global
    if DynamicTrading.Events.GetInjections then
         local global = DynamicTrading.Events.GetInjections()
         for k,v in pairs(global) do injections[k] = v end
    end
    
    -- 2. Faction (all active flash events)
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.stock and def.stock.injections then
            for tag, count in pairs(def.stock.injections) do
                injections[tag] = (injections[tag] or 0) + count
            end
        end
    end
    
    return injections
end

function DynamicTrading.Events.GetFactionExpertTags(faction)
    local tags = {}
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.stock and def.stock.expertTags then
            for _, tag in ipairs(def.stock.expertTags) do tags[tag] = true end
        end
    end
    return tags
end

function DynamicTrading.Events.GetFactionForbidTags(faction)
    local tags = {}
    for _, def in ipairs(DynamicTrading.Events.GetFactionFlashEventDefs(faction)) do
        if def.stock and def.stock.forbidTags then
            for _, tag in ipairs(def.stock.forbidTags) do tags[tag] = true end
        end
    end
    return tags
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
