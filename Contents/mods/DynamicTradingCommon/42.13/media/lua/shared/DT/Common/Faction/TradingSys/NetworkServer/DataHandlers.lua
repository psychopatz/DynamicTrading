-- ==============================================================================
-- NetworkServer/DataHandlers.lua
-- Logic: Data synchronization handlers (Faction, Roster, Trader, Stock)
-- Build 42 Compatible.
-- ==============================================================================

local COMMAND_MODULE = "DynamicTrading_V2"

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/ServerHelpers/ServerHelpers"
require "DT/Common/Pricing/DT_PriceConfig"

local DataHandlers = {}
local Handlers = {}

local function sendPriceConfigToPlayer(player)
    local payload = DynamicTrading.PriceConfig.BuildSyncPayload(DynamicTrading.PriceConfig.GetData())
    DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "SyncPriceConfig", payload)
end

local function sendPriceConfigActionResult(player, success, message, warnings)
    DynamicTrading.ServerHelpers.SendResponse(player, "DynamicTrading", "PriceConfigActionResult", {
        success = success == true,
        message = tostring(message or ""),
        warnings = warnings or {}
    })
end

local function syncOwnedFactionStatus(player)
    if not player or not DynamicTrading_Factions or not DynamicTrading_Factions.GetOwnedFactionStatus then
        return
    end

    local status = DynamicTrading_Factions.GetOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncOwnedFactionStatus", {
        status = status
    })
end

-- =============================================================================
-- HELPER: Send Complete SyncStock to Player
-- Used after transactions to update client cache with latest stock and faction wealth
-- =============================================================================
function DataHandlers.SendSyncStockToPlayer(player, traderID)
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if not stockData then return end
    
    local soul = DynamicTrading_Roster.GetSoulRegistry(traderID) or DynamicTrading_Roster.GetTrader(traderID)
    local factionID = soul and soul.factionID or nil
    local archetype = soul and soul.archetypeID or "General"
    
    -- Get current faction wealth (after transaction)
    local factionWealth = 0
    if factionID then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then
            factionWealth = faction.wealth or 0
        end
    end
    
    DynamicTrading.Log("DTV2", "Network", "Server", "Sending SyncStock: traderID=" .. tostring(traderID) .. ", factionID=" .. tostring(factionID) .. ", factionWealth=" .. tostring(factionWealth))
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
        id = traderID, 
        items = stockData.items, 
        restock = stockData.restock,
        deflation = stockData.deflation,
        factionID = factionID,
        archetype = archetype,
        factionWealth = factionWealth,
        activeFlashEvents = faction and faction.ActiveFlashEvents or {},
        activeFlashEvent = faction and faction.ActiveFlashEvent or { id = nil, expires = 0 },
        name = soul and soul.name or "Trader",
        identitySeed = soul and soul.identitySeed,
        gender = soul and soul.isFemale and "Female" or "Male",
        returnTime = soul and soul.returnTime
    })
end

function DataHandlers.SendPriceConfigToPlayer(player)
    sendPriceConfigToPlayer(player)
end

-- =============================================================================
-- COMMAND HANDLERS
-- =============================================================================

-- [FACTION DATA REQUEST]
-- Shared by the player-facing Faction Intelligence window and the admin debug UI.
Handlers.RequestFactionData = function(player, args)
    if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
        DynamicTrading_Factions.ResumeLeadership(player)
    end

    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}

    -- Keep the initial payload light: member registries plus only actively trading souls.
    local filteredSouls = {}
    if rosterData.Souls then
        for uuid, soul in pairs(rosterData.Souls) do
            if soul.status == "Trading" then
                filteredSouls[uuid] = soul
            end
        end
    end

    local minimalRoster = {
        FactionMembers = rosterData.FactionMembers or {},
        Souls = filteredSouls
    }

    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncFactionDebugData", {
        factions = factionData,
        roster = minimalRoster,
        ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
    })
end

-- [TRADER DATA REQUEST]
Handlers.RequestTrader = function(player, args)
    local traderID = args.traderID
    local traderData = DynamicTrading_Roster.GetTrader(traderID)
    if traderData then
        local response = {
            id = traderID,
            visuals = traderData.visuals,
            factionID = traderData.factionID,
            homeCoords = traderData.homeCoords,
            isSpawned = traderData.isPhysicallySpawned
        }
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncTrader", response)
    end
end

