-- ==============================================================================
-- DTNPC_Input.lua
-- Client-side Logic: Listens for key presses to trigger actions.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCInput = DTNPCInput or {}

function DTNPCInput.OnKeyPressed(key)
    if key == Keyboard.KEY_K then
        
        local player = getPlayer()
        if not player then return end

        player:Say("Signal Sent: Spawning NPC...")

        sendClientCommand(player, "DTNPC", "Spawn", {})
    end
end

Events.OnKeyPressed.Add(DTNPCInput.OnKeyPressed)
