-- =============================================================================
-- CLASS DEFINITION
-- =============================================================================
require "DT/Common/Dialogue/DT_Dialogue_Vocals"

DT_TradingWindow = DT_TradingWindow or ISCollapsableWindow:derive("DT_TradingWindow")
DT_TradingWindow.instance = nil

local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function nowMs()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    return math.floor((os.time() or 0) * 1000)
end

function DT_TradingWindow:IsPerfDebugEnabled()
    return DynamicTrading and DynamicTrading.DebugPerformance == true
end

function DT_TradingWindow:GetNowMs()
    return nowMs()
end

function DT_TradingWindow:logPerf(scope, message)
    if not self:IsPerfDebugEnabled() then
        return
    end

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "TradePerf", tostring(scope or "Window"), tostring(message or ""))
    else
        print("[DT TradePerf][" .. tostring(scope or "Window") .. "] " .. tostring(message or ""))
    end
end

function DT_TradingWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 600
    self.minimumHeight = 650
    self.isBuying = true
    self.transactionKind = "buy"
    self.sessionContext = nil
    self.selectedKey = nil
    self.radioObj = nil
    self.collapsed = {}
    self.lastSelectedIndex = -1
    self.localLogs = {}
    self.dataProvider = nil -- INJECTED ON CREATION

    -- ==========================================================
    -- LOGIC STATE TRACKERS
    -- ==========================================================
    self.idleTimer = 0
    self.updateTick = 0

    -- Prevent FPS drops by limiting inventory scanning frequency.
    self.inventoryDirty = false
    self.refreshCooldown = 0
    self.sellScanSession = nil
    self.sellScanListDirty = false
    self.sellScanLastListRefreshAt = 0
    self.lastOpenPopulateAt = 0
    self.tradeRequestPending = false
    self.awaitingAuthoritativeTradeSync = false
    self.tradeRequestStartedAt = 0
    self.tradePendingButtonTitle = nil

    self.lastHour = -1
    self.wasRaining = false
    self.wasFoggy = false

    -- Structure: { text="", isError=false, isPlayer=false, delay=0, sound=nil, audio=nil }
    self.msgQueue = {}
    self.typingTick = 0
end

function DT_TradingWindow:getTradeSessionContext()
    if self.sessionContext ~= nil then
        return self.sessionContext
    end

    if self.dataProvider and self.dataProvider.getTradeSessionContext then
        self.sessionContext = self.dataProvider:getTradeSessionContext(self.traderID, self.archetype)
    end

    return self.sessionContext
end

function DT_TradingWindow:getTransactionKind()
    local sessionContext = self:getTradeSessionContext()
    local transactionKind = sessionContext and sessionContext.transactionKind or nil
    if transactionKind == "gift" then
        return "gift"
    end

    return self.isBuying and "buy" or "sell"
end

function DT_TradingWindow:isGiftMode()
    return self:getTransactionKind() == "gift"
end

function DT_TradingWindow:getDefaultActionTitle()
    if self.isBuying then
        return T("DTCommon_UI_Trading_BuyItem", nil, "BUY ITEM")
    end

    if self:isGiftMode() then
        return T("DTCommon_UI_Trading_GiftItem", nil, "GIFT ITEM")
    end

    return T("DTCommon_UI_Trading_SellItem", nil, "SELL ITEM")
end

function DT_TradingWindow:getModeTabTitle(isBuying)
    if isBuying then
        return T("DTCommon_UI_Trading_BuyFromTrader", nil, "BUY FROM TRADER")
    end

    if self:isGiftMode() then
        return T("DTCommon_UI_Trading_GiftToNpc", nil, "GIFT TO NPC")
    end

    return T("DTCommon_UI_Trading_SellToTrader", nil, "SELL TO TRADER")
end