-- [ROSTER DATA REQUEST (FOR RADAR)]
Handlers.RequestRoster = function(player, args)
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local engineData = DynamicTrading_Engine.GetEngineData()
    
    -- Optimize Radar Roster: Only send souls that are currently Trading
    local minimalSouls = {}
    if rosterData.Souls then
        for uuid, soul in pairs(rosterData.Souls) do
            if soul.status == "Trading" then
                minimalSouls[uuid] = soul
            end
        end
    end

    local minimalRoster = {
        FactionMembers = rosterData.FactionMembers,
        Souls = minimalSouls,
        Traders = rosterData.Traders -- Traders are usually few, keeping for now
    }
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncRoster", {
        roster = minimalRoster,
        factions = factionData,
        globalEvents = engineData and engineData.EventSystem and engineData.EventSystem.activeEvents or {}
    })
end

-- [ON-DEMAND ROSTER REQUEST]
-- Shared by Radar/Common UIs when they need a faction's full soul list.
Handlers.RequestFactionRoster = function(player, args)
    local factionID = args.factionID
    if not factionID then return end

    local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
    if faction and faction.playerOwned then
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncFactionRoster", {
            factionID = factionID,
            members = {},
            souls = {},
            ownedStatus = DynamicTrading_Factions.GetOwnedFactionStatus(player)
        })
        return
    end

    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID] or {}
    
    local factionSouls = {}
    if rosterData.Souls then
        for _, uuid in ipairs(members) do
            if rosterData.Souls[uuid] then
                factionSouls[uuid] = rosterData.Souls[uuid]
            end
        end
    end
    
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncFactionRoster", {
        factionID = factionID,
        members = members,
        souls = factionSouls,
        ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
    })
end

Handlers.RequestOwnedFactionStatus = function(player, args)
    if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
        DynamicTrading_Factions.ResumeLeadership(player)
    end
    syncOwnedFactionStatus(player)
end

Handlers.RequestPriceConfig = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    sendPriceConfigToPlayer(player)
end

Handlers.ApplyPriceTagMultiplier = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    local success, reason = DynamicTrading.PriceConfig.SetTagMultiplier(args and args.tag, args and args.multiplier)
    if success then
        sendPriceConfigToPlayer(player)
        sendPriceConfigActionResult(player, true, "Tag multiplier updated.")
    else
        sendPriceConfigActionResult(player, false, reason or "Failed to update tag multiplier.")
    end
end

Handlers.ResetPriceTagMultiplier = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    local success, reason = DynamicTrading.PriceConfig.ResetTagMultiplier(args and args.tag)
    if success then
        sendPriceConfigToPlayer(player)
        sendPriceConfigActionResult(player, true, "Tag multiplier reset.")
    else
        sendPriceConfigActionResult(player, false, reason or "Failed to reset tag multiplier.")
    end
end

Handlers.ApplyItemBasePriceOverride = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    local success, reason = DynamicTrading.PriceConfig.SetItemOverride(args and args.itemKey, args and args.basePrice)
    if success then
        sendPriceConfigToPlayer(player)
        sendPriceConfigActionResult(player, true, "Item base price updated.")
    else
        sendPriceConfigActionResult(player, false, reason or "Failed to update item override.")
    end
end

Handlers.ResetItemBasePriceOverride = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    local success, reason = DynamicTrading.PriceConfig.ResetItemOverride(args and args.itemKey)
    if success then
        sendPriceConfigToPlayer(player)
        sendPriceConfigActionResult(player, true, "Item override reset.")
    else
        sendPriceConfigActionResult(player, false, reason or "Failed to reset item override.")
    end
end

Handlers.ResetAllPriceOverrides = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    DynamicTrading.PriceConfig.ResetAllOverrides()
    sendPriceConfigToPlayer(player)
    sendPriceConfigActionResult(player, true, "All price overrides reset.")
end

Handlers.ImportPricePreset = function(player, args)
    if not DynamicTrading.PriceConfig.CanEdit(player) then
        sendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
        return
    end

    if type(args) ~= "table" then
        sendPriceConfigActionResult(player, false, "Invalid preset payload.")
        return
    end

    local payload = {
        tagMultipliers = type(args.tagMultipliers) == "table" and args.tagMultipliers or {},
        itemOverrides = type(args.itemOverrides) == "table" and args.itemOverrides or {}
    }

    local success, warnings = DynamicTrading.PriceConfig.ReplaceFromPreset(payload)
    if success then
        sendPriceConfigToPlayer(player)
        sendPriceConfigActionResult(player, true, "Preset imported.", warnings)
    else
        sendPriceConfigActionResult(player, false, "Preset import failed.")
    end
end

