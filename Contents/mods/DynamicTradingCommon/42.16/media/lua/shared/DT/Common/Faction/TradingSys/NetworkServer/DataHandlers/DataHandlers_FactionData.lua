-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_FactionData.lua
-- Logic: Faction data synchronization handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local commandModule = context.COMMAND_MODULE
    local FACTION_ROSTER_PAGE_LIMIT = 40
    require "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState"

    local function hasAdminAccess(player)
        if not player or not player.getAccessLevel then
            return false
        end

        local accessLevel = player:getAccessLevel()
        return accessLevel and string.lower(tostring(accessLevel)) == "admin"
    end

    local function isCollapsedFaction(faction)
        return type(faction) == "table"
            and (faction.collapsed == true
                or faction.collapsedAt ~= nil
                or tostring(faction.state or "") == "Collapsed")
    end

    local function isLivingSoul(soul)
        if type(soul) ~= "table" then
            return false
        end

        local status = tostring(soul.status or "")
        local state = tostring(soul.state or "")
        if status == "Dead" or state == "Dead" or soul.deathFinalizedAt ~= nil then
            return false
        end

        local combatHealth = tonumber(soul.combatHealthCurrent)
        if combatHealth ~= nil and combatHealth <= 0 and status ~= "Away" and status ~= "Trading" then
            return false
        end

        local health = tonumber(soul.health)
        if health ~= nil and health <= 0 and status ~= "Away" and status ~= "Trading" then
            return false
        end

        return true
    end

    local function syncVisiblePopulationCounts(factionData, rosterData)
        if type(factionData) ~= "table" or type(rosterData) ~= "table" then
            return false
        end

        local membersByFaction = rosterData.FactionMembers
        local souls = rosterData.Souls
        if type(membersByFaction) ~= "table" or type(souls) ~= "table" then
            return false
        end

        local changed = false
        for factionID, faction in pairs(factionData) do
            if type(faction) == "table" then
                if isCollapsedFaction(faction) then
                    if tonumber(faction.memberCount) ~= 0 then
                        faction.memberCount = 0
                        changed = true
                    end
                elseif faction.playerOwned ~= true then
                    local members = membersByFaction[factionID]
                    if type(members) == "table" and #members > 0 then
                        local living = 0
                        for _, uuid in ipairs(members) do
                            if isLivingSoul(souls[uuid]) then
                                living = living + 1
                            end
                        end

                        if tonumber(faction.memberCount) ~= living then
                            faction.memberCount = living
                            changed = true
                        end

                        if living <= 0
                            and DynamicTrading_Factions
                            and DynamicTrading_Factions.AuditFactionExtinction then
                            DynamicTrading_Factions.AuditFactionExtinction(factionID, { reason = "roster_extinction" })
                        end
                    end
                end
            end
        end

        if changed and ModData and ModData.transmit then
            ModData.transmit("DynamicTrading_Factions")
        end
        return changed
    end

    -- [FACTION DATA REQUEST]
    -- Shared by the player-facing Faction Intelligence window and the admin debug UI.
    Handlers.RequestFactionData = function(player, args)
        if DynamicTrading_Factions and DynamicTrading_Factions.ResumeLeadership then
            DynamicTrading_Factions.ResumeLeadership(player)
        end

        local factionData = ModData.get("DynamicTrading_Factions") or {}
        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        syncVisiblePopulationCounts(factionData, rosterData)
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

        local response = {
            factions = factionData,
            roster = minimalRoster,
            ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
        }
        if args and args.includeBaseLedger == true and hasAdminAccess(player) then
            response.baseLedger = DT_FactionRespawnState and DT_FactionRespawnState.GetDebugSnapshot and DT_FactionRespawnState.GetDebugSnapshot() or nil
        end

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionDebugData", response)
    end

    -- [ON-DEMAND ROSTER REQUEST]
    -- Shared by Radar/Common UIs when they need a faction's full soul list.
    Handlers.RequestFactionRoster = function(player, args)
        local factionID = args.factionID
        if not factionID then
            return
        end

        local faction = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction and DynamicTrading_Factions.GetFaction(factionID) or nil
        if faction and faction.playerOwned then
            DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionRoster", {
                factionID = factionID,
                members = {},
                souls = {},
                ownedStatus = DynamicTrading_Factions.GetOwnedFactionStatus(player)
            })
            return
        end

        local rosterData = ModData.get("DynamicTrading_Roster") or {}
        local members = rosterData.FactionMembers and rosterData.FactionMembers[factionID] or {}
        local normalizedOffset = math.max(0, math.floor(tonumber(args.offset) or 0))
        local requestedLimit = tonumber(args.limit)
        local normalizedLimit = requestedLimit ~= nil
            and math.max(1, math.floor(requestedLimit))
            or math.max(#members, FACTION_ROSTER_PAGE_LIMIT)

        if normalizedOffset > #members then
            normalizedOffset = #members
        end

        local totalMembers = #members
        local membersPage = {}
        local lastIndex = math.min(totalMembers, normalizedOffset + normalizedLimit)
        for index = normalizedOffset + 1, lastIndex do
            membersPage[#membersPage + 1] = members[index]
        end

        local factionSouls = {}
        if rosterData.Souls then
            for _, uuid in ipairs(membersPage) do
                if rosterData.Souls[uuid] then
                    factionSouls[uuid] = rosterData.Souls[uuid]
                end
            end
        end

        DynamicTrading.ServerHelpers.SendResponse(player, commandModule, "SyncFactionRoster", {
            factionID = factionID,
            offset = normalizedOffset,
            limit = normalizedLimit,
            totalMembers = totalMembers,
            membersPage = membersPage,
            soulsPage = factionSouls,
            members = membersPage,
            souls = factionSouls,
            ownedStatus = DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus and DynamicTrading_Factions.GetOwnedFactionStatus(player) or nil
        })
    end
end
