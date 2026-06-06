-- ==============================================================================
-- DT_FactionBaseLedgerRenderers.lua
-- Renderers for the Faction Base Ledger debug window.
-- ==============================================================================

require "DT/UI/Shared/DT_UIUtils"

DT_FactionBaseLedgerRenderers = DT_FactionBaseLedgerRenderers or {}

local function getStatusColor(row)
    if row and row.active == true then
        return 0.35, 1.0, 0.45
    end
    if row and tostring(row.state or "") == "Collapsed" then
        return 1.0, 0.25, 0.20
    end
    return 1.0, 0.72, 0.30
end

function DT_FactionBaseLedgerRenderers.DrawBaseItem(listbox, y, item, alt)
    local row = item and item.item or nil
    if type(row) ~= "table" then
        return y + listbox.itemheight
    end

    DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)

    local r, g, b = getStatusColor(row)
    local statusText = tostring(row.status or "Inactive")
    local factionText = row.active and tostring(row.currentFactionName or row.currentFactionID or "") or tostring(row.formerFactionID or "")
    if factionText == "" then
        factionText = "No occupying faction"
    end
    local formerName = tostring(row.formerName or "")
    if formerName == "" then
        formerName = "None"
    end

    listbox:drawText(tostring(row.currentName or "Unknown Base"), 10, y + 3, r, g, b, 1, UIFont.Small)
    listbox:drawText(
        statusText
            .. " | "
            .. tostring(row.town or "Unknown")
            .. " | "
            .. tostring(math.floor(tonumber(row.x) or 0))
            .. ","
            .. tostring(math.floor(tonumber(row.y) or 0))
            .. ","
            .. tostring(math.floor(tonumber(row.z) or 0)),
        10,
        y + 20,
        0.78,
        0.78,
        0.78,
        1,
        UIFont.Small
    )
    listbox:drawText("Faction: " .. factionText, 10, y + 36, 0.62, 0.62, 0.62, 1, UIFont.Small)
    listbox:drawText("Former: " .. formerName, 10, y + 52, 0.54, 0.54, 0.54, 1, UIFont.Small)

    return y + listbox.itemheight
end

return DT_FactionBaseLedgerRenderers
