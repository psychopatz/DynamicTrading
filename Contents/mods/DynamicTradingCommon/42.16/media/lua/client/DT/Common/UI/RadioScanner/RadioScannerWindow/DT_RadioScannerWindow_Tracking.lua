require "DT/Common/Dialogue/DT_Dialogue_RadioTracker"

local function firstNonNil(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if value ~= nil then
            return value
        end
    end
    return nil
end

local function formatDisplayName(value)
    local text = tostring(value or "")
    if text == "" then
        return nil
    end

    text = string.gsub(text, "[_%-]+", " ")
    text = string.gsub(text, "(%l)(%u)", "%1 %2")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then
        return nil
    end
    return text
end

local function getLiveTrackedCharacter(uuid)
    local cell = getCell()
    if not cell then
        return nil
    end

    local zombieList = cell:getZombieList()
    if not zombieList then
        return nil
    end

    for index = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(index)
        if zombie then
            local modData = zombie:getModData()
            if modData and modData.DTNPC_UUID == uuid then
                return zombie
            end
        end
    end

    return nil
end

local function findTrackedListData(window, uuid)
    if not window or not window.listPanel or not window.listPanel.listbox then
        return nil
    end

    for _, item in ipairs(window.listPanel.listbox.items or {}) do
        if item and item.item and item.item.uuid == uuid then
            return item.item
        end
    end

    return nil
end

local function resolveTrackingCoords(data)
    if type(data) ~= "table" then
        return nil, nil, nil
    end

    local x = data.x
    local y = data.y
    local z = data.z
    if x == nil or y == nil then
        x = data.lastX
        y = data.lastY
        if z == nil then
            z = data.lastZ
        end
    end

    return x, y, z
end

local function buildTrackedTargetData(window, uuid)
    if not uuid or not DT_RadioScannerManager then
        return nil
    end

    local selectedData = window.trackingData or findTrackedListData(window, uuid)
    local soul = DT_RadioScannerManager.GetSoul and DT_RadioScannerManager.GetSoul(uuid) or nil
    local cachedEntry = DTNPCClient and DTNPCClient.NPCCache and DTNPCClient.NPCCache[uuid] or nil
    local npcData = cachedEntry and cachedEntry.npcData or nil
    local meta = DTNPCClient and DTNPCClient.GetMetadata and DTNPCClient.GetMetadata(uuid) or nil
    local tx, ty, tz = resolveTrackingCoords(selectedData)
    local isLive = selectedData and selectedData.isLive or nil
    if tx == nil or ty == nil then
        tx, ty, tz, isLive = DT_RadioScannerManager.GetTraderCoords(uuid)
    end
    local liveCharacter = getLiveTrackedCharacter(uuid)
    local selectedGender = selectedData and selectedData.gender or nil
    local isFemale = firstNonNil(
        selectedGender == "Female" and true or (selectedGender == "Male" and false or nil),
        soul and soul.isFemale,
        npcData and npcData.isFemale,
        meta and meta.isFemale,
        false
    ) == true
    local resolvedArchetype = firstNonNil(
        selectedData and selectedData.archetype,
        soul and (soul.archetypeID or soul.archetype),
        npcData and (npcData.archetypeID or npcData.archetype),
        meta and (meta.archetypeID or meta.archetype),
        "General"
    )

    local targetData = {
        uuid = uuid,
        name = firstNonNil(
            selectedData and selectedData.name,
            soul and soul.name,
            npcData and npcData.name,
            meta and meta.name,
            window.trackingName,
            "Unknown Signal"
        ),
        archetype = resolvedArchetype,
        archetypeID = resolvedArchetype,
        identitySeed = tonumber(firstNonNil(
            selectedData and selectedData.identitySeed,
            soul and soul.identitySeed,
            npcData and npcData.identitySeed,
            meta and meta.identitySeed,
            1
        )) or 1,
        gender = isFemale and "Female" or "Male",
        isFemale = isFemale,
        factionID = firstNonNil(
            selectedData and (selectedData.factionID or selectedData.faction),
            soul and soul.factionID,
            npcData and npcData.factionID,
            meta and meta.factionID,
            "Independent"
        ),
        factionName = selectedData and selectedData.factionName or nil,
        status = firstNonNil(soul and soul.status, npcData and npcData.status, meta and meta.status, "Unknown"),
        state = firstNonNil(soul and soul.state, npcData and npcData.state, meta and meta.state, "Unknown"),
        returnTime = firstNonNil(soul and soul.returnTime, npcData and npcData.returnTime, meta and meta.returnTime),
        x = tx,
        y = ty,
        z = tz,
        lastX = tx,
        lastY = ty,
        lastZ = tz,
        isLive = isLive == true,
        npcRef = liveCharacter,
        homeName = firstNonNil(
            soul and soul.homeCoords and soul.homeCoords.name,
            npcData and npcData.homeCoords and npcData.homeCoords.name,
            meta and meta.homeCoords and meta.homeCoords.name
        ),
    }

    if targetData.name == nil then
        return nil
    end

    return targetData
end

local function getTrackedLocationDetails(targetData)
    local result = {
        town = "Unknown",
        county = "Unknown",
        zone = "None",
        zoneLabel = nil,
        room = "Outside",
        roomLabel = nil,
        buildingLabel = formatDisplayName(targetData and targetData.homeName) or nil,
        safehouse = "None",
    }

    local x = targetData and targetData.lastX or nil
    local y = targetData and targetData.lastY or nil
    local z = targetData and targetData.lastZ or nil
    if not x or not y then
        return result
    end

    if DTM and DTM.GetTownName then
        result.town = tostring(DTM.GetTownName(x, y) or "Unknown")
    end
    if DTM and DTM.GetCountyName then
        result.county = tostring(DTM.GetCountyName(x, y) or "Unknown")
    end

    local cell = getCell()
    local square = cell and cell:getGridSquare(math.floor(x), math.floor(y), math.floor(z or 0)) or nil
    if square then
        local room = square:getRoom()
        if room then
            result.room = tostring(room:getName() or "Unknown Room")
            result.roomLabel = formatDisplayName(result.room)

            local building = square:getBuilding()
            if building then
                local def = building:getDef()
                if def and not result.buildingLabel then
                    local w = tonumber(def:getW() or 0) or 0
                    local h = tonumber(def:getH() or 0) or 0
                    if w > 0 and h > 0 then
                        result.buildingLabel = string.format("a %dx%d building", w, h)
                    end
                end
            end
        end

        if SafeHouse and SafeHouse.getSafeHouse then
            local safehouse = SafeHouse.getSafeHouse(square)
            if safehouse then
                result.safehouse = tostring(safehouse:getTitle() or safehouse:getOwner() or "Safehouse")
            end
        end
    end

    local meta = getWorld() and getWorld():getMetaGrid() or nil
    if meta then
        local zones = meta:getZonesAt(math.floor(x), math.floor(y), math.floor(z or 0))
        if zones and zones:size() > 0 then
            for index = 0, zones:size() - 1 do
                local zone = zones:get(index)
                local zoneType = zone and zone:getType() or nil
                if zoneType and zoneType ~= "World" then
                    result.zone = zoneType
                    result.zoneLabel = formatDisplayName(zoneType)
                    break
                end
            end
        end
    end

    return result
end

local function buildTrackedContext(targetData)
    if not targetData then
        return nil
    end

    local location = getTrackedLocationDetails(targetData)
    local coordsText = "Coordinates Unknown"
    if targetData.lastX and targetData.lastY then
        coordsText = string.format("%d, %d, %d", math.floor(targetData.lastX), math.floor(targetData.lastY), math.floor(targetData.lastZ or 0))
    end

    local signalLead = targetData.isLive and "I'm at" or "Last clean ping had me at"
    local siteDescription = "out in the open"
    if location.safehouse ~= "None" then
        siteDescription = "inside the safehouse tagged " .. tostring(location.safehouse)
    elseif location.room ~= "Outside" then
        local roomLabel = location.roomLabel or "interior"
        if location.buildingLabel then
            siteDescription = "inside " .. tostring(location.buildingLabel) .. ", around the " .. tostring(roomLabel)
        else
            siteDescription = "inside the " .. tostring(roomLabel)
        end
    elseif location.zoneLabel then
        if location.town ~= "Unknown" then
            siteDescription = "out in the " .. tostring(location.zoneLabel) .. " near " .. tostring(location.town)
        else
            siteDescription = "out in the " .. tostring(location.zoneLabel)
        end
    elseif location.town ~= "Unknown" then
        siteDescription = "near " .. tostring(location.town)
    end

    local distance = nil
    local player = getSpecificPlayer(0)
    if player and targetData.lastX and targetData.lastY then
        distance = IsoUtils.DistanceTo(targetData.lastX, targetData.lastY, player:getX(), player:getY())
    end

    return {
        seed = targetData.identitySeed,
        isLive = targetData.isLive == true,
        signalLead = signalLead,
        signalBadge = targetData.isLive and "LIVE SIGNAL" or "LAST KNOWN",
        distance = distance,
        coordsText = coordsText,
        siteDescription = siteDescription,
        location = location,
    }
end

local function buildTrackingReplyKey(targetData, context)
    local location = context and context.location or {}
    return table.concat({
        tostring(targetData and targetData.uuid or "none"),
        tostring(context and context.coordsText or "unknown"),
        tostring(context and context.isLive or false),
        tostring(location.room or "Outside"),
        tostring(location.safehouse or "None"),
        tostring(location.buildingLabel or ""),
    }, ":")
end

local function buildTrackingPanelHeading(targetData)
    if not targetData or not targetData.name then
        return "Tracked Channel:"
    end
    return "Tracked Channel: " .. tostring(targetData.name)
end

local function buildDiscoveryPanelHeading(targetData)
    if not targetData or not targetData.name then
        return "Open Channel:"
    end
    return "Open Channel: " .. tostring(targetData.name)
end

local TRACKING_PROXIMITY_STAGES = {
    { distance = 3000, key = "Approach3000" },
    { distance = 2000, key = "Approach2000" },
    { distance = 1500, key = "Approach1500" },
    { distance = 1000, key = "Approach1000" },
    { distance = 750, key = "Approach750" },
    { distance = 500, key = "Approach500" },
    { distance = 300, key = "Approach300" },
    { distance = 200, key = "Approach200" },
    { distance = 150, key = "Approach150" },
    { distance = 100, key = "Approach100" },
    { distance = 75, key = "Approach75" },
    { distance = 50, key = "Approach50" },
    { distance = 25, key = "Approach25" },
    { distance = 10, key = "Approach10" },
}

local function getTrackingProgressDepth(distance)
    if not distance then
        return 0
    end

    local depth = 0
    for index, stage in ipairs(TRACKING_PROXIMITY_STAGES) do
        if distance <= stage.distance then
            depth = index
        end
    end

    return depth
end

local function getTrackingDistanceToTarget(window)
    if not window or not window.trackingUUID or not DT_RadioScannerManager then
        return nil
    end

    local tx, ty = resolveTrackingCoords(window.trackingData)
    if tx == nil or ty == nil then
        tx, ty = DT_RadioScannerManager.GetTraderCoords(window.trackingUUID)
    end
    local player = getSpecificPlayer(0)
    if not tx or not ty or not player then
        return nil
    end

    return IsoUtils.DistanceTo(tx, ty, player:getX(), player:getY())
end

function DT_RadioScannerWindow:clearTrackingConversation()
    self.trackingMessageQueue = {}
    self.trackingMilestones = nil
    self.trackingAwayTriggered = nil
    self.lastTrackingDistance = nil
    self.lastAwayDepth = nil
    self.lastTriggeredTrackingDepth = nil
    self.discoveryTargetData = nil
    self.discoveryContext = nil
    if self.trackingDialoguePanel then
        self.trackingDialoguePanel:clearMessages()
        self.trackingDialoguePanel:setHeadingText("Tracked Channel:")
    end
end

function DT_RadioScannerWindow:queueTrackingConversationMessage(text, isPlayer, delay, isError)
    self.trackingMessageQueue = self.trackingMessageQueue or {}
    table.insert(self.trackingMessageQueue, {
        text = tostring(text or "..."),
        isPlayer = isPlayer == true,
        isError = isError == true,
        delay = tonumber(delay or 0) or 0,
    })
end

function DT_RadioScannerWindow:processTrackingDialogueQueue(uiDt)
    if not self.trackingDialoguePanel then
        return
    end

    local queue = self.trackingMessageQueue or {}
    if #queue == 0 then
        self.trackingDialoguePanel:setTypingVisible(false)
        return
    end

    local nextMessage = queue[1]
    local showTyping = (not nextMessage.isPlayer) and (nextMessage.delay or 0) > 0
    self.trackingDialoguePanel:setTypingVisible(showTyping)

    if nextMessage.delay and nextMessage.delay > 0 then
        nextMessage.delay = math.max(0, nextMessage.delay - uiDt)
        return
    end

    self.trackingDialoguePanel:addMessage(nextMessage.text, nextMessage.isPlayer, nextMessage.isError)
    self.trackingDialoguePanel:setTypingVisible(false)
    if (not nextMessage.isPlayer) and self.trackedPortraitPanel and self.trackedPortraitPanel.pulseSpeechAnimation then
        self.trackedPortraitPanel:pulseSpeechAnimation(48)
    end
    table.remove(queue, 1)
end

function DT_RadioScannerWindow:startTrackingConversation(targetData, context)
    if not self.trackingDialoguePanel then
        return
    end

    self.discoveryTargetData = nil
    self.discoveryContext = nil
    self:clearTrackingConversation()
    self.trackingDialoguePanel:setHeadingText(buildTrackingPanelHeading(targetData))

    local playerRequest = DynamicTrading.Dialogue.RadioTracker.GeneratePlayerRequest(targetData, context)
    local reply = DynamicTrading.Dialogue.RadioTracker.GenerateReply(targetData, context)

    self:queueTrackingConversationMessage(playerRequest, true, 0, false)
    self:queueTrackingConversationMessage(reply, false, 0.9, false)
end

function DT_RadioScannerWindow:showDiscoveryConversation(targetData, context, force)
    if not self.trackingDialoguePanel or not targetData or not context then
        return
    end

    if not force and self.trackingUUID then
        return
    end

    local heading = buildDiscoveryPanelHeading(targetData)
    local shouldSkip = force ~= true
        and self.discoveryTargetData
        and tostring(self.discoveryTargetData.uuid or "") == tostring(targetData.uuid or "")
        and self.trackingDialoguePanel
        and #(self.trackingDialoguePanel.localLogs or {}) > 0
    if shouldSkip then
        self.trackingDialoguePanel:setHeadingText(heading)
        return
    end

    self.trackingMessageQueue = {}
    self.trackingMilestones = nil
    self.trackingAwayTriggered = nil
    self.lastTrackingDistance = nil
    self.lastAwayDepth = nil
    self.lastTriggeredTrackingDepth = nil
    self.discoveryTargetData = targetData
    self.discoveryContext = context
    self.trackingDialoguePanel:clearMessages()
    self.trackingDialoguePanel:setHeadingText(heading)

    local playerRequest = DynamicTrading.Dialogue.RadioTracker.GeneratePlayerRequest(targetData, context)
    local reply = DynamicTrading.Dialogue.RadioTracker.GenerateReply(targetData, context)
    self:queueTrackingConversationMessage(playerRequest, true, 0, false)
    self:queueTrackingConversationMessage(reply, false, 0.9, false)
end

function DT_RadioScannerWindow:showDiscoveryConversationForSignal(uuid, data, force)
    if self.trackingUUID then
        return
    end

    if uuid == nil or uuid == "" then
        return
    end

    local previousData = self.trackingData
    local previousName = self.trackingName
    self.trackingData = data or self.trackingData
    self.trackingName = (data and data.name) or self.trackingName

    local targetData = buildTrackedTargetData(self, uuid)
    local context = targetData and buildTrackedContext(targetData) or nil

    self.trackingData = previousData
    self.trackingName = previousName

    if targetData and context then
        self:showDiscoveryConversation(targetData, context, force)
    end
end

function DT_RadioScannerWindow:processTrackingProximityDialogue()
    if not self.trackingUUID or not self.trackingData or not self.trackingContext then
        return
    end

    self.trackingMilestones = self.trackingMilestones or {}
    local distance = getTrackingDistanceToTarget(self)
    if not distance then
        return
    end

    self.trackingContext.distance = distance

    local currentDepth = getTrackingProgressDepth(distance)
    local lastTriggeredDepth = self.lastTriggeredTrackingDepth or 0
    if currentDepth > lastTriggeredDepth then
        local stage = TRACKING_PROXIMITY_STAGES[currentDepth]
        if stage and self.trackingMilestones[stage.key] ~= true then
            self.trackingMilestones[stage.key] = true
            self.lastTriggeredTrackingDepth = currentDepth

            local playerLine = DynamicTrading.Dialogue.RadioTracker.GeneratePlayerApproach(self.trackingData, self.trackingContext, stage.key)
            local replyLine = DynamicTrading.Dialogue.RadioTracker.GenerateApproachReply(self.trackingData, self.trackingContext, stage.key)
            self:queueTrackingConversationMessage(playerLine, true, 0, false)
            self:queueTrackingConversationMessage(replyLine, false, 0.9, false)

            self.trackingAwayTriggered = false
        end
    end

    if self.lastTrackingDistance and distance > (self.lastTrackingDistance + 15) then
        if not self.trackingAwayTriggered then
            local playerLine = DynamicTrading.Dialogue.RadioTracker.GeneratePlayerAway(self.trackingData, self.trackingContext)
            local replyLine = DynamicTrading.Dialogue.RadioTracker.GenerateAwayReply(self.trackingData, self.trackingContext)
            self:queueTrackingConversationMessage(playerLine, true, 0, false)
            self:queueTrackingConversationMessage(replyLine, false, 0.9, false)
            self.trackingAwayTriggered = true
            self.lastAwayDepth = currentDepth
        end
    end

    if self.trackingAwayTriggered and self.lastAwayDepth and currentDepth >= (self.lastAwayDepth + 2) then
        self.trackingAwayTriggered = false
        self.lastAwayDepth = nil
    end

    self.lastTrackingDistance = distance
end

function DT_RadioScannerWindow:refreshTrackingPresentation(force)
    if not self.signalDisplayPanel or not self.trackedPortraitPanel then
        return
    end

    if not self.trackingUUID then
        self.signalDisplayPanel:setVisible(true)
        self.trackedPortraitPanel:setVisible(false)
        self.trackedPortraitPanel:clearTrackingInfo(force)
        if self.trackingDialoguePanel then
            if self.discoveryTargetData then
                self.trackingDialoguePanel:setHeadingText(buildDiscoveryPanelHeading(self.discoveryTargetData))
            else
                self.trackingDialoguePanel:setHeadingText("Tracked Channel:")
            end
        end
        return
    end

    local targetData = buildTrackedTargetData(self, self.trackingUUID)
    if not targetData then
        self.signalDisplayPanel:setVisible(true)
        self.trackedPortraitPanel:setVisible(false)
        self.trackedPortraitPanel:clearTrackingInfo(force)
        return
    end

    local context = buildTrackedContext(targetData)
    self.trackingData = targetData
    self.trackingContext = context
    self.signalDisplayPanel:setVisible(false)
    self.trackedPortraitPanel:setVisible(true)
    self.trackedPortraitPanel:setTrackingInfo(targetData, context, force)
    if self.trackingDialoguePanel then
        self.trackingDialoguePanel:setHeadingText(buildTrackingPanelHeading(targetData))
    end
end

function DT_RadioScannerWindow:startTracking(uuid, name, data)
    self.trackingUUID = uuid
    self.trackingName = name
    self.trackingData = data
    self.trackingContext = nil
    self.trackingMilestones = {}
    self.trackingAwayTriggered = false
    self.lastTrackingDistance = nil
    self.lastAwayDepth = nil
    self.lastTriggeredTrackingDepth = 0
    self:refreshTrackingPresentation(true)

    local targetData = buildTrackedTargetData(self, uuid)
    local context = targetData and buildTrackedContext(targetData) or nil
    if targetData and context then
        self.trackingData = targetData
        self.trackingContext = context
        self:startTrackingConversation(targetData, context)
    else
        self:clearTrackingConversation()
    end

    getSpecificPlayer(0):Say("Tracking signal: " .. tostring(name))
end

function DT_RadioScannerWindow:stopTracking()
    self.trackingUUID = nil
    self.trackingName = nil
    self.trackingData = nil
    self.trackingContext = nil
    self:clearTrackingConversation()
    if EventMarkerHandler then
        EventMarkerHandler.remove(self.MARKER_ID)
    end

    if self.refreshTrackingPresentation then
        self:refreshTrackingPresentation(true)
    end

    if self.listPanel and self.listPanel.listbox then
        local selected = self.listPanel.listbox.selected
        if selected and self.listPanel.listbox.items[selected] then
            local itemData = self.listPanel.listbox.items[selected].item
            if itemData then
                self.actionPanel:updateButtonState(itemData.uuid)
            end
        end
    end
end

function DT_RadioScannerWindow:updateTrackingMarker()
    if not self.trackingUUID or not EventMarkerHandler or not DT_RadioScannerManager then
        return
    end

    local tx, ty = resolveTrackingCoords(self.trackingData)
    if tx == nil or ty == nil then
        tx, ty = DT_RadioScannerManager.GetTraderCoords(self.trackingUUID)
    end
    if not tx or not ty then
        return
    end

    local player = getSpecificPlayer(0)
    local dist = IsoUtils.DistanceTo(tx, ty, player:getX(), player:getY())
    local color = { r = 0, g = 1, b = 1 }

    if dist < 300 then
        color = { r = 0.1, g = 1, b = 0.1 }
    elseif dist < 1500 then
        color = { r = 1, g = 0.9, b = 0.2 }
    else
        color = { r = 1, g = 0.4, b = 0.1 }
    end

    EventMarkerHandler.set(
        self.MARKER_ID,
        "friend.png",
        60,
        tx,
        ty,
        color,
        "SIGNAL: " .. tostring(self.trackingName)
    )

    self:processTrackingProximityDialogue()
end
