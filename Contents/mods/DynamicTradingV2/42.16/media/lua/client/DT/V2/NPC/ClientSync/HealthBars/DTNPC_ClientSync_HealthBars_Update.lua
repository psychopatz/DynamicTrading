-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Update.lua
-- Update loop, stale cleanup, and damage text generation.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Update then
    return
end

modules.Update = true

local Constants = HealthBars.Constants
local Helpers = HealthBars.Helpers
local State = HealthBars.State

local function resolveTrackedZombie(uuid, entry, currentTime)
    local zombie = entry.zombie

    if zombie and not zombie:isDead() then
        if DTNPCClient.DoesZombieMatchUUID and DTNPCClient.DoesZombieMatchUUID(zombie, uuid) then
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

    local bodyInstanceID = entry.bodyInstanceID
    if not zombie and bodyInstanceID and DTNPCClient.FindZombieByBodyInstanceID then
        zombie = DTNPCClient.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    entry.zombie = zombie
    if zombie then
        entry.nextResolveAt = currentTime
        entry.worldX = zombie:getX()
        entry.worldY = zombie:getY()
        entry.worldZ = zombie:getZ()
    else
        entry.nextResolveAt = currentTime + Constants.ZOMBIE_RESOLVE_RETRY_MS
    end

    return zombie
end

local function isTrackedEntryStale(entry, currentTime)
    local hasCache = entry.uuid and Helpers.getCachedNPCData(entry.uuid) ~= nil
    local hasZombie = entry.zombie and not entry.zombie:isDead()
    return not hasCache and not hasZombie and (currentTime - (entry.lastSeenAt or 0)) > Constants.STALE_TRACK_MS
end

local function buildDamageText(delta)
    local amount = math.abs(delta)
    local prefix = delta > 0 and "-" or "+"
    local color = delta > 0
        and { r = 1, g = 0.45, b = 0.45, a = 1 }
        or { r = 0.6, g = 1, b = 0.6, a = 1 }
    local rounded

    if amount >= 10 then
        rounded = Helpers.round(amount, 0)
    elseif amount >= 5 then
        rounded = Helpers.round(amount, 1)
    else
        rounded = Helpers.round(amount, 2)
    end

    local text = prefix .. tostring(rounded)
    return {
        text = text,
        width = State.textManager:MeasureStringX(Constants.FONT_DAMAGE, text),
        color = color,
    }
end

HealthBars.resolveTrackedZombie = resolveTrackedZombie
HealthBars.isTrackedEntryStale = isTrackedEntryStale
HealthBars.buildDamageText = buildDamageText

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
    if self.updateCounter < Constants.UPDATE_RATE then
        return
    end
    self.updateCounter = 0

    local activeUUIDs = {}
    local currentTime = getTimeInMillis()
    local staleUUIDs = {}

    for uuid, tracked in pairs(DTNPCClient.HealthBarTracked or {}) do
        if tracked then
            local zombie = resolveTrackedZombie(uuid, tracked, currentTime)
            local npcData = tracked.npcData or Helpers.getCachedNPCData(uuid)

            if zombie then
                npcData = Helpers.getNPCData(zombie) or npcData
            end

            if npcData or zombie then
                HealthBars.touchTrackedEntry(tracked, zombie, npcData, tracked.bodyInstanceID, currentTime)
            end

            if zombie
                and not zombie:isDead()
                and math.abs(self.player:getZ() - zombie:getZ()) <= Constants.FLOOR_TOLERANCE
                and Helpers.calculateDistance(self.player, zombie) <= Constants.MAX_DRAW_DISTANCE
            then
                activeUUIDs[uuid] = true

                local barData = self.barList[uuid]
                if not barData then
                    barData = {
                        zombie = zombie,
                        uuid = uuid,
                        npcData = npcData,
                        currentHp = tracked.currentHp,
                        maxHp = tracked.maxHp,
                        staminaCurrent = tracked.staminaCurrent,
                        staminaMax = tracked.staminaMax,
                        staminaState = tracked.staminaState,
                        isIncapacitated = tracked.isIncapacitated,
                        isWeakened = tracked.isWeakened,
                        hasActiveBandage = tracked.hasActiveBandage,
                        bandageIconTexture = tracked.bandageIconTexture,
                        previousHp = tracked.currentHp,
                        name = tracked.name or "Unknown",
                        nameWidth = tracked.nameWidth or State.textManager:MeasureStringX(Constants.FONT_NAME, tracked.name or "Unknown"),
                        visibleUntil = tracked.visibleUntil or 0,
                    }
                    Helpers.cacheHealthTextMetrics(barData, tracked.currentHp, tracked.maxHp)
                    self.barList[uuid] = barData
                else
                    barData.zombie = zombie
                    barData.uuid = uuid
                    barData.npcData = npcData
                    barData.currentHp = tracked.currentHp
                    barData.maxHp = tracked.maxHp
                    barData.staminaCurrent = tracked.staminaCurrent
                    barData.staminaMax = tracked.staminaMax
                    barData.staminaState = tracked.staminaState
                    barData.isIncapacitated = tracked.isIncapacitated
                    barData.isWeakened = tracked.isWeakened
                    barData.hasActiveBandage = tracked.hasActiveBandage
                    barData.bandageIconTexture = tracked.bandageIconTexture
                    barData.name = tracked.name or barData.name or "Unknown"
                    barData.nameWidth = tracked.nameWidth or barData.nameWidth
                    barData.visibleUntil = math.max(barData.visibleUntil or 0, tracked.visibleUntil or 0)
                    Helpers.cacheHealthTextMetrics(barData, tracked.currentHp, tracked.maxHp)

                    if tracked.currentHp ~= barData.previousHp then
                        local delta = barData.previousHp - tracked.currentHp
                        if math.abs(delta) > 0.01 then
                            local damageData = buildDamageText(delta)
                            barData.visibleUntil = currentTime + Constants.COMBAT_SHOW_DURATION
                            self.damageTexts[uuid] = self.damageTexts[uuid] or {}
                            table.insert(self.damageTexts[uuid], {
                                text = damageData.text,
                                width = damageData.width,
                                x = zombie:getX(),
                                y = zombie:getY(),
                                z = zombie:getZ(),
                                color = damageData.color,
                                timestamp = currentTime,
                                expireTime = currentTime + Constants.DAMAGE_TEXT_TTL,
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
                table.insert(staleUUIDs, { uuid = uuid, bodyInstanceID = tracked.bodyInstanceID })
            end
        end
    end

    for i = 1, #staleUUIDs do
        local stale = staleUUIDs[i]
        DTNPCClient.UntrackNPCForHealthBars(stale.uuid, stale.bodyInstanceID)
    end

    for uuid, _ in pairs(self.barList) do
        if not activeUUIDs[uuid] then
            self.barList[uuid] = nil
            self.damageTexts[uuid] = nil
        end
    end
end
