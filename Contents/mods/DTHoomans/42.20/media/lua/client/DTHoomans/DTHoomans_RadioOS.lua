-- Physical Hoomans trader adapter for the Core Radio OS.
-- DTCommon.TraderContacts owns common enumeration/paging/market/actions;
-- this adapter contributes only physical eligibility and presentation details.

local loaded, OS = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS")
if not loaded or type(OS) ~= "table"
    or type(OS.RegisterContactProvider) ~= "function"
then
    return nil
end

DTHoomans = DTHoomans or {}
local Contacts = DTCommon and DTCommon.TraderContacts
    or require "DTCommon/DTCommon_TraderContacts"

local PROVIDER_ID = "dynamictrading:physical_traders"
local MAX_DISTANCE_SQUARED = 36

local function player()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function coordinate(object, method)
    if not object or type(object[method]) ~= "function" then return nil end
    local ok, value = pcall(object[method], object)
    return ok and tonumber(value) or nil
end

local function registryRecord(npcID)
    local registry = PNC and PNC.Registry or nil
    if not registry or type(registry.Get) ~= "function" then return nil end
    local ok, record = pcall(registry.Get, npcID)
    return ok and record or nil
end

local function liveBody(npcID)
    local registry = PNC and PNC.Registry or nil
    if not registry or type(registry.GetLiveZombie) ~= "function" then
        return nil
    end
    local ok, body = pcall(registry.GetLiveZombie, npcID)
    if not ok or not body then return nil end
    if type(body.isDead) == "function" then
        local deadOK, dead = pcall(body.isDead, body)
        if not deadOK or dead == true then return nil end
    end
    return body
end

local function nearby(body, current)
    local px, py = coordinate(current, "getX"), coordinate(current, "getY")
    local nx, ny = coordinate(body, "getX"), coordinate(body, "getY")
    if not px or not py or not nx or not ny then return false end
    return (px - nx) * (px - nx) + (py - ny) * (py - ny)
        <= MAX_DISTANCE_SQUARED
end

local function affiliation(npcID)
    local factions = PNC and PNC.Factions or nil
    if not factions or type(factions.GetNPCAffiliation) ~= "function" then
        return nil
    end
    local ok, value = pcall(factions.GetNPCAffiliation, npcID)
    return ok and type(value) == "table" and value or nil
end

local function displayName(record, npcID)
    local caravan = DTHoomans.Caravan
    local identity = PNC and PNC.Identity or nil
    local npcRecord = registryRecord(npcID)
    local name
    if caravan and type(caravan.ResolveTraderDisplayName) == "function" then
        local ok, value = pcall(caravan.ResolveTraderDisplayName, record)
        name = ok and value or nil
    end
    if not name and identity
        and type(identity.GetCharacterSummary) == "function"
    then
        local ok, summary = pcall(
            identity.GetCharacterSummary, npcRecord)
        name = ok and summary and summary.displayName or nil
    end
    name = name or npcRecord and npcRecord.identity
        and npcRecord.identity.displayName
    name = name or npcRecord and (npcRecord.displayName or npcRecord.name)
    name = tostring(name or record.n or npcID)
    return name ~= "" and name or npcID
end

local function buildConversationEntry(
    body,
    record,
    snapshot,
    current
)
    local selection = PNC and PNC.NPCSelection or nil
    if selection
        and type(selection.BuildEntry) == "function"
    then
        return selection.BuildEntry(
            body,
            record,
            snapshot,
            coordinate(current, "getX"),
            coordinate(current, "getY")
        )
    end
    -- Load-order-safe canonical minimum. PNC.Conversation.Open resolves all
    -- additional identity/relationship/presence data from Registry by ID.
    return {
        id = record and record.id,
        zombie = body,
        record = record,
        snapshot = snapshot,
    }
end

local function portraitDescriptor(npcID)
    local shared = PNC and PNC.CharacterWindowShared or nil
    local record = registryRecord(npcID)
    if not shared or type(shared.BuildPortraitSpec) ~= "function"
        or type(record) ~= "table"
    then
        return nil
    end
    local ok, descriptor = pcall(
        shared.BuildPortraitSpec, npcID, record, nil)
    return ok and type(descriptor) == "table" and descriptor or nil
end

local spec = {
    tradeActionID = "dynamictrading:physical_trade",
    talkActionID = "dynamictrading:physical_talk",
    talkMode = "physical",
    capabilities = { physical = true, talk = true },
    eligible = function(_, record)
        if type(record) ~= "table"
            or tonumber(record.a) == 1
            or tostring(record.s or DTCommon.STATUS_READY)
                ~= tostring(DTCommon.STATUS_READY)
        then
            return false
        end
        local npcID = record.p or record.l
        npcID = npcID and tostring(npcID) or ""
        if npcID == "" then return false end
        local body = liveBody(npcID)
        local current = player()
        if not body or not current or not nearby(body, current) then
            return false
        end
        local aff = affiliation(npcID)
        if not aff or tostring(aff.role or "") ~= "trader" then
            return false
        end
        if record.g and aff.factionID
            and tostring(record.g) ~= tostring(aff.factionID)
        then
            return false
        end
        return true, {
            title = displayName(record, npcID),
            portraitDescriptor = portraitDescriptor(npcID),
            capabilities = { npcID = npcID },
        }
    end,
}

local definition = {
    id = PROVIDER_ID,
    ownerModID = "DTHoomans",
    order = 25,
    isAvailable = function(context)
        return context and context.active == true
    end,
    list = function(context, page)
        return Contacts.List(spec, context, page)
    end,
    invoke = function(context, contactID, actionID, snapshot)
        if tostring(actionID or "")
            == tostring(spec.talkActionID)
        then
            local row = Contacts.Find(
                spec,
                contactID,
                context
            )
            if not row then
                return false, "trader_unavailable"
            end
            local npcID = row.capabilities
                and row.capabilities.npcID
            local body = npcID and liveBody(npcID) or nil
            local record = npcID and registryRecord(npcID) or nil
            local current = player()
            local conversation = PNC and PNC.Conversation or nil
            if not npcID or not body or not record
                or not current
                or not conversation
                or type(conversation.Open) ~= "function"
            then
                return false, "hoomans_conversation_unavailable"
            end
            local state = PNC.Network
                and PNC.Network.ClientState or nil
            local replicated = state
                and state.snapshots
                and state.snapshots[tostring(npcID)]
                or nil
            local entry = buildConversationEntry(
                body,
                record,
                replicated,
                current
            )
            local view = entry
                and conversation.Open(entry, current)
                or nil
            return view ~= nil,
                view and "conversation_opened"
                    or "conversation_open_failed"
        end
        return Contacts.Invoke(
            spec, context, contactID, actionID, snapshot)
    end,
}

if OS.UnregisterContactProvider then
    OS.UnregisterContactProvider(PROVIDER_ID)
end
OS.RegisterContactProvider(definition)

return definition
