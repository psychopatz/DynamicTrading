-- ==============================================================================
-- media/lua/client/DT/UI/Shared/DT_UIUtils.lua
-- Dynamic Trading UI Utilities
-- Reusable components and drawing logic for consistent styling
-- ==============================================================================

DT_UIUtils = DT_UIUtils or {}

local function clamp01(value, defaultValue)
    local n = tonumber(value)
    if n == nil then
        return defaultValue or 0
    end
    if n < 0 then
        return 0
    end
    if n > 1 then
        return 1
    end
    return n
end

--- Draws a consistent selection highlight for list items.
--- @param listbox ISScrollingListBox the listbox instance
--- @param y number the vertical position
--- @param item table the list item table (from self.items[i])
--- @param alt boolean whether this is an alternate row
--- @return boolean whether the item was highlighted as selected
function DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)
    local isSelected = (item.selected == true)
    
    -- Robust detection: sync with listbox.selected index if flag is missing
    if not isSelected and listbox.selected ~= -1 and listbox.items[listbox.selected] == item then
        isSelected = true
    end

    if isSelected then
        -- Consistent Green Highlight
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.4, 0.05, 0.5, 0.05)
        listbox:drawRectBorder(0, y, listbox.width, listbox.itemheight, 1, 0.1, 0.8, 0.1)
        return true
    elseif alt then
        -- Standard Zebra Striping (Subtle)
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 1, 1, 1)
    else
        -- Standard Transparent/Dark Background
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.1, 0, 0, 0)
    end
    
    return false
end

function DT_UIUtils.ScaleColor(color, factor, alpha)
    local source = type(color) == "table" and color or { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    local lift = tonumber(factor) or 1
    return {
        r = clamp01((source.r or 0.8) * lift, 0.8),
        g = clamp01((source.g or 0.8) * lift, 0.8),
        b = clamp01((source.b or 0.8) * lift, 0.8),
        a = clamp01(alpha, source.a or 1),
    }
end

function DT_UIUtils.GetReputationColor(reputation, options)
    local alpha = options and options.alpha or 1
    local stageData = DT_Reputation and DT_Reputation.GetStageData and DT_Reputation.GetStageData(reputation or 0) or nil
    local color = stageData and stageData.color or { r = 0.8, g = 0.8, b = 0.8 }
    return {
        r = clamp01(color.r, 0.8),
        g = clamp01(color.g, 0.8),
        b = clamp01(color.b, 0.8),
        a = clamp01(alpha, 1),
    }, tonumber(reputation) or 0, stageData and stageData.label or "Neutral"
end

function DT_UIUtils.GetFactionReputationColor(factionOrID, rosterData, options)
    local factionID = type(factionOrID) == "table" and factionOrID.id or factionOrID
    local factionType = type(factionOrID) == "table" and tostring(factionOrID.factionType or "") or ""
    if tostring(factionID or "") == "Bandits" or factionType == "bandit" then
        return { r = 1, g = 0.2, b = 0.2, a = clamp01(options and options.alpha or 1, 1) }, -100, "Hostile"
    end

    local reputation = DT_Reputation and DT_Reputation.GetFactionRep and DT_Reputation.GetFactionRep(factionID, rosterData) or 0
    return DT_UIUtils.GetReputationColor(reputation, options)
end

function DT_UIUtils.GetTraderReputationColor(traderUUID, factionID, options)
    if tostring(factionID or "") == "Bandits" then
        return { r = 1, g = 0.2, b = 0.2, a = clamp01(options and options.alpha or 1, 1) }, -100, "Hostile"
    end

    local reputation = DT_Reputation and DT_Reputation.GetEffectiveRep and DT_Reputation.GetEffectiveRep(traderUUID, factionID) or 0
    return DT_UIUtils.GetReputationColor(reputation, options)
end

--- Draws text inside a fixed-width lane. Long text scrolls horizontally.
--- @param panel ISUIElement drawing context
--- @param text string text to draw
--- @param x number left edge
--- @param y number top edge
--- @param width number clipping width
--- @param font UIFont font
--- @param r number red
--- @param g number green
--- @param b number blue
--- @param a number alpha
--- @param options table optional speedMs/gap/height
function DT_UIUtils.drawMarqueeText(panel, text, x, y, width, font, r, g, b, a, options)
    if not panel or width <= 0 then
        return
    end

    text = tostring(text or "")
    if text == "" then
        return
    end

    font = font or UIFont.Small
    local tm = getTextManager and getTextManager() or TextManager and TextManager.instance or nil
    local textWidth = tm and tm:MeasureStringX(font, text) or 0
    if textWidth <= width then
        panel:drawText(text, x, y, r, g, b, a, font)
        return
    end

    options = type(options) == "table" and options or {}
    local height = tonumber(options.height) or (tm and tm:getFontHeight(font) or 16)
    local gap = math.max(20, tonumber(options.gap) or 48)
    local speedMs = math.max(12, tonumber(options.speedMs) or 35)
    local now = getTimestampMs and getTimestampMs() or 0
    local cycle = math.max(1, textWidth + gap)
    local offset = math.floor((now / speedMs) % cycle)

    panel:setStencilRect(x, y, width, height + 2)
    panel:drawText(text, x - offset, y, r, g, b, a, font)
    panel:drawText(text, x - offset + textWidth + gap, y, r, g, b, a, font)
    panel:clearStencilRect()
end

DynamicTrading.Log("DTCommons", "UI", "Utility", "Shared UI Utils Loaded")
