-- ==============================================================================
-- DTNPC_ContextMenu_Orders.lua
-- Client command senders and coordinate input actions for the debug context menu.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.OrdersLoaded then
    return
end

Menu.OrdersLoaded = true

local RANDOM_OCCUPATIONS = {
    "General", "Farmer", "Butcher", "Doctor", "Mechanic", "Survivalist",
    "Gunrunner", "Foreman", "Scavenger", "Tailor", "Electrician", "Welder",
    "Chef", "Herbalist", "Smuggler", "Librarian", "Angler", "Sheriff",
    "Bartender", "Teacher", "Hunter", "Quartermaster", "Musician", "Janitor",
    "Carpenter", "Pawnbroker", "Pyro", "Athlete", "Pharmacist", "Hiker",
    "Burglar", "Blacksmith", "Tribal", "Painter", "RoadWarrior", "Designer",
    "Office", "Geek", "Brewer", "Demo"
}

local function attachNPCData(npc, npcData)
    if DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
end

local function isProtectState(state)
    return state == "ProtectRanged" or state == "ProtectMelee" or state == "ProtectAuto"
end

function Menu.OnOrder(npc, state, player, returnStatus)
    if not npc or not player then return end
    local npcData = Menu.GetNPCData(npc)

    local args = {
        x = npc:getX(),
        y = npc:getY(),
        z = npc:getZ(),
        state = state,
        returnStatus = returnStatus,
        uuid = npcData and npcData.uuid or nil,
    }

    if state == "GoTo" then
        args.targetX = player:getX()
        args.targetY = player:getY()
        args.targetZ = player:getZ()
    end

    sendClientCommand(player, "DTNPC", "Order", args)

    if not npcData then return end

    npcData.state = state

    if state == "Follow" or state == "Attack" or state == "AttackRange" or isProtectState(state) then
        npcData.master = player:getUsername()
        npcData.masterID = isClient() and player:getOnlineID() or 0
        npcData.tasks = {}
        npcData.combatOrder = isProtectState(state) and state or nil
    elseif state == "GoTo" then
        npcData.tasks = {
            { x = args.targetX, y = args.targetY, z = args.targetZ }
        }
        npcData.combatOrder = nil
    else
        npcData.tasks = {}
        npcData.combatOrder = nil
    end

    attachNPCData(npc, npcData)
    player:Say("Order (" .. npcData.name .. "): " .. state)
end

function Menu.OnCoordInput(target, button, player, npc)
    if button.internal ~= "OK" then return end

    local text = button.parent.entry:getText()
    if not text or text == "" then return end

    local parts = {}
    for num in string.gmatch(text, "[%d%.%-]+") do
        table.insert(parts, tonumber(num))
    end

    if #parts < 2 then
        player:Say("Invalid Coords! Use format: 10820,9463,0")
        return
    end

    local tx = parts[1]
    local ty = parts[2]
    local tz = parts[3] or 0

    if not tx or not ty or not tz then
        player:Say("Invalid Coords! Numbers not recognized.")
        return
    end

    local args = {
        x = npc:getX(),
        y = npc:getY(),
        z = npc:getZ(),
        state = "GoTo",
        targetX = tx,
        targetY = ty,
        targetZ = tz
    }

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Admin",
        "Sending GoTo command with coords: " .. tx .. "," .. ty .. "," .. tz
    )
    sendClientCommand(player, "DTNPC", "Order", args)

    local npcData = Menu.GetNPCData(npc)
    if npcData then
        npcData.state = "GoTo"
        npcData.tasks = {
            { x = tx, y = ty, z = tz }
        }
        attachNPCData(npc, npcData)
    end

    player:Say("Sent GoTo: " .. math.floor(tx) .. ", " .. math.floor(ty) .. ", " .. math.floor(tz))
end

function Menu.OnOpenCoordBox(player, npc)
    local defaultText = math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0"
    local modal = ISTextBox:new(
        0,
        0,
        280,
        180,
        "Enter Target Coordinates (X,Y,Z):",
        defaultText,
        nil,
        Menu.OnCoordInput,
        player:getPlayerNum(),
        player,
        npc
    )
    modal:initialise()
    modal:addToUIManager()
end

function Menu.OnSummon(player)
    sendClientCommand(player, "DTNPC", "Summon", {})
    player:Say("Signal Sent: Summoning Team...")
end

function Menu.OnSpawnRandomNPC(player)
    local occupation = RANDOM_OCCUPATIONS[ZombRand(#RANDOM_OCCUPATIONS) + 1]
    sendClientCommand(player, "DTNPC", "Spawn", { occupation = occupation })
end

function Menu.OnDebugGiveHeldWeapon(npc, player)
    if not npc or not player then
        return
    end

    local npcData = Menu.GetNPCData(npc)
    local heldItem = Menu.GetHeldDebugWeapon and Menu.GetHeldDebugWeapon(player) or nil
    if not heldItem then
        player:Say("Hold a weapon first.")
        return
    end

    sendClientCommand(player, "DTNPC", "DebugGiveHeldWeapon", {
        uuid = npcData and npcData.uuid or nil,
    })

    local itemName = heldItem.getDisplayName and heldItem:getDisplayName() or heldItem:getFullType()
    local npcName = npcData and npcData.name or "NPC"
    player:Say("Test handoff: " .. tostring(itemName) .. " -> " .. tostring(npcName))
end
