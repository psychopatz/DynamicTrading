-- ==============================================================================
-- DTNPC_ChatMenu.lua
-- Dedicated context menu for NPC interactions (Production).
-- ==============================================================================

local function getNPCData(zombie)
    if not zombie then return nil end
    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end
    -- Fallback for safety
    local modData = zombie:getModData()
    return modData and (modData.DTNPC_Data or modData.DTNPCBrain)
end

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

local function getAuthorityUsername(player)
    if not player then
        return nil
    end

    local username = player.getUsername and player:getUsername() or nil
    if DynamicTrading_Factions and DynamicTrading_Factions.GetPlayerFaction then
        local faction = DynamicTrading_Factions.GetPlayerFaction(username)
        local leader = faction and faction.leaderUsername or nil
        if leader and leader ~= "" then
            return tostring(leader)
        end
    end

    return username
end

local function isTravelCompanionForPlayer(player, npcData)
    if not player or not npcData then
        return false
    end

    if tostring(npcData.dcCompanionJob or "") ~= "TravelCompanion" then
        return false
    end

    if npcData.dcCompanionActive ~= true then
        return false
    end

    local authority = tostring(getAuthorityUsername(player) or "")
    local owner = tostring(npcData.dcCompanionOwner or npcData.ownerUsername or "")
    return authority ~= "" and owner == authority
end

local function sendCompanionOrder(player, npcData, args)
    if not player or not npcData or not npcData.uuid then
        return
    end

    args = type(args) == "table" and args or {}
    args.uuid = npcData.uuid
    sendClientCommand(player, "DTNPC", "Order", args)
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local square = nil
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then square = obj:getSquare(); break end
    end
    if not square then return end

    local npcList = {}
    local processedIDs = {} 

    local function scanSquare(sq)
        if not sq then return end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") then
                local npcData = getNPCData(obj)
                if npcData then
                    local id = obj:getPersistentOutfitID() or obj:getID()
                    if not processedIDs[id] then
                        -- Check distance (e.g., within 3 meters)
                        if calculateDistance(player, obj) < 3.0 then
                            table.insert(npcList, obj)
                            processedIDs[id] = true
                        end
                    end
                end
            end
        end
    end

    scanSquare(square)
    -- Also scan neighbors for ease of clicking
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz))
            end
        end
    end

    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local npcData = getNPCData(npc)
            local name = npcData and npcData.name or "Survivor"

            context:addOption("Talk to " .. name, npc, function(n)
                local id = n:getPersistentOutfitID() or n:getID()
                
                -- Delegate all interaction logic to the Dialogue Hub
                if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
                    DTNPC_TraderDialogue_Hub.Init(nil, npc, player)
                else
                    DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPC_TraderDialogue_Hub not found")
                end
            end)

            if isTravelCompanionForPlayer(player, npcData) then
                local companionOption = context:addOption("Companion Orders: " .. name, npc)
                local companionMenu = context:getNew(context)
                context:addSubMenu(companionOption, companionMenu)

                companionMenu:addOption("Follow", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "Follow",
                        returnStatus = "Resting",
                    })
                end)

                local protectOption = companionMenu:addOption("Protect", npc)
                local protectMenu = companionMenu:getNew(companionMenu)
                context:addSubMenu(protectOption, protectMenu)
                protectMenu:addOption("Auto", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "ProtectAuto",
                        combatOrder = "ProtectAuto",
                        returnStatus = "Resting",
                    })
                end)
                protectMenu:addOption("Ranged", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "ProtectRanged",
                        combatOrder = "ProtectRanged",
                        returnStatus = "Resting",
                    })
                end)
                protectMenu:addOption("Melee", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "ProtectMelee",
                        combatOrder = "ProtectMelee",
                        returnStatus = "Resting",
                    })
                end)

                companionMenu:addOption("Stay", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "Stay",
                        returnStatus = "Resting",
                    })
                end)

                companionMenu:addOption("Patch Up", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "PatchUp",
                    })
                end)

                companionMenu:addOption("Go Home", npc, function()
                    sendCompanionOrder(player, npcData, {
                        state = "Stay",
                        startDeparture = true,
                        returnStatus = "Resting",
                    })
                end)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
