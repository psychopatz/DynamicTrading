-- DynamicTrading-specific creation of additional canonical trader groups.
--
-- Core owns generic SurvivorWorld generation/commit. DTCommon owns the policy
-- that a debug trader should be a caravan attached to a canonical community.

DTCommon = DTCommon or {}
DTCommon.CoreTraderCandidateFactory =
    DTCommon.CoreTraderCandidateFactory or {}

local Factory = DTCommon.CoreTraderCandidateFactory
local SurvivorWorld = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorld"
local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local Presets = require "DTCommon/DTCommon_TraderPresets"

Factory.MAX_GENERATION_ATTEMPTS = 16
Factory.DEFAULT_MEMBER_COUNT = 3
Factory.SERIAL_BASE = 100000

local function point(value)
    value = type(value) == "table" and value or {}
    local x = tonumber(value.x)
    local y = tonumber(value.y)
    if x == nil or y == nil
        or x ~= x or y ~= y
        or x == math.huge or x == -math.huge
        or y == math.huge or y == -math.huge
    then
        return nil
    end
    return {
        x = x,
        y = y,
        z = tonumber(value.z) or 0,
    }
end

local function communityPosition(community)
    local home = community
        and type(community.home) == "table"
        and community.home or nil
    return home and point(home) or nil
end

local function distanceSquared(left, right)
    local dx = left.x - right.x
    local dy = left.y - right.y
    return dx * dx + dy * dy
end

local function nearestCommunity(registry, position)
    local preferred
    local preferredDistance
    local fallback
    local fallbackDistance

    for _, community in ipairs(registry:ListCommunities() or {}) do
        local home = communityPosition(community)
        if home and community.factionID then
            local distance = distanceSquared(home, position)
            local faction = registry:GetFaction(community.factionID)
            local traderFaction = faction
                and tostring(faction.archetypeID or "") == "trader"
            if traderFaction
                and (preferredDistance == nil
                    or distance < preferredDistance)
            then
                preferred = {
                    community = community,
                    faction = faction,
                }
                preferredDistance = distance
            end
            if fallbackDistance == nil
                or distance < fallbackDistance
            then
                fallback = {
                    community = community,
                    faction = faction,
                }
                fallbackDistance = distance
            end
        end
    end

    return preferred or fallback
end

local function actorsUnused(plan, actorRegistry)
    if not actorRegistry then return false end
    for _, actorID in ipairs(plan.memberActorIDs or {}) do
        if actorRegistry:Get(actorID) then return false end
    end
    return true
end

function Factory.Create(spec)
    spec = type(spec) == "table" and spec or {}
    local position = point(spec.position)
    if not position then return nil, "position_required" end

    local registry = spec.registry
        or SurvivorWorld.GetRuntimeRegistry()
    if not registry then
        return nil, "survivor_world_unavailable"
    end

    local actorRegistry = spec.actorRegistry
        or Actors.DefaultRegistry
    if not actorRegistry then
        return nil, "actor_registry_unavailable"
    end

    local home = nearestCommunity(registry, position)
    if not home or not home.community then
        return nil, "canonical_home_community_unavailable"
    end
    local community = home.community
    local faction = home.faction
        or registry:GetFaction(community.factionID)
    if not faction then
        return nil, "canonical_faction_unavailable"
    end

    local sectorID = SurvivorWorld.Generation.SectorID(
        position.x,
        position.y,
        spec.sectorSize
    )
    if not sectorID then return nil, "sector_unavailable" end

    local counts = registry:Counts()
    local baseSerial = Factory.SERIAL_BASE
        + math.max(0, tonumber(counts.groups) or 0)
    local attempts = math.max(
        1,
        math.min(
            Factory.MAX_GENERATION_ATTEMPTS,
            math.floor(
                tonumber(spec.maxAttempts)
                    or Factory.MAX_GENERATION_ATTEMPTS
            )
        )
    )

    local lastReason
    for attempt = 1, attempts do
        local serial = baseSerial + attempt
        local plan
        plan, lastReason =
            SurvivorWorld.Generation.BuildGroupPlan({
                worldSeed = registry:WorldSeed(),
                sectorID = sectorID,
                serial = serial,
                source = tostring(
                    spec.source or "DYNAMIC_TRADING_DEBUG"
                ),
                locationID = "dt_debug_site_" .. tostring(serial),
                location = position,
                locationKind = "temporary",
                factionID = community.factionID,
                factionName = faction.name,
                factionArchetypeID =
                    faction.archetypeID or "trader",
                groupType = "CARAVAN",
                initialMission = "TRADE",
                memberCount = math.max(
                    1,
                    math.floor(
                        tonumber(spec.memberCount)
                            or Factory.DEFAULT_MEMBER_COUNT
                    )
                ),
                createdAt = spec.createdAt,
            })
        if plan then
            plan.homeCommunityID = community.id
            local memberPlan, presetReason = Presets.BuildMembers({
                seed = plan.seed or spec.seed or plan.groupID,
                actorPrefix = plan.groupID,
                actorIDs = plan.memberActorIDs,
                memberCount = #(plan.memberActorIDs or {}),
            })
            if not memberPlan then
                lastReason = presetReason
            else
                plan.memberSpecs = memberPlan.memberSpecs
                if not registry:GetGroup(plan.groupID)
                    and actorsUnused(plan, actorRegistry)
                then
                    local group
                    group, lastReason =
                        SurvivorWorld.Bootstrap.CommitGroupPlan(
                            registry,
                            plan,
                            actorRegistry
                        )
                    if group then
                        SurvivorWorld.RuntimeStore.MarkDirty(
                            "dynamic_trading_debug_group_created"
                        )
                        local saved, saveReason =
                            SurvivorWorld.RuntimeStore.Save()
                        if saved ~= true and saveReason ~= "not_dirty" then
                            print(
                                "[DT][WARN] Core trader group persistence "
                                    .. "deferred: " .. tostring(saveReason)
                            )
                        end
                        if actorRegistry == Actors.DefaultRegistry
                            and Actors.RuntimeStore
                            and type(Actors.RuntimeStore.Save) == "function"
                        then
                            local actorSaved, actorSaveReason =
                                Actors.RuntimeStore.Save()
                            if actorSaved ~= true then
                                print(
                                    "[DT][WARN] Core trader actor persistence "
                                        .. "deferred: "
                                        .. tostring(actorSaveReason)
                                )
                            end
                        end
                        return {
                            actorID = plan.leaderActorID,
                            groupID = plan.groupID,
                            factionID = plan.factionID,
                            communityID = community.id,
                            position = position,
                            memberActorIDs = plan.memberActorIDs,
                            memberSpecs = plan.memberSpecs,
                        }, "canonical_group_created"
                    end
                else
                    lastReason = "generated_identity_collision"
                end
            end
        end
    end

    return nil, lastReason or "canonical_group_generation_failed"
end

return Factory
