-- =============================================================================
-- PLAYER DATA & ECONOMY HELPERS
-- =============================================================================

function DT_TradingWindow:getPlayerWealth(player)
    return self.dataProvider:getPlayerWealth(player)
end

function DT_TradingWindow:updateWallet()
    local player = getSpecificPlayer(0)
    -- [CRASH FIX] Check for valid player
    if not player or player:isDead() then
        if self.lblInfo then self.lblInfo:setName("Wallet: ---") end
        return
    end

    local wealth = self:getPlayerWealth(player)
    if self.lblInfo then
        self.lblInfo:setName("Wallet: $" .. wealth)
    end
end

function DT_TradingWindow:updateIdentityDisplay(trader)
    if self.lblName then self.lblName:setName(trader.name or "Unknown") end
    if self.lblArchetype then
        local archName = "Survivor"
        if self.dataProvider and self.dataProvider.getArchetypeName then
            archName = self.dataProvider:getArchetypeName(trader.archetype)
        elseif DynamicTrading.Archetypes and DynamicTrading.Archetypes[trader.archetype] then
            archName = DynamicTrading.Archetypes[trader.archetype].name
        end
        self.lblArchetype:setName(archName)
    end
    if self.lblTraderBudget then
        local budget = trader.budget or 0
        self.lblTraderBudget:setName("Trader Budget: $" .. budget)
        if budget < 50 then
            self.lblTraderBudget:setColor(1, 0.2, 0.2, 1)
        else
            self.lblTraderBudget:setColor(1, 0.8, 0.2, 1)
        end
    end
    if self.lblSignal then
        local gt = GameTime:getInstance()
        local text = "Status: Permanent"
        local r, g, b = 0.5, 0.8, 1.0
        local expireTime = trader.returnTime
        if expireTime then
            local diff = expireTime - gt:getWorldAgeHours()
            if diff <= 0.5 then
                text = "Status: Departing Now..."
                r, g, b = 1, 0, 0
            elseif diff < 1 then
                text = string.format("Status: Leaving in (%dm)", math.floor(diff * 60))
                r, g, b = 1, 0.4, 0
            elseif diff < 8 then
                text = string.format("Status: Leaving in (%dh)", math.ceil(diff))
                r, g, b = 1, 0.8, 0.2
            else
                text = string.format("Status: Leaving in (%dh)", math.ceil(diff))
                r, g, b = 0.2, 1, 0.2
            end
        end
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end
