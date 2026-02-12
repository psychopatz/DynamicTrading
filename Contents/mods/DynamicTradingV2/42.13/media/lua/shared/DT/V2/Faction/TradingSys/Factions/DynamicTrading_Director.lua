-- if isClient() and not isServer() then return end

require "DT/V2/Config"
require "DT/Common/Events/DT_EventManager"

DynamicTrading = DynamicTrading or {}
DynamicTrading.V2 = DynamicTrading.V2 or {}
DynamicTrading.V2.Director = {}

local Director = DynamicTrading.V2.Director

-- =============================================================================
-- 1. EVENT UPDATE (Called Daily Per Faction) - SERVER ONLY
-- =============================================================================
function Director.Update(faction)
    if isClient() and not isServer() then return end
    if not faction then return end
    
    local currentHour = math.floor(getGameTime():getWorldAgeHours())
    local Sandbox = SandboxVars.DynamicTrading
    
    -- A. EXPIRY CHECK
    if faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
        if currentHour >= faction.ActiveFlashEvent.expires then
            print("DT Director: Event [" .. faction.ActiveFlashEvent.id .. "] expired for faction " .. faction.id)
            faction.ActiveFlashEvent.id = nil
            faction.ActiveFlashEvent.expires = 0
        else
            -- Event still active, skip new triggers
            return
        end
    end

    -- B. STABILITY TRACKING
    if faction.state == "Stable" then
        faction.consecutiveStableDays = (faction.consecutiveStableDays or 0) + 1
    else
        faction.consecutiveStableDays = 0
    end

    -- C. TRIGGER ROLL
    local baseChance = Sandbox.EventChance or 50
    local stabilityBonus = math.floor((faction.consecutiveStableDays or 0) / 7) * 10 -- +10% chance per week of stability
    local roll = ZombRand(100) + 1
    
    if roll > (baseChance + stabilityBonus) then
        return -- No event today
    end

    -- D. CANDIDATE DISCOVERY (Registry Scan)
    local candidates = {}
    local wildcardPool = {}
    
    for id, def in pairs(DynamicTrading.Events.Registry) do
        if def.type == "flash" then
            -- Check if event can spawn based on faction context
            local canSpawn = true
            if def.canSpawn then
                -- V2 pass: pass faction object to canSpawn
                local ok, result = pcall(def.canSpawn, faction)
                canSpawn = ok and result
            end
            
            if canSpawn then
                table.insert(candidates, id)
            end
            
            -- Wildcards (Induce Chaos)
            -- Any negative event is a wildcard candidate for stable factions
            if def.sentiment == "Negative" or roll <= 5 then -- 5% chance for random positive wildcard too
                table.insert(wildcardPool, id)
            end
        end
    end

    -- E. SELECTION
    local finalID = nil
    
    -- High stability = higher chance for wildcard chaos
    local isWildcard = (faction.consecutiveStableDays or 0) > 14 and ZombRand(100) < (faction.consecutiveStableDays) 
    
    if isWildcard and #wildcardPool > 0 then
        finalID = wildcardPool[ZombRand(#wildcardPool) + 1]
        print("DT Director: WILDCARD selected for faction " .. faction.id .. " due to prolonged stability.")
    elseif #candidates > 0 then
        finalID = candidates[ZombRand(#candidates) + 1]
    end

    -- F. ACTIVATION
    if finalID then
        local minDur = Sandbox.V2_FlashEventMinDuration or 24
        local maxDur = Sandbox.V2_FlashEventMaxDuration or 72
        local duration = minDur + ZombRand(maxDur - minDur + 1)
        
        faction.ActiveFlashEvent.id = finalID
        faction.ActiveFlashEvent.expires = currentHour + duration
        
        print("DT Director: Faction [" .. faction.id .. "] triggered Event: " .. finalID .. " for " .. duration .. " hours.")
        
        -- PRE-CALCULATE IMPACTS (V2 Revamp)
        local def = DynamicTrading.Events.Registry[finalID]
        if def then
            -- 1. Casualties (Distributed)
            if def.factionImpact and def.factionImpact.memberCountPct then
                local pct = def.factionImpact.memberCountPct
                local totalToKill = math.floor(math.abs(faction.memberCount * pct))
                if totalToKill == 1 and pct < 0 then totalToKill = 1 end -- Ensure at least 1 if % is set
                faction.ActiveFlashEvent.targetCasualties = totalToKill
                print("  > Pre-calculated " .. totalToKill .. " casualties for duration of event.")
            else
                faction.ActiveFlashEvent.targetCasualties = 0
            end

            -- 2. Immediate Impacts (Wealth, Stockpile, Stability)
            if def.factionImpact then
                if def.factionImpact.wealthAdd then
                    faction.wealth = (faction.wealth or 0) + def.factionImpact.wealthAdd
                    print("  > Applied wealth hit: " .. def.factionImpact.wealthAdd)
                end
                if def.factionImpact.stockpileAdd then
                    for res, amt in pairs(def.factionImpact.stockpileAdd) do
                        faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
                        print("  > Applied stockpile hit [" .. res .. "]: " .. amt)
                    end
                end
                if def.factionImpact.stabilityAdd then
                    faction.consecutiveStableDays = math.max(0, (faction.consecutiveStableDays or 0) + def.factionImpact.stabilityAdd)
                end
            end

            -- Reset stability if negative wildcard/sentiment hit
            if def.sentiment == "Negative" then
                faction.consecutiveStableDays = 0
            end
        end
    end
end

-- =============================================================================
-- 2. PRICE MODIFIERS (Merged Global + Faction)
-- =============================================================================
function Director.GetPriceModifiers(traderID, factionID, itemTags)
    local multiplier = 1.0
    local verbose = DynamicTrading.Debug
    
    -- 1. Get Global Multipliers (Seasonal/Meta) via Common Event Manager
    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
        local globalMult = DynamicTrading.Events.GetPriceModifier(itemTags)
        if verbose and globalMult ~= 1.0 then
            print("[DT-V2-Director] Global Multiplier applied: " .. globalMult)
        end
        multiplier = multiplier * globalMult
    end
    
    -- 2. Get Faction Specific Multiplier
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local eventDef = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if eventDef and eventDef.effects then
                for _, tag in ipairs(itemTags or {}) do
                    if eventDef.effects[tag] and eventDef.effects[tag].price then
                        local fMult = eventDef.effects[tag].price
                        if verbose then
                            print("[DT-V2-Director] Faction Event (" .. faction.ActiveFlashEvent.id .. ") Multiplier for tag [" .. tag .. "]: " .. fMult)
                        end
                        multiplier = multiplier * fMult
                    end
                end
            end
        end
    end
    
    if verbose and multiplier ~= 1.0 then
        print("[DT-V2-Director] Final Event Multiplier: " .. multiplier)
    end

    return multiplier
end

-- =============================================================================
-- 3. SYSTEM MODIFIERS (traderLimit, scanChance, etc.)
-- =============================================================================
function Director.GetSystemModifier(factionID, key)
    local multiplier = 1.0
    
    -- 1. Global System Modifiers
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        multiplier = multiplier * DynamicTrading.Events.GetSystemModifier(key)
    end
    
    -- 2. Faction-Specific System Modifiers
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local eventDef = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if eventDef and eventDef.system and eventDef.system[key] then
                multiplier = multiplier * eventDef.system[key]
            end
        end
    end
    
    return multiplier
end

-- =============================================================================
-- 4. STOCK MODIFIERS (V2 Support)
-- =============================================================================

function Director.GetVolumeModifier(factionID, itemTags)
    local multiplier = 1.0
    
    -- 1. Global (Seasonal/Meta)
    if DynamicTrading.Events and DynamicTrading.Events.GetVolumeModifier then
        multiplier = multiplier * DynamicTrading.Events.GetVolumeModifier(itemTags)
    end
    
    -- 2. Faction Specific
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if def and def.stock and def.stock.volumeMult then
                multiplier = multiplier * def.stock.volumeMult
            end
        end
    end
    
    return multiplier
end

function Director.GetInjections(factionID)
    local injections = {}
    
    -- 1. Global
    if DynamicTrading.Events and DynamicTrading.Events.GetInjections then
        injections = DynamicTrading.Events.GetInjections()
    end
    
    -- 2. Faction Specific
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if def and def.stock and def.stock.injections then
                for tag, count in pairs(def.stock.injections) do
                    injections[tag] = (injections[tag] or 0) + count
                end
            end
        end
    end
    
    return injections
end

function Director.GetExpertTags(factionID)
    local tags = {}
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if def and def.stock and def.stock.expertTags then
                for _, tag in ipairs(def.stock.expertTags) do tags[tag] = true end
            end
        end
    end
    return tags
end

function Director.GetForbidTags(factionID)
    local tags = {}
    if factionID then
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        if faction and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
            local def = DynamicTrading.Events.Registry[faction.ActiveFlashEvent.id]
            if def and def.stock and def.stock.forbidTags then
                for _, tag in ipairs(def.stock.forbidTags) do tags[tag] = true end
            end
        end
    end
    return tags
end

print("DynamicTrading: V2 Director Module Loaded.")
return Director
