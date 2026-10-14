-- Project Hoomans physical-merchant adapter for the Core Radio OS.
--
-- This provider intentionally exposes only physical-only DT bindings. A
-- caravan record with abstract access is owned by the DTAbstract remote
-- provider in the radio scanner; Hoomans still owns its face-to-face path.
-- The server revalidates the body, role, faction and distance at snapshot and
-- trade commit, so this bounded client list is presentation only.

local loaded, OS = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS")
if not loaded or type(OS) ~= "table"
    or type(OS.RegisterContactProvider) ~= "function"
then
    return nil
end

DTHoomans = DTHoomans or {}
local PROVIDER_ID = "dynamictrading:physical_traders"
local ACTION_ID = "dynamictrading:physical_trade"
local MAX_CONTACTS = 64
local MAX_PAGE_SIZE = 12
local MAX_DISTANCE_SQUARED = 36

local function ready(record)
    return type(record) == "table"
        and tonumber(record.a) ~= 1
        and tostring(record.s or DTCommon.STATUS_READY)
            == tostring(DTCommon.STATUS_READY)
end

local function player()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function coordinate(object, method)
    if not object or type(object[method]) ~= "function" then return nil end
    local ok, value = pcall(object[method], object)
    value = ok and tonumber(value) or nil
    return value
end

local function liveBody(npcID)
    local registry = PNC and PNC.Registry or nil
    local body
    if not registry or type(registry.GetLiveZombie) ~= "function" then
        return nil
    end
    local ok, value = pcall(registry.GetLiveZombie, npcID)
    body = ok and value or nil
    if not body then return nil end
    if type(body.isDead) == "function" then
        local ok, dead = pcall(body.isDead, body)
        if not ok or dead == true then return nil end
    end
    return body
end

local function registryRecord(npcID)
    local registry = PNC and PNC.Registry or nil
    if not registry or type(registry.Get) ~= "function" then return nil end
    local ok, record = pcall(registry.Get, npcID)
    return ok and record or nil
end

local function nearby(body, current)
    local px = coordinate(current, "getX")
    local py = coordinate(current, "getY")
    local nx = coordinate(body, "getX")
    local ny = coordinate(body, "getY")
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

local function merchant(record, current)
    local npcID = record and (record.p or record.l) or nil
    local body
    local role
    local aff
    if not npcID or tostring(npcID) == "" or not ready(record) then
        return nil, nil, nil
    end
    npcID = tostring(npcID)
    body = liveBody(npcID)
    if not body or not nearby(body, current) then
        return nil, nil, nil
    end
    aff = affiliation(npcID)
    role = aff and tostring(aff.role or "") or ""
    if role ~= "trader" then return nil, nil, nil end
    if record.g and aff.factionID
        and tostring(record.g) ~= tostring(aff.factionID)
    then
        return nil, nil, nil
    end
    return npcID, body, aff
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
        local ok, summary = pcall(identity.GetCharacterSummary, npcRecord)
        name = ok and summary and summary.displayName or nil
    end
    name = name or npcRecord and npcRecord.identity
        and npcRecord.identity.displayName
    name = name or npcRecord and (npcRecord.displayName or npcRecord.name)
    name = tostring(name or (record and record.n) or npcID)
    return name ~= "" and name or npcID
end

local function portraitDescriptor(npcID)
    -- Project Hoomans owns the authoritative identity/appearance payload. Use
    -- its existing portrait builder only when a verified local record is
    -- available; otherwise Core renders its neutral fallback.
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

local function list(_, page)
    local rows = {}
    local current = player()
    page = type(page) == "table" and page or {}
    local offset = math.max(0, math.floor(tonumber(page.offset) or 0))
    local limit = math.max(1, math.min(MAX_PAGE_SIZE,
        math.floor(tonumber(page.limit) or MAX_PAGE_SIZE)))
    if not current or not DTCommon or not DTCommon.TraderService
        or type(DTCommon.TraderService.ForEach) ~= "function"
    then
        return { contacts = {}, total = 0 }
    end
    DTCommon.TraderService.ForEach(function(traderID, record)
        if #rows >= MAX_CONTACTS then return end
        local npcID = merchant(record, current)
        if npcID then
            rows[#rows + 1] = {
                id = tostring(traderID),
                title = displayName(record, npcID),
                status = tostring(record.s or DTCommon.STATUS_READY),
                portraitDescriptor = portraitDescriptor(npcID),
                actions = {
                    {
                        id = ACTION_ID,
                        label = DTCommon.T("DTHoomans_Trade", "Trade"),
                    },
                },
                capabilities = {
                    physical = true,
                    npcID = npcID,
                },
            }
        end
    end)
    table.sort(rows, function(left, right)
        return tostring(left.id) < tostring(right.id)
    end)
    local contacts = {}
    for index = offset + 1, math.min(#rows, offset + limit) do
        contacts[#contacts + 1] = rows[index]
    end
    return { contacts = contacts, total = #rows }
end

local function invoke(_, contactID, actionID)
    if tostring(actionID or "") ~= ACTION_ID then
        return false, "action_unsupported"
    end
    if not DTCommon or not DTCommon.TraderService
        or type(DTCommon.TraderService.GetRecord) ~= "function"
    then
        return false, "trader_service_unavailable"
    end
    local traderID = tostring(contactID or "")
    local record = DTCommon.TraderService.GetRecord(traderID)
    local npcID = merchant(record, player())
    if not npcID then return false, "merchant_unavailable" end
    if not DTCommon.Client
        or type(DTCommon.Client.OpenTrader) ~= "function"
    then
        return false, "trade_service_unavailable"
    end
    local opened, reason = DTCommon.Client.OpenTrader(traderID, {
        mode = "trade",
        npcID = npcID,
    })
    return opened == true, reason
end

local definition = {
    id = PROVIDER_ID,
    ownerModID = "DTHoomans",
    order = 25,
    isAvailable = function(context)
        return context and context.active == true
    end,
    list = list,
    invoke = invoke,
}

if OS.UnregisterContactProvider then OS.UnregisterContactProvider(PROVIDER_ID) end
OS.RegisterContactProvider(definition)

return definition
