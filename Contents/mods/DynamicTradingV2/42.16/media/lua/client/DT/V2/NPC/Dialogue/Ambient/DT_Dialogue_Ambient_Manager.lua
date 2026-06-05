-- ==============================================================================
-- DT_Dialogue_Ambient_Manager.lua
-- Ambient dialogue manager rendering and update methods.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

require "DT/Common/Dialogue/DT_Dialogue_Vocals"

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig
local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

local function playSpeechAudio(zombie, npcData, speechData)
    if not zombie or not speechData or not speechData.audio then
        return
    end

    if DialogueVocals and DialogueVocals.PlaySpeechAudio then
        DialogueVocals.PlaySpeechAudio(zombie, npcData, speechData.audio)
    end
end

local function shouldThrottleAmbientSpeech(manager, tracked, speechData, currentTime)
    if not tracked or not speechData then
        return false
    end

    local globalCooldownUntil = tonumber(manager.globalAmbientCooldownUntil) or 0
    if globalCooldownUntil > 0 and currentTime < globalCooldownUntil then
        return true
    end

    local lastSpeechAt = tonumber(tracked.lastAmbientSpeechAt) or 0
    local speechKey = tostring(speechData.speechKey or "")
    local lastSpeechKey = tostring(tracked.lastAmbientSpeechKey or "")
    if speechKey ~= "" and speechKey == lastSpeechKey and lastSpeechAt > 0
        and (currentTime - lastSpeechAt) < math.max(0, tonumber(Config.StateRepeatCooldownMs) or 0) then
        return true
    end

    local currentText = tostring(speechData.text or "")
    local lastText = tostring(tracked.lastAmbientSpeechText or "")
    if currentText ~= "" and currentText == lastText and lastSpeechAt > 0
        and (currentTime - lastSpeechAt) < math.max(0, tonumber(Config.TextRepeatCooldownMs) or 0) then
        return true
    end

    return false
end

local function rememberAmbientSpeech(manager, tracked, speechData, currentTime)
    if not tracked or not speechData then
        return
    end

    tracked.lastAmbientSpeechAt = currentTime
    tracked.lastAmbientSpeechKey = speechData.speechKey
    tracked.lastAmbientSpeechText = speechData.text
    manager.globalAmbientCooldownUntil = currentTime + math.max(0, tonumber(Config.GlobalAmbientCooldownMs) or 0)
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

                    local duration = speech.expireTime - speech.timestamp
                    local progress = math.min(1, (currentTime - speech.timestamp) / duration)
                    
                    -- Smoothly cross-fade between fonts for gradual shrinkage
                    local function drawAnimatedSpeech(panel, text, x, y, r, g, b, baseAlpha, p)
                        local a1, a2 = 0, 0
                        if p < 0.4 then
                            a1 = (0.4 - p) / 0.4
                            a2 = p / 0.4
                        else
                            a2 = 1
                        end
                        
                        local finalAlpha = baseAlpha * ((p > 0.7) and (1 - (p - 0.7) / 0.3) or 1)
                        
                        if a1 > 0.05 then
                            local w = Ambient.textManager:MeasureStringX(UIFont.Medium, text)
                            panel:drawText(text, x - (w/2) + 1, y + 1, 0, 0, 0, finalAlpha * a1 * 0.7, UIFont.Medium)
                            panel:drawText(text, x - (w/2), y, r, g, b, finalAlpha * a1, UIFont.Medium)
                        end
                        if a2 > 0.05 then
                            local w = Ambient.textManager:MeasureStringX(Ambient.FONT_DIALOGUE, text)
                            panel:drawText(text, x - (w/2) + 1, y + 1, 0, 0, 0, finalAlpha * a2 * 0.7, Ambient.FONT_DIALOGUE)
                            panel:drawText(text, x - (w/2), y, r, g, b, finalAlpha * a2, Ambient.FONT_DIALOGUE)
                        end
                    end

                    drawAnimatedSpeech(self, speech.text, screenX, screenY, speech.color.r, speech.color.g, speech.color.b, speech.color.a * alpha, progress)
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
                Ambient.TouchTrackedEntry(tracked, zombie, npcData, tracked.bodyInstanceID, currentTime)
            end

            local inRange = zombie
                and not zombie:isDead()
                and math.abs(self.player:getZ() - zombie:getZ()) <= Config.FloorTolerance
                and Ambient.CalculateDistance(self.player, zombie) <= Config.TriggerDistance

            if inRange then
                local currentNoticeSerial = npcData and tonumber(npcData.protectNoticeSerial) or 0
                if currentNoticeSerial > 0 and currentNoticeSerial ~= tracked.lastProtectNoticeSerial and npcData then
                    local noticeSpeech = Ambient.BuildProtectNoticeSpeechData(npcData, zombie, currentTime)
                    tracked.lastProtectNoticeSerial = currentNoticeSerial
                    if noticeSpeech then
                        noticeSpeech.zombie = zombie
                        playSpeechAudio(zombie, npcData, noticeSpeech)
                        self.speechList[uuid] = noticeSpeech
                        Ambient.ScheduleRepeatSpeak(tracked, currentTime)
                    end
                end

                if not tracked.wasInRange or not tracked.nextSpeakAt then
                    Ambient.ScheduleInitialSpeak(tracked, currentTime)
                end

                local shouldSpeak = currentTime >= (tracked.nextSpeakAt or math.huge)
                if shouldSpeak and npcData then
                    local speechData = Ambient.BuildSpeechData(npcData, zombie, currentTime)
                    if speechData then
                        local throttled = shouldThrottleAmbientSpeech(self, tracked, speechData, currentTime)
                        if throttled then
                            Ambient.ScheduleRepeatSpeak(tracked, currentTime)
                        else
                            speechData.zombie = zombie
                            playSpeechAudio(zombie, npcData, speechData)
                            self.speechList[uuid] = speechData
                            rememberAmbientSpeech(self, tracked, speechData, currentTime)
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
                        end
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
                table.insert(staleUUIDs, { uuid = uuid, bodyInstanceID = tracked.bodyInstanceID })
            end
        end
    end

    for i = 1, #staleUUIDs do
        local stale = staleUUIDs[i]
        DTNPCClient.UntrackNPCAmbientDialogue(stale.uuid, stale.bodyInstanceID)
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
    o.globalAmbientCooldownUntil = 0
    o.speechList = {}
    o:setCapture(false)

    return o
end
