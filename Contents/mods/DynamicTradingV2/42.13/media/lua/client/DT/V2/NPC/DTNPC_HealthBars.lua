-- ==============================================================================
-- DTNPC_HealthBars.lua
-- Optimized overhead UI overlay for Dynamic Trading NPCs.
-- Name is always visible, health bar appears on damage/combat.
-- ==============================================================================

require "ISUI/ISUIElement"
require "Utils/DT_ReputationManager"

DTNPCClient = DTNPCClient or {}

ISDTNPCHealthBarManager = ISUIElement:derive("ISDTNPCHealthBarManager")

local BAR_WIDTH = 60
local BAR_HEIGHT = 6
local NAME_Y_OFFSET = 144
local BAR_Y_OFFSET = 130
local PADDING = 2
local UPDATE_RATE = 6
local DAMAGE_TEXT_TTL = 2000
local DAMAGE_TEXT_SPEED = 50
local MAX_DRAW_DISTANCE = 22
local COMBAT_SHOW_DURATION = 5000
local FLOOR_TOLERANCE = 1
local ZOMBIE_RESOLVE_RETRY_MS = 1000
local STALE_TRACK_MS = 15000

local FONT_NAME = UIFont.Small
local FONT_DAMAGE = UIFont.Medium

local textManager = getTextManager()

DTNPCClient.HealthBarManagers = DTNPCClient.HealthBarManagers or {}
DTNPCClient.HealthBarTracked = DTNPCClient.HealthBarTracked or {}

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

local function getHealthRatio(current, maxValue)
    local safeMax = math.max(1, maxValue or 1)
    return clamp((current or 0) / safeMax, 0, 1)
end

local function getColorForRatio(ratio)
    if ratio >= 0.7 then
        return { r = 0.1, g = 0.75, b = 0.15, a = 1 }
    elseif ratio >= 0.35 then
        return { r = 0.95, g = 0.8, b = 0.1, a = 1 }
    end

    return { r = 0.8, g = 0.15, b = 0.15, a = 1 }
end

local function isCombatState(npcData)
    if not npcData then return false end

    local state = npcData.state
    return npcData.isHostile == true
        or state == "Attack"
        or state == "AttackRange"
        or state == "Flee"
end

local function getNPCData(zombie)
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

local function getCachedNPCData(uuid)
    local cacheEntry = DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid]
    return cacheEntry and cacheEntry.npcData or nil
end

local function resolveHealth(npcData, zombie, existingMax)
    local currentHp = tonumber(zombie and zombie:getHealth())
        or tonumber(npcData and npcData.health)
        or 0

    -- V2 only syncs current health. Build 42 zombie health is normalized,
    -- so default to 1 unless we've already observed a higher value.
    local maxHp = tonumber(existingMax) or 1

    if maxHp < currentHp then
        maxHp = currentHp
    end
    if maxHp <= 0 then
        maxHp = 1
    end

    return currentHp, maxHp
end

local function deriveUUID(zombie, npcData, uuid)
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

local function cacheNameMetrics(entry, name)
    local safeName = name or "Unknown"
    if entry.name ~= safeName then
        entry.name = safeName
        entry.nameWidth = textManager:MeasureStringX(FONT_NAME, safeName)
    elseif not entry.nameWidth then
        entry.nameWidth = textManager:MeasureStringX(FONT_NAME, safeName)
    end
end

local function touchTrackedEntry(entry, zombie, npcData, outfitID, currentTime)
    if zombie then
        entry.zombie = zombie
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    end

    if outfitID then
        entry.outfitID = outfitID
    end

    if npcData then
        entry.npcData = npcData
        cacheNameMetrics(entry, npcData.name)
        entry.currentHp, entry.maxHp = resolveHealth(npcData, zombie or entry.zombie, entry.maxHp)

        if isCombatState(npcData) then
            entry.visibleUntil = currentTime + COMBAT_SHOW_DURATION
        end
    elseif zombie then
        entry.currentHp, entry.maxHp = resolveHealth(nil, zombie, entry.maxHp)
    end

    entry.lastSeenAt = currentTime
end

local function getTrackedEntry(uuid)
    local entry = DTNPCClient.HealthBarTracked[uuid]
    if entry then
        return entry
    end

    entry = {
        uuid = uuid,
        name = "Unknown",
        nameWidth = textManager:MeasureStringX(FONT_NAME, "Unknown"),
        currentHp = 1,
        maxHp = 1,
        visibleUntil = 0,
        lastSeenAt = getTimeInMillis(),
        nextResolveAt = 0,
    }
    DTNPCClient.HealthBarTracked[uuid] = entry
    return entry
