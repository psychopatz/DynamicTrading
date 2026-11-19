-- Thin DynamicTrading bridge to PsychopatzCore's canonical actor lifecycle
-- and mark-and-sweep GC. DynamicTrading owns only commercial trader state and
-- active obligations; Core remains authoritative for actor identity, tombstones,
-- and GC orchestration.
DTCommon = DTCommon or {}

local Adapter = DTCommon.ActorLifecycle or {}
DTCommon.ActorLifecycle = Adapter

Adapter.PROVIDER_ID = "DynamicTrading.CommercialRoots"

local OBLIGATION_BUCKETS = { "obligations", "contracts", "debts" }
local OBLIGATION_REF_FIELDS = {
    "actorID",
    "actorId",
    "counterpartyID",
    "counterpartyRef",
    "targetRef",
    "targetKey",
    "obligorID",
    "creditorID",
    "debtorID",
    "counterparty",
}

local function safeRef(value)
    if type(value) ~= "string" and type(value) ~= "number" then return nil end
    local text = tostring(value)
    if text == "" or #text > 128 or string.find(text, "[%c]") then
        return nil
    end
    return text
end

local function isAuthority()
    if DTCommon and DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
    then
        return DTCommon.Storage.IsAuthority() == true
    end
    local runtime = PsychopatzCore and PsychopatzCore.RuntimeRole or nil
    if runtime and type(runtime.AllowsServerCode) == "function" then
        return runtime.AllowsServerCode() == true
    end
    local clientOnly = type(isClient) == "function" and isClient() == true
        and (type(isServer) ~= "function" or isServer() ~= true)
    return not clientOnly
end

local function worldAgeHours(options)
    if type(options) == "table" then
        if tonumber(options.retiredAt) ~= nil then
            return math.max(0, tonumber(options.retiredAt))
        end
        if tonumber(options.now) ~= nil then
            return math.max(0, tonumber(options.now))
        end
    end
    if type(getGameTime) == "function" then
        local gt = getGameTime()
        if gt and type(gt.getWorldAgeHours) == "function" then
            local hours = tonumber(gt:getWorldAgeHours())
            if hours and hours == hours then return math.max(0, hours) end
        end
    end
    return 0
end

