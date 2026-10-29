if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- Settlement trade binding.
--
-- Project Hoomans owns settlement staffing: a settler/refugee settlement is
-- generated with one member holding the `trader` role (see
-- PNC.CommunityDirector, and PNC.SettlementTraderStaffing for pre-existing
-- worlds). DynamicTrading never creates settlement NPCs and never assigns their
-- roles; it only binds a trader record to whichever member Project Hoomans made
-- the trader, so the existing trade UI, conversation gate and stock contract
-- work unchanged.

DTHoomans = DTHoomans or {}
DTHoomans.Settlement = DTHoomans.Settlement or {}

local Settlement = DTHoomans.Settlement
local Service = DTCommon and DTCommon.TraderService

local TRADER_ROLE = "trader"
local TRADER_ID_PREFIX = "dt_"
local SETTLEMENT_BINDING_PREFIX = "settlement_"
local MAX_BOUND_MEMBERS = 24
-- Bounded work for the periodic pass. A world with many settlements is bound
-- across several passes instead of in one long server tick.
local MAX_BINDINGS_PER_PASS = 16
-- Low-frequency sweep so a settlement generated mid-session becomes tradeable
-- without a restart. The pass is one registry scan and exits early when every
-- eligible faction is already bound.
local SWEEP_INTERVAL_HOURS = 0.5

local nextSweepAt

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function authority()
    return DTCommon and DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

-- The settlement trader as Project Hoomans staffed it. Prefer Project Hoomans'
-- own query; fall back to reading affiliation roles so the bridge still works
-- against a world whose staffing service is older or absent.
local function traderMember(factionID)
    local staffing = PNC and PNC.SettlementTraderStaffing or nil
    local factions = PNC and PNC.Factions or nil
    local members
    local index
    local affiliation
    local npcID
    if staffing and type(staffing.TraderMember) == "function" then
        npcID = staffing.TraderMember(factionID)
        npcID = npcID and tostring(npcID) or ""
        if npcID ~= "" then return npcID end
    end
    if not factions or type(factions.GetMembers) ~= "function" then
        return nil
    end
    members = factions.GetMembers(factionID)
    for index = 1, #(type(members) == "table" and members or {}) do
        affiliation = members[index].affiliation
        if affiliation and tostring(affiliation.role or "") == TRADER_ROLE then
            return tostring(members[index].npcID)
        end
    end
    return nil
end

