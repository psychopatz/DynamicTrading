-- ==============================================================================
-- DTNPC_JobUI.lua
-- Client-side registry for NPC job-specific UI and interaction handlers.
-- ==============================================================================

DTNPCJobUI = DTNPCJobUI or {}
DTNPCJobUI.Registry = DTNPCJobUI.Registry or {}

if DTNPCJobUI.EntryLoaded then
    return
end

DTNPCJobUI.EntryLoaded = true

local function getOrderedHandlers()
    local handlers = {}
    for _, handler in pairs(DTNPCJobUI.Registry) do
        handlers[#handlers + 1] = handler
    end

    table.sort(handlers, function(left, right)
        local leftPriority = tonumber(left and left.priority) or 0
        local rightPriority = tonumber(right and right.priority) or 0
        if leftPriority == rightPriority then
            return tostring(left and left.id or "") < tostring(right and right.id or "")
        end
        return leftPriority > rightPriority
    end)

    return handlers
end

function DTNPCJobUI.Register(handler)
    if type(handler) ~= "table" or not handler.id then
        return false
    end

    DTNPCJobUI.Registry[tostring(handler.id)] = handler
    return true
end

function DTNPCJobUI.Resolve(ui, npc, player, npcData)
    local handlers = getOrderedHandlers()
    for i = 1, #handlers do
        local handler = handlers[i]
        if handler and handler.matches and handler.matches(ui, npc, player, npcData) == true then
            return handler
        end
    end

    return nil
end

function DTNPCJobUI.GetTalkLabel(ui, npc, player, npcData, defaultName)
    local handler = DTNPCJobUI.Resolve(ui, npc, player, npcData)
    if handler and handler.getTalkLabel then
        local label = handler.getTalkLabel(ui, npc, player, npcData, defaultName)
        if label and label ~= "" then
            return label
        end
    end

    return "Talk to " .. tostring(defaultName or "Survivor")
end

function DTNPCJobUI.ApplyTraderProxyPatch(traderProxy, ui, npc, player, npcData)
    local handler = DTNPCJobUI.Resolve(ui, npc, player, npcData)
    if handler and handler.getTraderProxyPatch then
        local patch = handler.getTraderProxyPatch(ui, npc, player, npcData)
        if type(patch) == "table" then
            for key, value in pairs(patch) do
                traderProxy[key] = value
            end
        end
    end

    return traderProxy, handler
end

function DTNPCJobUI.TryGenerateOptions(ui, npc, player, npcData)
    local handler = DTNPCJobUI.Resolve(ui, npc, player, npcData)
    if handler and handler.generateOptions then
        return handler.generateOptions(ui, npc, player, npcData) == true, handler
    end

    return false, nil
end

function DTNPCJobUI.AddContextMenuOptions(context, ui, npc, player, npcData)
    local handler = DTNPCJobUI.Resolve(ui, npc, player, npcData)
    if handler and handler.addContextMenuOptions then
        return handler.addContextMenuOptions(context, ui, npc, player, npcData) == true, handler
    end

    return false, nil
end

require "DT/V2/NPC/Jobs/TravelCompanion/JobUITravelCompanion/DTNPC_JobUI_TravelCompanion"
require "DT/V2/NPC/Jobs/TraderNeeds/JobUITraderHelpEscort/DTNPC_JobUI_TraderHelpEscort"
require "DT/V2/NPC/Jobs/IncapacitatedRevive/DTNPC_JobUI_IncapacitatedRevive"
require "DT/V2/NPC/Bandits/DTNPC_Bandits"
require "DT/V2/NPC/Jobs/Bandits/DTNPC_JobUI_Bandit"
