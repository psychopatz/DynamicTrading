require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Buildings/DT_Buildings"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}
DT_Labour.Network.Internal = DT_Labour.Network.Internal or {}

require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_Shared"
require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_Inventory"
require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_Reputation"
require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_Recruitment"
require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_QueryHandlers"
require "DT/Common/Labour/LabourNetwork/Workers/DT_Workers"
require "DT/Common/Buildings/DT_BuildingsNetwork"
require "DT/Common/Labour/LabourNetwork/DT_LabourNetwork_Debug"

return DT_Labour.Network
