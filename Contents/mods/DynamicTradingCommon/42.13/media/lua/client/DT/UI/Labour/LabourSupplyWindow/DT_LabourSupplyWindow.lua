require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Nutrition"
require "DT/Common/Labour/DT_Labour_Network"

DT_LabourSupplyWindow = ISCollapsableWindow:derive("DT_LabourSupplyWindow")
DT_LabourSupplyWindow.instance = nil
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

-- Keep explicit load order so shared helpers are available before dependent modules.
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Shared"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_List"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Layout"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Scan"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Actions"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Lifecycle"
require "DT/UI/Labour/LabourSupplyWindow/DT_SupplyWindow_Events"

return DT_LabourSupplyWindow
