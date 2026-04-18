require "DT/UI/Shared/DT_UIUtils"

DT_FactionDebugRenderers = DT_FactionDebugRenderers or {}

-- ==========================================================
-- FACTION LIST ITEM RENDERER
-- ==========================================================
function DT_FactionDebugRenderers.drawFactionItem(listbox, y, item, alt)
    local f = item.item
    if not f then return y end

    local r, g, b = 1, 1, 1
    if f.state == "Thriving" then
        r, g, b = 0, 1, 0
    elseif f.state == "Stable" then
        r, g, b = 1, 1, 1
    elseif f.state == "Strained" then
        r, g, b = 1, 1, 0
    elseif f.state == "Struggling" then
        r, g, b = 1, 0.5, 0
    elseif f.state == "Collapsing" or f.state == "Starving" then 
        r, g, b = 1, 0, 0
    end

    -- Selection / Background (Unified Utility)
    DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)
    
    -- Count flash events
    local flashEvents = f.ActiveFlashEvents or {}
    if #flashEvents == 0 and f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        flashEvents = {
            {
                id = f.ActiveFlashEvent.id,
                expires = f.ActiveFlashEvent.expires or 0
            }
        }
    end
    local eventStr = (#flashEvents > 0) and tostring(#flashEvents) or "None"

    listbox:drawText(item.text, 10, y + 2, r, g, b, 1, UIFont.Medium)
    listbox:drawText("State: " .. tostring(f.state) .. " | Pop: " .. tostring(f.memberCount) .. " | ColonyWealth: $" .. tostring(f.ColonyWealth or 0) .. " | Flash Events: " .. eventStr, 10, y + 20, 0.7, 0.7, 0.7, 1, UIFont.Small)

    return y + listbox.itemheight
end

-- ==========================================================
-- ROSTER ITEM RENDERER
-- ==========================================================
function DT_FactionDebugRenderers.drawRosterItem(listbox, y, item, alt)
    local data = item.item
    local soul = data.soul
    local trader = data.trader

    if not soul then return y end

    -- Selection / Background (Unified Utility)
    DT_UIUtils.drawSelectionHighlight(listbox, y, item, alt)

    local status = soul.status or "Active"
    local spawned = trader and trader.isPhysicallySpawned and "Spawned: YES" or "Spawned: NO"
    local r, g, b = 1, 1, 1
    if status == "Dead" then 
        r,g,b = 1,0,0
    elseif status == "Away" then 
        r,g,b = 0.5, 0.5, 1
    elseif status == "Home" then 
        r,g,b = 0.5, 1, 0.5
    end

    listbox:drawText(soul.name .. " [" .. (soul.archetypeID or "N/A") .. "]", 10, y + 2, 1, 1, 1, 1, UIFont.Small)
    
    local returnInfo = ""
    local valRet = (soul.returnTime and soul.returnTime > 0) and soul.returnTime or (trader and trader.returnTime)
    if valRet and valRet > 0 then
        local currentHours = getGameTime():getWorldAgeHours()
        local diff = math.max(0, valRet - currentHours)
        
        if status == "Trading" then
            returnInfo = string.format(" | Trading Ends: %.1fh", diff)
        elseif status == "Away" then
            local dest = soul.returnStatus or "Destination"
            returnInfo = string.format(" | %s in: %.1fh", dest, diff)
        else
            returnInfo = string.format(" | Ret: %.2f", valRet)
            if soul.returnStatus and soul.returnStatus ~= "" then
                returnInfo = returnInfo .. " (" .. soul.returnStatus .. ")"
            end
        end
    end
    
    listbox:drawText("Status: " .. status .. " | " .. spawned .. returnInfo, 10, y + 20, r, g, b, 0.8, UIFont.Small)

    return y + listbox.itemheight
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Renderers Loaded")
