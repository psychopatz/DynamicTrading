require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/Labour/LabourRegistry/DT_LabourRegistry"
require "DT/Common/Labour/DT_Labour_Sim"
require "DT/Common/Labour/DT_Labour_Presentation"

DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sim = DT_Labour.Sim
local Presentation = DT_Labour.Presentation
local Network = DT_Labour.Network
local Internal = Network.Internal or {}

Network.Internal = Internal
Network.Handlers = Network.Handlers or {}

local function canUseDebugRecruit(player)
    if DynamicTrading and DynamicTrading.Debug then
        return true
    end

    if isDebugEnabled and isDebugEnabled() then
        return true
    end

    if player and player.getAccessLevel then
        local accessLevel = player:getAccessLevel()
        if accessLevel and accessLevel ~= "" and accessLevel ~= "None" then
            return true
        end
    end

    return false
end

Network.Handlers.DebugRecruitWorker = function(player, args)
    if not player or not canUseDebugRecruit(player) then return end
    args = args or {}

    local owner = Config.GetOwnerUsername(player)
    local sourceNPCID = args.sourceNPCID and tostring(args.sourceNPCID) or nil
    local worker = sourceNPCID and Registry.FindWorkerBySourceID(owner, sourceNPCID) or nil

    if not worker then
        worker = Internal.createWorkerFromRecruitArgs(owner, args)
    end

    Registry.Save()
    Sim.ProcessWorker(worker, (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID)
    Internal.syncWorkerList(player)
end

return Network
