local PlayerOwnership_Utils = {}

require "DT/Common/BuildingScannerConfig/DT_BuildingScannerConfig"

PlayerOwnership_Utils.MOD_DATA_KEY = "DynamicTrading_Factions"

function PlayerOwnership_Utils.getFactionData()
    if not ModData.exists(PlayerOwnership_Utils.MOD_DATA_KEY) then
        ModData.add(PlayerOwnership_Utils.MOD_DATA_KEY, {})
    end
    return ModData.get(PlayerOwnership_Utils.MOD_DATA_KEY)
end

function PlayerOwnership_Utils.getOwnerUsername(ownerUsername)
    if type(ownerUsername) == "string" then
        return ownerUsername
    end

    local player = ownerUsername
    if player and player.getUsername then
        local username = player:getUsername()
        if username and username ~= "" then
            return username
        end
    end

    return tostring(ownerUsername or "local")
end

function PlayerOwnership_Utils.trimName(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

function PlayerOwnership_Utils.sanitizeID(value)
    local text = string.lower(tostring(value or "local"))
    text = string.gsub(text, "[^%w_]+", "_")
    text = string.gsub(text, "_+", "_")
    text = string.gsub(text, "^_+", "")
    text = string.gsub(text, "_+$", "")
    if text == "" then
        text = "local"
    end
    return text
end

function PlayerOwnership_Utils.getWorkerRegistry()
    return DC_Colony and DC_Colony.Registry or nil
end

function PlayerOwnership_Utils.isWorkerRegistryAvailable()
    local registry = PlayerOwnership_Utils.getWorkerRegistry()
    if type(registry) ~= "table" then
        return false
    end

    local hasOwnerLookup = type(registry.GetWorkersForOwnerRaw) == "function"
        or type(registry.GetWorkersForOwner) == "function"
    local hasWorkerLookup = type(registry.GetWorkerForOwnerRaw) == "function"
        or type(registry.GetWorkerForOwner) == "function"

    return hasOwnerLookup and hasWorkerLookup
end

function PlayerOwnership_Utils.isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    if activated and activated.contains and activated:contains("DynamicColonies") then
        return true
    end
    return rawget(_G, "DC_Colony") ~= nil
end

function PlayerOwnership_Utils.isAdminReview(faction)
    if type(faction) ~= "table" then
        return false
    end
    local state = tostring(faction.leadershipState or "")
    return state == "AdminReview" or state == "Archived"
end

function PlayerOwnership_Utils.getColonyRegistry()
    return DC_Colony and DC_Colony.Registry or nil
end

function PlayerOwnership_Utils.getWorkerSummary(worker)
    local registry = PlayerOwnership_Utils.getWorkerRegistry()
    if registry and registry.GetWorkerSummary then
        return registry.GetWorkerSummary(worker)
    end
    return worker
end

function PlayerOwnership_Utils.getDeadState()
    local config = DC_Colony and DC_Colony.Config
    return tostring(config and config.States and config.States.Dead or "Dead")
end

function PlayerOwnership_Utils.isWorkerLiving(worker)
    return worker and tostring(worker.state or "") ~= PlayerOwnership_Utils.getDeadState()
end

function PlayerOwnership_Utils.findWorkerByID(ownerUsername, workerID)
    local registry = PlayerOwnership_Utils.getWorkerRegistry()
    if registry and registry.GetWorkerForOwnerRaw then
        return registry.GetWorkerForOwnerRaw(ownerUsername, workerID)
    end
    if registry and registry.GetWorkerForOwner then
        return registry.GetWorkerForOwner(ownerUsername, workerID)
    end
    return nil
end

function PlayerOwnership_Utils.getWorkersForOwner(ownerUsername)
    local registry = PlayerOwnership_Utils.getWorkerRegistry()
    if registry and registry.GetWorkersForOwnerRaw then
        return registry.GetWorkersForOwnerRaw(ownerUsername) or {}
    end
    if registry and registry.GetWorkersForOwner then
        return registry.GetWorkersForOwner(ownerUsername) or {}
    end
    return {}
end

function PlayerOwnership_Utils.appendUnique(array, value)
    if not value then
        return
    end
    for _, existing in ipairs(array) do
        if existing == value then
            return
        end
    end
    table.insert(array, value)
end

function PlayerOwnership_Utils.removeValue(array, value)
    if type(array) ~= "table" then
        return false
    end

    local removed = false
    for index = #array, 1, -1 do
        if array[index] == value then
            table.remove(array, index)
            removed = true
        end
    end
    return removed
end

function PlayerOwnership_Utils.containsValue(array, value)
    if type(array) ~= "table" then
        return false
    end

    for _, existing in ipairs(array) do
        if existing == value then
            return true
        end
    end

    return false
end

function PlayerOwnership_Utils.copyArray(source)
    local copy = {}
    for index, value in ipairs(source or {}) do
        copy[index] = value
    end
    return copy
end

function PlayerOwnership_Utils.ensureUniqueUsernames(array)
    local normalized = {}
    local seen = {}

    for _, value in ipairs(array or {}) do
        local username = PlayerOwnership_Utils.getOwnerUsername(value)
        if username ~= "" and not seen[username] then
            seen[username] = true
            normalized[#normalized + 1] = username
        end
    end

    table.sort(normalized, function(a, b)
        return tostring(a) < tostring(b)
    end)

    return normalized
end

function PlayerOwnership_Utils.getFactionRole(faction, username)
    local owner = PlayerOwnership_Utils.getOwnerUsername(username)
    if type(faction) ~= "table" or owner == "" then
        return nil
    end

    if PlayerOwnership_Utils.getOwnerUsername(faction.leaderUsername) == owner then
        return "leader"
    end

    if PlayerOwnership_Utils.containsValue(faction.memberUsernames, owner) then
        return "member"
    end

    return nil
end

function PlayerOwnership_Utils.buildFactionHome(player, workers)
    local x = nil
    local y = nil
    local z = 0

    if player and player.getX and player.getY then
        x = math.floor(player:getX())
        y = math.floor(player:getY())
        z = math.floor((player.getZ and player:getZ()) or 0)
    elseif workers and workers[1] then
        local worker = workers[1]
        x = math.floor(tonumber(worker.homeX) or tonumber(worker.workX) or 0)
        y = math.floor(tonumber(worker.homeY) or tonumber(worker.workY) or 0)
        z = math.floor(tonumber(worker.homeZ) or tonumber(worker.workZ) or 0)
    end

    if x == nil or y == nil then
        x, y, z = 0, 0, 0
    end

    local town = "Unknown"
    if DTM and DTM.GetTownName then
        local resolvedTown = DTM.GetTownName(x, y)
        if resolvedTown and resolvedTown ~= "" then
            town = resolvedTown
        end
    end

    return {
        name = "Player HQ",
        x = x,
        y = y,
        z = z,
        town = town
    }
end

function PlayerOwnership_Utils.getCurrentHours()
    local gameTime = getGameTime and getGameTime() or GameTime and GameTime:getInstance() or nil
    return gameTime and gameTime:getWorldAgeHours() or 0
end

function PlayerOwnership_Utils.getWalkHours()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    return tonumber(sandbox and sandbox.NPCTradingWalkHours) or 2
end

function PlayerOwnership_Utils.rollRadioStayHours()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local minHours = tonumber(sandbox and sandbox.TraderStayHoursMin) or 6
    local maxHours = tonumber(sandbox and sandbox.TraderStayHoursMax) or 24
    if minHours > maxHours then
        minHours = maxHours
    end
    return ZombRand(minHours, maxHours + 1)
end

return PlayerOwnership_Utils
