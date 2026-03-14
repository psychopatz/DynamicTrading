-- ==============================================================================
-- DT_Dialogue_Ambient_Manager.lua
-- Ambient dialogue manager rendering and update methods.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig

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
                and Ambient.CalculateDistance(player, zombie) <= Config.MaxDrawDistance
            then
                local alpha = zombie:getAlpha(self.playerIndex)
                if alpha > 0 then
                    local floatOffset = (currentTime - speech.timestamp) / Config.FloatSpeed
                    local screenX = isoToScreenX(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ()) - self.x
                    local screenY = isoToScreenY(self.playerIndex, zombie:getX(), zombie:getY(), zombie:getZ())
                        - self.y
                        - textYOffset
                        - floatOffset

                    self:drawText(
                        speech.text,
                        screenX - (speech.width / 2) + 1,
                        screenY + 1,
                        0,
                        0,
                        0,
                        alpha * 0.7,
                        Ambient.FONT_DIALOGUE
                    )
                    self:drawText(
                        speech.text,
                        screenX - (speech.width / 2),
                        screenY,
                        speech.color.r,
                        speech.color.g,
                        speech.color.b,
                        speech.color.a * alpha,
                        Ambient.FONT_DIALOGUE
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

    for uuid, tracked in pairs(DTNPCClient.DialogueAmbientTracked or DTNPCClient.AmbientDialogueTracked or {}) do
        if tracked then
            local zombie = Ambient.ResolveTrackedZombie(uuid, tracked, currentTime)
            local npcData = tracked.npcData or Ambient.GetCachedNPCData(uuid)

            if zombie then
                npcData = Ambient.GetNPCData(zombie) or npcData
            end

            if npcData or zombie then
                Ambient.TouchTrackedEntry(tracked, zombie, npcData, tracked.outfitID, currentTime)
            end

            local inRange = zombie
                and not zombie:isDead()
                and math.abs(self.player:getZ() - zombie:getZ()) <= Config.FloorTolerance
                and Ambient.CalculateDistance(self.player, zombie) <= Config.TriggerDistance

            if inRange then
                if not tracked.wasInRange or not tracked.nextSpeakAt then
                    Ambient.ScheduleInitialSpeak(tracked, currentTime)
                end

                local shouldSpeak = currentTime >= (tracked.nextSpeakAt or math.huge)
                if shouldSpeak and npcData then
                    local speechData = Ambient.BuildSpeechData(npcData, zombie, currentTime)
                    if speechData then
                        speechData.zombie = zombie
                        self.speechList[uuid] = speechData
                        if isDebugEnabled() then
                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Ambient",
                                "Queued Ambient for " .. tostring(npcData.name or uuid)
                                    .. " [" .. tostring(npcData.status or "Default")
                                    .. "/" .. tostring(npcData.state or "Default")
                                    .. "] -> " .. tostring(speechData.text)
                            )
                        end
                        Ambient.ScheduleRepeatSpeak(tracked, currentTime)
                    else
                        if isDebugEnabled() then
                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Ambient",
                                "Ambient lookup returned no speech for "
                                    .. tostring(npcData.name or uuid)
                                    .. " [" .. tostring(npcData.status or "Default")
                                    .. "/" .. tostring(npcData.state or "Default") .. "]"
                            )
                        end
                        Ambient.ScheduleRepeatSpeak(tracked, currentTime)
                    end
                end

                tracked.wasInRange = true
            else
                tracked.wasInRange = false
                tracked.nextSpeakAt = nil
            end

            if self.speechList[uuid] and zombie then
                self.speechList[uuid].zombie = zombie
            end

            if Ambient.IsTrackedEntryStale(tracked, currentTime) then
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
