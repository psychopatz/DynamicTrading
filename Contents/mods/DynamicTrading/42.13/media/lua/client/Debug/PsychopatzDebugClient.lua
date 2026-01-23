-- KEY_SEMICOLON in GLFW (Build 42) is 59
if not isDebugEnabled() then return end
local KEY_SEMICOLON = 39

local function onPsychopatzKey(key)
    if key == KEY_SEMICOLON then
        local player = getPlayer()
        if not player then return end

        if player:getUsername() == "Psychopatz" then
            
            print("Developer Access: Requesting Admin/Items from Server...")
            sendClientCommand(player, "Psychopatz", "GrantPowers", {})
        end
    end
end

Events.OnKeyPressed.Add(onPsychopatzKey)