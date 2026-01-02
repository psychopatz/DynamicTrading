require "ISUI/ISUIHandler"
-- No extra require needed for HaloTextHelper, it's global

local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "ScanResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        -- 1. SUCCESS (Green)
        if args.status == "SUCCESS" then
            player:playSound("RadioZombies")
            player:Say("Connected: " .. (args.name or "Unknown"))
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "New Signal Found", true, HaloTextHelper.getColorGreen())
            end
        
        -- 2. FAILURE: LIMIT REACHED (Red)
        elseif args.status == "LIMIT_REACHED" then
            player:playSound("RadioStatic")
            
            local failMsg = "Network Exhausted. Try again tomorrow."
            player:Say("The airwaves are dead... no more traders today.")
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, failMsg, true, HaloTextHelper.getColorRed())
            end
            
        -- 3. FAILURE: RNG / BAD LUCK (Red)
        else
            local failLines = {
                "Just static...",
                "Signal too weak.",
                "Connection lost.",
                "Dead air.",
                "No response.",
                "White noise..."
            }
            local text = failLines[ZombRand(#failLines)+1]
            
            player:Say(text)
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, text, true, HaloTextHelper.getColorRed())
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)