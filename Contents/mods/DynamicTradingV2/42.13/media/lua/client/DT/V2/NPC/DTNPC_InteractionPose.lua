-- ==============================================================================
-- DTNPC_InteractionPose.lua
-- Client-side helper that keeps an NPC in an explaining pose while interacting.
-- ==============================================================================

if isServer() and not isClient() then return end

DTNPC_InteractionPose = DTNPC_InteractionPose or {}
DTNPC_InteractionPose.Active = DTNPC_InteractionPose.Active or {}
DTNPC_InteractionPose.UPDATE_RATE = DTNPC_InteractionPose.UPDATE_RATE or 2
DTNPC_InteractionPose.DEFAULT_IDLE_STATE = "3"

local function getLocalPlayer()
    if getPlayer then
        local player = getPlayer()
        if player then
            return player
        end
    end

    return getSpecificPlayer(0)
end

local function getNPCUUID(npc)
    if not npc then return nil end

    local npcData = DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
    if npcData and npcData.uuid then
        return npcData.uuid
    end

    local modData = npc:getModData()
    if modData and modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end

    return tostring(npc:getPersistentOutfitID() or npc:getID())
end

local function clearForcedIdleState(npc)
    if not npc then return end

    local modData = npc:getModData()
    if modData then
        modData.DTNPCClientForcedIdleState = nil
    end

    npc:setVariable("DTIdleState", "0")
end

local function isConversationActiveForNPC(npc)
    if not npc or not DT_ConversationUI or not DT_ConversationUI.instance then
        return false
    end

    local ui = DT_ConversationUI.instance
    if not ui:getIsVisible() then
        return false
    end

    return ui.interactionObj == npc
end

local function isTradingWindowActiveForNPC(npc, uuid)
    if not npc or not DT_TradingWindow or not DT_TradingWindow.instance then
        return false
    end

    local ui = DT_TradingWindow.instance
    if not ui:getIsVisible() then
        return false
    end

    if ui.radioObj == npc then
        return true
    end

    if ui.dataProvider and ui.dataProvider._currentNPC == npc then
        return true
    end

    if uuid and ui.traderID and tostring(ui.traderID) == tostring(uuid) then
        return true
    end

    return false
end

local function isInteractionContextActive(entry)
    if not entry or not entry.npc then
        return false
    end

    if isConversationActiveForNPC(entry.npc) then
        return true
    end

    if isTradingWindowActiveForNPC(entry.npc, entry.uuid) then
        return true
    end

    return false
end

local function applyInteractionPose(entry)
    if not entry or not entry.npc then return false end

    local npc = entry.npc
    if npc:isDead() then
        return false
    end

    local modData = npc:getModData()
    if modData then
        modData.DTNPCClientForcedIdleState = tostring(entry.idleState or DTNPC_InteractionPose.DEFAULT_IDLE_STATE)
        local npcData = modData.DTNPC_Data
        local forcedIndex = tonumber(entry.idleState or DTNPC_InteractionPose.DEFAULT_IDLE_STATE) or 0
        if npcData then
            npcData.idleCycleIndex = forcedIndex
            npcData.idleCycleCounter = 0
        end
    end

    npc:setVariable("bMoving", false)
    npc:setVariable("Speed", 0.0)
    npc:setVariable("DTIdleState", tostring(entry.idleState or DTNPC_InteractionPose.DEFAULT_IDLE_STATE))

    local player = entry.player or getLocalPlayer()
    if player and not player:isDead() and math.abs((player:getZ() or 0) - npc:getZ()) <= 1 then
        npc:faceLocation(player:getX(), player:getY())
    end

    return true
end

function DTNPC_InteractionPose.Activate(npc, idleState, player)
    local uuid = getNPCUUID(npc)
    if not uuid then return nil end

    DTNPC_InteractionPose.Active[uuid] = {
        uuid = uuid,
        npc = npc,
        player = player or getLocalPlayer(),
        idleState = tostring(idleState or DTNPC_InteractionPose.DEFAULT_IDLE_STATE),
    }

    applyInteractionPose(DTNPC_InteractionPose.Active[uuid])
    return uuid
end

function DTNPC_InteractionPose.Deactivate(npcOrUUID)
    local uuid = npcOrUUID
    local npc = nil

    if type(npcOrUUID) == "table" then
        npc = npcOrUUID
        uuid = getNPCUUID(npcOrUUID)
    end

    if not uuid then return end

    local entry = DTNPC_InteractionPose.Active[uuid]
    if entry and entry.npc then
        npc = entry.npc
    end

    DTNPC_InteractionPose.Active[uuid] = nil
    clearForcedIdleState(npc)
end

local function onTick()
    DTNPC_InteractionPose._tickCounter = (DTNPC_InteractionPose._tickCounter or 0) + 1
    if DTNPC_InteractionPose._tickCounter < DTNPC_InteractionPose.UPDATE_RATE then
        return
    end
    DTNPC_InteractionPose._tickCounter = 0

    for uuid, entry in pairs(DTNPC_InteractionPose.Active) do
        if not isInteractionContextActive(entry) then
            DTNPC_InteractionPose.Deactivate(uuid)
        elseif not applyInteractionPose(entry) then
            DTNPC_InteractionPose.Active[uuid] = nil
        end
    end
end

Events.OnTick.Remove(onTick)
Events.OnTick.Add(onTick)
