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
    local header = window:drawScreenHeader(
        T("DTCommon_Radio_TraderScanner", "TRADERS"),
        state.statusText or T("DTCommon_Radio_Ready", "TRADER SCANNER"))
    if #rows == 0 then
        window:drawTextClipped(T("DTCommon_Radio_NoTraders", "NO TRADERS"),
            header.metrics.x, header.contentY, header.metrics.width, color)
        return
    end
    local index = math.max(1, math.min(#rows, state.traderIndex or 1))
    state.traderIndex = index
    local layout = window:screenListLayout(#rows, VISIBLE_ROWS, index, header)
    local first = layout.first
    for offset = 0, layout.visible - 1 do
        local row = rows[first + offset]
        local rect = window:screenRowRect(layout, offset)
        if not row or not rect then break end
        local selected = first + offset == index
        if selected then
            window:drawSprite("listrow_green_selected", rect.x, rect.y,
                rect.w, rect.h, 0.9)
            window:drawRect(rect.x, rect.y, rect.w, rect.h, 0.2,
                color.r * 0.2, color.g * 0.2, color.b * 0.2)
        else
            window:drawSprite("listrow_green_idle", rect.x, rect.y,
                rect.w, rect.h, 0.65)
        end
        local rowColor = selected and color
            or { r = color.r * 0.62, g = color.g * 0.62,
                b = color.b * 0.62, a = 1 }
        window:drawTextClipped(row.title or row.id,
            rect.x + math.max(2, math.floor(layout.metrics.scale)), rect.y,
            rect.w - math.max(2, math.floor(layout.metrics.scale)) * 2,
            rowColor)
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

local function hitTest(context, window, x, y)
    local rows = ensureRows(context, window)
    if #rows == 0 or type(window.screenListLayout) ~= "function" then
        return nil
    end
    local state = window.customState
    local header = window:headerLayout(
        state.statusText or T("DTCommon_Radio_Ready", "TRADER SCANNER"))
    local layout = window:screenListLayout(#rows, VISIBLE_ROWS,
        state.traderIndex or 1, header)
    for offset = 0, layout.visible - 1 do
        local rect = window:screenRowRect(layout, offset)
        if window:isInside(rect, x, y) then
            return { index = layout.first + offset }
        end
    end
    return nil
end

local function onScreenClick(context, window, value)
    local index = type(value) == "table" and tonumber(value.index) or nil
    if index then window.customState.traderIndex = index end
    return onSelect(context, window)
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
    hitTest = hitTest,
    onScreenClick = onScreenClick,
    onMove = onMove,
    onSelect = onSelect,
    isAvailable = function(context)
        return context and context.active == true
    end,
}

if OS.UnregisterApp then OS.UnregisterApp(APP_ID) end
OS.RegisterApp(definition)

return definition
