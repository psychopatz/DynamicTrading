-- =============================================================================
-- DYNAMIC TRADING: COMMON TRADING PROVIDER - CORE
-- =============================================================================
-- Shared provider helpers for V1/V2 wrappers.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.TradingProvider = DynamicTrading.TradingProvider or {}

local function getLocalPlayer()
    if getPlayer then
        local player = getPlayer()
        if player then return player end
    end
    return getSpecificPlayer(0)
end

local function getArchetypeDataForTrader(trader)
    local archetypeID = trader and trader.archetype or nil
    if DynamicTrading and DynamicTrading.GetArchetypeData then
        return DynamicTrading.GetArchetypeData(archetypeID)
    end

    return DynamicTrading and DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetypeID] or nil
end

function DynamicTrading.TradingProvider.AttachCore(provider)
    if not provider then return end

    if provider.getTradeSessionContext == nil then
        function provider:getTradeSessionContext()
            return nil
        end
    end

    if provider.lockItem == nil then
        function provider:lockItem(itemID)
            local player = getLocalPlayer()
            if not player then return end
            local modData = player:getModData()
            if not modData.DT_LockedItems then modData.DT_LockedItems = {} end
            modData.DT_LockedItems[itemID] = true
        end
    end

    if provider.getFavorStatus == nil then
        function provider:getFavorStatus(trader)
            return { canRequest = true, tooltip = "Return to conversation" }
        end
    end

    if provider.getAskButtonConfig == nil then
        function provider:getAskButtonConfig(isBuying)
            local sessionContext = self.getTradeSessionContext and self:getTradeSessionContext() or nil
            if sessionContext and sessionContext.transactionKind == "gift" and not isBuying then
                return { title = "Return to Talk", visible = true }
            end

            return { title = isBuying and "Talk" or "Ask What They Want", visible = true }
        end
    end

    if provider.getTradeModeConfig == nil then
        function provider:getTradeModeConfig(trader)
            local sessionContext = self.getTradeSessionContext and self:getTradeSessionContext(trader and trader.traderID, trader and trader.archetype) or nil
            if sessionContext and sessionContext.transactionKind == "gift" then
                return {
                    canBuy = false,
                    canSell = true,
                    defaultIsBuying = false
                }
            end

            local archetypeData = getArchetypeDataForTrader(trader)
            local canBuy = true
            local canSell = true

            if DynamicTrading and DynamicTrading.IsArchetypeBuyTabEnabled then
                canBuy = DynamicTrading.IsArchetypeBuyTabEnabled(archetypeData or (trader and trader.archetype))
            elseif archetypeData then
                canBuy = archetypeData.disableBuyTab ~= true
            end

            if DynamicTrading and DynamicTrading.IsArchetypeSellTabEnabled then
                canSell = DynamicTrading.IsArchetypeSellTabEnabled(archetypeData or (trader and trader.archetype))
            elseif archetypeData then
                canSell = archetypeData.disableSellTab ~= true
            end

            if not canBuy and not canSell then
                canBuy = true
            end

            return {
                canBuy = canBuy,
                canSell = canSell,
                defaultIsBuying = canBuy
            }
        end
    end

    if provider.isTradeModeEnabled == nil then
        function provider:isTradeModeEnabled(trader, isBuying)
            local config = self:getTradeModeConfig(trader)
            return isBuying and config.canBuy or config.canSell
        end
    end

    if provider.getDefaultTradingMode == nil then
        function provider:getDefaultTradingMode(trader)
            local config = self:getTradeModeConfig(trader)
            return config.defaultIsBuying ~= false
        end
    end

    if provider.onAsk == nil then
        function provider:onAsk(trader, isBuying, ui)
            local sessionContext = self.getTradeSessionContext and self:getTradeSessionContext(trader and trader.traderID, trader and trader.archetype) or nil
            if sessionContext and sessionContext.transactionKind == "gift" and not isBuying then
                if self.openHub then
                    self:openHub(trader, ui)
                end
                return
            end

            if isBuying then
                if self.openHub then
                    self:openHub(trader, ui)
                end
            else
                local playerMsg = self:getPlayerMessage("SellAsk", {})
                ui:queueMessage(playerMsg, false, true, 0)

                local npcMsg = self:getSellAskDialogue(trader)
                ui:queueMessage(npcMsg, false, false, 30)
            end
        end
    end

    if provider.playSound == nil then
        function provider:playSound(soundName)
            if DT_AudioManager then
                DT_AudioManager.PlaySound(soundName, false, 1.0)
            else
                getSoundManager():PlaySound(soundName, false, 1.0)
            end
        end
    end

    if provider.getLockButtonVisible == nil then
        function provider:getLockButtonVisible(isBuying)
            return not isBuying
        end
    end

    if provider.getArchetypeName == nil then
        function provider:getArchetypeName(archetype)
            if DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetype] then
                return DynamicTrading.Archetypes[archetype].name
            end
            return archetype or "Survivor"
        end
    end

    if provider.getWindowTitle == nil then
        function provider:getWindowTitle(trader)
            if not trader then return "Trading" end
            local sessionContext = self.getTradeSessionContext and self:getTradeSessionContext(trader and trader.traderID, trader and trader.archetype) or nil
            if sessionContext and sessionContext.windowTitle and sessionContext.windowTitle ~= "" then
                return tostring(sessionContext.windowTitle)
            end

            local name = trader.name or "Unknown"
            local archName = self.getArchetypeName and self:getArchetypeName(trader.archetype) or (trader.archetype or "Survivor")
            if sessionContext and sessionContext.transactionKind == "gift" then
                return name .. " - Gift"
            end
            return name .. " - " .. archName
        end
    end

    if provider.getPlayerWealth == nil then
        function provider:getPlayerWealth(player)
            player = player or getLocalPlayer()
            if not player then return 0 end
            local inv = player:getInventory()
            local loose = inv:getItemsFromType("Base.Money", true)
            local bundles = inv:getItemsFromType("Base.MoneyBundle", true)
            local looseCount = loose and loose:size() or 0
            local bundleCount = bundles and bundles:size() or 0
            return looseCount + (bundleCount * 100)
        end
    end

    if provider.getDailyStatus == nil then
        function provider:getDailyStatus()
            return 0, 999
        end
    end
end