Handlers.CreatePlayerFaction = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.CreatePlayerFaction(player, args.name)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or (ok and "Faction created." or "Faction creation failed.")
    })
end

Handlers.InvitePlayerToFaction = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.InvitePlayerToFaction(player, args.username)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Faction invite updated."
    })
end

Handlers.AcceptFactionInvite = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.AcceptFactionInvite(player, args.factionID)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Faction invite handled."
    })
end

Handlers.DeclineFactionInvite = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.DeclineFactionInvite(player, args.factionID)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Faction invite handled."
    })
end

Handlers.LeavePlayerFaction = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.LeavePlayerFaction(player)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Faction membership updated."
    })
end

Handlers.KickFactionMember = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.KickFactionMember(player, args.username)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Faction membership updated."
    })
end

Handlers.SetFactionWorkerTradeEligibility = function(player, args)
    args = args or {}
    local ok, message = DynamicTrading_Factions.SetWorkerTradeEligibility(player, args.workerID, args.enabled == true)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Trade access updated."
    })
end

Handlers.DispatchFactionTrade = function(player, args)
    args = args or {}
    local ok, message, _, details = DynamicTrading_Factions.DispatchTrade(player, args.workerID, false)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Dispatch complete.",
        traderID = details and details.traderID or nil,
        traderBackend = details and details.backend or nil,
        discoverTrader = details and details.discoverTrader == true or false
    })
end

Handlers.RecallFactionTrader = function(player, args)
    args = args or {}
    local ok, message, _, details = DynamicTrading_Factions.RecallTrade(player, args.workerID, false)
    syncOwnedFactionStatus(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "OwnedFactionActionResult", {
        success = ok == true,
        message = message or "Trader recalled.",
        traderID = details and details.traderID or nil,
        traderBackend = details and details.backend or nil,
        discoverTrader = false
    })
end

-- [STOCK DATA REQUEST]
Handlers.RequestStock = function(player, args)
    local traderID = args.traderID
    local stockData = DynamicTrading_Stock.GetStock(traderID)
    if stockData then
        -- Get soul data for factionID and archetype
        local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
        local factionID = soul and soul.factionID or nil
        local archetype = soul and soul.archetypeID or "General"
        
        -- Get faction wealth for budget
        local factionWealth = 0
        if factionID then
            local faction = DynamicTrading_Factions.GetFaction(factionID)
            if faction then
                factionWealth = faction.wealth or 0
            end
        end
        
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
            id = traderID, 
            items = stockData.items, 
            restock = stockData.restock,
            factionID = factionID,
            archetype = archetype,
            factionWealth = factionWealth,
            name = soul and soul.name or "Trader",
            identitySeed = soul and soul.identitySeed,
            gender = soul and soul.isFemale and "Female" or "Male",
            returnTime = soul and soul.returnTime
        })
    end
end

-- [STOCK GENERATION REQUEST]
Handlers.GenerateStock = function(player, args)
    local traderID = args.traderID
    local success, reason = DynamicTrading_Stock.CheckAndGenerateStock(traderID)
    
    if success then
        -- Send updated stock back to client (useful for Debug UI and Trading UI)
        local stockData = DynamicTrading_Stock.GetStock(traderID)
        if stockData then
            -- Get soul data for factionID and archetype (same as RequestStock)
            local soul = DynamicTrading_Roster.GetSoulRegistry(traderID)
            local factionID = soul and soul.factionID or nil
            local archetype = soul and soul.archetypeID or "General"
            
            -- Get faction wealth for budget
            local factionWealth = 0
            if factionID then
                local faction = DynamicTrading_Factions.GetFaction(factionID)
                if faction then
                    factionWealth = faction.wealth or 0
                end
            end
             
            -- Send complete SyncStock with all required fields
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "SyncStock", { 
                id = traderID, 
                items = stockData.items, 
                restock = stockData.restock,
                factionID = factionID,
                archetype = archetype,
                factionWealth = factionWealth,
                activeFlashEvents = faction and faction.ActiveFlashEvents or {},
                activeFlashEvent = faction and faction.ActiveFlashEvent or { id = nil, expires = 0 },
                name = soul and soul.name or "Trader",
                identitySeed = soul and soul.identitySeed,
                gender = soul and soul.isFemale and "Female" or "Male",
                returnTime = soul and soul.returnTime
            })
            
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stock Generated" })
        end
    else
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=false, reason=reason })
    end
end

DataHandlers.Handlers = Handlers
DataHandlers.SyncOwnedFactionStatus = syncOwnedFactionStatus
return DataHandlers
