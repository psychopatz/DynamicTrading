require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Nutrition"

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

return DT_Labour.Registry
