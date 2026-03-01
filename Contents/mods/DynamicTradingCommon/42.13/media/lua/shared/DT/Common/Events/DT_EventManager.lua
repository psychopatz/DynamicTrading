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
    DynamicTrading.Events.Registry[id] = data
    
    local sentiment = data.sentiment or "Neutral"
    print("[DynamicTrading] [Events] Registered: " .. tostring(id) .. " | Type: " .. tostring(data.type) .. " | Sentiment: " .. sentiment)
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

    -- B: META & SEASONAL EVENTS (Always Active if Conditions Met)
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if (def.type == "meta" or def.type == "seasonal") and def.condition then
            local isActive = es.activeEvents[id] ~= nil
            local shouldBeActive = def.condition()
            
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

    -- C: FLASH EVENTS (Random Lottery)
    local activeFlashCount = 0
    for id, _ in pairs(es.activeEvents) do
        local def = DynamicTrading.Events.Registry[id]
        if def and def.type == "flash" then activeFlashCount = activeFlashCount + 1 end
    end

    local maxFlashEvents = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.MaxEvents) or 3

    if activeFlashCount < maxFlashEvents then
        local daysSinceLast = currentDay - (es.lastEventDay or -10)
        local interval = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.EventFrequency) or 5
        
        if daysSinceLast >= interval then
            local chance = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.EventChance) or 50
            local roll = ZombRand(100) + 1
            
            if roll <= chance then
                if DynamicTrading.Debug then
                    print("[DynamicTrading] [Events] Flash lottery won! (Roll: " .. roll .. " <= Chance: " .. chance .. ") - Selecting candidate...")
                end
                local candidates = DynamicTrading.Events.GetFlashCandidates()
                
                -- SMART FILTERING
                local validPool = {}    -- Fresh events ready to fire
                local cooldownPool = {} -- Events recently fired (Backup)

                for _, id in ipairs(candidates) do
                    -- 1. Must not be currently active
                    if not es.activeEvents[id] then
                        -- 2. Check Cooldown
                        local unlockDay = 0
                        if DynamicTrading.CooldownManager and DynamicTrading.CooldownManager.GetEventCooldown then
                            unlockDay = DynamicTrading.CooldownManager.GetEventCooldown(id)
                        end
                        
                        if currentDay >= unlockDay then
                            table.insert(validPool, id)
                        else
                            table.insert(cooldownPool, id)
                        end
                    end
                end

                -- SELECTION LOGIC
                local finalPickID = nil

                if #validPool > 0 then
                    finalPickID = validPool[ZombRand(#validPool) + 1]
                elseif #cooldownPool > 0 then
                    finalPickID = cooldownPool[ZombRand(#cooldownPool) + 1]
                end

                if finalPickID then
                    local def = DynamicTrading.Events.Registry[finalPickID]
                    if def then
                        local duration = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.EventDuration) or 3
                        es.activeEvents[finalPickID] = { expires = currentDay + duration }
                        es.lastEventDay = currentDay
                        
                        if DynamicTrading.Debug then
                            print("[DynamicTrading] [Events] New Flash Event: " .. tostring(def.name) .. " (Duration: " .. duration .. " days)")
                        end

                        if DynamicTrading.NetworkLogs and DynamicTrading.NetworkLogs.AddLog then
                            DynamicTrading.NetworkLogs.AddLog("BREAKING NEWS: " .. def.name, "event")
                        end
                        changed = true
                    end
                else
                    if DynamicTrading.Debug then
                        print("[DynamicTrading] [Events] Flash lottery won, but no valid candidates found.")
                    end
                    es.lastEventDay = currentDay
                end
            else
                if DynamicTrading.Debug then
                    print("[DynamicTrading] [Events] Flash lottery failed (Roll: " .. roll .. " > Chance: " .. chance .. ")")
                end
                es.lastEventDay = currentDay - (interval - 1)
                changed = true
            end
        end
    end

    if changed then
        if isServer() or not isClient() then ModData.transmit("DynamicTrading_Engine_v1.3") end
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


-- =============================================================================
-- 4. FACTION EVENT PROCESSING (Unified V2 Director Logic)
-- =============================================================================
function DynamicTrading.Events.UpdateFaction(faction)
    if isClient() and not isServer() then return end
    if not faction then return end
    
    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    local Sandbox = SandboxVars.DynamicTrading
    
    -- A. EXPIRY CHECK
    if faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        if currentHour >= faction.ActiveFlashEvent.expires then
            print("[DynamicTrading] [Events] Event [" .. faction.ActiveFlashEvent.id .. "] expired for faction " .. faction.id)
            faction.ActiveFlashEvent.id = nil
            faction.ActiveFlashEvent.expires = 0
            faction.ActiveFlashEvent.targetCasualties = 0 
        else
            -- Event still active, skip new triggers
            return
        end
    end

    -- B. STABILITY TRACKING (Ensure key exists)
    if faction.state == "Stable" then
        faction.consecutiveStableDays = (faction.consecutiveStableDays or 0) + 1
    else
        faction.consecutiveStableDays = 0
    end

    -- C. TRIGGER ROLL
    local baseChance = (Sandbox and Sandbox.EventChance) or 50
    local stabilityBonus = math.floor((faction.consecutiveStableDays or 0) / 7) * 10 
    local roll = ZombRand(100) + 1
    
    if roll > (baseChance + stabilityBonus) then
        return -- No event today
    end

    -- D. CANDIDATE DISCOVERY
    local candidates = {}
    local wildcardPool = {}
    
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if def.type == "flash" then
            -- Context-Aware Spawn Check
            local canSpawn = true
            if def.canSpawn then
                local ok, result = pcall(def.canSpawn, faction)
                canSpawn = ok and result
            end
            
            if canSpawn then
                table.insert(candidates, id)
                
                -- Wildcard Pool (Negative events or 5% chaos chance)
                if def.sentiment == "Negative" or roll <= 5 then
                    table.insert(wildcardPool, id)
                end
            end
        end
    end

    -- E. SELECTION
    local finalID = nil
    -- Prolonged stability increases risk of "Wildcard" crisis
    local isWildcard = (faction.consecutiveStableDays or 0) > 14 and ZombRand(100) < (faction.consecutiveStableDays) 
    
    if isWildcard and #wildcardPool > 0 then
        finalID = wildcardPool[ZombRand(#wildcardPool) + 1]
        print("[DynamicTrading] [Events] WILDCARD selected for faction " .. faction.id .. " (Stability: " .. faction.consecutiveStableDays .. ")")
    elseif #candidates > 0 then
        finalID = candidates[ZombRand(#candidates) + 1]
    end

    -- F. ACTIVATION & IMMEDIATE IMPACTS
    if finalID then
        local minDur = (Sandbox and Sandbox.V2_FlashEventMinDuration) or 24
        local maxDur = (Sandbox and Sandbox.V2_FlashEventMaxDuration) or 72
        local duration = minDur + ZombRand(maxDur - minDur + 1)
        
        -- Init Event Instance
        if not faction.ActiveFlashEvent then faction.ActiveFlashEvent = {} end
        faction.ActiveFlashEvent.id = finalID
        faction.ActiveFlashEvent.expires = currentHour + duration
        
        local def = DynamicTrading.Events.Registry[finalID]
        print("[DynamicTrading] [Events] Faction [" .. faction.id .. "] triggered: " .. tostring(def and def.name or finalID))
        
        if def then
            -- 1. Casualty Calculation (Target for Simulation)
            if def.factionImpact and def.factionImpact.memberCountPct then
                local pct = def.factionImpact.memberCountPct
                local totalToKill = math.floor(math.abs(faction.memberCount * pct))
                if totalToKill == 1 and pct < 0 then totalToKill = 1 end 
                faction.ActiveFlashEvent.targetCasualties = totalToKill
            else
                faction.ActiveFlashEvent.targetCasualties = 0
            end

            -- 2. Immediate Impacts
            if def.factionImpact then
                if def.factionImpact.wealthAdd then
                    faction.wealth = (faction.wealth or 0) + def.factionImpact.wealthAdd
                end
                
                if def.factionImpact.stockpileAdd then
                    if not faction.stockpile then faction.stockpile = {} end
                    for res, amt in pairs(def.factionImpact.stockpileAdd) do
                        faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
                    end
                end
                
                if def.factionImpact.stabilityAdd then
                    faction.consecutiveStableDays = math.max(0, (faction.consecutiveStableDays or 0) + def.factionImpact.stabilityAdd)
                end
            end

            -- 3. Reset stability on Crisis
            if def.sentiment == "Negative" then
                faction.consecutiveStableDays = 0
            end
        end
    end
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
    
    -- 2. Faction
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.system and def.system[key] then
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

    -- 2. Apply Faction Specific Logic
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.effects then
            for _, tag in ipairs(itemTags or {}) do
                if def.effects[tag] and def.effects[tag].price then
                    local fMult = def.effects[tag].price
                    if verbose and fMult ~= 1.0 then
                        print("[DynamicTrading] [Events] Faction Event [" .. faction.ActiveFlashEvent.id .. "] Multiplier for tag [" .. tag .. "] for faction [" .. (faction.id or "unknown") .. "]: " .. fMult)
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
    
    -- 2. Faction
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.stock and def.stock.volumeMult then
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
    
    -- 2. Faction
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.stock and def.stock.injections then
            for tag, count in pairs(def.stock.injections) do
                injections[tag] = (injections[tag] or 0) + count
            end
        end
    end
    
    return injections
end

function DynamicTrading.Events.GetFactionExpertTags(faction)
    local tags = {}
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.stock and def.stock.expertTags then
            for _, tag in ipairs(def.stock.expertTags) do tags[tag] = true end
        end
    end
    return tags
end

function DynamicTrading.Events.GetFactionForbidTags(faction)
    local tags = {}
    if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
        if def and def.stock and def.stock.forbidTags then
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
