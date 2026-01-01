require "ISUI/ISUIHandler"
require "DynamicTrading_Config"
require "DynamicTradingUI"

local function DT_Debug_KeyPress(key)
    -- Check for "T" key (LWJGL KeyCode 20)
    if key == Keyboard.KEY_T then
        
        local player = getSpecificPlayer(0)
        if not player then return end

        -- 1. Gather all available Archetypes into a list
        local archetypes = {}
        if DynamicTrading.Archetypes then
            for id, data in pairs(DynamicTrading.Archetypes) do
                table.insert(archetypes, id)
            end
        end

        if #archetypes == 0 then
            player:Say("Debug Error: No Archetypes loaded!")
            return
        end

        -- 2. Pick a Random Archetype
        local randomArchetype = archetypes[ZombRand(#archetypes) + 1]
        
        -- 3. Generate a Random ID 
        -- This simulates meeting a unique person each time you press T.
        -- We use ZombRand to make sure the ID is unique so a new stock is generated.
        local uniqueID = "Debug_Trader_" .. tostring(ZombRand(100000))

        -- 4. Feedback
        player:Say("DEBUG: Found " .. randomArchetype .. " (ID: " .. uniqueID .. ")")
        
        -- 5. Open the UI
        -- This triggers the Manager to create the data and the UI to display it.
        DynamicTradingUI.ToggleWindow(uniqueID, randomArchetype)
    end
end

-- Hook into the key press event
Events.OnKeyPressed.Add(DT_Debug_KeyPress)