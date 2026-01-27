-- =============================================================================
-- DYNAMIC TRADING: TRADER DIALOGUE CHAT LOGIC
-- =============================================================================
require "UI/DT_ConversationUI"
require "02_DynamicTrading_Manager"

DT_TraderDialogue_Chat = {}

function DT_TraderDialogue_Chat.Start(ui, trader)
    if not ui or not trader then return end
    
    -- 1. Speak Intro
    -- We can use a greeting or a specific "ChatStart" dialogue if we want.
    -- For now, let's just use a generic prompt.
    ui:speak("What's on your mind? I've got a few minutes before the relay cycles.")
    
    -- 2. Generate Options
    DT_TraderDialogue_Chat.GenerateChatOptions(ui, trader)
end

function DT_TraderDialogue_Chat.GenerateChatOptions(ui, trader)
    local options = {}
    
    -- OPTION 1: HISTORY
    table.insert(options, {
        text = "Ask about the past",
        message = "How long has this network been running?",
        onSelect = function(ui)
            local msg = DynamicTrading.DialogueManager.GetDialogue(trader, "Chat", "History")
            ui:speak(msg)
            DT_TraderDialogue_Chat.GenerateChatOptions(ui, trader)
        end
    })

    -- OPTION 2: THE WORLD
    table.insert(options, {
        text = "Ask about the world",
        message = "Heard anything interesting on the wire?",
        onSelect = function(ui)
            local msg = DynamicTrading.DialogueManager.GetDialogue(trader, "Chat", "TheWorld")
            ui:speak(msg)
            DT_TraderDialogue_Chat.GenerateChatOptions(ui, trader)
        end
    })

    -- OPTION 3: PERSONAL
    table.insert(options, {
        text = "Ask how they're doing",
        message = "You doing okay out there?",
        onSelect = function(ui)
            local msg = DynamicTrading.DialogueManager.GetDialogue(trader, "Chat", "Personal")
            ui:speak(msg)
            DT_TraderDialogue_Chat.GenerateChatOptions(ui, trader)
        end
    })

    -- OPTION 4: BACK
    table.insert(options, {
        text = "Back to Main",
        message = "Let's talk about something else.",
        onSelect = function(ui)
            require "UI/DT_TraderDialogue_Hub"
            DT_TraderDialogue_Hub.Init(ui, trader)
        end
    })
    
    ui:updateOptions(options)
end
