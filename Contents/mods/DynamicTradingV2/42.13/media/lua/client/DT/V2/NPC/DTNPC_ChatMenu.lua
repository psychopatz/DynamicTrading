-- ==============================================================================
-- DTNPC_ChatMenu.lua
-- Dedicated context menu for NPC interactions (Production).
-- ==============================================================================

pcall(require, "DT/V2/NPC/Jobs/DTNPC_JobUI")

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

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test and ISWorldObjectContextMenu and ISWorldObjectContextMenu.Test then
        return true
    end

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
            local talkLabel = DTNPCJobUI and DTNPCJobUI.GetTalkLabel
                and DTNPCJobUI.GetTalkLabel(nil, npc, player, npcData, name)
                or ("Talk to " .. name)

            context:addOption(talkLabel, npc, function(n)
                -- Delegate all interaction logic to the Dialogue Hub
                if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
                    DTNPC_TraderDialogue_Hub.Init(nil, n, player)
                else
                    DynamicTrading.Log("DTV2", "NPC", "Error", "DTNPC_TraderDialogue_Hub not found")
                end
            end)

            if DTNPCJobUI and DTNPCJobUI.AddContextMenuOptions then
                DTNPCJobUI.AddContextMenuOptions(context, nil, npc, player, npcData)
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
