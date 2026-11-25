DTCommon = DTCommon or {}

if PsychopatzCore and PsychopatzCore.RequirePack then
    PsychopatzCore.RequirePack("pack.trading_common", "DTCommon")
else
    require "PsychopatzCore/Inventory/PsychopatzInventory"
end
require "DTCommon/DTCommon_Translation"
require "DTCommon/DTCommon_Constants"
require "DTCommon/DTCommon_ModActivationPolicy"
require "DTCommon/DTCommon_TraderFactionProfile"
local TradingFactionNames = require "DTCommon/Definitions/Factions/Trader"
DTCommon.TradingFactionNames = TradingFactionNames
local okProfiles, coreProfiles = pcall(
    require,
    "PsychopatzCore/World/SurvivorWorld/Generation/PsychopatzSurvivorWorldGenerationProfiles"
)
if okProfiles and type(coreProfiles) == "table"
    and type(coreProfiles.RegisterNamePool) == "function"
then
    coreProfiles.RegisterNamePool(
        TradingFactionNames.id or DTCommon.TRADER_PROFILE_ID or "DT.trader",
        TradingFactionNames
    )
end
require "DTCommon/DTCommon_MarketSchema"
require "DTCommon/DTCommon_Storage"
require "DTCommon/DTCommon_TraderSupport"
require "DTCommon/DTCommon_MarketSenseGateway"
require "DTCommon/DTCommon_MarketProfiles"
require "DTCommon/DTCommon_SettlementDirectory"
require "DTCommon/DTCommon_IntegrationRegistry"
require "DTCommon/DTCommon_SettlementMarket"
require "DTCommon/DTCommon_TraderProviderRegistry"
require "DTCommon/DTCommon_TraderPresets"
require "DTCommon/DTCommon_TraderGeneration"
require "DTCommon/DTCommon_CoreActorPolicy"
require "DTCommon/DTCommon_MarketEvents"
require "DTCommon/DTCommon_MarketEventDefinitions"
require "DTCommon/DTCommon_MarketEventProducer"
require "DTCommon/DTCommon_MarketEventPresentation"
require "DTCommon/DTCommon_CoreWorldEventProjection"
require "DTCommon/DTCommon_MarketPricing"
require "DTCommon/DTCommon_TraderStock"
require "DTCommon/DTCommon_CaravanStorage"
require "DTCommon/DTCommon_TraderRegistry"
require "DTCommon/DTCommon_TraderService"
require "DTCommon/DTCommon_TraderWorld"
require "DTCommon/DTCommon_SettlementExchange"
require "DTCommon/DTCommon_WorldKnowledge"
require "DTCommon/DTCommon_ActorLifecycle"
require "DTCommon/DTCommon_PlacePresentation"
DTCommon.GeneratedSemanticRegistry = require
    "DTCommon/ConvoEngine/Registry"
require "DTCommon/DTCommon_SemanticPack"
require "DTCommon/DTCommon_TradeAudit"
require "DTCommon/DTCommon_TradeAuditPrice"
require "DTCommon/DTCommon_TradeAuditProfiler"

return DTCommon
