-- =============================================================================
-- DT_EventManagerFaction_Modifiers.lua
-- =============================================================================
-- Modifiers and getters logic for Faction events.
-- =============================================================================

function DynamicTrading.Events.GetFactionSystemModifier(faction, key)
    local multiplier = 1.0

    if DynamicTrading.Events.GetSystemModifier then
        multiplier = multiplier * DynamicTrading.Events.GetSystemModifier(key)
    end

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

    if DynamicTrading.Events.GetPriceModifier then
        multiplier = multiplier * DynamicTrading.Events.GetPriceModifier(itemTags, verbose)
    end

    local flashDefs = DynamicTrading.Events.GetFactionFlashEventDefs(faction)
    for _, def in ipairs(flashDefs) do
        if def.effects then
            for _, tag in ipairs(itemTags or {}) do
                if def.effects[tag] and def.effects[tag].price then
                    local flashMultiplier = def.effects[tag].price
                    if verbose and flashMultiplier ~= 1.0 then
                        DynamicTrading.Log("DTCommons", "Event", "Logic", "Flash price mult from " .. tostring(def.name) .. " tag=" .. tag .. " for faction=" .. (faction.id or "unknown") .. " mult=" .. flashMultiplier)
                    end
                    multiplier = multiplier * flashMultiplier
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

    if DynamicTrading.Events.GetVolumeModifier then
        multiplier = multiplier * DynamicTrading.Events.GetVolumeModifier(itemTags)
    end

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

    if DynamicTrading.Events.GetInjections then
        local global = DynamicTrading.Events.GetInjections()
        for key, value in pairs(global) do injections[key] = value end
    end

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

function DynamicTrading.Events.getTraderBudgetMultiplier(faction)
    return DynamicTrading.Events.GetFactionSystemModifier(faction, "traderBudgetMult")
end

function DynamicTrading.Events.getPassiveIncomeMult(faction)
    return DynamicTrading.Events.GetFactionSystemModifier(faction, "passiveIncomeMult")
end

function DynamicTrading.Events.getAutoBuyPriceModifier(faction)
    return DynamicTrading.Events.GetFactionSystemModifier(faction, "autoBuyPriceMult")
end

function DynamicTrading.Events.getColonyWealthModifier(faction)
    return DynamicTrading.Events.GetFactionSystemModifier(faction, "colonyWealthMult")
end