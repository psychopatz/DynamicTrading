-- ==============================================================================
-- ColonyEconomy/VirtualStore/DT_VirtualStore.lua
-- Logic: Entry module for virtual store. 
-- ==============================================================================

local DT_VirtualStore = {}

DT_VirtualStore.Prices = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore_Prices"
DT_VirtualStore.AutoBuy = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore_AutoBuy"

return DT_VirtualStore
