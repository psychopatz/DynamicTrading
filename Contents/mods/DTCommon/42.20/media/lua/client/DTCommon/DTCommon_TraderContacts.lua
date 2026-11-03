-- Shared bounded trader-contact construction for radio/remote/physical
-- presentation providers. Adopters contribute eligibility/augmentation only.

DTCommon = DTCommon or {}
DTCommon.TraderContacts = DTCommon.TraderContacts or {}

local Contacts = DTCommon.TraderContacts

Contacts.MAX_CONTACTS = 64
Contacts.MAX_PAGE_SIZE = 12

local function marketEvents(record, spec)
    local presentation = DTCommon and DTCommon.MarketEventPresentation
    if not presentation or type(presentation.Summary) ~= "function" then
        return {}
    end
    local policy = record and record.ca or nil
    local settlementID
    if type(spec.marketSettlement) == "function" then
        local ok, value = pcall(spec.marketSettlement, record)
        if ok then settlementID = value end
    end
    settlementID = settlementID
        or policy and (policy.currentSettlementID
            or policy.lastSettlementID
            or policy.homeSettlementID)
    local ok, summary = pcall(
        presentation.Summary, settlementID, record, {})
    return ok and summary and summary.events or {}
end

local function actions(spec)
    local output = {}
    if spec.tradeActionID then
        output[#output + 1] = {
            id = spec.tradeActionID,
            label = DTCommon.T and DTCommon.T(
                spec.tradeLabelKey or "DTHoomans_Trade", "Trade")
                or "Trade",
        }
    end
    if spec.talkActionID then
        output[#output + 1] = {
            id = spec.talkActionID,
            label = DTCommon.T and DTCommon.T(
                spec.talkLabelKey or "DTCommon_Radio_Talk", "Talk")
                or "Talk",
        }
    end
    return output
end

local function project(spec, traderID, record, context)
    if type(spec.eligible) ~= "function" then return nil end
    local ok, eligible, extra = pcall(
        spec.eligible, traderID, record, context)
    if not ok or eligible ~= true then return nil end
    extra = type(extra) == "table" and extra or {}

    local capabilities = {}
    for key, value in pairs(spec.capabilities or {}) do
        capabilities[key] = value
    end
    for key, value in pairs(extra.capabilities or {}) do
        capabilities[key] = value
    end

    return {
        id = tostring(traderID),
        title = tostring(extra.title or record.n or traderID),
        status = tostring(record.s or DTCommon.STATUS_READY or "READY"),
        marketEvents = marketEvents(record, spec),
        portraitDescriptor = extra.portraitDescriptor,
        actions = actions(spec),
        capabilities = capabilities,
        providerData = extra.providerData,
    }
end

function Contacts.List(spec, context, page)
    spec = type(spec) == "table" and spec or {}
    page = type(page) == "table" and page or {}
    local rows = {}
    local service = DTCommon and DTCommon.TraderService or nil
    local offset = math.max(0, math.floor(tonumber(page.offset) or 0))
    local limit = math.max(1, math.min(
        Contacts.MAX_PAGE_SIZE,
        math.floor(tonumber(page.limit) or Contacts.MAX_PAGE_SIZE)
    ))
    if service and type(service.ForEach) == "function" then
        service.ForEach(function(traderID, record)
            if #rows >= Contacts.MAX_CONTACTS then return end
            local row = project(spec, traderID, record, context)
            if row then rows[#rows + 1] = row end
        end)
    end
    table.sort(rows, function(left, right)
        return tostring(left.id) < tostring(right.id)
    end)
    local contacts = {}
    for index = offset + 1, math.min(#rows, offset + limit) do
        contacts[#contacts + 1] = rows[index]
    end
    return { contacts = contacts, total = #rows }
end

function Contacts.Find(spec, traderID, context)
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.GetRecord) ~= "function" then
        -- Some lightweight presentation tests expose only ForEach.
        local wanted = tostring(traderID or "")
        local found
        if service and type(service.ForEach) == "function" then
            service.ForEach(function(id, record)
                if not found and tostring(id) == wanted then
                    found = project(spec, id, record, context)
                end
            end)
        end
        return found
    end
    local record = service.GetRecord(tostring(traderID or ""))
    return record and project(spec, traderID, record, context) or nil
end

function Contacts.Invoke(spec, context, traderID, actionID, snapshot)
    spec = type(spec) == "table" and spec or {}
    actionID = tostring(actionID or "")
    local row = Contacts.Find(spec, traderID, context)
    if not row then return false, spec.unavailableReason or "trader_unavailable" end
    local client = DTCommon and DTCommon.Client or nil

    if actionID == tostring(spec.talkActionID or "") then
        if not client or type(client.RequestTalk) ~= "function" then
            return false, "talk_service_unavailable"
        end
        return client.RequestTalk(traderID, spec.talkMode or "radio", {
            npcID = row.capabilities and row.capabilities.npcID,
            snapshot = snapshot,
        })
    end
    if actionID == tostring(spec.tradeActionID or "") then
        if not client or type(client.OpenTrader) ~= "function" then
            return false, "trade_service_unavailable"
        end
        local opened, reason = client.OpenTrader(traderID, {
            mode = "trade",
            npcID = row.capabilities and row.capabilities.npcID,
        })
        return opened == true, reason
    end
    return false, "action_unsupported"
end

return Contacts
