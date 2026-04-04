-- ==============================================================================
-- DTNPC_ContextMenu_Builder.lua
-- Main menu builder and event registration for the debug NPC context menu.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.BuilderLoaded then
    return
end

Menu.BuilderLoaded = true

local function scanSquare(square, npcList, processedIDs)
    if not square then return end

    local movingObjects = square:getMovingObjects()
    for i = 0, movingObjects:size() - 1 do
        local obj = movingObjects:get(i)
        if instanceof(obj, "IsoZombie") then
            local npcData = Menu.GetNPCData(obj)
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

function DTNPCMenu.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local square
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then
            square = obj:getSquare()
            break
        end
    end
    if not square then return end

    local npcList = {}
    local processedIDs = {}

    scanSquare(square, npcList, processedIDs)

    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz), npcList, processedIDs)
            end
        end
    end

    table.sort(npcList, function(a, b)
        return Menu.CalculateDistance(player, a) < Menu.CalculateDistance(player, b)
    end)

    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local npcData = Menu.GetNPCData(npc) or { name = "Unknown", state = "Unknown" }
            local status = " [" .. (npcData.state or "Idle") .. "]"

            local option = context:addOption("NPC: " .. npcData.name .. status)
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)

            subMenu:addOption("Follow Me", npc, Menu.OnOrder, "Follow", player)
            subMenu:addOption("Protect Me (Auto)", npc, Menu.OnOrder, "ProtectAuto", player)
            subMenu:addOption("Protect Me (Ranged)", npc, Menu.OnOrder, "ProtectRanged", player)
            subMenu:addOption("Protect Me (Melee)", npc, Menu.OnOrder, "ProtectMelee", player)
            subMenu:addOption("Stop / Guard", npc, Menu.OnOrder, "Stay", player)
            subMenu:addOption("Come Here (My Pos)", npc, Menu.OnOrder, "GoTo", player)

            if EventMarkerHandler then
                subMenu:addOption("Mark NPC Location", player, Menu.OnMarkNPC, npc)
            end

            local debugOption = subMenu:addOption("DEBUG / TEST")
            local debugSub = subMenu:getNew(subMenu)
            context:addSubMenu(debugOption, debugSub)

            debugSub:addOption("TEST: Enter Coordinates...", player, Menu.OnOpenCoordBox, npc)
            debugSub:addOption("TEST: Flee (Return as Resting)", npc, Menu.OnOrder, "Flee", player, "Resting")
            debugSub:addOption("TEST: Flee (Return as Trading)", npc, Menu.OnOrder, "Flee", player, "Trading")
            debugSub:addOption("TEST: Attack Me (Melee)", npc, Menu.OnOrder, "Attack", player)
            debugSub:addOption("TEST: Attack Me (Gun)", npc, Menu.OnOrder, "AttackRange", player)
            local heldWeaponLabel = Menu.GetHeldDebugWeaponLabel and Menu.GetHeldDebugWeaponLabel(player) or nil
            if heldWeaponLabel then
                debugSub:addOption("TEST: Give Held Weapon [" .. tostring(heldWeaponLabel) .. "]", npc, Menu.OnDebugGiveHeldWeapon, player)
            end
            debugSub:addOption("TEST: Force Ambient Speech", player, Menu.OnForceAmbientDialogue, npc)
            debugSub:addOption("DEBUG: Print Ambient Dialogue Info", player, Menu.OnDebugAmbientDialogue, npc)
            debugSub:addOption("DEBUG: Inspect Data", nil, function()
                Menu.OnInspectNPCData(npc)
            end)
        end

        return
    end

    local managerOption = context:addOption("[DEBUG]NPC Manager")
    local managerSubMenu = context:getNew(context)
    context:addSubMenu(managerOption, managerSubMenu)

    managerSubMenu:addOption("Summon All Followers", player, Menu.OnSummon)
    managerSubMenu:addOption("Spawn Random NPC", player, Menu.OnSpawnRandomNPC)

    if EventMarkerHandler then
        local markerOption = managerSubMenu:addOption("NPC Markers")
        local markerSubMenu = managerSubMenu:getNew(managerSubMenu)
        context:addSubMenu(markerOption, markerSubMenu)

        markerSubMenu:addOption("Mark All NPCs", player, Menu.OnMarkAllNPCs)
        markerSubMenu:addOption("Clear All NPC Markers", player, Menu.OnClearNPCMarkers)
    end

    managerSubMenu:addOption("Open NPC Global Debugger", nil, DTNPC_Debugger.OnOpenWindow)
end

if not Menu.EventsRegistered then
    Events.OnFillWorldObjectContextMenu.Add(DTNPCMenu.OnFillWorldObjectContextMenu)
    Menu.EventsRegistered = true
end
