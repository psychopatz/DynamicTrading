-- =============================================================================
-- DYNAMIC TRADING: SHARED ECONOMY LOGIC
-- =============================================================================
-- This module contains the core math and logic for trading, stripped of 
-- specific data dependencies (like specific Events or Soul lookups).
-- V1 and V2 wrappers should gather the data and pass it here.

DynamicTrading = DynamicTrading or {}
DynamicTrading.Economy = DynamicTrading.Economy or {}
DynamicTrading.Economy.Common = DynamicTrading.Economy.Common or {}

require "DT/Common/Items/DT_Fluids"

local Common = DynamicTrading.Economy.Common
DynamicTrading.Log("DTCommons", "Init", "Economy", "Common Economy Module initialized")

require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon_Utils"
require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon_TagsAndCharge"
require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon_Stock"
require "DT/Common/Trading/EconomyPrice/DT_EconomyPrice"
