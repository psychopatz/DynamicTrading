-- Remote abstract-trader adapter for the Core Radio OS.
-- Contact construction/paging/actions are shared by DTCommon.TraderContacts.

local loaded, OS = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS")
if not loaded or type(OS) ~= "table"
    or type(OS.RegisterContactProvider) ~= "function"
then
    return nil
end

DTAbstract = DTAbstract or {}
local Contacts = DTCommon and DTCommon.TraderContacts
    or require "DTCommon/DTCommon_TraderContacts"

local PROVIDER_ID = "dynamictrading:remote_traders"
local spec = {
    tradeActionID = "dynamictrading:trade",
    talkActionID = "dynamictrading:talk",
    talkMode = "radio",
    capabilities = { remote = true, talk = true },
    marketSettlement = function(record)
        local policy = record and record.ca or nil
        return policy and policy.lastSettlementID or nil
    end,
    eligible = function(_, record)
        return record
            and tonumber(record.a) == 1
            and tostring(record.s or DTCommon.STATUS_READY)
                == tostring(DTCommon.STATUS_READY)
            and tostring(record.p or record.l or "") ~= ""
    end,
}

local definition = {
    id = PROVIDER_ID,
    ownerModID = "DTAbstract",
    order = 30,
    isAvailable = function(context)
        return DTAbstract.Enabled ~= false
            and context and context.active == true
    end,
    list = function(context, page)
        return Contacts.List(spec, context, page)
    end,
    invoke = function(context, contactID, actionID, snapshot)
        return Contacts.Invoke(
            spec, context, contactID, actionID, snapshot)
    end,
}

if OS.UnregisterContactProvider then
    OS.UnregisterContactProvider(PROVIDER_ID)
end
OS.RegisterContactProvider(definition)

return definition
