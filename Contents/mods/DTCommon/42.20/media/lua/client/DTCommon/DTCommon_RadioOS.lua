-- DTCommon-owned Trader Scanner app for the Core Radio OS.
-- Providers own eligibility; this app only renders bounded rows and hands
-- Trade actions back to the registered provider / existing V2 client path.

local loaded, OS = pcall(require,
    "PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS")
if not loaded or type(OS) ~= "table"
    or type(OS.RegisterApp) ~= "function"
then
    return nil
end

DTCommon = DTCommon or {}
local APP_ID = "dynamictrading:traders"
local MAX_ROWS = 64
local VISIBLE_ROWS = 5

local function T(key, fallback)
    if DTCommon.T then return DTCommon.T(key, fallback) end
    return fallback or key
end

local function isTraderProvider(provider)
    return provider and string.sub(tostring(provider.id or ""), 1, 15)
        == "dynamictrading:"
end

local function refresh(window, context)
    local state = window.customState
    local rows = {}
    for _, provider in ipairs(OS.ListContactProviders(context)) do
        if isTraderProvider(provider) then
            local ok, page = OS.ListContacts(provider.id, context, {
                offset = 0,
                limit = 12,
                sort = "title",
            })
            if ok and page then
                for _, entry in ipairs(page.contacts or {}) do
                    if #rows >= MAX_ROWS then break end
                    rows[#rows + 1] = entry
                end
            end
        end
        if #rows >= MAX_ROWS then break end
    end
    table.sort(rows, function(left, right)
        local leftTitle = string.lower(tostring(left.title or left.id))
        local rightTitle = string.lower(tostring(right.title or right.id))
        if leftTitle == rightTitle then
            return tostring(left.providerID) .. ":" .. tostring(left.id)
                < tostring(right.providerID) .. ":" .. tostring(right.id)
        end
        return leftTitle < rightTitle
    end)
    state.traderRows = rows
    state.traderRevision = OS.GetRegistryRevision()
    state.traderIndex = math.max(1, math.min(#rows,
        tonumber(state.traderIndex) or 1))
end

local function ensureRows(context, window)
    local state = window.customState
    if state.traderRows == nil
        or state.traderRevision ~= OS.GetRegistryRevision()
    then
        refresh(window, context)
    end
    return state.traderRows
end

local function formatDenied(reason)
    local template = T("DTCommon_Radio_TradeDenied", "TRADE DENIED: %s")
    local ok, value = pcall(string.format, template, tostring(reason))
    return ok and value or template
end

local function render(context, window, screen)
    local state = window.customState
    local rows = ensureRows(context, window)
    local color = window:screenColors()
    window:drawScreenHeader(
        T("DTCommon_Radio_TraderScanner", "TRADERS"),
        state.statusText or T("DTCommon_Radio_Ready", "TRADER SCANNER"))
    if #rows == 0 then
        window:drawTextClipped(T("DTCommon_Radio_NoTraders", "NO TRADERS"),
            screen.x + 4 * window.scale, screen.y + 32 * window.scale,
            screen.w - 8 * window.scale, color)
        return
    end
    local index = math.max(1, math.min(#rows, state.traderIndex or 1))
    state.traderIndex = index
    local first = math.floor((index - 1) / VISIBLE_ROWS)
        * VISIBLE_ROWS + 1
    for offset = 0, VISIBLE_ROWS - 1 do
        local row = rows[first + offset]
        if not row then break end
        local y = screen.y + (29 + offset * 13) * window.scale
        local selected = first + offset == index
        if selected then
            window:drawRect(screen.x + 2 * window.scale, y - window.scale,
                screen.w - 4 * window.scale, 12 * window.scale, 0.3,
                color.r * 0.2, color.g * 0.2, color.b * 0.2)
        end
        local rowColor = selected and color
            or { r = color.r * 0.62, g = color.g * 0.62,
                b = color.b * 0.62, a = 1 }
        window:drawTextClipped(row.title or row.id,
            screen.x + 5 * window.scale, y,
            screen.w - 10 * window.scale, rowColor,
            math.floor(screen.w / (7 * window.scale)))
    end
end

local function onMove(context, window, delta)
    local rows = ensureRows(context, window)
    if #rows == 0 then return false end
    local state = window.customState
    state.traderIndex = ((state.traderIndex - 1 + delta) % #rows) + 1
    return true
end

local function onSelect(context, window)
    local rows = ensureRows(context, window)
    local entry = rows[window.customState.traderIndex]
    local action = entry and entry.actions and entry.actions[1]
    if not entry or not action then
        window.customState.statusText = T(
            "DTCommon_Radio_Unavailable", "TRADING UNAVAILABLE")
        return false
    end
    local accepted, reason = OS.InvokeContact(entry.providerID, context,
        entry.id, action.id, entry)
    window.customState.statusText = accepted
        and T("DTCommon_Radio_RequestSent", "TRADE REQUEST SENT")
        or formatDenied(reason)
    return accepted
end

local definition = {
    id = APP_ID,
    ownerModID = "DTCommon",
    label = T("DTCommon_Radio_TraderScanner", "TRADERS"),
    icon = "icon_trader",
    order = 40,
    open = function(context, window)
        window.customState.traderRows = nil
        window.customState.traderIndex = 1
        window.customState.statusText = nil
        refresh(window, context)
        return "custom"
    end,
    render = render,
    onMove = onMove,
    onSelect = onSelect,
    isAvailable = function(context)
        return context and context.active == true
    end,
}

if OS.UnregisterApp then OS.UnregisterApp(APP_ID) end
OS.RegisterApp(definition)

return definition
