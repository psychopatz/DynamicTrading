require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"

local PlayerOwnership = {}
local Internal = {}

require("DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_CoreLogic")(PlayerOwnership, Internal)
require("DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_WorkerLogic")(PlayerOwnership, Internal)
require("DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_TradeLogic")(PlayerOwnership, Internal)
require("DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_RegencyLogic")(PlayerOwnership, Internal)

if not isClient() or isServer() then
    if Events.OnPlayerDeath then
        Events.OnPlayerDeath.Add(Internal.onPlayerDeath)
    end
    Events.OnInitGlobalModData.Add(PlayerOwnership.RefreshAllPlayerFactions)
end

return PlayerOwnership
