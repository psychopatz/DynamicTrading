-- ==============================================================================
-- DTNPC_ContextMenu_Helpers.lua
-- Shared helper functions for the debug NPC context menu.
-- ==============================================================================

if not isDebugEnabled() then return end

DTNPCMenu = DTNPCMenu or {}
DTNPCMenu.ContextMenu = DTNPCMenu.ContextMenu or {}

local Menu = DTNPCMenu.ContextMenu

if Menu.HelpersLoaded then
    return
end

Menu.HelpersLoaded = true

function Menu.GetNPCData(zombie)
    if not zombie then return nil end

    if DTNPCClient and DTNPCClient.GetNPCData then
        local npcData = DTNPCClient.GetNPCData(zombie)
        if npcData then
            return npcData
        end
    end

    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end

    return nil
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

function Menu.IsValidDebugWeaponItem(item)
    if not item then
        return false
    end

    if item.IsWeapon and item:IsWeapon() then
        return true
    end

    local fullType = item.getFullType and item:getFullType() or item.getType and item:getType() or ""
    local lowered = lower(fullType)
    return lowered:find("bat", 1, true) ~= nil
        or lowered:find("axe", 1, true) ~= nil
        or lowered:find("knife", 1, true) ~= nil
        or lowered:find("crowbar", 1, true) ~= nil
        or lowered:find("hammer", 1, true) ~= nil
        or lowered:find("pistol", 1, true) ~= nil
        or lowered:find("revolver", 1, true) ~= nil
        or lowered:find("shotgun", 1, true) ~= nil
        or lowered:find("rifle", 1, true) ~= nil
        or lowered:find("carbine", 1, true) ~= nil
end

function Menu.GetHeldDebugWeapon(player)
    if not player then
        return nil
    end

    local primary = player:getPrimaryHandItem()
    if Menu.IsValidDebugWeaponItem(primary) then
        return primary, "primary"
    end

    local secondary = player:getSecondaryHandItem()
    if Menu.IsValidDebugWeaponItem(secondary) then
        return secondary, "secondary"
    end

    return nil, nil
end

function Menu.GetHeldDebugWeaponLabel(player)
    local item = Menu.GetHeldDebugWeapon(player)
    if not item then
        return nil
    end

    return item.getDisplayName and item:getDisplayName() or item.getName and item:getName() or item:getFullType()
end

function Menu.CalculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()

    return math.sqrt(dx * dx + dy * dy)
end

function Menu.GetMarkerVisuals(npcData)
    local color = { r = 0.2, g = 1, b = 0.2 }
    local icon = "friend.png"

    if not npcData then
        return color, icon
    end

    if npcData.state == "Follow" then
        color = { r = 0.2, g = 0.8, b = 1 }
        icon = "crew.png"
    elseif npcData.state == "Stay" or npcData.state == "Guard" then
        color = { r = 1, g = 1, b = 0.2 }
        icon = "defend.png"
    elseif npcData.state == "GoTo" then
        color = { r = 1, g = 0.5, b = 0.2 }
        icon = "loot.png"
    elseif npcData.isHostile then
        color = { r = 1, g = 0.2, b = 0.2 }
        icon = "raid.png"
    end

    return color, icon
end

function Menu.BuildMarkerDescription(player, npcData, x, y)
    local dx = player:getX() - x
    local dy = player:getY() - y
    local distance = math.sqrt(dx * dx + dy * dy)
    local distText = string.format("%.0fm away", distance)

    return (npcData.name or "Unknown") .. " - " .. (npcData.state or "Idle") .. " - " .. distText
end
