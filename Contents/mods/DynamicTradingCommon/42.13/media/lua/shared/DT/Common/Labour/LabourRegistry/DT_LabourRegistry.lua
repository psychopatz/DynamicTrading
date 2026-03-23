require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourSkills/DT_LabourSkills"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/LabourTiredness/DT_LabourTiredness"

DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

-- Keep explicit load order so registry foundations are available before higher-level APIs.
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Internal"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Data"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_WorkerState"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Workers"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Recruitment"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Presentation"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Ledgers"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_WorkerCommands"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry_Sites"
require "DT/Common/Labour/Warehouse/DT_LabourWarehouse"

return DT_Labour.Registry
