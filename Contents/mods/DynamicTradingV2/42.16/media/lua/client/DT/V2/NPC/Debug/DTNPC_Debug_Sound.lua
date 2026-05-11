-- ==============================================================================
-- DTNPC_Debug_Sound.lua
-- Context menu entry for testing NPC vocalizations.
-- ==============================================================================

local function getNPCData(zombie)
    if not zombie then return nil end
    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end
    local modData = zombie:getModData()
    return modData and (modData.DTNPC_Data or modData.DTNPCBrain)
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
                        table.insert(npcList, obj)
                        processedIDs[id] = true
                    end
                end
            end
        end
    end

    scanSquare(square)
    -- Also scan neighbors
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz))
            end
        end
    end

    if #npcList > 0 then
        local debugMain = context:addOption("Debug: NPC Vocal System")
        local mainSub = context:getNew(context)
        context:addSubMenu(debugMain, mainSub)

        for _, npc in ipairs(npcList) do
            local npcData = getNPCData(npc)
            local name = npcData and npcData.name or "Survivor"
            local voiceSet = "V" .. (1 + ((tonumber(npcData.identitySeed) or 0) % 4))
            
            local npcOption = mainSub:addOption(name .. " (" .. voiceSet .. ")")
            local subMenu = mainSub:getNew(mainSub)
            mainSub:addSubMenu(npcOption, subMenu)

            subMenu:addOption("Test Hurt Sound (Random Variant)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayHurtSound then
                    DTNPCHostility.PlayHurtSound(n, npcData, "Hurt")
                    n:setHaloNote("SFX: Hurt (" .. voiceSet .. ")", 255, 255, 255, 300)
                end
            end)

            subMenu:addOption("Test Incap Sound", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayHurtSound then
                    DTNPCHostility.PlayHurtSound(n, npcData, "Incap")
                    n:setHaloNote("SFX: Incap (" .. voiceSet .. ")", 255, 255, 0, 300)
                end
            end)

            subMenu:addOption("Test Death Sound", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayHurtSound then
                    DTNPCHostility.PlayHurtSound(n, npcData, "Death")
                    n:setHaloNote("SFX: Death (" .. voiceSet .. ")", 255, 0, 0, 300)
                end
            end)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
