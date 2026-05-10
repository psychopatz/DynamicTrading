-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Status.lua
-- Escort status text generation.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}

EscortUI.Modules = modules

if modules.Status then
    return
end

modules.Status = true

function EscortUI.BuildEscortStatusText(player, npcData, context, quest)
    local detail = quest and DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.GetQuestDetailData
        and DynamicObjectives.Quests.GetQuestDetailData(player, quest.id)
        or nil
    local summary = quest and DynamicObjectives
        and DynamicObjectives.Quests
        and DynamicObjectives.Quests.BuildSummaryText
        and DynamicObjectives.Quests.BuildSummaryText(quest, player)
        or "Stay close and keep the escort moving."

    local parts = { summary or "Stay close and keep the escort moving." }
    local npc = context and context.npcData or npcData or nil
    local current = tonumber(npc and (npc.combatHealthCurrent or (npc.combatHealth and npc.combatHealth.current)) or nil)
    local maxHealth = tonumber(npc and (npc.combatHealthMax or (npc.combatHealth and npc.combatHealth.max)) or nil)

    if current and maxHealth and maxHealth > 0 then
        parts[#parts + 1] = string.format("Health: %d/%d", math.floor(current + 0.5), math.floor(maxHealth + 0.5))
    end

    local state = tostring((npc and npc.state) or "")
    if state ~= "" then
        parts[#parts + 1] = "Order: " .. state
    end

    local hookState = quest and type(quest.hookState) == "table" and quest.hookState or nil
    local homeCoords = hookState and hookState.homeCoords or nil
    if player and type(homeCoords) == "table" and tonumber(homeCoords.x) and tonumber(homeCoords.y) then
        local dx = tonumber(homeCoords.x) - tonumber(player:getX())
        local dy = tonumber(homeCoords.y) - tonumber(player:getY())
        parts[#parts + 1] = string.format("Home: %.0fm", math.sqrt((dx * dx) + (dy * dy)))
    elseif detail and detail.targetLabel and tostring(detail.targetLabel) ~= "" then
        parts[#parts + 1] = "Destination: " .. tostring(detail.targetLabel)
    end

    return table.concat(parts, "\n")
end
