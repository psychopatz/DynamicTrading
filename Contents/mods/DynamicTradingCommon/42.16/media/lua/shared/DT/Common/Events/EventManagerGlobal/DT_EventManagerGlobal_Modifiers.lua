-- =============================================================================
-- DT_EventManagerGlobal_Modifiers.lua
-- =============================================================================
-- Global event modifiers calculations.
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
    local modifier = nil

    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.demographics and event.demographics[key] then
            if key:find("Mult") then
                modifier = (modifier or 1.0) * event.demographics[key]
            else
                modifier = (modifier or 0) + event.demographics[key]
            end
        end
    end

    if key:find("Mult") then return modifier or 1.0 end
    return modifier or 0
end

function DynamicTrading.Events.GetWorldModifier(key, subKey)
    local modifier = nil

    for _, event in ipairs(DynamicTrading.Events.ActiveEvents) do
        if event.world then
            local value = event.world[key]
            if type(value) == "table" and subKey then
                value = value[subKey]
            end

            if value then
                if key:find("Mult") or (type(event.world[key]) == "table" and key:find("Mults")) then
                    modifier = (modifier or 1.0) * value
                else
                    modifier = (modifier or 0) + value
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