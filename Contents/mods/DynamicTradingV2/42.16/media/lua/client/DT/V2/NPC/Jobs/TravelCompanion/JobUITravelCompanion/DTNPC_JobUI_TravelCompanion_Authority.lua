-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Authority.lua
-- Command authority and companion ownership helpers.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Authority then
    return
end

modules.Authority = true

function CompanionUI.NormalizeText(value)
    value = value and tostring(value) or ""
    return value ~= "" and value or nil
end

function CompanionUI.GetAuthorityUsername(player)
    if not player then
        return nil
    end

    local username = CompanionUI.NormalizeText(player.getUsername and player:getUsername() or nil)
    if DynamicTrading_Factions and DynamicTrading_Factions.GetPlayerFaction and username then
        local faction = DynamicTrading_Factions.GetPlayerFaction(username)
        local leader = CompanionUI.NormalizeText(faction and faction.leaderUsername or nil)
        if leader then
            return leader
        end
    end

    return username
end

function CompanionUI.GetLocalUsername(player)
    return CompanionUI.NormalizeText(player and player.getUsername and player:getUsername() or nil)
end

function CompanionUI.GetCommanderUsername(npcData, worker)
    local companionData = type(worker and worker.companion) == "table" and worker.companion or {}
    return CompanionUI.NormalizeText(
        npcData and npcData.dcCommanderUsername
            or companionData.commanderUsername
            or worker and worker.companionCommanderUsername
            or nil
    )
end

function CompanionUI.IsLocalCommander(player, npcData, worker)
    local username = CompanionUI.GetLocalUsername(player)
    local commander = CompanionUI.GetCommanderUsername(npcData, worker)
    return username ~= nil and commander ~= nil and username == commander
end

function CompanionUI.GetDistanceToNPC(player, npc)
    if not player or not npc then
        return 999999, 999999
    end

    local dx = (tonumber(player:getX()) or 0) - (tonumber(npc:getX()) or 0)
    local dy = (tonumber(player:getY()) or 0) - (tonumber(npc:getY()) or 0)
    local dz = math.abs((tonumber(player:getZ()) or 0) - (tonumber(npc:getZ()) or 0))
    return math.sqrt((dx * dx) + (dy * dy)), dz
end

function CompanionUI.CanClaimCommand(player, npc)
    local distance, dz = CompanionUI.GetDistanceToNPC(player, npc)
    return distance <= 6 and dz <= 1
end

function CompanionUI.SendClaimCommand(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    return DC_System.SendCommand("ClaimCompanionCommand", {
        workerID = worker.workerID
    }) == true
end

function CompanionUI.SendTransferCommand(worker, username)
    if not worker or not worker.workerID or not username or not DC_System or not DC_System.SendCommand then
        return false
    end

    return DC_System.SendCommand("TransferCompanionCommand", {
        workerID = worker.workerID,
        username = username
    }) == true
end

function CompanionUI.CollectTransferCandidates(player, worker)
    local currentUsername = CompanionUI.GetLocalUsername(player)
    local seen = {}
    local candidates = {}

    local function add(username)
        username = CompanionUI.NormalizeText(username)
        if not username or username == currentUsername or seen[username] then
            return
        end
        seen[username] = true
        candidates[#candidates + 1] = username
    end

    local status = DC_MainWindow and DC_MainWindow.cachedOwnedFactionStatus
        or DC_System and DC_System.ownedFactionStatusCache
        or nil
    local faction = status and status.faction or nil
    add(faction and faction.leaderUsername)
    for _, username in ipairs(status and status.memberUsernames or faction and faction.memberUsernames or {}) do
        add(username)
    end

    local ownerUsername = CompanionUI.NormalizeText(worker and worker.ownerUsername)
    if ownerUsername and ownerUsername ~= currentUsername then
        add(ownerUsername)
    end

    table.sort(candidates)
    return candidates
end

function CompanionUI.RefreshCompanionWorker(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return
    end

    DC_System.SendCommand("RequestCompanionCommandStatus", {
        workerID = worker.workerID
    })
end
