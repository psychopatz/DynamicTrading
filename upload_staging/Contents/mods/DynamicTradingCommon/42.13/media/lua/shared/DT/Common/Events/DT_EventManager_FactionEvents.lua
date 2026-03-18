-- =============================================================================
-- DT_EventManager_FactionEvents.lua
-- =============================================================================
-- Faction flash event processing and faction-specific modifier calculations.
-- =============================================================================

-- =============================================================================
-- SCHEMA HELPERS
-- =============================================================================

local function ensureFactionFlashSchema(faction)
    faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}

    -- Migrate legacy single-event field if needed.
    if faction.ActiveFlashEvent and faction.ActiveFlashEvent.id and #faction.ActiveFlashEvents == 0 then
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Event", "Logic", "Migrating legacy ActiveFlashEvent into list for faction " .. tostring(faction.id))
        end
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

-- =============================================================================
-- FACTION UPDATE LOGIC
-- =============================================================================

function DynamicTrading.Events.UpdateFaction(faction)
    if isClient() and not isServer() then return end
    if not faction then return end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "=== FACTION UPDATE START === [" .. tostring(faction.id) .. "]")
    end

    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local active = ensureFactionFlashSchema(faction)

    -- A. EXPIRE OLD EVENTS
    local expiredCount = 0
    for i = #active, 1, -1 do
        local entry = active[i]
        if not entry or not entry.id then
            table.remove(active, i)
        elseif currentHour >= (entry.expires or 0) then
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "Event expired: " .. tostring(entry.id) .. " for faction " .. tostring(faction.id))
            end
            table.remove(active, i)
            expiredCount = expiredCount + 1
        end
    end

    if DynamicTrading.Debug and expiredCount > 0 then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Removed " .. expiredCount .. " expired events from faction " .. tostring(faction.id))
    end

    -- B. STABILITY TRACKING
    if faction.state == "Stable" then
        faction.consecutiveStableDays = (faction.consecutiveStableDays or 0) + 1
    else
        faction.consecutiveStableDays = 0
    end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Faction " .. tostring(faction.id) .. " state=" .. (faction.state or "unknown") .. " stableDays=" .. (faction.consecutiveStableDays or 0))
    end

    local minSlots, maxSlots = DynamicTrading.Events.GetFactionFlashSlotBounds()
    local baseChance = tonumber(sandbox.EventChance) or 50
    local stabilityBonus = math.floor((faction.consecutiveStableDays or 0) / 7) * 10

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Slot bounds: min=" .. minSlots .. " max=" .. maxSlots .. " | Current active: " .. #active)
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Spawn chance: base=" .. baseChance .. " stability_bonus=" .. stabilityBonus .. " total=" .. (baseChance + stabilityBonus))
    end

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

        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Event", "Logic", "Candidate pools: candidates=" .. #candidates .. " wildcard=" .. #wildcardPool)
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
            DynamicTrading.Log("DTCommons", "Event", "Logic", "Faction [" .. tostring(faction.id) .. "] flash event ACTIVATED: " .. tostring(def and def.name or finalID) .. " duration=" .. duration .. "h targetCasulties=" .. entry.targetCasualties)
        end

        if def and def.factionImpact then
            if def.factionImpact.wealthAdd then
                faction.wealth = (faction.wealth or 0) + def.factionImpact.wealthAdd
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "Wealth applied: +" .. def.factionImpact.wealthAdd)
                end
            end

            if def.factionImpact.stockpileAdd then
                faction.stockpile = faction.stockpile or {}
                for res, amt in pairs(def.factionImpact.stockpileAdd) do
                    faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
                    if DynamicTrading.Debug then
                        DynamicTrading.Log("DTCommons", "Event", "Logic", "Stockpile: " .. res .. " +" .. amt)
                    end
                end
            end

            if def.factionImpact.stabilityAdd then
                local oldStability = faction.consecutiveStableDays or 0
                faction.consecutiveStableDays = math.max(0, oldStability + def.factionImpact.stabilityAdd)
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "Stability: " .. oldStability .. " -> " .. faction.consecutiveStableDays)
                end
            end
        end

        if def and def.sentiment == "Negative" then
            faction.consecutiveStableDays = 0
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "Negative event: stability reset to 0")
            end
        end
    end

    local function trySpawn(force)
        if #active >= maxSlots then 
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "trySpawn: already at max slots (" .. maxSlots .. ")")
            end
            return false 
        end

        local roll = ZombRand(100) + 1
        local threshold = baseChance + stabilityBonus
        if not force and roll > threshold then
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "trySpawn: roll " .. roll .. " > threshold " .. threshold .. " (no spawn)")
            end
            return false
        end

        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Event", "Logic", "trySpawn: roll " .. roll .. " <= threshold " .. threshold .. " (attempting spawn)")
        end

        local candidates, wildcardPool = buildCandidatePools(roll)
        if #candidates == 0 and #wildcardPool == 0 then
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "trySpawn: no valid candidates")
            end
            return false
        end

        local isWildcard = (not force) and ((faction.consecutiveStableDays or 0) > 14)
            and (ZombRand(100) < (faction.consecutiveStableDays or 0))

        local finalID = nil
        if isWildcard and #wildcardPool > 0 then
            finalID = wildcardPool[ZombRand(#wildcardPool) + 1]
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "WILDCARD selected: " .. tostring(finalID) .. " (stableDays=" .. (faction.consecutiveStableDays or 0) .. ")")
            end
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
    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Enforcing minimum slots: " .. minSlots)
    end
    while #active < minSlots do
        if not trySpawn(true) then break end
    end

    -- D. OPTIONAL EXTRA SPAWN UP TO MAX SLOTS
    if #active < maxSlots then
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Event", "Logic", "Attempting optional spawn up to max")
        end
        trySpawn(false)
    end

    syncLegacyActiveFlashMirror(faction)

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "=== FACTION UPDATE END === [" .. tostring(faction.id) .. "] active_events=" .. #active)
    end
end

-- =============================================================================
-- FACTION SPECIFIC MODIFIERS
-- =============================================================================

function DynamicTrading.Events.GetFactionSystemModifier(faction, key)
    local multiplier = 1.0
    
    -- 1. Global
    if DynamicTrading.Events.GetSystemModifier then
        multiplier = multiplier * DynamicTrading.Events.GetSystemModifier(key)
    end
    
    -- 2. Faction (all active flash events)
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.system and def.system[key] then
            multiplier = multiplier * def.system[key]
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "System modifier from flash: " .. tostring(def.name) .. " key=" .. key .. " mult=" .. def.system[key])
            end
        end
    end
    
    return multiplier
