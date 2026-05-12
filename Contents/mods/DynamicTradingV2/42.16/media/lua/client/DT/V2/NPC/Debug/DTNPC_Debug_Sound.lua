-- ==============================================================================
-- DTNPC_Debug_Sound.lua
-- Context menu entry for testing NPC vocalizations.
-- ==============================================================================

require "DT/V2/NPC/Debug/DTNPC_Debug_SoundUI"

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

    local debugMain = context:addOption("Debug: NPC Vocal System")
    local mainSub = context:getNew(context)
    context:addSubMenu(debugMain, mainSub)

    mainSub:addOption("[UI] Open Vocal Debug...", nil, function()
        if DTNPC_Debug_SoundUI and DTNPC_Debug_SoundUI.ToggleWindow then
            DTNPC_Debug_SoundUI.ToggleWindow()
        end
    end)

    if #npcList > 0 then
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

            subMenu:addOption("Test Effort Sound", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayHurtSound then
                    DTNPCHostility.PlayHurtSound(n, npcData, "Effort")
                    n:setHaloNote("SFX: Effort (" .. voiceSet .. ")", 200, 200, 255, 300)
                end
            end)

            subMenu:addOption("Test Bandage", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayVocal then
                    DTNPCHostility.PlayVocal(n, npcData, "Bandage")
                    n:setHaloNote("SFX: Bandage (" .. voiceSet .. ")", 100, 255, 100, 300)
                end
            end)

            -- --- New Ambient Chatter Tests ---
            local ambientOption = subMenu:addOption("Test Ambient Chatter")
            local ambientMenu = context:getNew(subMenu)
            subMenu:addSubMenu(ambientOption, ambientMenu)
            
            ambientMenu:addOption("Test Hey (Chat + Text)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.Say then
                    DTNPCHostility.Say(n, npcData, "Hey!", "Chat")
                end
            end)

            ambientMenu:addOption("Test Sigh", npc, function(n)
                if DTNPCHostility and DTNPCHostility.Say then
                    DTNPCHostility.Say(n, npcData, "...sigh...", "Sigh")
                end
            end)

            ambientMenu:addOption("Test Sneeze (Ambient)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayVocal then
                    DTNPCHostility.PlayVocal(n, npcData, "Ambient")
                    n:setHaloNote("SFX: Ambient/Sneeze", 200, 200, 255, 300)
                end
            end)

            ambientMenu:addOption("Test State (Jump/Sleep/Smoke)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayVocal then
                    DTNPCHostility.PlayVocal(n, npcData, "State")
                    n:setHaloNote("SFX: State", 200, 255, 200, 300)
                end
            end)

            ambientMenu:addOption("Test Alone (Ambient)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.Say then
                    DTNPCHostility.Say(n, npcData, "I'm all alone...", "Ambient")
                end
            end)

            ambientMenu:addOption("Test Angry (Chat Pool)", npc, function(n)
                if DTNPCHostility and DTNPCHostility.Say then
                    DTNPCHostility.Say(n, npcData, "Damm it!", "Chat")
                end
            end)

            ambientMenu:addOption("Test Specific: Angry", npc, function(n)
                if DTNPCHostility and DTNPCHostility.PlayVocal then
                    DTNPCHostility.PlayVocal(n, npcData, "Chat_Angry")
                    n:setHaloNote("SFX: Angry", 255, 100, 100, 300)
                end
            end)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
