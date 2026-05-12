-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Conversation.lua
-- Conversation flow for incapacitated revive interactions.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Conversation then
    return
end

modules.Conversation = true

local function buildLeaveOptions()
    return {
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("Stay alive.")
                innerUI:updateOptions({})
            end,
        },
    }
end

function ReviveUI.ShowReviveConversation(ui, npc, playerObj, npcData, overrideSpeech)
    npcData = ReviveUI.GetNPCData(npc) or npcData
    if not npcData then
        return
    end

    local info = ReviveUI.GetReviveInfo(playerObj, npcData, true)
    local requiredCount = tonumber(info and info.requiredCount) or ReviveUI.GetRequiredCount(npcData)
    local availableCount = ReviveUI.CountSupplies(playerObj)
    local hpCurrent = DTNPCHealth and DTNPCHealth.GetCurrentHP and DTNPCHealth.GetCurrentHP(npcData) or nil
    local hpMax = DTNPCHealth and DTNPCHealth.GetMaxHP and DTNPCHealth.GetMaxHP(npcData) or nil
    local summary = "You're down hard."
    if hpCurrent and hpMax then
        summary = "Current health: " .. tostring(math.floor(hpCurrent)) .. "/" .. tostring(math.floor(hpMax)) .. "."
    end
    if requiredCount and requiredCount > 0 then
        summary = summary .. " I need " .. tostring(requiredCount) .. " bandages or rags to get moving."
    else
        summary = summary .. " I need bandages or rags to get moving."
    end

    ui:speak(overrideSpeech or "If you have bandages or rags, I can still make it home.")
    ui:updateOptions({
        {
            text = "Status",
            message = "",
            onSelect = function(innerUI)
                ReviveUI.ShowReviveConversation(innerUI, npc, playerObj, ReviveUI.GetNPCData(npc) or npcData, summary)
            end,
        },
        {
            text = requiredCount and ("Revive (" .. tostring(availableCount) .. "/" .. tostring(requiredCount) .. ")")
                or ("Revive (" .. tostring(availableCount) .. " supplies)"),
            message = "",
            onSelect = function(innerUI)
                local liveNPCData = ReviveUI.GetNPCData(npc) or npcData
                local canRevive, liveInfo = DTNPCHealth and DTNPCHealth.CanPlayerRevive and DTNPCHealth.CanPlayerRevive(playerObj, liveNPCData) or false, nil
                if DTNPCHealth and DTNPCHealth.CanPlayerRevive then
                    canRevive, liveInfo = DTNPCHealth.CanPlayerRevive(playerObj, liveNPCData)
                end
                if canRevive ~= true then
                    local required = liveInfo and liveInfo.requiredCount or requiredCount or "?"
                    local available = liveInfo and liveInfo.availableCount or availableCount or 0
                    innerUI:speak("You need " .. tostring(required) .. " bandages or rags. You only have " .. tostring(available) .. ".")
                    ReviveUI.ShowReviveConversation(innerUI, npc, playerObj, liveNPCData)
                    return
                end

                ReviveUI.RememberPending(innerUI, npc, playerObj, liveNPCData)
                sendClientCommand(playerObj, "DTNPC", "ReviveRequest", {
                    uuid = liveNPCData and liveNPCData.uuid or nil,
                })
                innerUI:speak("Hold still. I've got you.")
                innerUI:updateOptions(buildLeaveOptions())
            end,
        },
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("Then move. I need to work.")
                innerUI:updateOptions({})
            end,
        },
    })
end

function ReviveUI.ShowReviveResultConversation(ui, npc, playerObj, npcData, result)
    local thankYouLine = nil
    if DTNPC_WaveHiInteraction and DTNPC_WaveHiInteraction.BuildPlanForEmote then
        local plan = DTNPC_WaveHiInteraction.BuildPlanForEmote("thankyou", playerObj, npc, npcData)
        thankYouLine = plan and plan.introGreeting and plan.introGreeting.text or plan and plan.npcLine or nil
    end

    ui:speak(thankYouLine or "Thank you. I can make it home from here.")
    ui:updateOptions({
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:speak((result and result.message) or "They head home slowly.")
                innerUI:updateOptions({})
            end,
        },
    })
end
