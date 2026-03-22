require "DT/UI/Labour/MainWindow/DT_MainWindow"
require "DT/UI/Labour/DT_LabourMapProvider"
require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourNetwork/DT_Labour_Network"

-- Keep explicit load order so helpers are registered before dependent modules.
require "DT/UI/Labour/System/DT_System_Shared"
require "DT/UI/Labour/System/DT_System_Window"
require "DT/UI/Labour/System/DT_System_Factions"
require "DT/UI/Labour/System/DT_System_Conversation"
require "DT/UI/Labour/System/DT_System_Recruitment"
require "DT/UI/Labour/System/DT_System_Options"
require "DT/UI/Labour/System/DT_System_Events"

return DT_System
