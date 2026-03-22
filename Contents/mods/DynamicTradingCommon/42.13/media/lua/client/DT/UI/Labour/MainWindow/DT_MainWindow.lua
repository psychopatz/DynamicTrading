require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "ISUI/ISPanel"
require "ISUI/ISModalDialog"
require "DT/UI/Labour/DT_LabourJobModal"
require "DT/UI/Labour/DT_LabourQuantityModal"
require "DT/UI/Labour/DT_LabourHelpWindow"
require "DT/UI/Labour/SupplyWindow/DT_SupplyWindow"
require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/LabourNetwork/DT_Labour_Network"
require "DT/Common/UI/Trading/Provider/DT_TradingProvider_Core"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow"
require "DT/UI/Faction/DT_PlayerFactionNameModal"

DT_MainWindow = ISCollapsableWindow:derive("DT_MainWindow")
DT_MainWindow.instance = nil
DT_MainWindow.cachedWorkers = DT_MainWindow.cachedWorkers or {}
DT_MainWindow.cachedDetails = DT_MainWindow.cachedDetails or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

-- Keep explicit load order so core helpers are available before dependent modules.
require "DT/UI/Labour/MainWindow/MainWindowCore/DT_MainWindowCore"
require "DT/UI/Labour/MainWindow/DT_MainWindow_List"
require "DT/UI/Labour/MainWindow/MainWindowLayout/DT_MainWindowLayout"
require "DT/UI/Labour/MainWindow/MainWindowDetail/DT_MainWindowDetail"
require "DT/UI/Labour/MainWindow/MainWindowActions/DT_MainWindowActions"
require "DT/UI/Labour/MainWindow/DT_MainWindow_Lifecycle"
require "DT/UI/Labour/MainWindow/DT_MainWindow_Events"

return DT_MainWindow
