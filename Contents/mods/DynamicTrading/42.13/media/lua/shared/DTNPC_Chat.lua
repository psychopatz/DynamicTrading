-- ==============================================================================
-- DTNPC_Chat.lua
-- Decoupled Dialogue System.
-- Handles broadcasting chat messages from NPCs to all players in MP.
-- Build 42 Compatible.
-- ==============================================================================

DTNPC = DTNPC or {}
DTNPC.Chat = {}

-- Color presets
DTNPC.Chat.Colors = {
    white = "<RGB:1,1,1>",
    red = "<RGB:1,0.2,0.2>",
    green = "<RGB:0.2,1,0.2>",
    blue = "<RGB:0.4,0.6,1>",
    gray = "<RGB:0.6,0.6,0.6>",
    yellow = "<RGB:1,1,0.2>",
    orange = "<RGB:1,0.6,0.2>",
    purple = "<RGB:0.8,0.4,1>",
}

-- Main Entry Point
-- usage: DTNPC.Chat.Say(zombie, "Hello World", "red")
function DTNPC.Chat.Say(zombie, text, colorName)
    if not zombie or not text then return end

    local colorTag = DTNPC.Chat.Colors[colorName] or DTNPC.Chat.Colors["white"]
    local brain = DTNPC.GetBrain(zombie)
    local prefix = ""
    
    if brain and brain.name then
        prefix = "[" .. brain.name .. "] "
    end
    
    local fullText = colorTag .. prefix .. text

    if isClient() then
        -- Send request to server to broadcast (so everyone sees it)
        local args = {
            id = zombie:getPersistentOutfitID(),
            text = fullText
        }
        sendClientCommand(getPlayer(), "DTNPC", "ChatBroadcast", args)
    else
        -- Server: Broadcast immediately
        DTNPC.Chat.Broadcast(zombie:getPersistentOutfitID(), fullText)
    end
end

-- ==============================================================================
-- SERVER SIDE HANDLER
-- ==============================================================================
if isServer() then
    function DTNPC.Chat.Broadcast(id, text)
        local args = { id = id, text = text }
        sendServerCommand("DTNPC", "ChatMsg", args)
    end
end

-- ==============================================================================
-- CLIENT SIDE RECEIVER
-- ==============================================================================
if isClient() then
    local function onServerCommand(module, command, args)
        if module ~= "DTNPC" then return end
        
        if command == "ChatMsg" then
            if not args.id or not args.text then return end
            
            -- Find the zombie
            local zombie = nil
            local cell = getCell()
            if cell then
                local zombieList = cell:getZombieList()
                for i = 0, zombieList:size() - 1 do
                    local z = zombieList:get(i)
                    if z and z:getPersistentOutfitID() == args.id then
                        zombie = z
                        break
                    end
                end
            end
            
            if zombie then
                zombie:Say(args.text)
            end
        end
    end
    
    Events.OnServerCommand.Add(onServerCommand)
end