local function sortedKeys(tbl)
    local keys = {}
    for key in pairs(type(tbl) == "table" and tbl or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    return keys
end

local function resolveCoreRegistry(options)
    if type(options) == "table" and options.registry then
        return options.registry
    end
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    return actors and actors.DefaultRegistry or nil
end

local function resolveActorsModule()
    return PsychopatzCore and PsychopatzCore.Actors or nil
end

local function resolveService()
    return DTCommon and DTCommon.TraderService or nil
end

local function resolvePolicy()
    return DTCommon and DTCommon.CoreActorPolicy or nil
end

local function resolveStorage()
    return DTCommon and DTCommon.Storage or nil
end

local function resolveWorldKnowledge(options)
    if type(options) == "table" and type(options.worldKnowledge) == "table" then
        return options.worldKnowledge
    end
    if PsychopatzCore and type(PsychopatzCore.WorldKnowledge) == "table" then
        return PsychopatzCore.WorldKnowledge
    end
    local ok, mod = pcall(
        require, "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"
    )
    if ok and type(mod) == "table" then return mod end
    return nil
end

local function touchAndTransmit()
    local storage = resolveStorage()
    if not storage then return end
    if type(storage.Touch) == "function" then storage.Touch() end
    if type(storage.Transmit) == "function" then storage.Transmit() end
end

local function buildMatchSet(ref, tombstone, extraAliases)
    local set = {}
    local function add(value)
        local text = safeRef(value)
        if not text then return end
        set[text] = true
        if string.sub(text, 1, 4) == "npc:" then
            set[string.sub(text, 5)] = true
        elseif string.sub(text, 1, 6) == "actor:" then
            set[string.sub(text, 7)] = true
            set["npc:" .. text] = true
        else
            set["npc:" .. text] = true
            set["actor:" .. text] = true
        end
    end
    add(ref)
    if type(tombstone) == "table" then
        add(tombstone.ref)
        for _, alias in ipairs(tombstone.aliases or {}) do
            add(alias)
        end
    end
    if type(extraAliases) == "table" then
        for _, alias in ipairs(extraAliases) do
            add(alias)
        end
    end
    return set
end

local function iterTradersSorted()
    local byID = {}
    local service = resolveService()
    local storage = resolveStorage()
    if service and type(service.ForEach) == "function" then
        service.ForEach(function(traderID, record)
            local key = safeRef(traderID)
            if key and type(record) == "table" then
                byID[key] = record
            end
        end)
    elseif storage and type(storage.GetData) == "function" then
        local data = storage.GetData()
        for traderID, record in pairs((type(data) == "table" and data.t) or {}) do
            local key = safeRef(traderID)
            if key and type(record) == "table" then
                byID[key] = record
            end
        end
    end
    local ordered = {}
    for _, key in ipairs(sortedKeys(byID)) do
        ordered[#ordered + 1] = { traderID = key, record = byID[key] }
    end
    return ordered
end

local function isEntryActive(entry)
    if type(entry) ~= "table" then return false end
    if entry.active == true then return true end
    local status = type(entry.status) == "string" and string.lower(entry.status) or nil
    return status == "active" or status == "open"
end

local function collectEntryRefs(entry, seen, out)
    for index = 1, #OBLIGATION_REF_FIELDS do
        local candidate = safeRef(entry[OBLIGATION_REF_FIELDS[index]])
        if candidate and not seen[candidate] then
            seen[candidate] = true
            out[#out + 1] = candidate
        end
    end
end

function Adapter.HasActiveObligations(record, traderID)
    local seen = {}
    local refs = {}
    local foundActive = false
    local primaryActorID = type(record) == "table"
        and type(record.ca) == "table"
        and safeRef(record.ca.actorID)
        or nil

    local function scanContainer(container, filterTraderID, defaultActorID)
        if type(container) ~= "table" then return end
        for _, key in ipairs(sortedKeys(container)) do
            local entry = container[key]
            if isEntryActive(entry) then
                local entryTrader = safeRef(entry.traderID or entry.traderId)
                local matchesTrader = filterTraderID == nil
                    or entryTrader == nil
                    or entryTrader == safeRef(filterTraderID)
                if matchesTrader then
                    foundActive = true
                    collectEntryRefs(entry, seen, refs)
                    if defaultActorID and not seen[defaultActorID] then
                        seen[defaultActorID] = true
                        refs[#refs + 1] = defaultActorID
                    end
                end
            end
        end
    end

    if type(record) == "table" then
        for index = 1, #OBLIGATION_BUCKETS do
            scanContainer(record[OBLIGATION_BUCKETS[index]], nil, primaryActorID)
        end
    end

    local storage = resolveStorage()
    local data = storage and type(storage.GetData) == "function"
        and storage.GetData() or nil
    if type(data) == "table" then
        for index = 1, #OBLIGATION_BUCKETS do
            scanContainer(
                data[OBLIGATION_BUCKETS[index]],
                traderID,
                traderID ~= nil and primaryActorID or nil
            )
        end
    end

    table.sort(refs)
    return foundActive, refs
end

function Adapter.ClearDeadWorldKnowledge(actorID, aliases, options)
    local wkg = resolveWorldKnowledge(options)
    if type(wkg) ~= "table" or type(wkg.KnowledgeState) ~= "table" then
        return 0
    end
    local byActor = wkg.KnowledgeState.byActor
    if type(byActor) ~= "table" then return 0 end

    local matchSet = buildMatchSet(actorID, options and options.tombstone, aliases)
    local cleared = 0
    for _, key in ipairs(sortedKeys(byActor)) do
        if matchSet[tostring(key)] then
            byActor[key] = nil
            cleared = cleared + 1
        end
    end

    local runtime = wkg.KnowledgeState.runtime
    if type(runtime) == "table" and type(runtime.cooldowns) == "table" then
        for _, key in ipairs(sortedKeys(runtime.cooldowns)) do
            if matchSet[tostring(key)] then
                runtime.cooldowns[key] = nil
            end
        end
    end
    return cleared
end

local function isPrimaryMatch(record, matchSet)
    if type(record) ~= "table" then return false end
    local ca = type(record.ca) == "table" and record.ca or nil
    local candidates = {
        ca and safeRef(ca.actorID),
        safeRef(record.l),
        safeRef(record.p),
    }
    for index = 1, 3 do
        if candidates[index] and matchSet[candidates[index]] then
            return true
        end
    end
    return false
end

local function scrubMemberList(record, matchSet)
    if type(record) ~= "table" or type(record.m) ~= "table" then
        return 0
    end
    local kept = {}
    local removed = 0
    for index = 1, #record.m do
        local memberID = safeRef(record.m[index])
        if memberID and matchSet[memberID] then
            removed = removed + 1
        elseif memberID then
            kept[#kept + 1] = record.m[index]
        end
    end
    if removed > 0 then
        record.m = kept
    end
    return removed
end

local function markRecordRetired(record, at)
    local policy = resolvePolicy()
    if policy and type(policy.SetAvailable) == "function" then
        policy.SetAvailable(record, false, "actor_retired")
    else
        record.ca = type(record.ca) == "table" and record.ca or {}
        record.ca.available = false
        record.ca.availabilityReason = "actor_retired"
    end
    record.s = (DTCommon and DTCommon.STATUS_AWAY) or "AWAY"
    record.ca = type(record.ca) == "table" and record.ca or {}
    record.ca.providerState = "released"
    record.ca.lifecycleState = "retired"
    record.ca.journeyID = nil
    record.ca.journeyState = nil
    record.ca.retiredAt = at
end

local function releaseLiveLeaseForRetirement(traderID, record, actorID, reg, at)
    if DTAbstract and DTAbstract.TraderWorldProvider
        and type(DTAbstract.TraderWorldProvider.releaseTrader) == "function"
        and record and traderID
    then
        pcall(DTAbstract.TraderWorldProvider.releaseTrader, traderID, record, at)
    end

    local actor = reg and type(reg.Get) == "function" and reg:Get(actorID) or nil
    local actorsMod = resolveActorsModule()
    if actor and type(actor.providerLease) == "table"
        and actor.providerLease.state ~= "released"
        and actorsMod and type(actorsMod.Provider) == "table"
        and type(actorsMod.Provider.Release) == "function"
    then
        local released = actorsMod.Provider.Release(actor, {
            authority = "server",
            owner = actor.providerLease.owner,
            now = at,
            force = true,
        })
        if released and released.providerLease and type(reg.Commit) == "function" then
            reg:Commit(actor.actorId or actorID, {
                providerLease = released.providerLease,
            }, actor.revision)
        end
    end

    if PNC and PNC.Registry and type(PNC.Registry.Get) == "function"
        and type(PNC.Registry.RemoveRecord) == "function"
    then
        local pncRec = PNC.Registry.Get(actorID)
        if type(pncRec) == "table" and type(pncRec.runtime) == "table"
            and pncRec.runtime.dtProviderProjection == true
        then
            PNC.Registry.RemoveRecord(actorID)
        end
    end
    return actor
end

function Adapter.OnActorRetired(actorID, options)
    if not isAuthority() then return false, "server_authority_required" end
    options = type(options) == "table" and options or {}
    local targetActorID = safeRef(actorID)
    if not targetActorID then return false, "core_actor_required" end

    local at = worldAgeHours(options)
    Adapter.ClearDeadWorldKnowledge(targetActorID, options.aliases, options)

    local service = resolveService()
    local matchSet = buildMatchSet(targetActorID, options.tombstone, options.aliases)
    local targetTrader = safeRef(options.traderID)
    local toRemove = {}
    local updated = 0
    local removed = 0
    local scrubbedMembers = 0
    local touched = false

    for _, item in ipairs(iterTradersSorted()) do
        local traderID = item.traderID
        local record = item.record
        local matchesPrimary = (targetTrader ~= nil and traderID == targetTrader)
            or (targetTrader == nil and isPrimaryMatch(record, matchSet))

        if matchesPrimary then
            local hasObligation = Adapter.HasActiveObligations(record, traderID)
            markRecordRetired(record, at)
            if options.removeCommercialRecord == true
                and not hasObligation
                and service and type(service.Remove) == "function"
            then
                toRemove[#toRemove + 1] = traderID
            else
                updated = updated + 1
                touched = true
            end
        else
            local scrubbed = scrubMemberList(record, matchSet)
            if scrubbed > 0 then
                scrubbedMembers = scrubbedMembers + scrubbed
                touched = true
            end
        end
    end

    for index = 1, #toRemove do
        local ok = service.Remove(toRemove[index])
        if ok then removed = removed + 1 end
    end

    if touched then touchAndTransmit() end
    return true, {
        updated = updated,
        removed = removed,
        scrubbedMembers = scrubbedMembers,
    }
end

function Adapter.RetireTraderActor(traderIDOrActorID, options)
    if not isAuthority() then return nil, "server_authority_required" end
    options = type(options) == "table" and options or {}

    local reg = resolveCoreRegistry(options)
    if not reg or type(reg.Retire) ~= "function" then
        return nil, "core_registry_unavailable"
    end

    local service = resolveService()
    local key = safeRef(traderIDOrActorID)
    if not key then return nil, "trader_or_actor_required" end

    local traderID = nil
    local record = nil
    if service and type(service.GetRecord) == "function" then
        record = service.GetRecord(key)
        if record then traderID = key end
    end

    local actorID = safeRef(options.actorID)
        or (record and type(record.ca) == "table" and safeRef(record.ca.actorID))
        or (record and safeRef(record.p or record.l))
        or (not record and key)
        or nil
    if not actorID then return nil, "core_actor_required" end

    if not record then
        local matchSet = buildMatchSet(actorID, nil, options.aliases)
        for _, item in ipairs(iterTradersSorted()) do
            if isPrimaryMatch(item.record, matchSet) then
                traderID = item.traderID
                record = item.record
                break
            end
        end
    end

    local at = worldAgeHours(options)
    local actor = releaseLiveLeaseForRetirement(traderID, record, actorID, reg, at)
    local identity = type(actor) == "table" and type(actor.identity) == "table"
        and actor.identity or nil

    local tombstone, retireErr = reg:Retire(actorID, {
        authority = "server",
        reason = options.reason or "death",
        retiredAt = at,
        graceHours = options.graceHours,
        label = options.label
            or (record and record.n)
            or (identity and identity.displayName),
        owner = options.owner or "DynamicTrading",
        role = options.role
            or (record and record.r)
            or (identity and identity.role),
        aliases = options.aliases,
        allowAlreadyRetired = options.allowAlreadyRetired ~= false,
        expectedLifecycleRevision = options.expectedLifecycleRevision,
        adoptUnissued = options.adoptUnissued,
    })
    if not tombstone then return nil, retireErr or "core_retire_failed" end

    local _, reconcileResult = Adapter.OnActorRetired(actorID, {
        traderID = traderID,
        aliases = tombstone.aliases or options.aliases,
        tombstone = tombstone,
        worldKnowledge = options.worldKnowledge,
        removeCommercialRecord = options.keepCommercialRecord ~= true,
        now = at,
    })
    return tombstone, reconcileResult
end

local function collectStrongRefs(_, emit)
    local seen = {}
    local function emitUnique(ref, reason, detail)
        if not safeRef(ref) or seen[ref] then return end
        seen[ref] = true
        emit(ref, reason, detail)
    end

    for _, item in ipairs(iterTradersSorted()) do
        local hasActive, refs = Adapter.HasActiveObligations(
            item.record, item.traderID
        )
        if hasActive then
            for index = 1, #refs do
                emitUnique(refs[index], "dt_active_obligation", {
                    traderID = item.traderID,
                })
            end
        end
    end

    local storage = resolveStorage()
    local data = storage and type(storage.GetData) == "function"
        and storage.GetData() or nil
    if type(data) == "table" then
        for bucketIdx = 1, #OBLIGATION_BUCKETS do
            local bucket = data[OBLIGATION_BUCKETS[bucketIdx]]
            if type(bucket) == "table" then
                for _, key in ipairs(sortedKeys(bucket)) do
                    local entry = bucket[key]
                    if isEntryActive(entry) then
                        local refs = {}
                        local localSeen = {}
                        collectEntryRefs(entry, localSeen, refs)
                        for index = 1, #refs do
                            emitUnique(refs[index], "dt_active_obligation", {
                                bucket = OBLIGATION_BUCKETS[bucketIdx],
                            })
                        end
                    end
                end
            end
        end
    end

    return true
end

local function collectWeakRefs(ctx, emit)
    local reg = ctx and ctx.registry or nil
    local function isRetired(id)
        if not safeRef(id) then return false end
        if reg and type(reg.GetLifecycleState) == "function" then
            return reg:GetLifecycleState(id) == "RETIRED"
        end
        return false
    end

    for _, item in ipairs(iterTradersSorted()) do
        local record = item.record
        local ca = type(record.ca) == "table" and record.ca or {}
        local primaryID = safeRef(ca.actorID or record.l or record.p)
        if primaryID and (isRetired(primaryID) or ca.availabilityReason == "actor_retired") then
            emit(primaryID, "dt_retired_trader_record", {
                traderID = item.traderID,
            })
        end
        for index = 1, #(record.m or {}) do
            local memberID = safeRef(record.m[index])
            if memberID and isRetired(memberID) then
                emit(memberID, "dt_retired_member_ref", {
                    traderID = item.traderID,
                })
            end
        end
    end

    return true
end

local function isOwnedActive(ref, ctx)
    local reg = ctx and ctx.registry or nil
    local tombstone = reg and type(reg.tombstones) == "table"
        and reg.tombstones[ref] or nil
    local matchSet = buildMatchSet(ref, tombstone)

    for _, item in ipairs(iterTradersSorted()) do
        local record = item.record
        if isPrimaryMatch(record, matchSet) then
            local ca = type(record.ca) == "table" and record.ca or nil
            if ca and ca.available ~= false
                and ca.availabilityReason ~= "actor_retired"
                and (ca.providerState == "materialized" or ca.lifecycleState == "traveling")
            then
                return true, "dt_active_trader_lease"
            end
        end
    end

    return false
end

local function onBeforePurge(ref, ctx)
    local tombstone = ctx and ctx.tombstone or nil
    local matchSet = buildMatchSet(ref, tombstone)
    local compacted = Adapter.ClearDeadWorldKnowledge(
        ref,
        tombstone and tombstone.aliases or nil,
        ctx
    )

    local service = resolveService()
    local toRemove = {}
    local touched = false

    for _, item in ipairs(iterTradersSorted()) do
        local traderID = item.traderID
        local record = item.record
        if isPrimaryMatch(record, matchSet) then
            if not Adapter.HasActiveObligations(record, traderID)
                and service and type(service.Remove) == "function"
            then
                toRemove[#toRemove + 1] = traderID
            end
        else
            local scrubbed = scrubMemberList(record, matchSet)
            if scrubbed > 0 then
                compacted = compacted + scrubbed
                touched = true
            end
        end
    end

    for index = 1, #toRemove do
        if service.Remove(toRemove[index]) then
            compacted = compacted + 1
        end
    end

    if touched then touchAndTransmit() end
    return true, compacted
end

function Adapter.RegisterGCProvider(gc)
    if not isAuthority() then return false, "server_authority_required" end
    local targetGC = gc or (PsychopatzCore and PsychopatzCore.Actors and PsychopatzCore.Actors.GC)
    if not targetGC or type(targetGC.RegisterReferenceProvider) ~= "function" then
        return false, "core_gc_unavailable"
    end
    return targetGC.RegisterReferenceProvider(Adapter.PROVIDER_ID, {
        owner = "DynamicTrading",
        maxRefs = 2048,
        CollectStrongRefs = collectStrongRefs,
        CollectWeakRefs = collectWeakRefs,
        IsOwnedActive = isOwnedActive,
        OnBeforePurge = onBeforePurge,
    })
end

Adapter.RegisterGCProvider()

local function registerHook()
    if isAuthority() then Adapter.RegisterGCProvider() end
end

if Events and Events.OnInitGlobalModData
    and type(Events.OnInitGlobalModData.Add) == "function"
    and not Adapter._gcInitHookRegistered
then
    Adapter._gcInitHookRegistered = true
    Events.OnInitGlobalModData.Add(registerHook)
end

if Events and Events.OnServerStarted
    and type(Events.OnServerStarted.Add) == "function"
    and not Adapter._gcServerHookRegistered
then
    Adapter._gcServerHookRegistered = true
    Events.OnServerStarted.Add(registerHook)
end

return Adapter
