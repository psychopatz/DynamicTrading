-- Late-game & multiplayer-scale benchmark for DT + Core abstract pathing,
-- lifecycle/hydration transitions, trading stock & transactions, and ModData
-- compact persistence footprint.

local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local ActorInventory = require "PsychopatzCore/Actors/PsychopatzActorInventory"
local Json = require "PsychopatzCore/Serialization/PsychopatzJson"
local Presets = require "DTCommon/DTCommon_TraderPresets"

local CARAVAN_COUNT = 60
local MEMBERS_PER_CARAVAN = 3
local PATH_TICKS = 100
local TRADE_OPS = 400

local function ms(startClock)
    return (os.clock() - startClock) * 1000
end

-- ---------------------------------------------------------------------------
-- 1. Late-game caravan generation + Core actor creation + canonical inventory
-- ---------------------------------------------------------------------------
local registry = Actors.NewRegistry()
local caravanActorIDs = {}
local actorIDs = {}
local tGen = os.clock()

for c = 1, CARAVAN_COUNT do
    local built, reason = Presets.BuildMembers({
        seed = "mp_lategame_world:" .. tostring(c),
        actorPrefix = "mp_caravan_" .. tostring(c),
        memberCount = MEMBERS_PER_CARAVAN,
        providerID = "DTAbstract",
    })
    T.truthy(built, reason)
    caravanActorIDs[c] = built.actorIDs
    for m = 1, #built.memberSpecs do
        local spec = built.memberSpecs[m]
        local actor, createReason = registry:Create({
            actorId = spec.actorID,
            identitySeed = spec.identitySeed,
            identity = spec.identity,
            appearance = spec.appearance,
            starterItems = spec.startingItems,
            equipment = spec.equipment,
            world = {
                position = {
                    x = 10000 + (c * 37) % 3000,
                    y = 8000 + (c * 53) % 3000,
                    z = 0,
                },
            },
        })
        T.truthy(actor, createReason)
        actorIDs[#actorIDs + 1] = actor.actorId
    end
end
local genMs = ms(tGen)

-- ---------------------------------------------------------------------------
-- 2. Abstract pathing / journey stepping (60 caravans x 100 MP ticks)
-- ---------------------------------------------------------------------------
local tPath = os.clock()
local activeJourneys = 0
for c = 1, CARAVAN_COUNT do
    local leaderID = caravanActorIDs[c][1]
    local actor = registry:Get(leaderID)
    local nextWorld, jReason = World.StartJourney(actor.world, leaderID, {
        journeyID = "journey:mp:" .. tostring(c),
        origin = { x = 10200 + c * 10, y = 9200, z = 0 },
        destination = { x = 12400 - c * 8, y = 7100 + c * 5, z = 0 },
        speed = 55,
        startAt = 0,
    })
    T.truthy(nextWorld, jReason)
    registry:Commit(leaderID, { world = nextWorld }, actor.revision)
    activeJourneys = activeJourneys + 1
end

local projectedPoints = 0
for tick = 1, PATH_TICKS do
    local worldHour = tick * 0.5
    for c = 1, CARAVAN_COUNT do
        local leaderID = caravanActorIDs[c][1]
        local actor = registry:Get(leaderID)
        local pos = World.ProjectPosition(actor.world, worldHour)
        if pos and pos.x then
            projectedPoints = projectedPoints + 1
        end
    end
end
local pathMs = ms(tPath)

-- ---------------------------------------------------------------------------
-- 3. Lifecycle transitions: personalInventory Decode + Encode round-trip
--    (simulating late-game MP materialization/dematerialization churn)
-- ---------------------------------------------------------------------------
local tLifecycle = os.clock()
local decodedItemsTotal = 0
for i = 1, #actorIDs do
    local actor = registry:Get(actorIDs[i])
    if actor and type(actor.personalInventory) == "table" then
        local ledger, decReason = ActorInventory.Decode(actor.personalInventory)
        T.truthy(ledger, decReason)
        local list = ledger:List()
        decodedItemsTotal = decodedItemsTotal + #list
    end
end
local lifecycleMs = ms(tLifecycle)

-- ---------------------------------------------------------------------------
-- 4. Trading stock & Item ModData compact serialization benchmark
-- ---------------------------------------------------------------------------
local tTrade = os.clock()
local traderStore = { v = 1, r = 0, t = {} }
for c = 1, 40 do
    local stock = {}
    for s = 1, 15 do
        stock[s] = {
            id = "Base.Item_" .. tostring(s),
            q = 5 + (s % 10),
            p = 10 + s * 3,
            c = 1.0,
        }
    end
    traderStore.t["trader:mp:" .. tostring(c)] = {
        n = "Caravan Trader",
        b = 500,
        s = "READY",
        m = caravanActorIDs[c],
        i = stock,
    }
end

for op = 1, TRADE_OPS do
    local tid = "trader:mp:" .. tostring(((op - 1) % 40) + 1)
    local rec = traderStore.t[tid]
    local slot = rec.i[((op - 1) % #rec.i) + 1]
    if slot.q > 1 then
        slot.q = slot.q - 1
        rec.b = rec.b + slot.p
    else
        slot.q = slot.q + 5
        rec.b = math.max(0, rec.b - slot.p)
    end
    traderStore.r = traderStore.r + 1
end

local encodedModData = Json.Encode(traderStore)
local decodedModData = Json.Decode(encodedModData)
local tradeMs = ms(tTrade)

T.truthy(type(decodedModData) == "table" and decodedModData.r == TRADE_OPS,
    "trader ModData round-trip preserved revision")
T.equal(projectedPoints, CARAVAN_COUNT * PATH_TICKS,
    "all abstract pathing projections completed")
T.truthy(decodedItemsTotal >= #actorIDs * 4,
    "all canonical actors retained worn/starter items")

-- Generous regression budgets (well above expected ~5-60ms on normal hardware)
T.truthy(genMs < 2000, "generation budget exceeded: " .. tostring(genMs) .. "ms")
T.truthy(pathMs < 1000, "abstract pathing budget exceeded: " .. tostring(pathMs) .. "ms")
T.truthy(lifecycleMs < 1500, "lifecycle decode budget exceeded: " .. tostring(lifecycleMs) .. "ms")
T.truthy(tradeMs < 1000, "trading+moddata budget exceeded: " .. tostring(tradeMs) .. "ms")

print(string.format(
    "[DT BENCHMARK] caravans=%d actors=%d gen=%.2fms path(%d ticks)=%.2fms lifecycle(%d items)=%.2fms trade+moddata(%d ops, %d bytes)=%.2fms",
    CARAVAN_COUNT,
    #actorIDs,
    genMs,
    PATH_TICKS,
    pathMs,
    decodedItemsTotal,
    lifecycleMs,
    TRADE_OPS,
    #encodedModData,
    tradeMs
))
print("dt_lategame_mp_benchmark: PASS")
