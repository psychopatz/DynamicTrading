-- =============================================================================
-- MAIN UPDATE LOOP
-- =============================================================================
function DT_TradingWindow:update()
    ISCollapsableWindow.update(self)

    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
        self:close()
        return
    end

    if self.listbox then
        if self.listbox.items == nil then self.listbox.items = {} end
        if self.listbox.items == nil then self.listbox.items = {} end
        if type(self.listbox.selected) ~= "number" then self.listbox.selected = -1 end
        self.listbox.onRightMouseUp = self.onListRightMouseUp
    end

    if self.refreshCooldown and self.refreshCooldown > 0 then
        self.refreshCooldown = self.refreshCooldown - 1
    end

    if self.tradeRequestPending and (tonumber(self.tradeRequestStartedAt) or 0) > 0 then
        local elapsed = (self:GetNowMs() or 0) - (tonumber(self.tradeRequestStartedAt) or 0)
        if elapsed >= 8000 then
            self.tradeRequestPending = false
            self.awaitingAuthoritativeTradeSync = false
            self.tradeRequestStartedAt = 0
            self.tradePendingButtonTitle = nil
            self.inventoryDirty = true
            self.refreshCooldown = 0
            if self.btnAction then
                self.btnAction:setTitle(self:getDefaultActionTitle())
                self.btnAction:setEnable(false)
            end
            self:logPerf("TradeTimeout", "trade request timeout, forcing refresh for trader=" .. tostring(self.traderID))
        end
    end

    if self.sellScanSession and not self.sellScanSession.completed and not self.isBuying then
        local progressed = DT_TradingItemUtils
            and DT_TradingItemUtils.Internal
            and DT_TradingItemUtils.Internal.processSellScanSession
            and DT_TradingItemUtils.Internal.processSellScanSession(self.sellScanSession)

        if progressed then
            local now = self:GetNowMs()
            local shouldRefreshList = self.sellScanSession.completed
                or self.sellScanSession.needsListRefresh
                or (self.sellScanListDirty == true)
            if shouldRefreshList and (self.sellScanSession.completed or (now - (self.sellScanLastListRefreshAt or 0)) >= 120) then
                self:refreshSellScanProgress(true)
            end
        end
    end

    if self.inventoryDirty and self.refreshCooldown and self.refreshCooldown <= 0 then
        if self.dataProvider and self.dataProvider.invalidateTradeCaches then
            self.dataProvider:invalidateTradeCaches(self.traderID)
        end
        self:populateList()
        self.inventoryDirty = false
        self.refreshCooldown = 30
    end

    if not self.traderID or not self.dataProvider then
        self:close()
        return
    end

    local trader = self.dataProvider:getTrader(self.traderID, self.archetype)
    if not trader then
        self:logLocal("Signal Lost: Contact unavailable.", true)
        self:close()
        return
    end

    self:updateIdentityDisplay(trader)
    self:updateWallet()

    if not self:isConnectionValid() then
        self:close()
        return
    end

    if self.isBuying and self.btnAsk then
        local favorStatus = self.dataProvider:getFavorStatus(trader)
        if favorStatus then
            self.btnAsk:setEnable(favorStatus.canRequest)
            self.btnAsk.tooltip = favorStatus.tooltip
        else
            self.btnAsk:setEnable(false)
        end
    end

    if #self.msgQueue > 0 then
        local msg = self.msgQueue[1]

        if msg.delay > 0 then
            msg.delay = msg.delay - 1
        else
            self:logLocal(msg.text, msg.isError, msg.isPlayer)

            if self.portraitPanel then
                if msg.tag == "transaction" and self.portraitPanel.pulseTradeAnimation then
                    self.portraitPanel:pulseTradeAnimation()
                elseif (not msg.isPlayer) and self.portraitPanel.pulseSpeechAnimation then
                    self.portraitPanel:pulseSpeechAnimation()
                end
            end

            if player then
                self:playQueuedTradeMessageAudio(msg)
            end

            table.remove(self.msgQueue, 1)
            self:resetIdleTimer()
        end
    end

    self.typingTick = self.typingTick + 1
    self.updateTick = self.updateTick + 1

    if self.updateTick >= 30 then
        self.updateTick = 0

        local gameTime = GameTime:getInstance()
        local climate = ClimateManager:getInstance()
        local currentHour = gameTime:getHour()
        local isRaining = climate:getRainIntensity() > 0.4
        local isFoggy = climate:getFogIntensity() > 0.4
        local ambientMsg = nil

        if currentHour ~= self.lastHour then
            if currentHour == 5 then
                ambientMsg = self.dataProvider:getAmbientMessage(trader, "Morning")
            elseif currentHour == 17 then
                ambientMsg = self.dataProvider:getAmbientMessage(trader, "Evening")
            elseif currentHour == 21 then
                ambientMsg = self.dataProvider:getAmbientMessage(trader, "Night")
            end
            self.lastHour = currentHour
        end

        if not ambientMsg then
            if isRaining ~= self.wasRaining then
                ambientMsg = isRaining
                    and self.dataProvider:getAmbientMessage(trader, "RainStart")
                    or self.dataProvider:getAmbientMessage(trader, "RainStop")
                self.wasRaining = isRaining
            elseif isFoggy ~= self.wasFoggy then
                ambientMsg = isFoggy and self.dataProvider:getAmbientMessage(trader, "FogStart")
                self.wasFoggy = isFoggy
            end
        end

        if ambientMsg then
            self:queueMessage(ambientMsg, false, false, 10)
        end

        if #self.msgQueue == 0 then
            self.idleTimer = self.idleTimer + 30

            if self.idleTimer >= 3600 then
                local idleMsg = self.dataProvider:getIdleMessage(trader)
                if idleMsg then
                    self:queueMessage(idleMsg, false, false, 0)
                end
                self.idleTimer = 0
            end
        end
    end
end
