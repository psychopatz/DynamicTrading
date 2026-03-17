-- =============================================================================
-- TradingWindowWrapper_Actions.lua
-- Item actions, hub behavior, connection checks, and toggle override.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}

local function getLocalPlayer()
    if getPlayer then
        local player = getPlayer()
        if player then
            return player
        end
    end

    return getSpecificPlayer(0)
end

local function setTradingInteractionPose(npcRef)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Activate and npcRef then
        DTNPC_InteractionPose.Activate(
            npcRef,
            DTNPCLogic and DTNPCLogic.Stationary and DTNPCLogic.Stationary.TRADE_INTERACTION_IDLE_STATE or "1",
            getLocalPlayer()
        )
    end
end

local function clearTradingInteractionPose(npcRef)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Deactivate and npcRef then
        DTNPC_InteractionPose.Deactivate(npcRef)
    end
end

function V2_DataProvider:openHub(trader, parentUI)
    if parentUI then parentUI:close() end

    if trader.npcRef and DTNPC_TraderDialogue_Hub then
        DTNPC_TraderDialogue_Hub.Init(nil, trader.npcRef, getLocalPlayer())
    end
end

function V2_DataProvider:isConnectionValid(npc)
    if not npc then
        return self._currentNPC ~= nil
    end

    if DT_TradingWindow and DT_TradingWindow.instance then
        if not DT_TradingWindow.instance:getIsVisible() then
            return false
        end
    end

    return DynamicTrading.Utils.IsInteractionValid(npc, nil, nil)
end

local originalToggle = DT_TradingWindow.ToggleWindow

function DT_TradingWindow.ToggleWindowV2(traderID, archetype, npcRef)
    DynamicTrading.Log("DTV2", "Trade", "Wrapper", "ToggleWindowV2 called")
    DynamicTrading.Log("DTV2", "Trade", "Wrapper", "TraderID: " .. tostring(traderID))
    DynamicTrading.Log("DTV2", "Trade", "Wrapper", "Archetype: " .. tostring(archetype))

    V2_DataProvider._currentTraderID = traderID
    V2_DataProvider._currentNPC = npcRef

    originalToggle(traderID, archetype, npcRef, V2_DataProvider)

    if DT_TradingWindow and DT_TradingWindow.instance then
        DT_TradingWindow.instance.onCloseCallback = function()
            clearTradingInteractionPose(npcRef)
        end
        setTradingInteractionPose(npcRef)
    else
        clearTradingInteractionPose(npcRef)
    end
end
