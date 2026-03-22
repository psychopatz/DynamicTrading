require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Labour/Warehouse/DT_LabourWarehouse"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}
DT_Labour.Network.Internal = DT_Labour.Network.Internal or {}
DT_Labour.Network.Workers = DT_Labour.Network.Workers or {}

-- Keep explicit load order so shared worker helpers exist before dependent handlers.
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Shared"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Assignment"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Deposit"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Money"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Withdraw"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Drop"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Job"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers_Lifecycle"

return DT_Labour.Network
