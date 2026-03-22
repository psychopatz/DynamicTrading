require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sites"
require "DT/Common/Labour/LabourNutrition/DT_LabourNutrition"
require "DT/Common/Labour/DT_Labour_Output"
require "DT/Common/Labour/DT_Labour_Presentation"
require "DT/Common/Labour/LabourInteraction/DT_Labour_Interaction"
require "DT/Common/Labour/Warehouse/DT_LabourWarehouse"

DT_Labour = DT_Labour or {}
DT_Labour.Sim = DT_Labour.Sim or {}
DT_Labour.Sim.Internal = DT_Labour.Sim.Internal or {}

local Sim = DT_Labour.Sim

if isClient() and not isServer() then
    return Sim
end

Sim.tickCounter = Sim.tickCounter or 0
Sim.lastProcessedHour = Sim.lastProcessedHour or -1

require "DT/Common/Labour/LabourSim/DT_LabourSim_Helpers"
require "DT/Common/Labour/LabourSim/DT_LabourSim_Outcome"
require "DT/Common/Labour/LabourSim/DT_LabourSim_Nutrition"
require "DT/Common/Labour/LabourSim/DT_LabourSim_Scavenge"
require "DT/Common/Labour/LabourSim/DT_LabourSim_Process"

Events.OnTick.Add(Sim.OnTick)

return Sim
