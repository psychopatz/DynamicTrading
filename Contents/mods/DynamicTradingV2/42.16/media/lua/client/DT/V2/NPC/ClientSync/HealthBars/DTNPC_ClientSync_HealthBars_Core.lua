-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Core.lua
-- Shared constants, state, and helper functions for health bars.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}
require "DT/UI/Shared/DT_UIUtils"

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
Constants.STAMINA_BAR_HEIGHT = 4
Constants.STAMINA_BAR_GAP = 4
Constants.NAME_Y_OFFSET = 152
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
Constants.FONT_HP = UIFont.Medium
Constants.FONT_DAMAGE = UIFont.Medium
Constants.HP_TEXT_GAP = 6
Constants.HP_TEXT_TOP_GAP = 12
Constants.HEART_ICON_SIZE = 16
Constants.HEART_ICON_GAP = 2
Constants.HEART_TEXTURE_PATH = "media/ui/Moodle_internal_plus_red.png"
Constants.BANDAGE_ICON_GAP = 6
Constants.BANDAGE_ICON_SIZE = 10

State.textManager = getTextManager()
State.bandageTextureCache = State.bandageTextureCache or {}

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

function Helpers.getStaminaRatio(current, maxValue)
    local safeMax = math.max(1, tonumber(maxValue) or 1)
    return Helpers.clamp((tonumber(current) or 0) / safeMax, 0, 1)
end

function Helpers.isIncapacitatedState(npcData)
    return npcData and npcData.state == "Incapacitated"
end

function Helpers.isWeakenedState(npcData)
    return npcData
        and tostring(npcData.healthState or "") == "Weakened"
        and tostring(npcData.state or "") ~= "Incapacitated"
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

function Helpers.getWeakenedBarColor()
    return {
        r = 0.88,
        g = 0.58,
        b = 0.16,
        a = 0.92,
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
        or Helpers.isWeakenedState(npcData)
end

function Helpers.getNameColor(npcData, uuid)
    if DT_UIUtils and DT_UIUtils.GetTraderReputationColor then
        return DT_UIUtils.GetTraderReputationColor(uuid or (npcData and npcData.uuid), npcData and npcData.factionID, { alpha = 1 })
    end

    if npcData and npcData.isHostile == true then
        return { r = 1.0, g = 0.28, b = 0.28, a = 1.0 }
    end

    return { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
end

function Helpers.hasActiveBandage(npcData)
    if not npcData then return false end

    local combatHealth = npcData.combatHealth
    if type(combatHealth) ~= "table" then
        return npcData.state == "Bandage"
    end

    if combatHealth.activeBandage == true and combatHealth.bandageDirty ~= true then
        return true
    end

    return npcData.state == "Bandage"
end

local function isValidTexture(tex)
    return tex and tex.getName and tex:getName() ~= "Question_Highlight"
end

local function tryTexture(textureName)
    if not textureName or textureName == "" then
        return nil
    end

    local tex = getTexture(textureName)
    if isValidTexture(tex) then
        return tex
    end

    -- Try without .png extension if present
    local noExt = textureName:gsub("%.png$", "")
    if noExt ~= textureName then
        tex = getTexture(noExt)
        if isValidTexture(tex) then return tex end
    end

    -- Try lowercase
    local lower = textureName:lower()
    if lower ~= textureName then
        tex = getTexture(lower)
        if isValidTexture(tex) then return tex end
        
        local lowerNoExt = lower:gsub("%.png$", "")
        if lowerNoExt ~= lower then
            tex = getTexture(lowerNoExt)
            if isValidTexture(tex) then return tex end
        end
    end

    return nil
end

function Helpers.getHeartTexture()
    if State.heartTexture ~= nil then
        return State.heartTexture or nil
    end

    local tex = tryTexture(Constants.HEART_TEXTURE_PATH)
        or tryTexture("heart_on")
    
    State.heartTexture = tex or false
    return tex
end

local function resolveBandageFullType(npcData)
    local combatHealth = npcData and npcData.combatHealth or nil
    if type(combatHealth) ~= "table" then
        return nil
    end

    local explicitFullType = tostring(combatHealth.bandageItemFullType or "")
    if explicitFullType ~= "" then
        return explicitFullType
    end

    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.getBandageItemFullType then
        local ok, fullType = pcall(DTNPCHealth.Internal.getBandageItemFullType, npcData)
        if ok and fullType and tostring(fullType) ~= "" then
            return tostring(fullType)
        end
    end

    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.getBandageTierDef then
        local ok, _, tierDef = pcall(DTNPCHealth.Internal.getBandageTierDef, combatHealth.bandageTier)
        if ok and type(tierDef) == "table" and tostring(tierDef.iconFullType or "") ~= "" then
            return tostring(tierDef.iconFullType)
        end
    end

    return "Base.Bandage"
end

function Helpers.getBandageIconTexture(npcData)
    local fullType = resolveBandageFullType(npcData)
    if not fullType then
        return nil
    end

    local cache = State.bandageTextureCache or {}
    State.bandageTextureCache = cache
    if cache[fullType] ~= nil then
        return cache[fullType] or nil
    end

    local texture = nil
    local script = getScriptManager and getScriptManager():getItem(fullType) or nil
    if script and script.getIcon then
        local iconName = script:getIcon()
        if iconName and iconName ~= "" then
            texture = tryTexture("Item_" .. tostring(iconName))
                or tryTexture(tostring(iconName))
                or tryTexture("media/textures/Item_" .. tostring(iconName) .. ".png")
        end
    end

    if not isValidTexture(texture) and InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item and item.getTex then
            local itemTex = item:getTex()
            if isValidTexture(itemTex) then
                texture = itemTex
            end
        end
    end

    cache[fullType] = isValidTexture(texture) and texture or false
    return cache[fullType] or nil
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
    local combatHealth = npcData and npcData.combatHealth or nil
    if type(combatHealth) == "table" and combatHealth.current ~= nil and combatHealth.max ~= nil then
        local currentHp = tonumber(combatHealth.current) or 0
        local maxHp = tonumber(combatHealth.max) or math.max(1, currentHp)
        if maxHp <= 0 then
            maxHp = math.max(1, tonumber(existingMax) or 1)
        end
        return currentHp, maxHp
    end

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

function Helpers.formatHealthValue(value)
    return tostring(Helpers.round(tonumber(value) or 0, 0))
end

function Helpers.formatHealthText(currentHp, maxHp)
    return "[" .. Helpers.formatHealthValue(currentHp) .. "/" .. Helpers.formatHealthValue(maxHp) .. "]"
end

function Helpers.cacheHealthTextMetrics(entry, currentHp, maxHp)
    local hpText = Helpers.formatHealthText(currentHp, maxHp)
    if entry.hpText ~= hpText then
        entry.hpText = hpText
        entry.hpTextWidth = State.textManager:MeasureStringX(Constants.FONT_HP, hpText)
    elseif not entry.hpTextWidth then
        entry.hpTextWidth = State.textManager:MeasureStringX(Constants.FONT_HP, hpText)
    end
end
