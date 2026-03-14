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

function V2_DataProvider:lockItem(itemID)
    local player = getLocalPlayer()
    if not player then return end
    local modData = player:getModData()
    if not modData.DT_LockedItems then modData.DT_LockedItems = {} end
    modData.DT_LockedItems[itemID] = true
end

function V2_DataProvider:openHub(trader, parentUI)
    if parentUI then parentUI:close() end

    if trader.npcRef and DTNPC_TraderDialogue_Hub then
        DTNPC_TraderDialogue_Hub.Init(nil, trader.npcRef, getLocalPlayer())
    end
end

function V2_DataProvider:getFavorStatus(trader)
    return { canRequest = true, tooltip = "Return to conversation" }
end

function V2_DataProvider:getAskButtonConfig(isBuying)
    if isBuying then
        return { title = "Talk", visible = true }
    else
        return { title = "Ask What They Want", visible = true }
    end
end

function V2_DataProvider:onAsk(trader, isBuying, ui)
    if isBuying then
        self:openHub(trader, ui)
    else
        local playerMsg = self:getPlayerMessage("SellAsk", {})
        ui:queueMessage(playerMsg, false, true, 0)

        local npcMsg = self:getSellAskDialogue(trader)
        ui:queueMessage(npcMsg, false, false, 30)
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

function V2_DataProvider:getPlayerWealth(player)
    if not player then return 0 end
    local inv = player:getInventory()
    local loose = inv:getItemsFromType("Base.Money", true)
    local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = loose and loose:size() or 0
    local bundleCount = bundles and bundles:size() or 0
    local total = looseCount + (bundleCount * 100)
    return total
end

function V2_DataProvider:getDailyStatus()
    return 0, 999
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
