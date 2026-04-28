-- =============================================================================
-- DYNAMIC TRADING: DEBUG CONVERSATION TEST
-- =============================================================================
-- Adds a context menu option to easily test the DT_ConversationUI framework.
-- =============================================================================
if not isDebugEnabled() then return end

require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/Contacts/DT_TraderContacts"
require "DT/Common/UI/Contacts/DT_ContactsWindow"
require "DT/Common/UI/Contacts/DT_ContactsConversation"

local DebugDialogue = {}
local NPCGenerator = {}

local function grantRandomContact(debugOpenConversation)
    local randomNPC = NPCGenerator.Create()
    local _, saved = DT_TraderContacts.UnlockContact(randomNPC, {
        ignoreReputation = true,
        debugGranted = true,
    })

    if debugOpenConversation and saved then
        DT_ContactsConversation.Open(saved)
    else
        DT_ContactsWindow.Open({ selectTraderID = saved and saved.id or nil })
    end
end

-- =============================================================================
-- 1. NPC RANDOMIZER
-- =============================================================================
NPCGenerator.Names = {
    Male = { "Rick", "Daryl", "Joel", "Arthur", "Leon", "Isaac", "Gordon", "Booker" },
    Female = { "Ellie", "Clementime", "Jill", "Lara", "Sarah", "Alyx", "Cortana", "Ripley" }
}

NPCGenerator.Surnames = {
    "Grimes", "Dixon", "Miller", "Morgan", "Kennedy", "Clarke", "Freeman", "DeWitt", "Vance"
}

NPCGenerator.Archetypes = {
    "Farmer", "Doctor", "Mechanic", "Survivalist", "Soldier", "Chef", "General"
}

