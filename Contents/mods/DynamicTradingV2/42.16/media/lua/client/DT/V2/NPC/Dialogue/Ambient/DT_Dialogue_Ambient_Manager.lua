-- ==============================================================================
-- DT_Dialogue_Ambient_Manager.lua
-- Ambient dialogue manager rendering and update methods.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

require "DT/Common/Dialogue/DT_Dialogue_Vocals"
require "Utils/ConfigManager/DT_ConfigManager"

local Ambient = DTNPCClient.DialogueAmbient
local Config = DTNPCClient.DialogueAmbientConfig or DTNPCClient.AmbientDialogueConfig
local DialogueVocals = DynamicTrading
    and DynamicTrading.Dialogue
    and DynamicTrading.Dialogue.Vocals

local function collapseAmbientCue(cueType)
    local normalizedCue = tostring(cueType or "")
    local baseCue = string.match(normalizedCue, "^([%a]+)_[%w]+$")
    if baseCue == "Chat" or baseCue == "Sigh" or baseCue == "Ambient" then
        return baseCue
    end
    return normalizedCue ~= "" and normalizedCue or "Chat"
end

local function isAmbientTextLogEnabled()
    if DT_ConfigManager and DT_ConfigManager.isAmbientTextLogsEnabled then
        return DT_ConfigManager.isAmbientTextLogsEnabled() == true
    end
    return false
end

local function isAmbientDebugEnabled()
    return DynamicTrading
        and DynamicTrading.Debug == true
        and DynamicTrading.Log
        and isAmbientTextLogEnabled()
end

local function playSpeechAudio(zombie, npcData, speechData)
    if not zombie or not speechData or not speechData.audio then
        return false
    end

    if DialogueVocals and DialogueVocals.PlaySpeechAudio then
        local played = DialogueVocals.PlaySpeechAudio(zombie, npcData, speechData.audio)
        if played then
            return true
        end
    end

    if DTNPCHostility and DTNPCHostility.PlayVocal and speechData.audio.vocalType then
        local cueType = speechData.audio.vocalType
        if speechData.audio.preferVariantPool == true then
            cueType = collapseAmbientCue(cueType)
        end
        return DTNPCHostility.PlayVocal(zombie, npcData, cueType, speechData.audio) ~= nil
    end

    return false
end

local function maybePlayRangeEnterAudio(tracked, zombie, npcData, currentTime)
    if not tracked or not zombie or not npcData then
        return false
    end

    local lastAt = tonumber(tracked.lastEntryAudioAt) or 0
    if lastAt > 0 and (currentTime - lastAt) < 6500 then
        return false
    end

    local fallbackAudio = Ambient.BuildFallbackAmbientAudio and Ambient.BuildFallbackAmbientAudio(npcData) or nil
    if not fallbackAudio then
        return false
    end

    tracked.lastEntryAudioAt = currentTime
    playSpeechAudio(zombie, npcData, { audio = fallbackAudio })
    return true
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

                if not tracked.wasInRange and npcData then
                    maybePlayRangeEnterAudio(tracked, zombie, npcData, currentTime)
                end

                if not tracked.wasInRange or not tracked.nextSpeakAt then
                    Ambient.ScheduleInitialSpeak(tracked, currentTime)
                end

                local shouldSpeak = currentTime >= (tracked.nextSpeakAt or math.huge)
                if shouldSpeak and npcData then
                    local speechData = Ambient.BuildSpeechData(npcData, zombie, currentTime)
                    if speechData then
                        speechData.zombie = zombie
                        playSpeechAudio(zombie, npcData, speechData)
                        self.speechList[uuid] = speechData
                        if isAmbientDebugEnabled() then
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
                        local fallbackAudio = Ambient.BuildFallbackAmbientAudio and Ambient.BuildFallbackAmbientAudio(npcData) or nil
                        if fallbackAudio then
                            playSpeechAudio(zombie, npcData, { audio = fallbackAudio })
                        end
                        if isAmbientDebugEnabled() then
                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Ambient",
                                "Ambient lookup returned no speech for "
                                    .. tostring(npcData.name or uuid)
                                    .. " [" .. tostring(npcData.status or "Default")
                                    .. "/" .. tostring(npcData.state or "Default") .. "]"
                                    .. (fallbackAudio and " (played pooled fallback vocal)" or "")
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
    o.speechList = {}
    o:setCapture(false)

    return o
end
