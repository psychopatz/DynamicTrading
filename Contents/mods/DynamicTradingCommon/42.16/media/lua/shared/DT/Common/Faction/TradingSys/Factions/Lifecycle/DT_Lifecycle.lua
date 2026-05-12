local context = require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Context"

require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Queue"(context)
require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Bootstrap"(context)
require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Creation"(context)
require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Roster"(context)
require "DT/Common/Faction/TradingSys/Factions/Lifecycle/DT_Lifecycle_Hooks"(context)

return context.Lifecycle
