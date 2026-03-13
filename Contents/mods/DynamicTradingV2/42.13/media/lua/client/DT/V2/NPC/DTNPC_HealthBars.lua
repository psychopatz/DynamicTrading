-- ==============================================================================
-- DTNPC_HealthBars.lua
-- Old-style overhead UI overlay for Dynamic Trading NPCs.
-- Name is always visible, health bar appears on damage/combat.
-- ==============================================================================

require "ISUI/ISUIElement"

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

local function resolveHealth(npcData, zombie, existingMax)
    local currentHp = tonumber(zombie and zombie:getHealth())
        or tonumber(npcData.health)
        or 0

    -- V2 only syncs current health. For Build 42 NPC-zombies, health is normalized,
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
                local label = barData.name or "Unknown"
                local textWidth = getTextManager():MeasureStringX(UIFont.Small, label)

                self:drawText(label, screenX - (textWidth / 2), screenY - nameYOffset, 1, 1, 1, alpha, UIFont.Small)

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

    local damageTextOffset = barYOffset + 26
    for uuid, damageList in pairs(self.damageTexts) do
        for i = #damageList, 1, -1 do
            local dmg = damageList[i]
            if currentTime > dmg.expireTime then
                table.remove(damageList, i)
            else
                local timeOffset = (currentTime - dmg.timestamp) / DAMAGE_TEXT_SPEED
                local screenX = isoToScreenX(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.x
                local screenY = isoToScreenY(self.playerIndex, dmg.x, dmg.y, dmg.z) - self.y - damageTextOffset - timeOffset
                local textWidth = getTextManager():MeasureStringX(UIFont.Medium, dmg.text)

                self:drawText(
                    dmg.text,
                    screenX - (textWidth / 2),
                    screenY,
                    dmg.color.r,
                    dmg.color.g,
                    dmg.color.b,
                    dmg.color.a,
                    UIFont.Medium
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

    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    if not zombieList then return end

    local activeUUIDs = {}
    local currentTime = getTimeInMillis()

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local modData = zombie:getModData()
            if modData and modData.IsDTNPC then
                local npcData = getNPCData(zombie)
                local uuid = modData.DTNPC_UUID or tostring(zombie:getPersistentOutfitID())

                if npcData
                    and uuid
                    and math.abs(self.player:getZ() - zombie:getZ()) <= FLOOR_TOLERANCE
                    and calculateDistance(self.player, zombie) <= MAX_DRAW_DISTANCE
                then
                    activeUUIDs[uuid] = true

                    local currentHp, maxHp
                    local barData = self.barList[uuid]

                    if not barData then
                        currentHp, maxHp = resolveHealth(npcData, zombie, nil)
                        barData = {
                            zombie = zombie,
                            currentHp = currentHp,
                            maxHp = maxHp,
                            previousHp = currentHp,
                            name = npcData.name or "Unknown",
                            visibleUntil = isCombatState(npcData) and (currentTime + COMBAT_SHOW_DURATION) or 0,
                        }
                        self.barList[uuid] = barData
                    else
                        currentHp, maxHp = resolveHealth(npcData, zombie, barData.maxHp)
                        barData.zombie = zombie
                        barData.currentHp = currentHp
                        barData.maxHp = maxHp
                        barData.name = npcData.name or barData.name or "Unknown"

                        if isCombatState(npcData) then
                            barData.visibleUntil = currentTime + COMBAT_SHOW_DURATION
                        end

                        if currentHp ~= barData.previousHp then
                            local delta = barData.previousHp - currentHp
                            if math.abs(delta) > 0.01 then
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

                                barData.visibleUntil = currentTime + COMBAT_SHOW_DURATION
                                self.damageTexts[uuid] = self.damageTexts[uuid] or {}
                                table.insert(self.damageTexts[uuid], {
                                    text = prefix .. tostring(rounded),
                                    x = zombie:getX(),
                                    y = zombie:getY(),
                                    z = zombie:getZ(),
                                    color = color,
                                    timestamp = currentTime,
                                    expireTime = currentTime + DAMAGE_TEXT_TTL,
                                })
                            end
                        end

                        barData.previousHp = currentHp
                    end
                end
            end
        end
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

DTNPCClient.HealthBarManagers = DTNPCClient.HealthBarManagers or {}

local function initForPlayer(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    if DTNPCClient.HealthBarManagers[playerIndex] then
        return
    end

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

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnPreUIDraw.Add(onPreUIDraw)
