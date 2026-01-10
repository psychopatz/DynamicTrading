-- ==============================================================================
-- MyNPC_Input.lua
-- Client-side Logic: Listens for key presses to trigger actions.
-- ==============================================================================

MyNPCInput = MyNPCInput or {}

function MyNPCInput.OnKeyPressed(key)
    -- 1. Check if the key pressed is "K"
    if key == Keyboard.KEY_K then
        
        local player = getPlayer()
        if not player then return end

        -- 2. Visual Feedback (So you know it worked)
        player:Say("Signal Sent: Spawning NPC...")

        -- 3. Send Signal to Server
        -- This triggers the SpawnNPC function in MyNPC_Spawn.lua
        sendClientCommand(player, "MyNPC", "Spawn", {})
    end
end

-- Register the event
Events.OnKeyPressed.Add(MyNPCInput.OnKeyPressed)