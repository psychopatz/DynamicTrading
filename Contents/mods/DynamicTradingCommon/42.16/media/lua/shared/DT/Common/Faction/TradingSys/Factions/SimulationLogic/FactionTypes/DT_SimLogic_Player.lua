-- ==============================================================================
-- SimulationLogic/FactionTypes/DT_SimLogic_Player.lua
-- Logic: Player-owned dynamic colonies specific logic.
-- ==============================================================================

local PlayerSim = {}

function PlayerSim.PreProcess(faction, id)
    if not faction or not faction.playerOwned then return faction end
    
    if tostring(faction.leadershipState or "") == "AdminReview" or 
       (DynamicTrading_Factions.IsDynamicColoniesEnabled and not DynamicTrading_Factions.IsDynamicColoniesEnabled()) then
        return nil
    end

    if DynamicTrading_Factions.RefreshPlayerFaction then
        faction = DynamicTrading_Factions.RefreshPlayerFaction(id)
    end
    
    return faction
end

function PlayerSim.DeathCheck(faction, id)
    if not faction then return false end
    if faction.memberCount <= 0 then
        if DynamicTrading_Factions.MarkFactionAdminReview then
            DynamicTrading_Factions.MarkFactionAdminReview(id, "no_linked_workers")
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Player faction ["..(faction.name or id).."] moved to admin review")
        end
        return true -- indicating it died/needs review
    end
    return false
end

return PlayerSim
