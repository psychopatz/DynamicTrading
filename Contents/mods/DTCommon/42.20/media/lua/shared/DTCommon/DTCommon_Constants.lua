DTCommon = DTCommon or {}

DTCommon.VERSION = 1
DTCommon.MOD_ID = "DTCommon"
-- Short, reserved Dynamic Trading namespace for cross-module identifiers.
-- Keep the namespace in the shared contract so adopters never need to repeat
-- the former `dynamictrading.*` strings or guess the canonical profile ID.
DTCommon.NAMESPACE = "DT"
DTCommon.TRADER_PROFILE_ID = "DT.trader"
DTCommon.TRADER_PROFILE_SOURCE = "DynamicTrading"
DTCommon.TRADER_NAMESPACE = "DT.trader"
DTCommon.TRADE_CAPABILITY = "DT.trade"
DTCommon.TRADE_ACTION_ID = "DT.trade"
DTCommon.REFERRAL_ACTION_ID = "DT.referral"
DTCommon.RUMORS_ACTION_ID = "DT.rumors"
DTCommon.PRESET_EXTENSION = "DT.preset"
DTCommon.TRADER_PRESET_EXTENSION = "DT.traderPreset"
DTCommon.MODDATA_KEY = "DTCommon.Traders"
DTCommon.MARKET_MODDATA_KEY = "DTCommon.SettlementMarkets"
DTCommon.EVENT_MODDATA_KEY = "DTCommon.MarketEvents"
DTCommon.MONEY_FULL_TYPE = "Base.Money"
-- Degraded fallback labels only. Optional representation adapters may
-- provide a more specific canonical display name and role presentation.
DTCommon.DEFAULT_TRADER_NAME = "Caravan Trader"
DTCommon.DEFAULT_TRADER_ROLE = "trader"
DTCommon.DEFAULT_CARAVAN_ID = "debug_caravan"
DTCommon.OP_BUY = "BUY"
DTCommon.OP_SELL = "SELL"
DTCommon.STATUS_READY = "READY"
DTCommon.STATUS_AWAY = "AWAY"
DTCommon.DEFAULT_STOCK = {
    { fullType = "Base.Bandage", quantity = 5 },
    { fullType = "Base.CannedBeans", quantity = 5 },
}

return DTCommon
