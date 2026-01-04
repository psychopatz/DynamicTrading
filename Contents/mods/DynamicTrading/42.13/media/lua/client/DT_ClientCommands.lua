require "ISUI/ISUIHandler"
-- No extra require needed for HaloTextHelper, it's global

local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "ScanResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        local myName = player:getUsername()
        local targetName = args.targetUser or "Unknown"
        local isMe = (myName == targetName)
        
        -- ==========================================================
        -- SCENARIO A: I PERFORMED THE SCAN (Full Feedback)
        -- ==========================================================
        if isMe then
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

        -- ==========================================================
        -- SCENARIO B: SOMEONE ELSE SCANNED (Network Broadcast)
        -- ==========================================================
        else
            -- Check Sandbox Setting: Is Public Network enabled?
            local publicNetwork = SandboxVars.DynamicTrading.PublicNetwork
            if not publicNetwork then return end -- If false, ignore others completely.

            -- If Public, we only care about SUCCESS (Don't spam me when others fail)
            if args.status == "SUCCESS" then
                if HaloTextHelper then
                    local msg = targetName .. " located: " .. (args.name or "Unknown")
                    -- Show as a general notification (no arrow, just text on screen)
                    HaloTextHelper.addText(player, msg, HaloTextHelper.getColorGreen())
                end
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)