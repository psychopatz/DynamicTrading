-- ==============================================================================
-- media/lua/client/DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow.lua
-- Dedicated Info UI for Factions
-- Refactored to match Radar Window (Scalable, Hideable, Header Separated)
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISTabPanel"
require "DT/UI/Faction/DT_FactionList"
require "DT/UI/Faction/DT_FactionInfoHeaderPanel"
require "DT/UI/Faction/DT_PlayerFactionNameModal"
require "DT/UI/Faction/DT_PlayerFactionMembersModal"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Info"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Reputation"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Economics"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Calendar"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Stockpiles"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Population"
require "DT/UI/Faction/DT_NPCProfilePanel"
require "DT/UI/Faction/Tabs/DT_FactionInfoTab_Infrastructure"
require "DT/UI/Faction/Tabs/DT_FactionEventLogPanel"

DT_FactionInfoWindow = ISCollapsableWindow:derive("DT_FactionInfoWindow")
DT_FactionInfoWindow.instance = nil

require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow_HelpersLogic"
require "DT/UI/Faction/Tabs/DT_FactionInfoFooterPanel"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow_UILogic"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow_DataLogic"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow_InteractionLogic"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow_NetworkLogic"
