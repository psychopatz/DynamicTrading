DTCommon = DTCommon or {}

DTCommon.VERSION = 1
DTCommon.MOD_ID = "DTCommon"
DTCommon.MODDATA_KEY = "DTCommon.Traders"
DTCommon.MARKET_MODDATA_KEY = "DTCommon.SettlementMarkets"
DTCommon.MONEY_FULL_TYPE = "Base.Money"
-- Degraded fallback labels only. The canonical trader name and role come from
-- Project Hoomans (DTHoomans.Caravan.ResolveTraderDisplayName plus the NPC
-- affiliation role). DEFAULT_TRADER_ROLE uses Project Hoomans' own role token.
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
