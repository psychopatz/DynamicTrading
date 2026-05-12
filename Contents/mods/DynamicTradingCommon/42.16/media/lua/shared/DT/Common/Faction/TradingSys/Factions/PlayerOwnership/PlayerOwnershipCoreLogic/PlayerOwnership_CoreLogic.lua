local buildContext = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Context"

return function(Public, Internal)
    local context = buildContext(Public, Internal)

    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_ColonySync"(context)
    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Query"(context)
    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Refresh"(context)
    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Membership"(context)
    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Status"(context)
    require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnershipCoreLogic/PlayerOwnership_CoreLogic_Admin"(context)
end
