-- ==============================================================================
-- DTNPC_ContextMenuProvider_FollowMethod.lua
-- Generic follow-spacing submenu for any NPC currently following the player.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}

local function T(key, params, fallback)
    return DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
        and DynamicTrading.Text.Get(key, params, fallback)
        or fallback
        or tostring(key or "")
end

local function normalizeFollowSpacingMode(mode)
    local text = string.lower(tostring(mode or ""))
    if text == "far" then
        return "far"
    end
    if text == "near" then
        return "near"
    end
    return nil
end

local function getFollowSpacingMode(npcData)
    local mode = normalizeFollowSpacingMode(npcData and npcData.followSpacingMode or nil)
    if mode then
        return mode
    end
    if npcData and npcData.doObjectiveEscortActive == true then
        return "far"
    end
    return "near"
end

local function isLocalPlayerFollowOwner(player, npcData)
    if not player or not npcData then
        return false
    end
    if tostring(npcData.state or "") ~= "Follow" then
        return false
    end

    local playerID = player.getOnlineID and player:getOnlineID() or nil
    if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
        return true
    end

    local username = player.getUsername and player:getUsername() or nil
    if not username or username == "" then
        return false
    end

    return tostring(npcData.master or "") == username
end

local function issueFollowSpacingOrder(player, npc, npcData, followSpacingMode)
    if not player or not npc or not npcData or not npcData.uuid or not sendClientCommand then
        return false
    end

    local mode = normalizeFollowSpacingMode(followSpacingMode)
    if not mode then
        return false
    end

    sendClientCommand(player, "DTNPC", "Order", {
        uuid = npcData.uuid,
        state = "Follow",
        followSpacingMode = mode,
        returnStatus = npcData.requestedReturnStatus or "Resting",
    })

    npcData.followSpacingMode = mode
    if DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
    return true
end

local function addFollowMethodOption(context, ui, npc, player, npcData)
    if not context or not npc or not isLocalPlayerFollowOwner(player, npcData) then
        return
    end

    local name = tostring(npcData and npcData.name or "Survivor")
    local currentMode = getFollowSpacingMode(npcData)
    local rootOption = context:addOption(T("DTNPC_UI_FollowMethodForName", {
        name = name,
    }, "Follow Method: {name}"))
    local subMenu = context:getNew(context)
    context:addSubMenu(rootOption, subMenu)

    subMenu:addOption(
        currentMode == "near"
            and T("DTNPC_UI_ModeActive", { label = T("DTNPC_UI_Near", nil, "Near") }, "{label} [ACTIVE]")
            or T("DTNPC_UI_Near", nil, "Near"),
        npc,
        function(targetNPC)
        local liveData = DTNPCContextMenu.GetNPCData(targetNPC) or npcData
        issueFollowSpacingOrder(player, targetNPC, liveData, "near")
        end
    )
    subMenu:addOption(
        currentMode == "far"
            and T("DTNPC_UI_ModeActive", { label = T("DTNPC_UI_Far", nil, "Far") }, "{label} [ACTIVE]")
            or T("DTNPC_UI_Far", nil, "Far"),
        npc,
        function(targetNPC)
        local liveData = DTNPCContextMenu.GetNPCData(targetNPC) or npcData
        issueFollowSpacingOrder(player, targetNPC, liveData, "far")
        end
    )
end

DTNPCContextMenu.RegisterProvider({
    id = "follow_method",
    priority = 80,
    addOptions = addFollowMethodOption,
})
