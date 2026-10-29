-- Headless behaviour harness for the DynamicTrading <-> Project Hoomans bridge.
-- Stubs the PNC surface the bridge talks to, then asserts that DynamicTrading
-- consumes Project Hoomans naming/role authority instead of its own.

local ROOT = os.getenv("DT_MODS_ROOT") or "."
local calls = {}

local function record(name, ...)
    calls[#calls + 1] = { name = name, args = { ... } }
end

local function lastCall(name)
    for index = #calls, 1, -1 do
        if calls[index].name == name then return calls[index] end
    end
    return nil
end

local function countCalls(name)
    local count = 0
    for index = 1, #calls do
        if calls[index].name == name then count = count + 1 end
    end
    return count
end

local failures = 0
local checks = 0

local function check(condition, label, detail)
    checks = checks + 1
    if condition then
        print("  ok   " .. label)
    else
        failures = failures + 1
        print("  FAIL " .. label .. (detail and ("  -> " .. tostring(detail)) or ""))
    end
end

-- ---------------------------------------------------------------- stubs

PsychopatzCore = { RuntimeRole = { AllowsServerCode = function() return true end } }

DTCommon = {
    MOD_ID = "DTCommon",
    DEFAULT_TRADER_NAME = "Caravan Trader",
    DEFAULT_TRADER_ROLE = "trader",
    DEFAULT_CARAVAN_ID = "debug_caravan",
    STATUS_READY = "READY",
}
DTHoomans = { MOD_ID = "DTHoomans" }

DTCommon.Storage = {
    IsAuthority = function() return true end,
    LoadInventory = function() return { maxWeight = 100, getWeight = function() return 5 end }, nil end,
    GetData = function() return { t = {} } end,
    SaveInventory = function() return true end,
}
DTCommon.TraderStock = {
    SnapshotItems = function() return {}, nil end,
    SaveAndTransmit = function() return true end,
}
DTCommon.TraderSupport = {
    Bounded = function(value, limit)
        return tostring(value or ""):sub(1, limit)
    end,
}

local affiliations = {
    npcGuardOne = "leader",
    npcMerchant = "trader",
    npcGuardTwo = "guard",
}
local npcRecords = {}
for npcID, _ in pairs(affiliations) do
    npcRecords[npcID] = {
        id = npcID,
        alive = true,
        presenceState = "live",
        name = npcID .. " CanonicalName",
        identity = { displayName = npcID .. " CanonicalName" },
        equipment = {},
        inventory = { items = {}, worn = {} },
    }
end

PNC = {
    Const = { PRESENCE_LIVE = "live" },
    FactionConstants = {
        ROLES = { "leader", "guard", "trader", "medic" },
        VALID_ROLES = { leader = true, guard = true, trader = true, medic = true },
        MOBILE_PATH_RANDOM = "random",
        MOBILE_CONTROL_STRATEGIC = "strategic",
    },
    Registry = {
        Get = function(npcID) return npcRecords[tostring(npcID)] end,
        GetLiveZombie = function() return nil end,
    },
    Identity = {
        GetCharacterSummary = function(record)
            return { displayName = record and record.identity and record.identity.displayName }
        end,
    },
    Inventory = {
        GetWeightState = function() return { usedWeight = 0, maxWeight = 80 } end,
    },
    API = {
        SetEquipmentSlot = function(...) record("SetEquipmentSlot", ...) return true end,
        Despawn = function(npcID) record("Despawn", npcID) return true end,
    },
    PopulationIdentity = {
        FactionName = function(archetypeID, seed)
            record("FactionName", archetypeID, seed)
            return "Northstar Trading Caravan"
        end,
        FactionTags = function(archetypeID, kind)
            record("FactionTags", archetypeID, kind)
            return { populationGenerated = true, mobileGroup = true, mobilePathMode = "random" }
        end,
    },
    FactionNameGenerator = {
        GenerateFactionName = function(archetypeID, seed)
            record("GenerateFactionName", archetypeID, seed)
            return "Fallback Generated Caravan"
        end,
    },
    Factions = {
        Create = function(spec) record("Factions.Create", spec) return true, "created", { id = "faction_test_1" } end,
        Get = function(factionID) return { id = factionID, archetypeID = "trader", memberIDs = { npcMerchant = true } } end,
        GetNPCAffiliation = function(npcID)
            local role = affiliations[tostring(npcID)]
            return role and { role = role, factionID = "faction_test_1" } or nil
        end,
        SetLeader = function(...) record("SetLeader", ...) return true, "leader_set" end,
        SetNPCRole = function(...) record("SetNPCRole", ...) return true, "role_set" end,
        RemoveNPC = function(...) record("RemoveNPC", ...) return true end,
        Destroy = function(...) record("Destroy", ...) return true end,
    },
    MobileGroupDirector = {
        GenerateForFaction = function(factionID, spec)
            record("GenerateForFaction", factionID, spec)
            -- Mirrors Project Hoomans: exactly `groupSize` members are created,
            -- and their roles are the requested role order.
            local count = math.max(1, math.floor(tonumber(spec.groupSize) or 3))
            -- Project Hoomans assigns the requested role order by spawn
            -- index: index 1 is the trader, the rest are guards.
            local base = { "npcMerchant", "npcGuardOne", "npcGuardTwo" }
            local ids = {}
            for index = 1, count do
                local npcID = base[index] or ("npcExtra_" .. tostring(index))
                ids[index] = npcID
                if not npcRecords[npcID] then
                    npcRecords[npcID] = {
                        id = npcID, alive = true, presenceState = "live",
                        name = npcID .. " CanonicalName",
                        identity = { displayName = npcID .. " CanonicalName" },
                        equipment = {}, inventory = { items = {}, worn = {} },
                    }
                end
                affiliations[npcID] = (spec.roleOrder and spec.roleOrder[index])
                    or (index == 1 and "trader" or "guard")
            end
            return true, "generated", {
                npcIDs = ids,
                createdCount = count,
                mobile = { controlMode = "strategic" },
                pathMode = "random",
            }
        end,
    },
    API_Conversations = {},
}

getGameTime = function() return { getWorldAgeHours = function() return 100 end } end
-- The roaming lifecycle places a caravan near a player and refuses to spawn
-- without one.
local harnessPlayer = {
    getX = function() return 1000 end,
    getY = function() return 2000 end,
    getZ = function() return 0 end,
}
function getPlayer() return harnessPlayer end

-- ------------------------------------------------- bridge under test

local Conversation = dofile(ROOT .. "/DTHoomans/42.20/media/lua/shared/DTHoomans/DTHoomans_Conversation.lua")
local Caravan = dofile(ROOT .. "/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua")

-- DTCommon.TraderService stub is needed by CaravanService, but the real shared
-- service is loaded afterwards to test the snapshot naming seam.
local traderRecords = {}
local function bindFaction(traderID, factionID, traderNPCID, memberNPCIDs)
    record("BindFaction", traderID, factionID, traderNPCID, memberNPCIDs)
    local entry = traderRecords[traderID] or {}
    entry.g = factionID
    entry.l = traderNPCID
    entry.p = traderNPCID
    entry.m = memberNPCIDs
    traderRecords[traderID] = entry
    return true, "bound"
end
DTCommon.TraderService = {
    Create = function(definition)
        record("Service.Create", definition)
        local entry = traderRecords[definition.traderID] or {}
        entry.definition = definition
        traderRecords[definition.traderID] = entry
        return definition.traderID, entry
    end,
    BindFaction = bindFaction,
    BindCaravan = bindFaction,
    Remove = function(traderID) record("Service.Remove", traderID) return true end,
    GetRecord = function(traderID) return traderRecords[traderID] end,
    Get = function(traderID)
        return { traderID = traderID, displayName = DTCommon.DEFAULT_TRADER_NAME }
    end,
}

-- reload CaravanService now that the DTCommon stub exists (load order parity)
package.loaded = package.loaded
Caravan = dofile(ROOT .. "/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanService.lua")

print("== 1. faction creation uses Project Hoomans naming and tags ==")
local request = Caravan.Spawn(100, 200, 0)
check(request and request.status == "spawned", "caravan spawns", request and request.reason)

local create = lastCall("Factions.Create")
check(create ~= nil, "Factions.Create called")
check(create and create.args[1].name == "Northstar Trading Caravan",
    "faction name comes from PNC.PopulationIdentity.FactionName",
    create and create.args[1].name)
check(create and create.args[1].archetypeID == "trader", "archetype stays trader")
local tags = create and create.args[1].tags or {}
check(tags.populationGenerated == true and tags.mobileGroup == true
    and tags.mobilePathMode == "random", "canonical population tags present")
check(tags.dynamicTrading == true, "DT ownership tag present")
check(tags.abstractDeathImmune == true,
    "roaming caravan is resilient to abstract death")
check(tags.debugCaravan == nil,
    "a lifecycle caravan is not marked as a debug caravan")
check(create and create.args[1].name ~= "Dynamic Trading Caravan", "hardcoded name removed")

local nameCall = lastCall("FactionName")
check(nameCall ~= nil, "PopulationIdentity.FactionName used (not the raw generator)")
check(nameCall and nameCall.args[1] == "trader", "generator asked for the trader pool",
    nameCall and nameCall.args[1])
check(nameCall and tostring(nameCall.args[2] or "") ~= "", "stable seed supplied",
    nameCall and nameCall.args[2])

print("== 2. generation record follows the Project Hoomans shape ==")
local generate = lastCall("GenerateForFaction")
local spec = generate and generate.args[2] or {}
local generation = spec.generation or {}
check(generation.source == "dynamic_trading", "source preserved")
check(generation.generationId == request.requestID, "generationId carries the request identity",
    generation.generationId)
check(tostring(generation.seed or "") ~= "", "canonical seed field present", generation.seed)
check(tonumber(generation.createdAt) == 100, "createdAt present", generation.createdAt)
check(generation.requestID == request.requestID, "DT requestID kept for diagnostics")

print("== 3. merchant selection follows the Project Hoomans affiliation ==")
check(lastCall("SetLeader") == nil,
    "no faction leader is assigned: the caravan roams without one")
check(spec.roleOrder ~= nil, "roaming role order requested")
check(spec.roleOrder and spec.roleOrder[1] == "trader"
    and spec.roleOrder[2] == "guard" and spec.roleOrder[3] == "guard",
    "role order is one trader followed by guards",
    spec.roleOrder and table.concat(spec.roleOrder, ","))
check(spec.assignLeader == false, "Project Hoomans is told to skip the leader")
local roles = {}
for index = 1, #calls do
    if calls[index].name == "SetNPCRole" then
        roles[calls[index].args[1]] = calls[index].args[2]
    end
end
check(roles.npcMerchant == "trader", "merchant role uses the Project Hoomans token", roles.npcMerchant)
check(roles.npcGuardOne == "guard" and roles.npcGuardTwo == "guard", "guards use the guard token")
for npcID, role in pairs(roles) do
    check(role ~= "merchant", "no DT-invented role token for " .. tostring(npcID), role)
end
check(countCalls("SetNPCRole") == 3, "three canonical role writes")

print("== 4. the trader record keeps trade state only ==")
local serviceCreate = lastCall("Service.Create")
check(serviceCreate and serviceCreate.args[1].displayName == nil,
    "no DynamicTrading display name written", serviceCreate and serviceCreate.args[1].displayName)
check(serviceCreate and serviceCreate.args[1].traderRole == nil,
    "no DynamicTrading role written", serviceCreate and serviceCreate.args[1].traderRole)
check(serviceCreate and serviceCreate.args[1].caravanID ~= nil, "caravan binding still written")

print("== 5. canonical name resolution ==")
check(Caravan.ResolveNPCName("npcMerchant") == "npcMerchant CanonicalName",
    "resolves the Project Hoomans identity name", Caravan.ResolveNPCName("npcMerchant"))
check(Caravan.ResolveNPCName("npcMissing") == nil, "unresolved ids return nil")
check(Caravan.ResolveTraderDisplayName({ p = "npcMerchant" }) == "npcMerchant CanonicalName",
    "trader record resolves through its live merchant")
check(Caravan.ResolveTraderDisplayName({ m = { "npcMerchant" } }) == "npcMerchant CanonicalName",
    "member list fallback works")

print("== 6. shared snapshot applies the canonical name ==")
local requireStub = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return { PriceContext = function() return {} end }
    end
    return { getWeight = function() return 0 end }
end
_G.require = requireStub
local Service = dofile(ROOT .. "/DTCommon/42.20/media/lua/shared/DTCommon/DTCommon_TraderService.lua")
local savedGetRecord = Service.GetRecord
local savedGet = Service.Get
Service.GetRecord = function() return { p = "npcMerchant" } end
Service.Get = function() return { traderID = "dt_1", displayName = DTCommon.DEFAULT_TRADER_NAME } end
local snapshot, reason = Service.Snapshot("dt_1")
check(snapshot ~= nil, "snapshot built", reason)
check(snapshot and snapshot.displayName == "npcMerchant CanonicalName",
    "snapshot carries the Project Hoomans name", snapshot and snapshot.displayName)
DTHoomans.Caravan = nil
local degraded = Service.Snapshot("dt_1")
check(degraded and degraded.displayName == DTCommon.DEFAULT_TRADER_NAME,
    "graceful fallback when the bridge is absent", degraded and degraded.displayName)
DTHoomans.Caravan = Caravan

print("== 7. conversation roles use the Project Hoomans tokens ==")
check(Conversation.RoleForNPC("npcMerchant") == "trader",
    "affiliation role wins for the merchant", Conversation.RoleForNPC("npcMerchant"))
check(Conversation.RoleForNPC("npcGuardTwo") == "guard",
    "affiliation role wins for the guard", Conversation.RoleForNPC("npcGuardTwo"))
check(Conversation.RoleForNPC("npcGuardOne") ~= "trader",
    "a guard is never misreported as the merchant",
    Conversation.RoleForNPC("npcGuardOne"))

local savedFactions = PNC.Factions
PNC.Factions = nil
DTHoomans.Client = {
    GetConversationTraderID = function(npcID)
        -- mirrors DT's client lookup: every caravan member maps to its trader
        return (npcID == "npcMerchant" or npcID == "npcGuardTwo") and "dt_1" or nil
    end,
    GetTraderLeaderID = function() return "npcMerchant" end,
}
check(Conversation.RoleForNPC("npcMerchant") == "trader",
    "client fallback still resolves the merchant", Conversation.RoleForNPC("npcMerchant"))
check(Conversation.RoleForNPC("npcGuardTwo") == "guard",
    "client fallback still resolves a guard", Conversation.RoleForNPC("npcGuardTwo"))
PNC.Factions = savedFactions

print("== 8. graceful degradation when Project Hoomans naming is unavailable ==")
local savedIdentity = PNC.PopulationIdentity
local savedGenerator = PNC.FactionNameGenerator
PNC.PopulationIdentity = nil
PNC.FactionNameGenerator = nil
local degradedRequest = Caravan.Spawn(300, 400, 0)
local degradedCreate = lastCall("Factions.Create")
check(degradedRequest and degradedRequest.status == "spawned",
    "caravan still spawns without the generator", degradedRequest and degradedRequest.reason)
check(degradedCreate and degradedCreate.args[1].name == "Trading Caravan",
    "literal fallback used only as last resort", degradedCreate and degradedCreate.args[1].name)
check(degradedCreate and degradedCreate.args[1].tags.mobileGroup == true
    and degradedCreate.args[1].tags.abstractDeathImmune == true,
    "DT ownership and resilience tags survive an absent PopulationIdentity")
PNC.PopulationIdentity = savedIdentity
PNC.FactionNameGenerator = savedGenerator

local savedFactionService = PNC.Factions
PNC.Factions = nil
local refused = Caravan.Spawn(500, 600, 0)
check(refused == nil, "spawn refuses when the faction service is absent")
PNC.Factions = savedFactionService

print("== 9. settlement trader binding ==")
Service.GetRecord = savedGetRecord
Service.Get = savedGet

-- Project Hoomans staffs the settlement; DynamicTrading only binds it.
local settlementMembers = {
    { npcID = "npcLeader", affiliation = { role = "leader" } },
    { npcID = "npcTrader", affiliation = { role = "trader" } },
    { npcID = "npcWorker", affiliation = { role = "worker" } },
}
local unstaffedMembers = {
    { npcID = "npcLeader", affiliation = { role = "leader" } },
    { npcID = "npcWorker", affiliation = { role = "worker" } },
}
local factionList = {
    {
        id = "faction_settle_1", archetypeID = "settler", status = "active",
        tags = { settlementType = "friendly" },
        memberIDs = { npcLeader = true, npcTrader = true, npcWorker = true },
    },
    {
        id = "faction_settle_2", archetypeID = "settler", status = "active",
        tags = {}, memberIDs = { npcLeader = true, npcWorker = true },
    },
    {
        id = "faction_caravan_1", archetypeID = "trader", status = "active",
        tags = { mobileGroup = true }, mobile = { active = true },
        memberIDs = { npcGuardOne = true, npcMerchant = true, npcGuardTwo = true },
    },
}
PNC.Factions.Get = function(factionID)
    for index = 1, #factionList do
        if factionList[index].id == factionID then return factionList[index] end
    end
    return nil
end
PNC.Factions.List = function() return factionList end
PNC.Factions.GetMembers = function(factionID)
    if factionID == "faction_settle_1" then return settlementMembers end
    if factionID == "faction_settle_2" then return unstaffedMembers end
    return {}
end
PNC.Factions.IsMobileGroup = function(faction)
    return type(faction) == "table"
        and type(faction.mobile) == "table"
        and faction.mobile.active == true
end
PNC.SettlementTraderStaffing = {
    TraderMember = function(factionID)
        if factionID == "faction_settle_1" then return "npcTrader" end
        return nil
    end,
}

local Settlement = dofile(
    ROOT .. "/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_SettlementTrader.lua")

local bound, bindReason = Settlement.EnsureTraderForFaction("faction_settle_1")
check(bound == true, "settlement trader bound", bindReason)
check(bindReason == "bound", "binding reason", bindReason)
local settlementCreate = lastCall("Service.Create")
check(settlementCreate and settlementCreate.args[1].traderID == "dt_faction_settle_1",
    "trader record keyed by the faction id",
    settlementCreate and settlementCreate.args[1].traderID)
check(settlementCreate and settlementCreate.args[1].abstractAccessEnabled == false,
    "a settlement trader is met in person, not by radio")
check(settlementCreate and settlementCreate.args[1].caravanID == "settlement_faction_settle_1",
    "the binding label marks a settlement",
    settlementCreate and settlementCreate.args[1].caravanID)
local bindCall = lastCall("BindFaction")
check(bindCall ~= nil, "BindFaction used for the settlement")
check(bindCall and bindCall.args[2] == "faction_settle_1", "bound to the faction")
check(bindCall and bindCall.args[3] == "npcTrader",
    "bound to the member Project Hoomans made the trader",
    bindCall and bindCall.args[3])
check(bindCall and #bindCall.args[4] == 3, "every member bound so guards can refer",
    bindCall and #bindCall.args[4])

local again, againReason = Settlement.EnsureTraderForFaction("faction_settle_1")
check(again == true and againReason == "already_bound", "rebinding is idempotent", againReason)

local noTrader, noTraderReason = Settlement.EnsureTraderForFaction("faction_settle_2")
check(noTrader == false and noTraderReason == "settlement_has_no_trader",
    "an unstaffed settlement is refused, never staffed by DynamicTrading", noTraderReason)

local mobile, mobileReason = Settlement.EnsureTraderForFaction("faction_caravan_1")
check(mobile == false and mobileReason == "mobile_group",
    "the caravan keeps its own spawn path", mobileReason)

local missing, missingReason = Settlement.EnsureTraderForFaction("faction_missing")
check(missing == false and missingReason == "faction_not_found",
    "unknown faction refused", missingReason)

local sweep = Settlement.EnsureBindings()
check(sweep.scanned == 3, "sweep scanned the registry", sweep.scanned)
check(sweep.bound == 0 and sweep.alreadyBound == 1, "sweep bound nothing new",
    sweep.bound .. "/" .. sweep.alreadyBound)
check(sweep.withoutTrader == 1, "sweep reported the unstaffed settlement",
    sweep.withoutTrader)
check(sweep.skipped == 1, "sweep skipped the mobile caravan", sweep.skipped)
check(sweep.failed == 0, "sweep had no failures", sweep.failed)
check(Settlement.TraderIDFor("faction_settle_9") == "dt_faction_settle_9",
    "trader id helper")

print("== 10. settlement stock is not capped by resident carry weight ==")
local settlementCapacity = Caravan.GetCapacity({ g = "faction_settle_1" })
check(settlementCapacity == nil,
    "settlement binding has no member-capacity ceiling", settlementCapacity)
local caravanCapacity = Caravan.GetCapacity({ g = "faction_caravan_1" })
check(caravanCapacity ~= nil, "caravan binding still sums member capacity")

print("== 11. sandbox option drives the caravan member count ==")
SandboxVars = { DTHoomans = { CaravanMemberCount = 5 } }
local sandboxRequest = Caravan.Spawn(700, 800, 0, nil, nil, { debug = true })
check(sandboxRequest and sandboxRequest.status == "spawned", "caravan spawns with the option",
    sandboxRequest and sandboxRequest.reason)
local sandboxSpec = lastCall("GenerateForFaction") and lastCall("GenerateForFaction").args[2] or {}
check(sandboxSpec.groupSize == 5, "sandbox member count is requested",
    sandboxSpec.groupSize)
check(sandboxSpec.roleOrder and #sandboxSpec.roleOrder == 5,
    "role order matches the member count", sandboxSpec.roleOrder and #sandboxSpec.roleOrder)
check(sandboxSpec.roleOrder and sandboxSpec.roleOrder[1] == "trader"
    and sandboxSpec.roleOrder[5] == "guard", "one trader then guards")
local debugTags = lastCall("Factions.Create").args[1].tags
check(debugTags.debugCaravan == true, "the debug request still marks a test caravan")
local debugRoles = 0
for index = 1, #calls do
    if calls[index].name == "SetNPCRole" then debugRoles = debugRoles + 1 end
end
check(debugRoles >= 5, "every requested member is role-configured", debugRoles)
SandboxVars = nil
local fallbackRequest = Caravan.Spawn(900, 1000, 0)
local fallbackSpec = lastCall("GenerateForFaction").args[2]
check(fallbackSpec.groupSize == 3,
    "without the sandbox table the documented default is used",
    fallbackSpec.groupSize)

print("== 12. roaming caravan lifecycle ==")
local Lifecycle = dofile(
    ROOT .. "/DTHoomans/42.20/media/lua/server/DTHoomans/DTHoomans_CaravanLifecycle.lua")
local roamingFactions = {
    { id = "faction_roam_1", archetypeID = "trader", status = "active",
      tags = { dynamicTrading = true, mobileGroup = true },
      mobile = { active = true }, memberIDs = {} },
    { id = "faction_settle_1", archetypeID = "settler", status = "active",
      tags = {}, memberIDs = {} },
}
PNC.Factions.List = function() return roamingFactions end
check(Lifecycle.CountRoaming() == 1, "one roaming caravan counted",
    Lifecycle.CountRoaming())
local filling = Lifecycle.Tick()
check(filling.roaming == 1, "one roaming caravan detected", filling.roaming)
check(filling.spawned == 1, "the lifecycle fills toward the cap", filling.skipped)

roamingFactions[2] = { id = "faction_roam_2", archetypeID = "trader",
    status = "active", tags = { dynamicTrading = true, mobileGroup = true },
    mobile = { active = true }, memberIDs = {} }
local atCapacity = Lifecycle.Tick()
check(atCapacity.spawned == 0, "a full world is not over-spawned", atCapacity.spawned)
check(atCapacity.skipped == "at_capacity", "cap reason reported", atCapacity.skipped)

roamingFactions[1] = nil
roamingFactions[2] = nil
local replaced = Lifecycle.Tick()
check(replaced.roaming == 0, "a lost caravan is detected", replaced.roaming)
check(replaced.spawned == 1, "a replacement caravan is raised", replaced.skipped)
check(Lifecycle.MAX_ROAMING_CARAVANS == 2, "the roaming cap is bounded")
check(type(Lifecycle.LastSummary()) == "table", "last summary is exposed")

print(string.format("\n%d checks, %d failures", checks, failures))
os.exit(failures == 0 and 0 or 1)