local function boundMemberIDs(factionID)
    local factions = PNC and PNC.Factions or nil
    local members
    local output = {}
    local index
    if not factions or type(factions.GetMembers) ~= "function" then
        return output
    end
    members = factions.GetMembers(factionID)
    for index = 1, #(type(members) == "table" and members or {}) do
        if #output >= MAX_BOUND_MEMBERS then break end
        output[#output + 1] = tostring(members[index].npcID)
    end
    return output
end

local function isMobileGroup(faction)
    local factions = PNC and PNC.Factions or nil
    if type(factions) == "table"
        and type(factions.IsMobileGroup) == "function"
    then
        return factions.IsMobileGroup(faction) == true
    end
    return type(faction.tags) == "table"
        and faction.tags.mobileGroup == true
end

-- Project Hoomans owns the settlement identity. Resolve the active community
-- through its public faction index rather than inventing a DT settlement key
-- from the faction id. The query is already bounded and sorted by Hoomans.
local function activeCommunityForFaction(factionID)
    local communities = PNC and PNC.Communities or nil
    local values
    if not communities or type(communities.GetForFaction) ~= "function" then
        return nil, "settlement_identity_unavailable"
    end
    values = communities.GetForFaction(factionID)
    for index = 1, #(type(values) == "table" and values or {}) do
        local community = values[index]
        if type(community) == "table"
            and community.status == "active"
            and tostring(community.factionID or "") == tostring(factionID)
            and tostring(community.id or "") ~= ""
        then
            return community
        end
    end
    return nil, "settlement_not_found"
end

-- Provisioning is deliberately separate from a commercial visit. This path
-- runs when Hoomans has staffed a resident trader, so a first quote has a
-- local market context even if no mobile trader has ever arrived.
local function ensureResidentMarket(factionID)
    local communities = PNC and PNC.Communities or nil
    local provision = Settlement.ProvisionMarket
    local community
    local reason
    local market
    -- Older bridge-only harnesses may load this binding module without the
    -- Hoomans community service or the settlement market adapter. Production
    -- Hoomans loads both; retain the binding-only compatibility surface when
    -- those optional services are absent.
    if not communities or type(communities.GetForFaction) ~= "function"
        or type(Service.SetHomeSettlement) ~= "function"
        or type(provision) ~= "function"
    then
        return true, "context_service_unavailable", nil
    end
    community, reason = activeCommunityForFaction(factionID)
    if not community then return false, reason, nil end
    market, reason = provision(community)
    if not market then
        return false, reason or "market_provision_failed", nil
    end
    return true, "market_provisioned", community
end

local function bindResidentContext(traderID, community)
    if not community or type(Service.SetHomeSettlement) ~= "function" then
        return true, "context_service_unavailable"
    end
    local bound, reason = Service.SetHomeSettlement(traderID, community.id)
    if not bound then return false, reason or "home_context_failed" end
    return true, "home_context_bound"
end

Settlement.TRADER_ROLE = TRADER_ROLE
Settlement.SWEEP_INTERVAL_HOURS = SWEEP_INTERVAL_HOURS
Settlement.MAX_BINDINGS_PER_PASS = MAX_BINDINGS_PER_PASS

function Settlement.TraderIDFor(factionID)
    if factionID == nil or tostring(factionID) == "" then return nil end
    return TRADER_ID_PREFIX .. tostring(factionID)
end

Settlement.ActiveCommunityForFaction = activeCommunityForFaction

-- Bind a trader record to an existing settlement faction. Returns
-- ok, reason where reason is one of:
--   "bound", "rebound", "already_bound", "settlement_has_no_trader",
--   "mobile_group" (the caravan path owns it), "faction_not_found",
--   "faction_not_active", "not_authority", "trader_service_unavailable",
--   "trader_record_failed", "binding_failed".
function Settlement.EnsureTraderForFaction(factionID)
    local factions = PNC and PNC.Factions or nil
    local faction
    local npcID
    local traderID
    local record
    local members
    local bound
    local reason
    local existing
    if not authority() then return false, "not_authority" end
    if not Service or type(Service.Create) ~= "function"
        or type(Service.BindFaction) ~= "function"
    then
        return false, "trader_service_unavailable"
    end
    if not factions or type(factions.Get) ~= "function" then
        return false, "faction_service_unavailable"
    end
    if factionID == nil or tostring(factionID) == "" then
        return false, "faction_not_found"
    end
    faction = factions.Get(factionID)
    if type(faction) ~= "table" then return false, "faction_not_found" end
    if faction.status ~= "active" then return false, "faction_not_active" end
    if isMobileGroup(faction) then return false, "mobile_group" end
    npcID = traderMember(factionID)
    if not npcID then return false, "settlement_has_no_trader" end
    traderID = Settlement.TraderIDFor(factionID)
    existing = Service.GetRecord and Service.GetRecord(traderID) or nil
    local contextOK, contextReason, residentCommunity =
        ensureResidentMarket(factionID)
    if not contextOK then return false, contextReason end
    if existing and tostring(existing.p or existing.l or "") == npcID then
        local boundContext, boundReason = bindResidentContext(
            traderID, residentCommunity)
        if not boundContext then return false, boundReason end
        return true, "already_bound", existing
    end
    record, reason = Service.Create({
        traderID = traderID,
        -- The DT record's binding label: a settlement rather than a caravan.
        caravanID = SETTLEMENT_BINDING_PREFIX .. tostring(factionID),
        -- A settlement trader is met in person. The radio shortcut stays a
        -- caravan feature.
        abstractAccessEnabled = false,
    })
    if not record then return false, reason or "trader_record_failed" end
    members = boundMemberIDs(factionID)
    bound, reason = Service.BindFaction(traderID, factionID, npcID, members)
    if not bound then return false, reason or "binding_failed" end
    local boundContext, boundReason = bindResidentContext(
        traderID, residentCommunity)
    if not boundContext then return false, boundReason end
    return true, existing and "rebound" or "bound", record
end

-- Bounded sweep over the persistent faction registry. Skips mobile groups,
-- inactive factions and settlements Project Hoomans did not staff with a trader.
function Settlement.EnsureBindings()
    local factions = PNC and PNC.Factions or nil
    local summary = {
        scanned = 0,
        bound = 0,
        alreadyBound = 0,
        withoutTrader = 0,
        skipped = 0,
        failed = 0,
        truncated = false,
    }
    local list
    local index
    local ok
    local reason
    local factionID
    if not authority() then
        summary.reason = "not_authority"
        return summary
    end
    if not factions or type(factions.List) ~= "function" then
        summary.reason = "faction_service_unavailable"
        return summary
    end
    list = factions.List()
    for index = 1, #(type(list) == "table" and list or {}) do
        factionID = list[index].id
        summary.scanned = summary.scanned + 1
        if summary.bound >= MAX_BINDINGS_PER_PASS then
            summary.truncated = true
        else
            ok, reason = Settlement.EnsureTraderForFaction(factionID)
            if ok and reason == "already_bound" then
                summary.alreadyBound = summary.alreadyBound + 1
            elseif ok then
                summary.bound = summary.bound + 1
                log("INFO", "settlement_trader_bound faction="
                    .. tostring(factionID))
            elseif reason == "settlement_has_no_trader" then
                summary.withoutTrader = summary.withoutTrader + 1
            elseif reason == "mobile_group"
                or reason == "faction_not_active"
                or reason == "faction_not_found"
            then
                summary.skipped = summary.skipped + 1
            else
                summary.failed = summary.failed + 1
                log("WARN", "settlement_trader_bind_failed faction="
                    .. tostring(factionID)
                    .. " reason=" .. tostring(reason))
            end
        end
    end
    if summary.bound > 0 or summary.failed > 0 or summary.truncated then
        log("INFO", "settlement_trader_sweep scanned="
            .. tostring(summary.scanned)
            .. " bound=" .. tostring(summary.bound)
            .. " alreadyBound=" .. tostring(summary.alreadyBound)
            .. " withoutTrader=" .. tostring(summary.withoutTrader)
            .. " skipped=" .. tostring(summary.skipped)
            .. " failed=" .. tostring(summary.failed)
            .. " truncated=" .. tostring(summary.truncated))
    end
    return summary
end

-- Bindings must reach the client before it can offer the trade option, so the
-- sweep runs at world start and then on a slow clock for settlements generated
-- during the session.
local function onTick()
    local at = worldAge()
    if nextSweepAt and at < nextSweepAt then return end
    nextSweepAt = at + SWEEP_INTERVAL_HOURS
    Settlement.EnsureBindings()
end

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Settlement.StartHookRegistered
then
    Settlement.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        nextSweepAt = worldAge() + SWEEP_INTERVAL_HOURS
        Settlement.EnsureBindings()
    end)
end

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not Settlement.TickHookRegistered
then
    Settlement.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Settlement
