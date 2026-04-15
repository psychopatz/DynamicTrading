local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    function Public.EnterRegency(ownerUsername)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return nil end
        if tostring(faction.leadershipState or "") == "AdminReview" then return faction end
        faction.leadershipState = "Regency"
        faction.regencyReason = "leader_dead"
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end

    function Public.ResumeLeadership(ownerUsername)
        local faction = Public.GetPlayerFaction(ownerUsername)
        if not Public.IsPlayerFaction(faction) then return nil end
        if tostring(faction.leadershipState or "") == "AdminReview" then return faction end
        if Utils.getOwnerUsername(faction.leaderUsername) ~= Utils.getOwnerUsername(ownerUsername) then
            return faction
        end
        if type(ownerUsername) ~= "string" and ownerUsername and ownerUsername.isDead and ownerUsername:isDead() then
            return faction
        end
        faction.leadershipState = "Active"
        faction.regencyReason = nil
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end

    function Internal.onPlayerDeath(player)
        if not player or (isClient() and not isServer()) then return end
        Public.EnterRegency(player)
    end
end