end

function DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, outfitID)
    local resolvedUUID = deriveUUID(zombie, npcData, uuid)
    if not resolvedUUID then return nil end

    local entry = getTrackedEntry(resolvedUUID)
    touchTrackedEntry(entry, zombie, npcData, outfitID, getTimeInMillis())
    return entry
end

function DTNPCClient.MarkNPCCombatForHealthBars(uuid, zombie, npcData, outfitID)
    local entry = DTNPCClient.TrackNPCForHealthBars(zombie, npcData, uuid, outfitID)
    if entry then
        entry.visibleUntil = getTimeInMillis() + COMBAT_SHOW_DURATION
    end
    return entry
end

function DTNPCClient.UntrackNPCForHealthBars(uuid, outfitID)
    local resolvedUUID = uuid

    if not resolvedUUID and outfitID and DTNPCClient.OutfitIDToUUID then
        resolvedUUID = DTNPCClient.OutfitIDToUUID[outfitID]
    end
    if not resolvedUUID then return end

    DTNPCClient.HealthBarTracked[resolvedUUID] = nil

    for _, manager in pairs(DTNPCClient.HealthBarManagers or {}) do
        if manager then
            manager.barList[resolvedUUID] = nil
            manager.damageTexts[resolvedUUID] = nil
        end
    end
end

local function resolveTrackedZombie(uuid, entry, currentTime)
    local zombie = entry.zombie

    if zombie and not zombie:isDead() then
        local modData = zombie:getModData()
        if modData and (modData.DTNPC_UUID == uuid or modData.IsDTNPC) then
            return zombie
        end
    end

    if currentTime < (entry.nextResolveAt or 0) then
        return nil
    end

    zombie = nil
    if DTNPCClient.FindZombieByUUID then
        zombie = DTNPCClient.FindZombieByUUID(uuid)
    end

    if not zombie and entry.outfitID and DTNPCClient.FindZombieByOutfitID then
        zombie = DTNPCClient.FindZombieByOutfitID(entry.outfitID)
    end

    entry.zombie = zombie
    if zombie then
        entry.nextResolveAt = currentTime
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    else
        entry.nextResolveAt = currentTime + ZOMBIE_RESOLVE_RETRY_MS
    end

    return zombie
end

local function isTrackedEntryStale(entry, currentTime)
    local hasCache = entry.uuid and getCachedNPCData(entry.uuid) ~= nil
    local hasZombie = entry.zombie and not entry.zombie:isDead()
    return not hasCache and not hasZombie and (currentTime - (entry.lastSeenAt or 0)) > STALE_TRACK_MS
end

local function buildDamageText(delta)
    local amount = math.abs(delta)
    local prefix = delta > 0 and "-" or "+"
    local color = delta > 0
        and { r = 1, g = 0.45, b = 0.45, a = 1 }
        or { r = 0.6, g = 1, b = 0.6, a = 1 }
    local rounded

    if amount >= 10 then
        rounded = round(amount, 0)
    elseif amount >= 5 then
        rounded = round(amount, 1)
    else
        rounded = round(amount, 2)
    end

    local text = prefix .. tostring(rounded)
    return {
        text = text,
        width = textManager:MeasureStringX(FONT_DAMAGE, text),
        color = color,
    }
end

function ISDTNPCHealthBarManager:initialize()
    ISUIElement.initialise(self)
end

function ISDTNPCHealthBarManager:prerender()
    self:setStencilRect(0, 0, self.renderWidth, self.renderHeight)
end

