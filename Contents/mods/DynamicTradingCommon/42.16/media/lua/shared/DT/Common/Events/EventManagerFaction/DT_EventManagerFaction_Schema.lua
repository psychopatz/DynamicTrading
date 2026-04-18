-- =============================================================================
-- DT_EventManagerFaction_Schema.lua
-- =============================================================================
-- Schema definitions and migrations for Faction Events.
-- =============================================================================

function DynamicTrading.Events._ensureFactionFlashSchema(faction)
    faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}

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

function DynamicTrading.Events._syncLegacyActiveFlashMirror(faction)
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

    local entries = DynamicTrading.Events._ensureFactionFlashSchema(faction)
    for _, entry in ipairs(entries) do
        if entry and entry.id then
            local def = DynamicTrading.Events.Registry[entry.id]
            if def then table.insert(defs, def) end
        end
    end
    return defs
end