DTCommon = DTCommon or {}

local Service = DTCommon.TraderService or {}
DTCommon.TraderService = Service

local Storage = DTCommon.Storage
local Stock = DTCommon.TraderStock
local Support = DTCommon.TraderSupport
local Policy = require "DTCommon/DTCommon_CoreActorPolicy"

local function canonicalRecord(record)
    if type(record) ~= "table" then return record end
    -- Old save aliases are accepted only by Policy.Normalize. All live
    -- callers see and subsequently persist the canonical actor/provider keys.
    record.ca = Policy.Normalize(record.ca)
    return record
end

function Service.ForEach(callback)
    if type(callback) ~= "function" then return false end
    local data = Storage.GetData()
    local id
    local record
    for id, record in pairs(data.t) do
        callback(tostring(id), canonicalRecord(record))
    end
    return true
end

function Service.GetRecord(traderID)
    traderID = Support.Bounded(traderID, 128)
    if traderID == "" then return nil end
    return canonicalRecord(Storage.GetData().t[traderID])
end

function Service.Get(traderID)
    local record = Service.GetRecord(traderID)
    if not record then return nil end
    return {
        traderID = Support.Bounded(traderID, 128),
        displayName = Support.Bounded(record.n, 96),
        traderRole = Support.Bounded(record.r, 48),
        caravanID = Support.Bounded(record.c, 96),
        status = Support.Bounded(record.s or DTCommon.STATUS_READY, 32),
        budget = math.max(0, math.floor(tonumber(record.b) or 0)),
        stockVersion = math.max(0, math.floor(tonumber(record.v) or 0)),
        physicalNpcID = record.p and Support.Bounded(record.p, 128) or nil,
        factionID = record.g and Support.Bounded(record.g, 192) or nil,
        leaderNPCID = record.l and Support.Bounded(record.l, 128) or nil,
        memberNPCIDs = type(record.m) == "table" and record.m or {},
        abstractAccessEnabled = record.a == 1,
        actorID = record.ca and record.ca.actorID or nil,
        actorAvailable = record.ca == nil
            or record.ca.available ~= false,
        provider = record.ca and record.ca.provider or nil,
        providerState = record.ca and record.ca.providerState or nil,
        providerLeaseID = record.ca and record.ca.providerLeaseID or nil,
        providerBodyID = record.ca and record.ca.providerBodyID or nil,
        homeSettlementID = record.ca and record.ca.homeSettlementID or nil,
        currentSettlementID = record.ca and record.ca.currentSettlementID or nil,
        lastSettlementID = record.ca and record.ca.lastSettlementID or nil,
    }
end

function Service.Create(definition)
    if not DTCommon.Storage.IsAuthority() then
        return nil, "server_authority_required"
    end
    definition = type(definition) == "table" and definition or {}
    local traderID = Support.Bounded(definition.traderID, 128)
    if traderID == "" then return nil, "trader_id_required" end
    local existing = Service.GetRecord(traderID)
    if existing then return traderID, existing end

    local record = {
        n = Support.Bounded(
            definition.displayName or DTCommon.DEFAULT_TRADER_NAME, 96),
        r = Support.Bounded(
            definition.traderRole or DTCommon.DEFAULT_TRADER_ROLE, 48),
        c = Support.Bounded(
            definition.caravanID or DTCommon.DEFAULT_CARAVAN_ID, 96),
        b = math.max(0, math.floor(tonumber(definition.budget) or 500)),
        s = Support.Bounded(
            definition.status or DTCommon.STATUS_READY, 32),
        v = 1,
        p = nil,
        g = nil,
        l = nil,
        m = {},
        a = definition.abstractAccessEnabled == false and 0 or 1,
        ca = Policy.New(definition.coreActor or definition),
    }
    local saved, reason = Storage.SaveInventory(record, Stock.New())
    if not saved then return nil, reason end
    Storage.GetData().t[traderID] = record
    Stock.SaveAndTransmit()
    return traderID, record
end

-- Remove a trader record when its external NPC/faction transaction cannot be
-- committed. The Project Hoomans faction remains the authoritative rollback
-- target; this only prevents an empty DT record from surviving a failure.
function Service.Remove(traderID)
    local data
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    traderID = Support.Bounded(traderID, 128)
    if traderID == "" then return false, "trader_id_required" end
    data = Storage.GetData()
    if not data.t[traderID] then return false, "trader_not_found" end
    data.t[traderID] = nil
    Stock.SaveAndTransmit()
    return true