function ISDTNPCHealthBarManager:render()
    if not self.active then
        self:clearStencilRect()
        return
    end

    local player = self.player
    if not player then
        self:clearStencilRect()
        return
    end

    local zoom = getCore():getZoom(self.playerIndex)
    if zoom <= 0 then
        zoom = 1
    end

    local scaleDivisor = zoom > 1 and (zoom * 1.15) or 1
    local barWidth = BAR_WIDTH / scaleDivisor
    local barHeight = BAR_HEIGHT / scaleDivisor
    local nameYOffset = NAME_Y_OFFSET / zoom
    local barYOffset = BAR_Y_OFFSET / zoom
    local damageTextOffset = barYOffset + 26
    local currentTime = getTimeInMillis()

    for _, barData in pairs(self.barList) do
        local zombie = barData.zombie
        if zombie
            and not zombie:isDead()
            and math.abs(player:getZ() - zombie:getZ()) <= FLOOR_TOLERANCE
            and calculateDistance(player, zombie) <= MAX_DRAW_DISTANCE
        then
            local alpha = zombie:getAlpha(self.playerIndex)
            if alpha > 0 then
                local screenX = isoToScreenX(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.x
                local screenY = isoToScreenY(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.y

                self:drawText(
                    barData.name,
                    screenX - (barData.nameWidth / 2),
                    screenY - nameYOffset,
                    1,
                    1,
                    1,
                    alpha,
                    FONT_NAME
                )

                if barData.visibleUntil and currentTime <= barData.visibleUntil then
                    local hpRatio = getHealthRatio(barData.currentHp, barData.maxHp)
                    local hpColor = getColorForRatio(hpRatio)
                    local barLeft = screenX - (barWidth / 2)
                    local barTop = screenY - barYOffset

                    self:drawRect(
                        barLeft - PADDING,
                        barTop - PADDING,
                        barWidth + (PADDING * 2),
                        barHeight + (PADDING * 2),
                        0.55 * alpha,
                        0,
                        0,
                        0
                    )
                    self:drawRect(
                        barLeft,
                        barTop,
                        barWidth * hpRatio,
                        barHeight,
                        hpColor.a * alpha,
                        hpColor.r,
                        hpColor.g,
                        hpColor.b
                    )
                    self:drawRectBorder(
                        barLeft - PADDING,
                        barTop - PADDING,
                        barWidth + (PADDING * 2),
                        barHeight + (PADDING * 2),
                        alpha,
                        0.4,
                        0.4,
                        0.4
                    )
                end
            end
        end
    end

    for uuid, damageList in pairs(self.damageTexts) do
        for i = #damageList, 1, -1 do
            local dmg = damageList[i]
            if currentTime > dmg.expireTime then
                table.remove(damageList, i)
            else
                local timeOffset = (currentTime - dmg.timestamp) / DAMAGE_TEXT_SPEED
                local screenX = isoToScreenX(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.x
                local screenY = isoToScreenY(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.y - damageTextOffset - timeOffset

                self:drawText(
                    dmg.text,
                    screenX - (dmg.width / 2),
                    screenY,
                    dmg.color.r,
                    dmg.color.g,
                    dmg.color.b,
                    dmg.color.a,
                    FONT_DAMAGE
                )
            end
        end

        if #damageList == 0 then
            self.damageTexts[uuid] = nil
        end
    end

    self:clearStencilRect()
end

function ISDTNPCHealthBarManager:update()
    local offsetX = getPlayerScreenLeft(self.playerIndex)
    local offsetY = getPlayerScreenTop(self.playerIndex)

    self:setX(offsetX)
    self:setY(offsetY)
    self.renderWidth = getPlayerScreenWidth(self.playerIndex)
    self.renderHeight = getPlayerScreenHeight(self.playerIndex)
    self:setWidth(self.renderWidth)
    self:setHeight(self.renderHeight)

    self.player = getSpecificPlayer(self.playerIndex)
    if not self.player then return end

    self.updateCounter = (self.updateCounter or 0) + 1
    if self.updateCounter < UPDATE_RATE then
        return
    end
    self.updateCounter = 0

    local activeUUIDs = {}
    local currentTime = getTimeInMillis()
    local staleUUIDs = {}

    for uuid, tracked in pairs(DTNPCClient.HealthBarTracked or {}) do
        if tracked then
            local zombie = resolveTrackedZombie(uuid, tracked, currentTime)
            local npcData = tracked.npcData or getCachedNPCData(uuid)

            if zombie then
                npcData = getNPCData(zombie) or npcData
            end

            if npcData or zombie then
                touchTrackedEntry(tracked, zombie, npcData, tracked.outfitID, currentTime)
            end

            if zombie
                and not zombie:isDead()
                and math.abs(self.player:getZ() - zombie:getZ()) <= FLOOR_TOLERANCE
                and calculateDistance(self.player, zombie) <= MAX_DRAW_DISTANCE
            then
                activeUUIDs[uuid] = true

                local barData = self.barList[uuid]
                if not barData then
                    barData = {
                        zombie = zombie,
                        currentHp = tracked.currentHp,
                        maxHp = tracked.maxHp,
                        previousHp = tracked.currentHp,
                        name = tracked.name or "Unknown",
                        nameWidth = tracked.nameWidth or textManager:MeasureStringX(FONT_NAME, tracked.name or "Unknown"),
                        visibleUntil = tracked.visibleUntil or 0,
                    }
                    self.barList[uuid] = barData
                else
                    barData.zombie = zombie
                    barData.currentHp = tracked.currentHp
                    barData.maxHp = tracked.maxHp
                    barData.name = tracked.name or barData.name or "Unknown"
                    barData.nameWidth = tracked.nameWidth or barData.nameWidth
                    barData.visibleUntil = math.max(barData.visibleUntil or 0, tracked.visibleUntil or 0)

                    if tracked.currentHp ~= barData.previousHp then
                        local delta = barData.previousHp - tracked.currentHp
                        if math.abs(delta) > 0.01 then
                            local damageData = buildDamageText(delta)
                            barData.visibleUntil = currentTime + COMBAT_SHOW_DURATION
                            self.damageTexts[uuid] = self.damageTexts[uuid] or {}
                            table.insert(self.damageTexts[uuid], {
                                text = damageData.text,
                                width = damageData.width,
                                x = zombie:getX(),
                                y = zombie:getY(),
                                z = zombie:getZ(),
                                color = damageData.color,
                                timestamp = currentTime,
                                expireTime = currentTime + DAMAGE_TEXT_TTL,
                            })
                        end
                    end
                end

                barData.previousHp = tracked.currentHp
            elseif self.barList[uuid] then
                self.barList[uuid] = nil
                self.damageTexts[uuid] = nil
            end

            if isTrackedEntryStale(tracked, currentTime) then
                table.insert(staleUUIDs, { uuid = uuid, outfitID = tracked.outfitID })
            end
        end
    end

    for i = 1, #staleUUIDs do
        local stale = staleUUIDs[i]
        DTNPCClient.UntrackNPCForHealthBars(stale.uuid, stale.outfitID)
    end

    for uuid, _ in pairs(self.barList) do
        if not activeUUIDs[uuid] then
            self.barList[uuid] = nil
            self.damageTexts[uuid] = nil
        end
    end
end

function ISDTNPCHealthBarManager:new(playerIndex, player)
    local offsetX = getPlayerScreenLeft(playerIndex)
    local offsetY = getPlayerScreenTop(playerIndex)
    local o = ISUIElement:new(offsetX, offsetY, getPlayerScreenWidth(playerIndex), getPlayerScreenHeight(playerIndex))
    setmetatable(o, self)
    self.__index = self

    o.playerIndex = playerIndex
    o.player = player
    o.active = true
    o.renderWidth = getPlayerScreenWidth(playerIndex)
    o.renderHeight = getPlayerScreenHeight(playerIndex)
    o.updateCounter = 0
    o.barList = {}
    o.damageTexts = {}
    o:setCapture(false)

    return o
end

local function initForPlayer(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    if DTNPCClient.HealthBarManagers[playerIndex] then return end

    local manager = ISDTNPCHealthBarManager:new(playerIndex, player)
    manager:initialise()
    DTNPCClient.HealthBarManagers[playerIndex] = manager
end

local function onCreatePlayer(playerIndex)
    initForPlayer(playerIndex)
end

local function onGameStart()
    for i = 0, getNumActivePlayers() - 1 do
        initForPlayer(i)
    end
end

local function onPreUIDraw()
    for _, manager in pairs(DTNPCClient.HealthBarManagers or {}) do
        if manager and manager.active then
            manager:update()
            manager:prerender()
            manager:render()
        end
    end
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not attacker or not target then return end
    if attacker:getObjectName() ~= "Player" then return end

    local modData = target:getModData()
    if not modData or not modData.IsDTNPC then return end

    DTNPCClient.MarkNPCCombatForHealthBars(
        modData.DTNPC_UUID,
        target,
        getNPCData(target),
        target:getPersistentOutfitID()
    )

    if DT_ReputationManager then
        local npcData = getNPCData(target)
        DT_ReputationManager.RecordNPCHit(modData.DTNPC_UUID, npcData and npcData.factionID)
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnPreUIDraw.Add(onPreUIDraw)
Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
