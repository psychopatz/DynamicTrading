-- ==============================================================================
-- DT_TraderSession.lua
-- Logic: Temporary per-trader budget tracking, extracting from ColonyWealth.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Config"

DT_TraderSession = {}
local MOD_DATA_KEY = "DynamicTrading_TraderSessions"

function DT_TraderSession.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {})
    end
end

function DT_TraderSession.GetSession(traderUUID)
    local data = ModData.get(MOD_DATA_KEY)
    if not data then return nil end
    return data[traderUUID]
end

function DT_TraderSession.Create(traderUUID, factionID)
    DT_TraderSession.Init()
    local data = ModData.get(MOD_DATA_KEY)
    
    -- If session already exists and is active, do nothing
    if data[traderUUID] and not data[traderUUID].closed then
        return data[traderUUID]
    end

    local faction = DynamicTrading_Factions.GetFaction(factionID)
    if not faction then return nil end

    local config = DynamicTrading.Config.TraderBudget or {
        BaseBudget = 500,
        MinBudget = 100,
        MaxBudget = 15000,
        IncapacitatedPenaltyMult = 0.25
    }

    local maxBudget = config.MaxBudget
    local budgetPercent = (SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.TraderBudgetPercent or 10.0) / 100

    -- Event hook planned for Phase 4: getTraderBudgetMultiplier(faction)
    local eventMult = 1.0 
    if DynamicTrading.Events and DynamicTrading.Events.getTraderBudgetMultiplier then
        eventMult = DynamicTrading.Events.getTraderBudgetMultiplier(faction)
    end

    if faction.factionType == "independent" then
        local allocatedBudget = math.floor((config.BaseBudget + ZombRand(1001)) * eventMult)
        data[traderUUID] = {
            budget = allocatedBudget,
            bought = 0,
            factionID = factionID,
            allocated = 0, -- 0 means it isn't returned to ColonyWealth
            closed = false
        }
        ModData.transmit(MOD_DATA_KEY)
        DynamicTrading.Log("Colony", "Economy", "Session", "Created Independent session for " .. tostring(traderUUID) .. " with budget: " .. tostring(allocatedBudget))
        return data[traderUUID]
    end

    local allocatedBudget = math.floor((faction.ColonyWealth * budgetPercent) * eventMult)
    allocatedBudget = math.max(config.MinBudget, math.min(maxBudget, allocatedBudget))

    -- Cap allocation to what the faction actually has
    if allocatedBudget > faction.ColonyWealth then
        allocatedBudget = faction.ColonyWealth
    end

    -- Deduct from faction
    DynamicTrading_Factions.AllocateTraderBudget(factionID, allocatedBudget)

    data[traderUUID] = {
        budget = allocatedBudget,
        bought = 0,
        factionID = factionID,
        allocated = allocatedBudget,
        closed = false
    }

    ModData.transmit(MOD_DATA_KEY)
    DynamicTrading.Log("Colony", "Economy", "Session", "Created trader session for " .. tostring(traderUUID) .. " with budget: " .. tostring(allocatedBudget))
    return data[traderUUID]
end

function DT_TraderSession.OnBuy(traderUUID, value)
    local session = DT_TraderSession.GetSession(traderUUID)
    if session and not session.closed then
        session.budget = math.max(0, session.budget + value)
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

function DT_TraderSession.OnSell(traderUUID, value)
    local session = DT_TraderSession.GetSession(traderUUID)
    if session and not session.closed then
        session.budget = math.max(0, session.budget - value)
        session.bought = (session.bought or 0) + value
        ModData.transmit(MOD_DATA_KEY)
        return true
    end
    return false
end

function DT_TraderSession.Close(traderUUID, reason)
    local data = ModData.get(MOD_DATA_KEY)
    if not data then return end
    local session = data[traderUUID]

    if session and not session.closed then
        session.closed = true
        
        local returnAmount = session.budget + (session.bought or 0)
        
        if reason == "incapacitated" then
            local penaltyMult = DynamicTrading.Config.TraderBudget and DynamicTrading.Config.TraderBudget.IncapacitatedPenaltyMult or 0.25
            returnAmount = math.floor(returnAmount * penaltyMult)
            DynamicTrading.Log("Colony", "Economy", "Session", "Closing session for " .. tostring(traderUUID) .. " with 75% penalty (incapacitated). Returning: " .. tostring(returnAmount))
        else
            DynamicTrading.Log("Colony", "Economy", "Session", "Closing normal session for " .. tostring(traderUUID) .. ". Returning: " .. tostring(returnAmount))
        end

        if session.factionID and session.allocated > 0 then
            DynamicTrading_Factions.ReturnTraderBudget(session.factionID, returnAmount)
        end
        
        -- Clean up
        data[traderUUID] = nil
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DT_TraderSession.CloseAll()
    local data = ModData.get(MOD_DATA_KEY)
    if not data then return end
    
    for uuid, session in pairs(data) do
        if not session.closed then
            DT_TraderSession.Close(uuid, "normal")
        end
    end
end

if not isClient() or isServer() then
    Events.OnInitGlobalModData.Add(DT_TraderSession.Init)
end

local function OnReceiveGlobalModData(key, data)
    if key == MOD_DATA_KEY and type(data) == "table" then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

return DT_TraderSession
