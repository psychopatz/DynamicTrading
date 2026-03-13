-- ==============================================================================
-- DTNPC_AmbientDialogue.lua
-- Client-only overhead dialogue display for nearby DT NPCs.
-- Mirrors the health bar tracking flow so no extra server work is needed.
-- ==============================================================================

require "ISUI/ISUIElement"
require "DT/V2/NPC/DTNPC_AmbientDialogueConfig"

DTNPCClient = DTNPCClient or {}

ISDTNPCAmbientDialogueManager = ISUIElement:derive("ISDTNPCAmbientDialogueManager")

local FONT_DIALOGUE = UIFont.Small
local textManager = getTextManager()
local Config = DTNPCClient.AmbientDialogueConfig

DTNPCClient.AmbientDialogueManagers = DTNPCClient.AmbientDialogueManagers or {}
DTNPCClient.AmbientDialogueTracked = DTNPCClient.AmbientDialogueTracked or {}

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
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

local function deriveUUID(zombie, npcData, uuid)
    if uuid then return uuid end
    if npcData and npcData.uuid then return npcData.uuid end
    if not zombie then return nil end

    local modData = zombie:getModData()
    if modData and modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end

    return tostring(zombie:getPersistentOutfitID())
end

local function cacheTextMetrics(entry, name)
    local safeName = name or "Unknown"
    if entry.name ~= safeName then
        entry.name = safeName
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
        cacheTextMetrics(entry, npcData.name)
    end

    entry.lastSeenAt = currentTime
end

local function getTrackedEntry(uuid)
    local entry = DTNPCClient.AmbientDialogueTracked[uuid]
    if entry then
        return entry
    end

    entry = {
        uuid = uuid,
        name = "Unknown",
        lastSeenAt = getTimeInMillis(),
        nextResolveAt = 0,
        nextSpeakAt = 0,
        wasInRange = false,
    }
    DTNPCClient.AmbientDialogueTracked[uuid] = entry
    return entry
end

function DTNPCClient.TrackNPCForAmbientDialogue(zombie, npcData, uuid, outfitID)
    local resolvedUUID = deriveUUID(zombie, npcData, uuid)
    if not resolvedUUID then return nil end

    local entry = getTrackedEntry(resolvedUUID)
    touchTrackedEntry(entry, zombie, npcData, outfitID, getTimeInMillis())
    return entry
end

function DTNPCClient.UntrackNPCAmbientDialogue(uuid, outfitID)
    local resolvedUUID = uuid

    if not resolvedUUID and outfitID and DTNPCClient.OutfitIDToUUID then
        resolvedUUID = DTNPCClient.OutfitIDToUUID[outfitID]
    end
    if not resolvedUUID then return end

    DTNPCClient.AmbientDialogueTracked[resolvedUUID] = nil

    for _, manager in pairs(DTNPCClient.AmbientDialogueManagers or {}) do
        if manager then
            manager.speechList[resolvedUUID] = nil
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
        entry.nextResolveAt = currentTime + Config.ResolveRetryMs
    end

    return zombie
end

local function isTrackedEntryStale(entry, currentTime)
    local hasCache = entry.uuid and getCachedNPCData(entry.uuid) ~= nil
    local hasZombie = entry.zombie and not entry.zombie:isDead()
    return not hasCache and not hasZombie and (currentTime - (entry.lastSeenAt or 0)) > Config.StaleTrackMs
end

local function formatDialogue(entry)
    if not entry or not entry.dialogue then
        return nil
    end

    if DynamicTrading and DynamicTrading.Dialogue and DynamicTrading.Dialogue.Core and DynamicTrading.Dialogue.Core.FormatMessage then
        return DynamicTrading.Dialogue.Core.FormatMessage(entry.dialogue, {
            traderName = entry.traderName
        })
    end

    return entry.dialogue
end

local function buildSpeechData(npcData, zombie, currentTime)
    local dialogueEntry = Config.GetDialogueForNPC(npcData)
    if not dialogueEntry then
        return nil
    end

    dialogueEntry.traderName = npcData and npcData.name or "Trader"
    local text = formatDialogue(dialogueEntry)
    if not text or text == "" or text == "..." then
        return nil
    end

    local color = Config.GetSentimentColor(dialogueEntry.sentiment)
    return {
        text = text,
        width = textManager:MeasureStringX(FONT_DIALOGUE, text),
        color = color,
        x = zombie:getX(),
        y = zombie:getY(),
        z = zombie:getZ(),
        timestamp = currentTime,
        expireTime = currentTime + Config.DisplayTimeMs,
    }
