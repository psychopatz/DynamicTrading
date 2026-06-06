-- ==============================================================================
-- NetworkServer/DebugHandlers.lua
-- Logic: Admin-only debug commands
-- Build 42 Compatible.
-- ==============================================================================

local COMMAND_MODULE = "DynamicTrading_V2"

require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/ServerHelpers/ServerHelpers"
require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
require "DT/V1/Manager"

local DebugHandlers = {}
local Handlers = {}

local function hasAdminAccess(player)
    if not player or not player.getAccessLevel then
        return false
    end

    local accessLevel = player:getAccessLevel()
    return accessLevel and string.lower(tostring(accessLevel)) == "admin"
end

local function areDynamicColoniesEnabled()
    return DynamicTrading_Factions.IsDynamicColoniesEnabled
        and DynamicTrading_Factions.IsDynamicColoniesEnabled() == true
end

local function sendDynamicColoniesRequired(player)
    DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
        success = false,
        reason = "Dynamic Colonies required"
    })
end

-- =============================================================================
-- DEBUG & ADMIN COMMANDS
-- =============================================================================
require "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState"

Handlers.DebugCommand = function(player, args)
    if not hasAdminAccess(player) then 
        DynamicTrading.Log("DTCommons", "Error", "Security", "Unauthorized DebugCommand attempt by " .. tostring(player and player:getUsername() or "unknown"))
        return 
    end
    
    local action = args.action
    DynamicTrading.Log("DTCommons", "Debug", "Server", "Server received action [" .. tostring(action) .. "] from " .. player:getUsername())

    if action == "SimulateDay" then
        -- Force the daily update for all factions
        DynamicTrading_Factions.UpdateDaily()
        -- Also force the engine simulation
        DynamicTrading_Engine.RunDailySimulation()
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Simulation Triggered" })

    elseif action == "createTestFaction" then
        local targetID = args.targetID or ("Faction_" .. ZombRand(1000))
        -- This calls our new logic that includes the LocationManager!
        DynamicTrading_Factions.CreateFaction(targetID, {
            memberCount = ZombRand(5, 15),
            stockpile = { food = 200, ammo = 100 }
        })
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Created" })

    elseif action == "WipeFactions" then
        -- Clear the ModData table completely
        local key = "DynamicTrading_Factions"
        -- We must overwrite the actual table content in the ModData system
        local data = ModData.get(key)
        if data then
            -- Clear existing keys
            for k in pairs(data) do data[k] = nil end
        else
            ModData.add(key, {})
        end
        
        -- Re-initialize to restore the "Independent" nomadic faction and Town factions
        DynamicTrading_Factions.Init()
        ModData.transmit(key)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="All Factions Wiped & Repopulated" })

    elseif action == "DumpFactionBaseLedger" then
        if DT_FactionRespawnState and DT_FactionRespawnState.DumpDebug then
            DT_FactionRespawnState.DumpDebug(tonumber(args.limit) or 80, true)
        end
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction base ledger dumped to logs" })

    elseif action == "TeleportToFactionBase" then
        local x = tonumber(args.x)
        local y = tonumber(args.y)
        local z = tonumber(args.z) or 0
        if x and y and player and player.setX and player.setY and player.setZ then
            player:setX(x)
            player:setY(y)
            player:setZ(z)
            if player.setLx then player:setLx(x) end
            if player.setLy then player:setLy(y) end
            if player.setLz then player:setLz(z) end
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
                success = true,
                reason = "Teleported to base: " .. tostring(args.name or "Unknown")
            })
        else
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
                success = false,
                reason = "Invalid base teleport coordinates"
            })
        end

    elseif action == "ForceRestock" then
        -- Reset restock timers for a specific trader
        local traderID = args.targetID
        local stock = DynamicTrading_Stock.GetStock(traderID)
        if stock then
            stock.restock.nextRestockTime = 0
            ModData.transmit("DynamicTrading_Stock")
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Restock Forced" })
        end
    elseif action == "ModifySoul" then
        local factionID = args.factionID
        local amount = args.amount
        if amount > 0 then
            for i=1, amount do
                local archetypes = {}
                for aid, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, aid) end
                local randomArch = archetypes[ZombRand(#archetypes) + 1]
                DynamicTrading_Roster.AddSoul(factionID, randomArch)
                
                local f = DynamicTrading_Factions.GetFaction(factionID)
                if f then f.memberCount = f.memberCount + 1 end
            end
        else
            DynamicTrading_Roster.RemoveSoul(factionID, math.abs(amount))
            local f = DynamicTrading_Factions.GetFaction(factionID)
            if f then f.memberCount = math.max(0, f.memberCount + amount) end
        end
        ModData.transmit("DynamicTrading_Factions")
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Roster Modified" })

    elseif action == "ModifyStockpile" then
        local factionID = args.factionID
        local res = args.resource
        local amt = args.amount
        DynamicTrading_Factions.ModifyStockpile(factionID, res, amt)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Stockpile Modified" })

    elseif action == "ModifyColonyWealth" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading_Factions.ModifyColonyWealth(factionID, amt)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Colony Wealth Modified" })

    elseif action == "ModifyFactionBias" then
        local factionID = args.factionID
        local amt = args.amount
        DynamicTrading.ServerHelpers.SendReputationSync(player, {
            action = "factionBiasDelta",
            factionID = tostring(factionID or ""),
            amount = tonumber(amt) or 0,
            reason = "admin_debug"
        })
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Reputation Modified" })

    elseif action == "AdminReviewPlayerFaction" then
        if not areDynamicColoniesEnabled() then
            sendDynamicColoniesRequired(player)
            return
        end
        local factionID = tostring(args.factionID or "")
        local faction = DynamicTrading_Factions.MarkFactionAdminReview and DynamicTrading_Factions.MarkFactionAdminReview(factionID, "admin_review")
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
            success = faction ~= nil,
            reason = faction and "Colony moved to admin review" or "Failed to move colony to admin review"
        })

    elseif action == "RestorePlayerFactionLeader" then
        if not areDynamicColoniesEnabled() then
            sendDynamicColoniesRequired(player)
            return
        end
        local ok, message = DynamicTrading_Factions.AdminRestoreFactionLeader(
            tostring(args.factionID or ""),
            tostring(args.username or "")
        )
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
            success = ok == true,
            reason = message or "Leader restore processed"
        })

    elseif action == "ArchivePlayerFaction" then
        if not areDynamicColoniesEnabled() then
            sendDynamicColoniesRequired(player)
            return
        end
        local ok, message = DynamicTrading_Factions.AdminArchiveFaction(tostring(args.factionID or ""))
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
            success = ok == true,
            reason = message or "Archive processed"
        })

    elseif action == "DeletePlayerFactionArchive" then
        if not areDynamicColoniesEnabled() then
            sendDynamicColoniesRequired(player)
            return
        end
        local ok, message = DynamicTrading_Factions.AdminDeleteFactionArchive(tostring(args.factionID or ""))
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
            success = ok == true,
            reason = message or "Archive delete processed"
        })

    elseif action == "ForceSpawn" then
        local town = args.town or "Rosewood"
        local factionID = town .. "_" .. tostring(math.floor(ZombRand(100000, 999999)))
        DynamicTrading_Factions.CreateFaction(factionID, {
            town = town,
            memberCount = 10
        })
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Faction Spawned" })

    elseif action == "ForceTraderByArchetype" then
        local archetypeID = tostring(args.archetypeID or args.archetype or "")
        local trader = DynamicTrading.Manager
            and DynamicTrading.Manager.SpawnTraderWithArchetype
            and DynamicTrading.Manager.SpawnTraderWithArchetype(archetypeID, {
                factionID = "Independent",
                forceFaction = true,
                discoverForPlayer = player
            }) or nil

        if trader then
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
                success = true,
                reason = "Trader spawned: " .. tostring(trader.name or archetypeID),
                traderID = trader.id,
                archetype = trader.archetype
            })
        else
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", {
                success = false,
                reason = "Failed to spawn trader for archetype: " .. archetypeID
            })
        end
    
    elseif action == "InjectEvent" then
        local factionID = args.factionID
        local eventID = args.eventID
        local hours = args.hours or 72 -- Default 3 days
        
        local factionData = ModData.get("DynamicTrading_Factions")
        local faction = factionData and factionData[factionID]
        
        if faction then
            local currentHour = math.floor(getGameTime():getWorldAgeHours())
            faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}

            if eventID then
                table.insert(faction.ActiveFlashEvents, {
                    id = eventID,
                    expires = currentHour + hours,
                    targetCasualties = 0
                })
            else
                faction.ActiveFlashEvents = {}
            end

            local first = faction.ActiveFlashEvents[1]
            faction.ActiveFlashEvent = {
                id = first and first.id or nil,
                expires = first and (first.expires or 0) or 0,
                targetCasualties = first and (first.targetCasualties or 0) or 0
            }
            
            ModData.transmit("DynamicTrading_Factions")
            local msg = eventID and ("Event Injected: " .. eventID) or "Event Cleared"
            DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason=msg })
        end
        
    elseif action == "ForceRecalcVirtualStore" then
        local DT_VirtualStore = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
        DT_VirtualStore.Prices.RecalculatePrices(true)
        DynamicTrading.ServerHelpers.SendResponse(player, COMMAND_MODULE, "TradeResult", { success=true, reason="Virtual Store Prices Recalculated" })
    end
end


DebugHandlers.Handlers = Handlers
return DebugHandlers
