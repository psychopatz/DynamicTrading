-- =============================================================================
-- DYNAMIC TRADING: TRADER DIALOGUE HUB
-- =============================================================================
require "UI/DT_ConversationUI"
require "02_DynamicTrading_Manager"
require "DT_DialogueManager"

DT_TraderDialogue_Hub = {}

function DT_TraderDialogue_Hub.Init(ui, trader, parentUI)
    if not ui then
        -- Open if not already open
        if DT_ConversationUI then
            ui = DT_ConversationUI.Open(trader, nil, nil, true, parentUI)
        else
            return
        end
    end
    
    if not trader then return end
    
    -- 1. Intro Speech (Generic Hub Intro)
    local hubIntro = DynamicTrading.DialogueManager.GetDialogue(trader, "Request", "HubIntro")
    ui:speak(hubIntro or "Channels open. What do you need?")

    -- 2. Generate Top Level Options
    DT_TraderDialogue_Hub.GenerateHubOptions(ui, trader)
end

function DT_TraderDialogue_Hub.GenerateHubOptions(ui, trader)
    local options = {}
    
    -- OPTION 1: REQUEST TRADER (Ask a Favor)
    -- Only if not already requested
    if not trader.hasRequestedFavor then
         table.insert(options, {
            text = "Request a Contact",
            message = "I'm looking for someone specific...",
            onSelect = function(ui)
                require "UI/DT_TraderDialogue_Request"
                DT_TraderDialogue_Request.Start(ui, trader)
            end
        })
    else
         table.insert(options, {
            text = "Request a Contact (Unavailable)",
            message = "I already asked for a favor...",
            onSelect = function(ui)
                ui:speak("I'm already working on your last request. Give me some time.")
                DT_TraderDialogue_Hub.GenerateHubOptions(ui, trader)
            end
        })
    end

    -- OPTION 2: CHAT (Placeholder)
    table.insert(options, {
        text = "Small Talk",
        message = "How is it out there?",
        onSelect = function(ui)
            local idle = DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
            ui:speak(idle or "Same as always. Quiet and dangerous.")
            DT_TraderDialogue_Hub.GenerateHubOptions(ui, trader)
        end
    })

    -- OPTION 3: LEAVE
    table.insert(options, {
        text = "Sign Off",
        message = "I'm out. Stay safe.",
        onSelect = function(ui)
            ui:close()
        end
    })
    
    ui:updateOptions(options)
end