end

function ISDTNPCAmbientDialogueManager:initialize()
    ISUIElement.initialise(self)
end

function ISDTNPCAmbientDialogueManager:prerender()
    self:setStencilRect(0, 0, self.renderWidth, self.renderHeight)
end

function ISDTNPCAmbientDialogueManager:render()
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

    local textYOffset = Config.TextYOffset / zoom
    local currentTime = getTimeInMillis()

    for uuid, speech in pairs(self.speechList) do
        if currentTime > speech.expireTime then
            self.speechList[uuid] = nil
        else
            local zombie = speech.zombie
            if zombie
                and not zombie:isDead()
                and math.abs(player:getZ() - zombie:getZ()) <= Config.FloorTolerance
                and calculateDistance(player, zombie) <= Config.MaxDrawDistance
            then
                local alpha = zombie:getAlpha(self.playerIndex)
                if alpha > 0 then
                    local floatOffset = (currentTime - speech.timestamp) / Config.FloatSpeed
                    local screenX = isoToScreenX(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.x
                    local screenY = isoToScreenY(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.y - textYOffset - floatOffset

                    self:drawText(
                        speech.text,
                        screenX - (speech.width / 2) + 1,
                        screenY + 1,
                        0,
                        0,
                        0,
                        alpha * 0.7,
                        FONT_DIALOGUE
                    )
                    self:drawText(
                        speech.text,
                        screenX - (speech.width / 2),
                        screenY,
                        speech.color.r,
                        speech.color.g,
                        speech.color.b,
                        speech.color.a * alpha,
                        FONT_DIALOGUE
                    )
                end
            end
        end
    end

    self:clearStencilRect()
end

function ISDTNPCAmbientDialogueManager:update()
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
    if self.updateCounter < Config.UpdateRate then
        return
    end
    self.updateCounter = 0

    local currentTime = getTimeInMillis()
    local staleUUIDs = {}

    for uuid, tracked in pairs(DTNPCClient.AmbientDialogueTracked or {}) do
        if tracked then
            local zombie = resolveTrackedZombie(uuid, tracked, currentTime)
            local npcData = tracked.npcData or getCachedNPCData(uuid)

            if zombie then
                npcData = getNPCData(zombie) or npcData
            end

            if npcData or zombie then
                touchTrackedEntry(tracked, zombie, npcData, tracked.outfitID, currentTime)
            end

            local inRange = zombie
                and not zombie:isDead()
                and math.abs(self.player:getZ() - zombie:getZ()) <= Config.FloorTolerance
                and calculateDistance(self.player, zombie) <= Config.TriggerDistance

            if inRange then
                local shouldSpeak = (not tracked.wasInRange)
                    and currentTime >= (tracked.nextSpeakAt or 0)
                if shouldSpeak and npcData then
                    local speechData = buildSpeechData(npcData, zombie, currentTime)
                    if speechData then
                        speechData.zombie = zombie
                        self.speechList[uuid] = speechData
                        tracked.nextSpeakAt = currentTime + Config.CooldownMs
                    end
                end

                tracked.wasInRange = true
            else
                tracked.wasInRange = false
            end

            if self.speechList[uuid] and zombie then
                self.speechList[uuid].zombie = zombie
            end

            if isTrackedEntryStale(tracked, currentTime) then
                table.insert(staleUUIDs, { uuid = uuid, outfitID = tracked.outfitID })
            end
        end
    end

    for i = 1, #staleUUIDs do
        local stale = staleUUIDs[i]
        DTNPCClient.UntrackNPCAmbientDialogue(stale.uuid, stale.outfitID)
    end
end

function ISDTNPCAmbientDialogueManager:new(playerIndex, player)
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
    o.speechList = {}
    o:setCapture(false)

    return o
end

local function initForPlayer(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    if DTNPCClient.AmbientDialogueManagers[playerIndex] then return end

    local manager = ISDTNPCAmbientDialogueManager:new(playerIndex, player)
    manager:initialise()
    DTNPCClient.AmbientDialogueManagers[playerIndex] = manager
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
    for _, manager in pairs(DTNPCClient.AmbientDialogueManagers or {}) do
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