end

function Service.BindPhysical(traderID, npcID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    record.p = Support.Bounded(npcID, 128)
    Stock.SaveAndTransmit()
    return true
end

function Service.ClearPhysical(traderID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    record.p = nil
    Stock.SaveAndTransmit()
    return true
end

-- Faction binding: the trader is a member of a Project Hoomans faction, and the
-- record keeps only compact ids beside the virtual-inventory envelope. The live
-- NPC records and faction registry remain authoritative; these fields only let
-- DTCommon reconnect the trader UI after a reload. The bound member is a
-- caravan's merchant or a settlement's trader - the shape is identical.
function Service.BindFaction(traderID, factionID, traderNPCID, memberNPCIDs)
    local record
    local members = {}
    local index
    local value
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    record.g = Support.Bounded(factionID, 192)
    record.l = Support.Bounded(traderNPCID, 128)
    record.p = record.l
    for index = 1, math.min(#(memberNPCIDs or {}), 24) do
        value = Support.Bounded(memberNPCIDs[index], 128)
        if value ~= "" then members[#members + 1] = value end
    end
    record.m = members
    Stock.SaveAndTransmit()
    return true
end

-- Bind the same canonical faction roster for a bodyless provider.  The
-- actor/group identity is shared with the physical provider, but `p` must
-- remain empty: DTAbstract may expose portraits and conversation participants
-- without materializing a Project Hoomans body.
function Service.BindActorGroup(traderID, factionID, leaderActorID, memberActorIDs)
    local record
    local members = {}
    local seen = {}
    local value
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    record.g = Support.Bounded(factionID, 192)
    record.l = Support.Bounded(leaderActorID, 128)
    record.p = nil
    for index = 1, math.min(#(memberActorIDs or {}), 24) do
        value = Support.Bounded(memberActorIDs[index], 128)
        if value ~= "" and not seen[value] then
            members[#members + 1] = value
            seen[value] = true
        end
    end
    if record.l ~= "" and not seen[record.l] then
        table.insert(members, 1, record.l)
    end
    record.m = members
    Stock.SaveAndTransmit()
    return true
end

-- Bind a resident trader to the canonical Hoomans community identity without
-- pretending that the trader commercially visited it. The service owns the
-- persisted merchant context, but does not provision or mutate a market here.
function Service.SetHomeSettlement(traderID, settlementID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    local previous = Policy.Get(record)
    local policy, reason = Policy.SetHomeSettlement(record, settlementID)
    if not policy then return false, reason end
    if previous.homeSettlementID ~= policy.homeSettlementID
        or previous.currentSettlementID ~= policy.currentSettlementID
    then
        Storage.Touch()
        Storage.Transmit()
    end
    return true, "home_context_bound", record
end

-- Shared by later Hoomans excursions: update pricing/location context without
-- changing commercial-visit history or stock.
function Service.SetCurrentSettlement(traderID, settlementID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    local previous = Policy.Get(record)
    local policy, reason = Policy.SetCurrentSettlement(record, settlementID)
    if not policy then return false, reason end
    if previous.currentSettlementID ~= policy.currentSettlementID then
        Storage.Touch()
        Storage.Transmit()
    end
    return true, "current_context_updated", record
end

function Service.SetDestinationSettlement(traderID, settlementID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    local previous = Policy.Get(record)
    local policy, reason = Policy.SetDestinationSettlement(record, settlementID)
    if not policy then return false, reason end
    if previous.destinationSettlementID ~= policy.destinationSettlementID then
        Storage.Touch()
        Storage.Transmit()
    end
    return true, "destination_context_updated", record
end

function Service.SetOriginSettlement(traderID, settlementID)
    if not DTCommon.Storage.IsAuthority() then
        return false, "server_authority_required"
    end
    local record = Service.GetRecord(traderID)
    if not record then return false, "trader_not_found" end
    local previous = Policy.Get(record)
    local policy, reason = Policy.SetOriginSettlement(record, settlementID)
    if not policy then return false, reason end
    if previous.originSettlementID ~= policy.originSettlementID then
        Storage.Touch()
        Storage.Transmit()
    end
    return true, "origin_context_updated", record
end

-- Compatibility alias: the caravan path binds a faction too.
Service.BindCaravan = Service.BindFaction

return Service
