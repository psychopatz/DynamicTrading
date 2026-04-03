-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Core.lua
-- Shared constants, state, and helper functions for health bars.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Core then
    return
end

modules.Core = true

local Constants = HealthBars.Constants or {}
local Helpers = HealthBars.Helpers or {}
local State = HealthBars.State or {}

HealthBars.Constants = Constants
HealthBars.Helpers = Helpers
HealthBars.State = State

Constants.BAR_WIDTH = 60
Constants.BAR_HEIGHT = 6
Constants.NAME_Y_OFFSET = 144
Constants.BAR_Y_OFFSET = 130
Constants.PADDING = 2
Constants.UPDATE_RATE = 6
Constants.DAMAGE_TEXT_TTL = 2000
Constants.DAMAGE_TEXT_SPEED = 50
Constants.MAX_DRAW_DISTANCE = 22
Constants.COMBAT_SHOW_DURATION = 5000
Constants.FLOOR_TOLERANCE = 1
Constants.ZOMBIE_RESOLVE_RETRY_MS = 1000
Constants.STALE_TRACK_MS = 15000
Constants.FONT_NAME = UIFont.Small
Constants.FONT_DAMAGE = UIFont.Medium

State.textManager = getTextManager()

DTNPCClient.HealthBarManagers = DTNPCClient.HealthBarManagers or {}
DTNPCClient.HealthBarTracked = DTNPCClient.HealthBarTracked or {}

function Helpers.clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function Helpers.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Helpers.calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function Helpers.getHealthRatio(current, maxValue)
    local safeMax = math.max(1, maxValue or 1)
    return Helpers.clamp((current or 0) / safeMax, 0, 1)
end

function Helpers.getColorForRatio(ratio)
    if ratio >= 0.7 then
        return { r = 0.1, g = 0.75, b = 0.15, a = 1 }
    elseif ratio >= 0.35 then
        return { r = 0.95, g = 0.8, b = 0.1, a = 1 }
    end

    return { r = 0.8, g = 0.15, b = 0.15, a = 1 }
end

function Helpers.isIncapacitatedState(npcData)
    return npcData and npcData.state == "Incapacitated"
end

function Helpers.getIncapacitatedBarColor(currentTime)
    local pulse = (math.sin(currentTime / 140) + 1) * 0.5
    return {
        r = 0.35 + (0.2 * pulse),
        g = 0.03 + (0.04 * pulse),
        b = 0.03 + (0.04 * pulse),
        a = 0.8 + (0.2 * pulse),
    }
end

function Helpers.isCombatState(npcData)
    if not npcData then return false end

    local state = npcData.state
    return npcData.isHostile == true
        or state == "Attack"
        or state == "AttackRange"
        or state == "Flee"
        or state == "Incapacitated"
end

function Helpers.getNPCData(zombie)
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

function Helpers.getCachedNPCData(uuid)
    local cacheEntry = DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
    return cacheEntry and cacheEntry.npcData or nil
end

function Helpers.resolveHealth(npcData, zombie, existingMax)
    local currentHp = tonumber(zombie and zombie:getHealth())
        or tonumber(npcData and npcData.health)
        or 0

    local maxHp = tonumber(existingMax) or 1

    if maxHp < currentHp then
        maxHp = currentHp
    end
    if maxHp <= 0 then
        maxHp = 1
    end

    return currentHp, maxHp
end

function Helpers.deriveUUID(zombie, npcData, uuid)
    if uuid then return uuid end
    if npcData and npcData.uuid then return npcData.uuid end
    if zombie then
        local modData = zombie:getModData()
        if modData and modData.DTNPC_UUID then
            return modData.DTNPC_UUID
        end
        return tostring(zombie:getPersistentOutfitID())
    end
    return nil
end

function Helpers.cacheNameMetrics(entry, name)
    local safeName = name or "Unknown"
    if entry.name ~= safeName then
        entry.name = safeName
        entry.nameWidth = State.textManager:MeasureStringX(Constants.FONT_NAME, safeName)
    elseif not entry.nameWidth then
        entry.nameWidth = State.textManager:MeasureStringX(Constants.FONT_NAME, safeName)
    end
end
