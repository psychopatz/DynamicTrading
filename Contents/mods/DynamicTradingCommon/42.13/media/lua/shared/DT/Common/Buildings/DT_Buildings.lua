require "DT/Common/Labour/LabourConfig/DT_LabourConfig"

DT_Buildings = DT_Buildings or {}
DT_Buildings.Config = DT_Buildings.Config or {}
DT_Buildings.Internal = DT_Buildings.Internal or {}

require "DT/Common/Buildings/DT_BuildingsConfig"
require "DT/Common/Buildings/DT_BuildingsData"
require "DT/Common/Buildings/DT_BuildingsHousing"
require "DT/Common/Buildings/DT_BuildingsProjects"
require "DT/Common/Buildings/DT_BuildingsPresentation"

return DT_Buildings
