-- Remote abstract-trader adapter for the Core Radio OS.
-- Only server-authenticated abstract-capable records enter this provider;
-- OpenTrader still uses DTCommon's existing snapshot/trade flow.

local loaded, OS = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS")
if not loaded or type(OS) ~= "table"
    or type(OS.RegisterContactProvider) ~= "function"
then
    return nil
end

DTAbstract = DTAbstract or {}
local PROVIDER_ID = "dynamictrading:remote_traders"
local ACTION_ID = "dynamictrading:trade"
local TALK_ACTION_ID = "dynamictrading:talk"
local MAX_CONTACTS = 64
local MAX_PAGE_SIZE = 12

local function ready(record)
    return record and tonumber(record.a) == 1
        and tostring(record.s or DTCommon.STATUS_READY)
            == tostring(DTCommon.STATUS_READY)
        and tostring(record.p or record.l or "") ~= ""
end

local function findTrader(traderID)
    local wanted = tostring(traderID or "")
    local found
    if wanted == "" or not DTCommon or not DTCommon.TraderService
        or type(DTCommon.TraderService.ForEach) ~= "function"
    then
        return nil
    end
    DTCommon.TraderService.ForEach(function(id, record)
        if tostring(id) == wanted and ready(record) then found = record end
    end)
    return found
end

local function list(_, page)
    local rows = {}
    page = type(page) == "table" and page or {}
    local offset = math.max(0, math.floor(tonumber(page.offset) or 0))
    local limit = math.max(1, math.min(MAX_PAGE_SIZE,
        math.floor(tonumber(page.limit) or MAX_PAGE_SIZE)))
    if DTCommon and DTCommon.TraderService
        and type(DTCommon.TraderService.ForEach) == "function"
    then
        DTCommon.TraderService.ForEach(function(traderID, record)
            if #rows < MAX_CONTACTS and ready(record) then
                rows[#rows + 1] = {
                    id = tostring(traderID),
                    title = tostring(record.n or traderID),
                    status = tostring(record.s or "READY"),
                    actions = {
                        {
                            id = ACTION_ID,
                            label = DTCommon.T("DTHoomans_Trade", "Trade"),
                        },
                        {
                            id = TALK_ACTION_ID,
                            label = DTCommon.T(
                                "DTCommon_Radio_Talk", "Talk"),
                        },
                    },
                    capabilities = { remote = true, talk = true },
                }
            end
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

local function invoke(_, contactID, actionID, snapshot)
    actionID = tostring(actionID or "")
    if actionID ~= ACTION_ID and actionID ~= TALK_ACTION_ID then
        return false, "action_unsupported"
    end
    if not findTrader(contactID) then return false, "trader_unavailable" end
    if actionID == TALK_ACTION_ID then
        if not DTCommon.Client
            or type(DTCommon.Client.RequestTalk) ~= "function"
        then
            return false, "talk_service_unavailable"
        end
        return DTCommon.Client.RequestTalk(contactID, "radio", {
            snapshot = snapshot,
        })
    end
    if not DTCommon.Client or type(DTCommon.Client.OpenTrader) ~= "function" then
        return false, "trade_service_unavailable"
    end
    local opened, reason = DTCommon.Client.OpenTrader(contactID, {
        mode = "trade",
    })
    return opened == true, reason
end

local definition = {
    id = PROVIDER_ID,
    ownerModID = "DTAbstract",
    order = 30,
    isAvailable = function(context)
        return DTAbstract.Enabled ~= false
            and context and context.active == true
    end,
    list = list,
    invoke = invoke,
}

if OS.UnregisterContactProvider then OS.UnregisterContactProvider(PROVIDER_ID) end
OS.RegisterContactProvider(definition)

return definition
