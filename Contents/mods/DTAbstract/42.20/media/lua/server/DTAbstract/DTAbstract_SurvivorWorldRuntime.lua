-- DTAbstract adopter for the canonical PsychopatzCore SurvivorWorld.
-- Owns no population/world persistence; it only activates Core and resolves
-- existing canonical actors/groups for DynamicTrading commercial roles.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then
    return
end

DTAbstract = DTAbstract or {}
DTAbstract.SurvivorWorldRuntime =
    DTAbstract.SurvivorWorldRuntime or {}

local Runtime = DTAbstract.SurvivorWorldRuntime
local SurvivorWorld = require
    "PsychopatzCore/SurvivorWorld/PsychopatzSurvivorWorld"
local Actors = require "PsychopatzCore/Actors/PsychopatzActors"

local customActorRegistry

function Runtime.SetActorRegistry(value)
    customActorRegistry = value
end

function Runtime.GetActorRegistry()
    return customActorRegistry or Actors.DefaultRegistry
end

local function engineSeedString()
    local instance = WorldGenParams and WorldGenParams.INSTANCE or nil
    if not instance or not instance.getSeedString then return nil end
    local ok, value = pcall(instance.getSeedString, instance)
    value = ok and tostring(value or "") or ""
    return value ~= "" and value or nil
end

local function playerPosition(player)
    if not player then return nil end
    local getX = player.getX
    local getY = player.getY
    if type(getX) ~= "function" or type(getY) ~= "function" then
        return nil
    end
    local okX, x = pcall(getX, player)
    local okY, y = pcall(getY, player)
    if not okX or not okY or tonumber(x) == nil or tonumber(y) == nil then
        return nil
    end
    local z = 0
    if type(player.getZ) == "function" then
        local okZ, value = pcall(player.getZ, player)
        if okZ then z = tonumber(value) or 0 end
    end
    return { x = tonumber(x), y = tonumber(y), z = z }
end

local function firstOnlinePlayer()
    if type(getOnlinePlayers) == "function" then
        local ok, players = pcall(getOnlinePlayers)
        if ok and players then
            if type(players.size) == "function"
                and type(players.get) == "function"
            then
                local sizeOK, size = pcall(players.size, players)
                if sizeOK and tonumber(size) and size > 0 then
                    local getOK, player = pcall(players.get, players, 0)
                    if getOK and player then return player end
                end
            elseif type(players) == "table" and players[1] then
                return players[1]
            end
        end
    end
    if type(getSpecificPlayer) == "function" then
        local ok, player = pcall(getSpecificPlayer, 0)
        if ok and player then return player end
    end
    if type(getPlayer) == "function" then
        local ok, player = pcall(getPlayer)
        if ok and player then return player end
    end
    return nil
end

function Runtime.ResolveAnchor(spec)
    spec = type(spec) == "table" and spec or {}
    local source = spec.anchor or spec.position
    if type(source) == "table"
        and tonumber(source.x) ~= nil
        and tonumber(source.y) ~= nil
    then
        return {
            x = tonumber(source.x),
            y = tonumber(source.y),
            z = tonumber(source.z) or 0,
        }
    end
    return playerPosition(firstOnlinePlayer())
end

function Runtime.Ensure(spec)
    spec = type(spec) == "table" and spec or {}
    local registry = SurvivorWorld.GetRuntimeRegistry()
    if registry then
        local counts = registry:Counts()
        local population = registry:GetPopulation()
        if counts.communities > 0
            or counts.groups > 0
            or population.bootstrapCompleted == true
        then
            Runtime.Registry = registry
            return registry, "existing"
        end
    end

    local anchor = Runtime.ResolveAnchor(spec)
    if not anchor then
        registry = registry or SurvivorWorld.ActivateRuntime({
            worldSeed = SurvivorWorld.Generation.ResolveWorldSeed({
                seedString = engineSeedString(),
            }),
        })
        Runtime.Registry = registry
        return nil, "survivor_world_anchor_unavailable"
    end

    local result
    registry, result = SurvivorWorld.Bootstrap.EnsureRuntime({
        seedString = engineSeedString(),
        anchor = anchor,
        communityCount = spec.communityCount or 3,
        groupCount = spec.groupCount or 3,
        traderGroupCount = 2,
        source = "WORLD_POPULATION_BOOTSTRAP",
        actorRegistry = spec.actorRegistry
            or Runtime.GetActorRegistry(),
    })
    if not registry then return nil, result end
    Runtime.Registry = registry
    Runtime.LastBootstrapReason = result
    return registry, result
