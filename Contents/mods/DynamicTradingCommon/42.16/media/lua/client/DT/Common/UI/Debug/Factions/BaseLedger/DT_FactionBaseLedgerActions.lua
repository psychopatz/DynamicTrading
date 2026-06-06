-- ==============================================================================
-- DT_FactionBaseLedgerActions.lua
-- Actions for the Faction Base Ledger debug window.
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"

DT_FactionBaseLedgerActions = DT_FactionBaseLedgerActions or {}

local function teleportLocalPlayer(x, y, z)
    local player = getPlayer and getPlayer() or nil
    if not player then
        return false
    end

    player:setX(x)
    player:setY(y)
    player:setZ(z)
    if player.setLx then player:setLx(x) end
    if player.setLy then player:setLy(y) end
    if player.setLz then player:setLz(z) end
    return true
end

function DT_FactionBaseLedgerActions.TeleportToBase(row)
    if type(row) ~= "table" then
        return false
    end

    local x = tonumber(row.x)
    local y = tonumber(row.y)
    local z = tonumber(row.z) or 0
    if not x or not y then
        return false
    end

    local moved = teleportLocalPlayer(x, y, z)

    DT_DebugNetworkAdapter.sendDebugAction("TeleportToFactionBase", {
        x = x,
        y = y,
        z = z,
        name = tostring(row.currentName or row.formerName or "Faction Base"),
    })
    return moved
end

function DT_FactionBaseLedgerActions.DumpLedger()
    DT_DebugNetworkAdapter.sendDebugAction("DumpFactionBaseLedger", { limit = 120 })
    return true
end

return DT_FactionBaseLedgerActions
