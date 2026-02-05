-- =============================================================================
-- DYNAMIC TRADING V2: NPC TRADER DIALOGUE HUB
-- =============================================================================
require "UI/DT_ConversationUI"
require "NPC/DTNPC_TradingHandler"

DTNPC_TraderDialogue_Hub = {}

function DTNPC_TraderDialogue_Hub.Init(ui, npc, player)
    if not ui then
        -- Open if not already open
        if DT_ConversationUI then
            -- We create a "fake" trader object from the NPC for the UI
            local brain = npc:getModData().DTNPCBrain
            local traderProxy = {
                id = npc:getPersistentOutfitID() or npc:getID(),
                name = brain and brain.name or "Survivor",
                archetype = brain and brain.archetypeID or brain.occupation or "Survivor",
                gender = npc:isFemale() and "Female" or "Male",
                portraitID = brain and brain.portraitID or 1
            }

            ui = DT_ConversationUI.Open(traderProxy, nil, nil, false) -- isRadio = false
        else
            return
        end
    end
    
    if not npc or not player then return end
    
    -- 1. Intro Speech
    ui:speak("Hello. What can I do for you?")

    -- 2. Generate Options
    DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
end

function DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
    local options = {}
    
    -- OPTION 1: CHAT (First implementation)
    table.insert(options, {
        text = "Chat",
        message = "Got a minute to talk?",
        onSelect = function(ui)
            ui:speak("I'm holding down the fort here. Stay safe out there.")
            DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
        end
    })

    -- OPTION 2: TRADE (Conditional)
    local rosterData = ModData.get("DynamicTrading_Roster")
    local isTrading = false
    
    local brain = npc:getModData().DTNPCBrain
    local id = (brain and brain.uuid) or npc:getPersistentOutfitID() or npc:getID()
    
    if rosterData and rosterData.Souls and rosterData.Souls[id] then
        if rosterData.Souls[id].status == "Trading" then
            isTrading = true
        end
    end

    if isTrading then
        table.insert(options, {
            text = "Trade",
            message = "Let's see what you've got.",
            onSelect = function(ui)
                if DTNPC_TradingHandler then
                     DTNPC_TradingHandler.InitiateTrade(ui, npc, player)
                else
                     print("Error: DTNPC_TradingHandler missing")
                     ui:speak("I... forgot how to trade.")
                end
            end
        })
    end

    -- OPTION 3: QUEST (Placeholder)
    table.insert(options, {
        text = "Quest",
        message = "Got any work for me?",
        onSelect = function(ui)
            ui:speak("Nothing at the moment. Check back later.")
            DTNPC_TraderDialogue_Hub.GenerateOptions(ui, npc, player)
        end
    })

    -- OPTION 4: LEAVE
    table.insert(options, {
        text = "Leave",
        message = "I'll be going now. Good luck.",
        onSelect = function(ui)
            ui:close()
        end
    })
    
    ui:updateOptions(options)
end
