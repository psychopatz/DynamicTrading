DTCommon = DTCommon or {}

if PsychopatzCore and PsychopatzCore.RequirePack then
    PsychopatzCore.RequirePack("pack.trading_common", "DTCommon")
else
    require "PsychopatzCore/Inventory/PsychopatzInventory"
end
require "DTCommon/DTCommon_Translation"
require "DTCommon/DTCommon_Constants"
require "DTCommon/DTCommon_ModActivationPolicy"
require "DTCommon/DTCommon_MarketSchema"
require "DTCommon/DTCommon_Storage"
require "DTCommon/DTCommon_TraderSupport"
require "DTCommon/DTCommon_MarketSenseGateway"
require "DTCommon/DTCommon_MarketProfiles"
require "DTCommon/DTCommon_SettlementDirectory"
require "DTCommon/DTCommon_IntegrationRegistry"
require "DTCommon/DTCommon_SettlementMarket"
require "DTCommon/DTCommon_TraderProviderRegistry"
require "DTCommon/DTCommon_TraderGeneration"
require "DTCommon/DTCommon_PreSurvivorWorldImport"
require "DTCommon/DTCommon_CoreActorPolicy"
require "DTCommon/DTCommon_MarketEvents"
require "DTCommon/DTCommon_MarketEventDefinitions"
require "DTCommon/DTCommon_MarketEventProducer"
require "DTCommon/DTCommon_MarketEventPresentation"
require "DTCommon/DTCommon_MarketPricing"
require "DTCommon/DTCommon_TraderStock"
require "DTCommon/DTCommon_TraderRegistry"
require "DTCommon/DTCommon_TraderService"
require "DTCommon/DTCommon_TraderWorld"
require "DTCommon/DTCommon_SettlementExchange"
require "DTCommon/DTCommon_WorldKnowledge"
require "DTCommon/DTCommon_PlacePresentation"
require "DTCommon/DTCommon_SemanticPack"
require "DTCommon/DTCommon_TradeAudit"
require "DTCommon/DTCommon_TradeAuditPrice"
require "DTCommon/DTCommon_TradeAuditProfiler"

return DTCommon
