-- media/lua/client/DT_ClientEvents.lua
local function OnServerCommand(module, command, args)
    if module == "DynamicTrading" and command == "ScanResult" then
        if args.success then
            local player = getSpecificPlayer(0)
            if player then
                player:Say("Connected: " .. (args.name or "Unknown"))
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)