function NPCGenerator.Create()
    local gender = (ZombRand(2) == 0) and "Male" or "Female"
    
    local nameList = NPCGenerator.Names[gender]
    local firstName = nameList[ZombRand(#nameList) + 1]
    local lastName = NPCGenerator.Surnames[ZombRand(#NPCGenerator.Surnames) + 1]
    
    local archetype = NPCGenerator.Archetypes[ZombRand(#NPCGenerator.Archetypes) + 1]
    local identitySeed = ZombRand(1000) + 1 
    
    local trader = {
        name = firstName .. " " .. lastName, -- Reverted to original name construction
        archetype = archetype,
        gender = gender,
        identitySeed = identitySeed,
    }
    return trader
end

-- =============================================================================
-- 2. DIALOGUE NODES (STATE MACHINE)
-- =============================================================================

-- STATE: INTRO
function DebugDialogue.Node_Intro(ui, data)
    local role = ui.target.archetype
    local intro = "Systems online. " .. role .. " subroutine loaded."
    
    ui:speak(intro)
    
    local options = {
        -- TEST 1: Normal Behavior (Button Text = Chat Text)
        { 
            text = "Who are you?", 
            onSelect = DebugDialogue.Node_Identity 
        },
        
        -- TEST 2: Split Behavior (Short Button -> Long Message)
        { 
            text = "Formal Greeting", 
            message = "Greetings, survivor. It is a distinct pleasure to make your acquaintance in this digital construct.",
            onSelect = function(ui) 
                ui:speak("Example of a long player message triggered by a short button.")
                DebugDialogue.Node_Intro(ui) -- Loop back
            end 
        },

        -- TEST 3: Action Logic
        { 
            text = "Simulate Trade", 
            message = "Can you give me something?",
            onSelect = DebugDialogue.Node_Begging 
        },
        -- TEST 3: Action Logic
        { 
            text = "Simulate Trade", 
            message = "Can you give me something?",
            onSelect = DebugDialogue.Node_Begging 
        },
        -- TEST 3: Action Logic
        { 
            text = "Simulate Trade", 
            message = "Can you give me something?",
            onSelect = DebugDialogue.Node_Begging 
        },
        -- TEST 3: Action Logic
        { 
            text = "Simulate Trade", 
            message = "Can you give me something?",
            onSelect = DebugDialogue.Node_Begging 
        },
        -- TEST 3: Action Logic
        { 
            text = "Simulate Trade", 
            message = "Can you give me something?",
            onSelect = DebugDialogue.Node_Begging 
        },
        
        -- TEST 4: Silent Closing
        { 
            text = "[End Simulation]", 
            message = "", -- Empty string = No chat log
            onSelect = DebugDialogue.Node_Goodbye 
        }
        
    }
    ui:updateOptions(options, {
        resetHistory = true,
    })
end

-- STATE: IDENTITY
function DebugDialogue.Node_Identity(ui, data)
    local info = "Name: " .. ui.target.name .. "\nGender: " .. ui.target.gender .. "\nIdentity Seed: " .. ui.target.identitySeed
    
    ui:speak("Here is my generated data:\n" .. info)
    
    local options = {
        { 
            text = "Tell me about portraits.", 
            message = "How does the portrait system work?",
            onSelect = function(ui) 
                local identitySeed = ui.target.identitySeed or (ZombRand(1000) + 1)
                local archetype = ui.target.archetype or "General"
                local gender = ui.target.gender or "Male"
                
                local mappedID = 1
                if DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetMappedID then
                    mappedID = DynamicTrading.Portraits.GetMappedID(archetype, gender, identitySeed)
                end

                local info = "Name: " .. ui.target.name .. "\nGender: " .. ui.target.gender .. "\nIdentity Seed: " .. identitySeed
                ui:log(info)
                
                if ui.target.identitySeed then
                    ui:speak("If my portrait is white, check: media/ui/Portraits/" .. archetype .. "/" .. gender .. "/" .. mappedID .. ".png") 
                end
                ui:updateOptions({})
            end
        }
    }
    ui:updateOptions(options)
end

-- STATE: BEGGING
function DebugDialogue.Node_Begging(ui, data)
    ui:speak("I possess no inventory, but I can pretend.")
    
    local options = {
        { 
            text = "Take Apple", 
            message = "*Takes the digital apple*",
            onSelect = function(ui)
                -- 1. Narrative Message (System/Grey)
                ui:addMessage("*Inventory Updated*", "System", false)
                
                -- 2. Player Thanks (Blue)
                ui:queueMessage("Thanks!", "Me", true, 10, "DT_RadioRandom")
                
                -- 3. Return
                DebugDialogue.Node_Intro(ui) 
            end 
        },
        { 
            text = "Nevermind", 
            message = "Actually, forget it.",
            onSelect = DebugDialogue.Node_Intro 
        }
    }
    ui:updateOptions(options)
end

-- STATE: GOODBYE
function DebugDialogue.Node_Goodbye(ui, data)
    ui:speak("Terminating session...")
    -- Close after a short delay so the player reads the text
    -- We can't use queue for function calls easily without extending the UI class, 
    -- so we just close immediately or use a timer. 
    -- For now, just close.
    ui:close()
end

-- =============================================================================
-- 3. LAUNCHER (CONTEXT MENU)
-- =============================================================================

local function OnDebugContext(player, context, worldObjects, test)
    local mainOption = context:addOption("[DEBUG] Conversation UI", nil, nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(mainOption, subMenu)

    -- OPTION A: RADIO MODE
    subMenu:addOption("Radio Mode (Random NPC)", nil, function()
        local randomNPC = NPCGenerator.Create()
        local ui = DT_ConversationUI.Open(randomNPC, nil, nil, true)
        DebugDialogue.Node_Intro(ui)
    end)

    -- OPTION B: IN-PERSON MODE
    subMenu:addOption("In-Person Mode (Random NPC)", nil, function()
        local randomNPC = NPCGenerator.Create()
        local ui = DT_ConversationUI.Open(randomNPC, nil, nil, false)
        DebugDialogue.Node_Intro(ui)
    end)

    subMenu:addOption("Grant Random Contact", nil, function()
        grantRandomContact(false)
    end)

    subMenu:addOption("Open Random Contact Frequency", nil, function()
        grantRandomContact(true)
    end)

    subMenu:addOption("Open Contacts Window", nil, function()
        DT_ContactsWindow.Open()
    end)
end

Events.OnFillWorldObjectContextMenu.Add(OnDebugContext)
