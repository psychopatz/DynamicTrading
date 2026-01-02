require "ISUI/ISUIHandler"

local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "ScanResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        if args.success then
            -- The Server finished creating the trader. Now we show the success message.
            player:playSound("RadioZombies")
            player:Say("Connected: " .. (args.name or "Unknown"))
            HaloTextHelper.addTextWithArrow(player, "New Signal Found", true, HaloTextHelper.getColorGreen())
        else
            player:Say("Failed to establish connection.")
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)