require "DT/Common/Dialogue/DT_Dialogue_Core"

DynamicTrading = DynamicTrading or {}
DynamicTrading.AmbientDialogue = DynamicTrading.AmbientDialogue or {}
DynamicTrading.AmbientDialogue.Archetypes = DynamicTrading.AmbientDialogue.Archetypes or {}

local Core = DynamicTrading.Dialogue.Core

local function normalizeAmbientEntry(entry)
    if not entry then
        return nil
    end

    if type(entry) == "string" then
        return {
            dialogue = entry,
            sentiment = "neutral"
        }
    end

    if type(entry) ~= "table" then
        return nil
    end

    local dialogue = entry.dialogue or entry[1]
    if not dialogue or dialogue == "" then
        return nil
    end

    return {
        dialogue = dialogue,
        sentiment = entry.sentiment or entry[2] or "neutral"
    }
end

local function getAmbientPoolFromLanguageTable(langTable, status, state)
    if not langTable then
        return nil
    end

    local statusTable = langTable[status]
    if not statusTable then
        return nil
    end

    if statusTable[1] then
        return statusTable
    end

    return statusTable[state] or statusTable.Default or statusTable.Generic
end

local function getAmbientPoolFromTarget(target, status, state, lang)
    if not target then
        return nil
    end

    if target[lang] then
        local pool = getAmbientPoolFromLanguageTable(target[lang], status, state)
        if pool then
            return pool
        end
    end

    if target.EN then
        local pool = getAmbientPoolFromLanguageTable(target.EN, status, state)
        if pool then
            return pool
        end
    end

    local statusTable = target[status]
    if not statusTable then
        return nil
    end

    if statusTable[1] then
        return statusTable
    end

    local langTable = statusTable[lang] or statusTable.EN or statusTable
    if not langTable then
        return nil
    end

    if langTable[1] then
        return langTable
    end

    return langTable[state] or langTable.Default or langTable.Generic
end

local function getAmbientPool(archetype, status, state)
    local db = DynamicTrading.AmbientDialogue and DynamicTrading.AmbientDialogue.Archetypes or nil
    if not db then
        return nil
    end

    local lang = DynamicTrading.GetLanguage()
    local safeArchetype = archetype or "General"
    local safeStatus = status or "Default"
    local safeState = state or "Default"

    local searchOrder = {
        { target = db[safeArchetype], status = safeStatus, state = safeState },
        { target = db[safeArchetype], status = safeStatus, state = "Default" },
        { target = db.General, status = safeStatus, state = safeState },
        { target = db.General, status = safeStatus, state = "Default" },
        { target = db.General, status = "Default", state = safeState },
        { target = db.General, status = "Default", state = "Default" },
    }

    for i = 1, #searchOrder do
        local search = searchOrder[i]
        local pool = getAmbientPoolFromTarget(search.target, search.status, search.state, lang)
        if pool then
            return pool
        end
    end

    return nil
end

function DynamicTrading.AmbientDialogue.GetEntry(trader, status, state, args)
    local safeTrader = trader or {}
    local pool = getAmbientPool(
        safeTrader.archetype or safeTrader.archetypeID or "General",
        status,
        state
    )

    if not pool or #pool == 0 then
        return nil
    end

    local entry = normalizeAmbientEntry(Core.PickRandom(pool))
    if not entry then
        return nil
    end

    local safeArgs = args or {}
    if safeTrader.name and not safeArgs.traderName then
        safeArgs.traderName = safeTrader.name
    end

    entry.dialogue = Core.FormatMessage(entry.dialogue, safeArgs)
    return entry
end