end

local function usedActorIDs()
    local used = {}
    local service = DTCommon and DTCommon.TraderService or nil
    if service and type(service.ForEach) == "function" then
        service.ForEach(function(_, record)
            local ca = record and record.ca or nil
            local actorID = ca
                and (ca.actorID) or nil
            if actorID then used[tostring(actorID)] = true end
        end)
    end
    return used
end

local function traderGroup(registry, group)
    if type(group) ~= "table" then return false end
    local kind = string.upper(tostring(group.groupType or ""))
    if kind == "CARAVAN" or kind == "TRADER" then return true end
    local faction = registry:GetFaction(group.factionID)
    return faction and tostring(faction.archetypeID) == "trader"
end

function Runtime.ListTraderCandidates(spec)
    spec = type(spec) == "table" and spec or {}
    local registry, reason = Runtime.Ensure(spec)
    if not registry then return {}, reason end
    local actorRegistry = spec.actorRegistry
        or Runtime.GetActorRegistry()
    local used = usedActorIDs()
    local output = {}
    local anchor = Runtime.ResolveAnchor(spec)

    for _, group in ipairs(registry:ListGroups() or {}) do
        if traderGroup(registry, group) then
            local actorID = group.leaderActorID
                or (group.memberActorIDs and group.memberActorIDs[1])
            if actorID and not used[tostring(actorID)] then
                local actor = actorRegistry and actorRegistry:Get(actorID)
                if actor then
                    local position =
                        registry:ProjectGroupMemberPosition(
                            group.id,
                            actorID,
                            actor.world,
                            spec.now
                        )
                    position = position
                        or (group.location and {
                            x = group.location.x,
                            y = group.location.y,
                            z = group.location.z or 0,
                        })
                    local distanceSquared
                    if anchor and position then
                        local dx = position.x - anchor.x
                        local dy = position.y - anchor.y
                        distanceSquared = dx * dx + dy * dy
                    end
                    output[#output + 1] = {
                        actorID = actorID,
                        groupID = group.id,
                        factionID = group.factionID,
                        communityID = group.homeCommunityID,
                        memberActorIDs = group.memberActorIDs,
                        position = position,
                        distanceSquared = distanceSquared,
                    }
                end
            end
        end
    end
    table.sort(output, function(left, right)
        if left.distanceSquared ~= nil
            and right.distanceSquared ~= nil
            and left.distanceSquared ~= right.distanceSquared
        then
            return left.distanceSquared < right.distanceSquared
        end
        return tostring(left.groupID) < tostring(right.groupID)
    end)
    return output
end

function Runtime.SelectTraderCandidate(spec)
    local candidates, reason = Runtime.ListTraderCandidates(spec)
    if #candidates == 0 then
        return nil, reason or "canonical_trader_candidate_unavailable"
    end
    local sequence = math.max(
        1,
        math.floor(tonumber(spec and spec.sequence) or 1)
    )
    return candidates[((sequence - 1) % #candidates) + 1]
end

function Runtime.FindGroupForActor(actorID)
    actorID = tostring(actorID or "")
    if actorID == "" then return nil, "actor_id_required" end
    local registry = Runtime.GetRegistry()
    if not registry then return nil, "survivor_world_unavailable" end
    for _, group in ipairs(registry:ListGroups() or {}) do
        for _, memberID in ipairs(group.memberActorIDs or {}) do
            if tostring(memberID) == actorID then
                return group
            end
        end
    end
    return nil, "actor_group_not_found"
end

function Runtime.MarkDirty(reason)
    return SurvivorWorld.RuntimeStore.MarkDirty(
        reason or "dtabstract_survivor_world_mutation"
    )
end

function Runtime.GetRegistry()
    return Runtime.Registry
        or SurvivorWorld.GetRuntimeRegistry()
end

Runtime.SurvivorWorld = SurvivorWorld
Runtime.Actors = Actors

return Runtime
