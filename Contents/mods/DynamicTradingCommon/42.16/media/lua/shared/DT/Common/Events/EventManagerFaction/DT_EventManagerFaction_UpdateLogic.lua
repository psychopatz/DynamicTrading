-- =============================================================================
-- DT_EventManagerFaction_UpdateLogic.lua
-- =============================================================================
-- The main UpdateFaction loop.
-- =============================================================================

function DynamicTrading.Events.UpdateFaction(faction)
    if isClient() and not isServer() then return end
    if not faction then return end

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "=== FACTION UPDATE START === [" .. tostring(faction.id) .. "]")
    end

    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local active = DynamicTrading.Events._ensureFactionFlashSchema(faction)

    local expiredCount = 0
    for index = #active, 1, -1 do
        local entry = active[index]
        if not entry or not entry.id then
            table.remove(active, index)
        elseif currentHour >= (entry.expires or 0) then
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "Event expired: " .. tostring(entry.id) .. " for faction " .. tostring(faction.id))
            end
            table.remove(active, index)
            faction.lastEventExpiredHour = currentHour
            expiredCount = expiredCount + 1
        end
    end

    if DynamicTrading.Debug and expiredCount > 0 then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Removed " .. expiredCount .. " expired events from faction " .. tostring(faction.id))
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
        for _, entry in ipairs(active) do
            if entry and entry.id == id then return true end
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

        if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayEvents and DynamicTrading.GameplayLogs.AddFactionEvent then
            local eventName = tostring(def and def.name or finalID)
            DynamicTrading.Log("DTLogs", "Gameplay", "Lifecycle", "Flash lifecycle hook fired | Faction: " .. tostring(faction.id) .. " | Event: " .. eventName .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
            DynamicTrading.GameplayLogs.AddFactionEvent(faction.id, DynamicTrading.GameplayEvents.FLASH_EVENT_ACTIVATED, {eventName})
        end

        if def and def.factionImpact then
            if def.factionImpact.wealthAdd then
                faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) + def.factionImpact.wealthAdd)
                if DynamicTrading.Debug then
                    DynamicTrading.Log("DTCommons", "Event", "Logic", "ColonyWealth applied: +" .. def.factionImpact.wealthAdd)
                end
            end

            if def.factionImpact.stockpileAdd then
                faction.stockpile = faction.stockpile or {}
                for resource, amount in pairs(def.factionImpact.stockpileAdd) do
                    faction.stockpile[resource] = (faction.stockpile[resource] or 0) + amount
                    if DynamicTrading.Debug then
                        DynamicTrading.Log("DTCommons", "Event", "Logic", "Stockpile: " .. resource .. " +" .. amount)
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

        local cooldownHours = 72
        if not force and (faction.lastEventExpiredHour and currentHour - faction.lastEventExpiredHour < cooldownHours) then
            if DynamicTrading.Debug then
                DynamicTrading.Log("DTCommons", "Event", "Logic", "trySpawn: faction on cooldown. Last expiry: " .. faction.lastEventExpiredHour .. " Current: " .. currentHour)
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

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "Enforcing minimum slots: " .. minSlots)
    end
    while #active < minSlots do
        if not trySpawn(true) then break end
    end

    if #active < maxSlots then
        if DynamicTrading.Debug then
            DynamicTrading.Log("DTCommons", "Event", "Logic", "Attempting optional spawn up to max")
        end
        trySpawn(false)
    end

    DynamicTrading.Events._syncLegacyActiveFlashMirror(faction)

    if DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Event", "Logic", "=== FACTION UPDATE END === [" .. tostring(faction.id) .. "] active_events=" .. #active)
    end
end