function DT_TradingWindow:getActionButtonTitle(data)
    if not data then
        return self:getDefaultActionTitle()
    end

    local price = tonumber(data.price) or 0
    if self.isBuying then
        return T("DTCommon_UI_Trading_BuyPrice", { price = price }, "BUY ($" .. tostring(price) .. ")")
    end

    local qty = tonumber(data.qty) or 1
    if self:isGiftMode() then
        if qty > 1 then
            return T(
                "DTCommon_UI_Trading_GiftValueEach",
                { qty = qty, price = price },
                "GIFT x" .. tostring(qty) .. " (Value $" .. tostring(price) .. " EA)"
            )
        end
        return T("DTCommon_UI_Trading_GiftValue", { price = price }, "GIFT (Value $" .. tostring(price) .. ")")
    end

    if qty > 1 then
        return T(
            "DTCommon_UI_Trading_SellPriceEach",
            { qty = qty, price = price },
            "SELL x" .. tostring(qty) .. " ($" .. tostring(price) .. " EA)"
        )
    end
    return T("DTCommon_UI_Trading_SellPrice", { price = price }, "SELL ($" .. tostring(price) .. ")")
end

function DT_TradingWindow:refreshTradeLabels()
    if self.btnTabBuy then
        self.btnTabBuy:setTitle(self:getModeTabTitle(true))
    end

    if self.btnTabSell then
        self.btnTabSell:setTitle(self:getModeTabTitle(false))
    end

    if self.btnAction and (not self.listbox or self.listbox.selected == -1) then
        self.btnAction:setTitle(self:getDefaultActionTitle())
    end
end

function DT_TradingWindow:resetIdleTimer()
    self.idleTimer = 0
end

function DT_TradingWindow:isTradeRequestLocked()
    return self.tradeRequestPending == true
end

function DT_TradingWindow:beginTradeRequest()
    if self.tradeRequestPending then
        return false
    end

    self.tradeRequestPending = true
    self.awaitingAuthoritativeTradeSync = false
    self.tradeRequestStartedAt = self:GetNowMs()
    if self.btnAction then
        self.tradePendingButtonTitle = self.btnAction.title or self:getDefaultActionTitle()
        self.btnAction:setEnable(false)
        self.btnAction:setTitle(T("DTCommon_UI_Trading_Processing", nil, "PROCESSING..."))
    end
    return true
end

function DT_TradingWindow:onTradeRequestFailed()
    self.tradeRequestPending = false
    self.awaitingAuthoritativeTradeSync = false
    self.tradeRequestStartedAt = 0
    self.tradePendingButtonTitle = nil
    if self.populateList then
        self:populateList()
    end
end

function DT_TradingWindow:onTradeRequestAccepted()
    if not self.tradeRequestPending then
        return
    end

    self.awaitingAuthoritativeTradeSync = true
end

function DT_TradingWindow:onAuthoritativeTradeSync()
    if not self.tradeRequestPending and not self.awaitingAuthoritativeTradeSync then
        return
    end

    self.tradeRequestPending = false
    self.awaitingAuthoritativeTradeSync = false
    self.tradeRequestStartedAt = 0
    self.tradePendingButtonTitle = nil
end

function DT_TradingWindow:queueMessage(text, isError, isPlayer, delay, soundName, tag, audio)
    if tag then
        for _, msg in ipairs(self.msgQueue) do
            if msg.tag == tag then
                msg.delay = 0
            end
        end
    end

    table.insert(self.msgQueue, {
        text = text,
        isError = isError or false,
        isPlayer = isPlayer or false,
        delay = delay or 0,
        sound = soundName,
        tag = tag,
        audio = audio,
    })
end

function DT_TradingWindow:isRadioTradeSession()
    if self.radioObj and instanceof and instanceof(self.radioObj, "InventoryItem") then
        return true
    end

    local trader = self:getCurrentTrader()
    if trader and trader.npcRef then
        return false
    end

    return self.radioObj ~= nil and not (trader and trader.npcRef)
end

function DT_TradingWindow:getTradeSpeaker()
    local trader = self:getCurrentTrader()
    local npcRef = trader and trader.npcRef or nil
    local npcData = nil

    if npcRef and DTNPC and DTNPC.GetData then
        npcData = DTNPC.GetData(npcRef)
    end

    return trader, npcRef, npcData