end

function DynamicTrading.Events.GetFactionPriceModifier(faction, itemTags, verbose)
    local multiplier = 1.0
    verbose = verbose or DynamicTrading.Debug

    -- 1. Apply Global Modifiers First
    if DynamicTrading.Events.GetPriceModifier then
        multiplier = multiplier * DynamicTrading.Events.GetPriceModifier(itemTags, verbose)
    end

    -- 2. Apply Faction Specific Logic (all active flash events)
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.effects then
            for _, tag in ipairs(itemTags or {}) do
                if def.effects[tag] and def.effects[tag].price then
                    local fMult = def.effects[tag].price
                    if verbose and fMult ~= 1.0 then
                        DynamicTrading.Log("DTCommons", "Event", "Logic", "Flash price mult from " .. tostring(def.name) .. " tag=" .. tag .. " for faction=" .. (faction.id or "unknown") .. " mult=" .. fMult)
                    end
                    multiplier = multiplier * fMult
                end
            end
        end
    end
    
    if verbose and multiplier ~= 1.0 then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Final faction price multiplier: " .. multiplier)
    end

    return multiplier
end

function DynamicTrading.Events.GetFactionVolumeModifier(faction, itemTags)
    local multiplier = 1.0
    
    -- 1. Global
    if DynamicTrading.Events.GetVolumeModifier then
        multiplier = multiplier * DynamicTrading.Events.GetVolumeModifier(itemTags)
    end
    
    -- 2. Faction (all active flash events)
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.stock and def.stock.volumeMult then
            multiplier = multiplier * def.stock.volumeMult
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "Volume mult from flash: " .. tostring(def.name) .. " mult=" .. def.stock.volumeMult)
            end
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
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.stock and def.stock.injections then
            for tag, count in pairs(def.stock.injections) do
                injections[tag] = (injections[tag] or 0) + count
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "Injection from flash: " .. tostring(def.name) .. " tag=" .. tag .. " count=" .. count)
                end
            end
        end
    end
    
    return injections
end

function DynamicTrading.Events.GetFactionExpertTags(faction)
    local tags = {}
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.stock and def.stock.expertTags then
            for _, tag in ipairs(def.stock.expertTags) do 
                tags[tag] = true
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "Expert tag from flash: " .. tostring(def.name) .. " tag=" .. tag)
                end
            end
        end
    end
    return tags
end

function DynamicTrading.Events.GetFactionForbidTags(faction)
    local tags = {}
    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.stock and def.stock.forbidTags then
            for _, tag in ipairs(def.stock.forbidTags) do 
                tags[tag] = true
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "Forbid tag from flash: " .. tostring(def.name) .. " tag=" .. tag)
                end
            end
        end
    end
    return tags
end

DynamicTrading.Log("DTCommons", "Event", "Logic", "Module Loaded.")