end

function DT_TradingWindow:getTradeDispositionHook(trader, npcData)
    if not DialogueVocals or not DialogueVocals.ResolveDispositionHook then
        return nil
    end

    return DialogueVocals.ResolveDispositionHook(
        npcData,
        trader and trader.status or nil,
        trader and trader.currentState or nil,
        trader
    )
end

function DT_TradingWindow:buildNPCTradeAudio(text, options)
    local opts = type(options) == "table" and options or {}
    if self:isRadioTradeSession() then
        return {
            uiSound = opts.uiSound or opts.soundName or "DT_RadioRandom",
            uiVolume = opts.uiVolume or 0.1,
        }
    end

    if not DialogueVocals or not DialogueVocals.BuildSpeechAudio then
        return nil
    end

    local trader, npcRef, npcData = self:getTradeSpeaker()
    if not npcRef and not npcData then
        return {
            uiSound = opts.uiSound or opts.soundName or "DT_RadioRandom",
            uiVolume = opts.uiVolume or 0.1,
        }
    end

    local hook = self:getTradeDispositionHook(trader, npcData) or opts.hook
    if not hook then
        if opts.tag == "transaction" then
            hook = opts.isError and "angry" or "trading"
        elseif opts.tag == "greeting" then
            hook = "welcome"
        elseif opts.tag == "farewell" then
            hook = "bye"
        elseif opts.tag == "sellask" then
            hook = "trading"
        end
    end

    return DialogueVocals.BuildSpeechAudio(npcData, {
        text = text,
        sentiment = opts.sentiment,
        status = trader and trader.status or nil,
        state = trader and trader.currentState or nil,
        entry = trader,
        hook = hook,
        uiSound = opts.uiSound,
        uiVolume = opts.uiVolume,
        soundName = opts.soundName,
        vocalType = opts.vocalType,
        channel = opts.channel or ("trading_" .. tostring(opts.tag or "window")),
        cooldownMs = opts.cooldownMs or 0,
    })
end

function DT_TradingWindow:playQueuedTradeMessageAudio(msg)
    if not msg then
        return nil
    end

    local _, npcRef, npcData = self:getTradeSpeaker()
    if msg.audio and DialogueVocals and DialogueVocals.PlaySpeechAudio then
        return DialogueVocals.PlaySpeechAudio(npcRef, npcData, msg.audio)
    end

    if self.dataProvider and self.dataProvider.playSound then
        self.dataProvider:playSound(msg.sound or "DT_RadioRandom")
    end

    return nil
end

function DT_TradingWindow:getCurrentTrader()
    if not self.dataProvider or not self.traderID or not self.dataProvider.getTrader then
        return nil
    end

    return self.dataProvider:getTrader(self.traderID, self.archetype)
end

function DT_TradingWindow:getTradeModeConfig(trader)
    if self.dataProvider and self.dataProvider.getTradeModeConfig then
        return self.dataProvider:getTradeModeConfig(trader or self:getCurrentTrader())
    end

    return { canBuy = true, canSell = true, defaultIsBuying = true }
end

function DT_TradingWindow:isTradeModeEnabled(isBuying, trader)
    local config = self:getTradeModeConfig(trader)
    return isBuying and config.canBuy or config.canSell
end

function DT_TradingWindow:syncTradeModeVisibility(trader)
    local config = self:getTradeModeConfig(trader)

    if self.btnTabBuy then
        self.btnTabBuy:setVisible(config.canBuy)
    end

    if self.btnTabSell then
        self.btnTabSell:setVisible(config.canSell)
    end

    self:refreshTradeLabels()

    return config
end

function DT_TradingWindow:coerceTradeMode(trader)
    local config = self:syncTradeModeVisibility(trader)
    if not self:isTradeModeEnabled(self.isBuying, trader) then
        self.isBuying = config.defaultIsBuying ~= false
    end

    return config
end
