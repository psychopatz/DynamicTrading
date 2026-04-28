function DT_RadioScannerWindow:setCategory(category)
    if self.currentCategory == category then
        return
    end

    self.currentCategory = category
    if self.listPanel and self.listPanel.setLayoutMode then
        self.listPanel:setLayoutMode(category)
    end

    self:refresh()
end

function DT_RadioScannerWindow:updateSignalDisplayState(bestRange)
    if not self.signalDisplayPanel then
        return
    end

    local state = "none"
    local player = getSpecificPlayer(0)
    local scanStatus = DT_RadioScannerManager and DT_RadioScannerManager.GetScanStatus and DT_RadioScannerManager.GetScanStatus(self.device, player) or nil
    local foundCount = scanStatus and scanStatus.foundCount or (DT_RadioScannerManager and DT_RadioScannerManager.GetCount and DT_RadioScannerManager.GetCount() or 0)
    local rosterData = DT_RadioScannerManager and DT_RadioScannerManager.GetRosterData and DT_RadioScannerManager.GetRosterData() or nil
    local totalTrading = 0
    local currentHours = getGameTime():getWorldAgeHours()
    local hasReusableSlots = true

    if scanStatus then
        hasReusableSlots = (scanStatus.availableSlots or 0) > 0 or (scanStatus.replaceableSlots or 0) > 0
    end

    if rosterData and rosterData.Souls then
        for _, soul in pairs(rosterData.Souls) do
            local isExpired = soul.returnTime and soul.returnTime <= currentHours
            if soul.status == "Trading" and not isExpired and soul.state ~= "Departure" then
                totalTrading = totalTrading + 1
            end
        end
    end

    self.lastFoundCount = self.lastFoundCount or foundCount
    if foundCount > self.lastFoundCount then
        self.foundVisualTimer = 2.0
    end
    self.lastFoundCount = foundCount

    local currentHour = getGameTime():getTimeOfDay()
    local gateDisabled = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.DisableNightScanGate == true
    local isNightDisabled = not gateDisabled and (currentHour >= 22.0 or currentHour < 5.0)

    if (bestRange or 0) > 0 then
        state = "search"
        if totalTrading == 0 or isNightDisabled then
            state = "none"
        end
        if not isNightDisabled and self.foundVisualTimer and self.foundVisualTimer > 0 then
            state = "found"
        end
    end

    self.signalDisplayPanel:setSignalState(state)
end

function DT_RadioScannerWindow:refresh()
    if not self.listPanel or not self.headerPanel or not self.actionPanel then
        return
    end

    local listbox = self.listPanel.listbox
    local selectedUUID = nil
    if listbox.selected and listbox.selected ~= -1 and listbox.items[listbox.selected] and listbox.items[listbox.selected].item then
        selectedUUID = listbox.items[listbox.selected].item.uuid
    end

    listbox:clear()
    listbox.selected = -1

    if self.actionPanel and self.actionPanel.updateSelectionState then
        self.actionPanel:updateSelectionState(nil)
    end

    if not DT_RadioScannerManager then
        return
    end

    local player = getSpecificPlayer(0)
    if not player then
        return
    end

    local bestRange = 0
    local bestName = "Unknown"
    local bestProfile = nil
    local bestDevice = self.device
    if self.device then
        bestName, bestRange = DT_RadioScannerManager.GetDeviceInfo(self.device)
        if DT_RadioScannerManager.GetDeviceProfile then
            bestProfile = DT_RadioScannerManager.GetDeviceProfile(self.device)
        end
    end

    if bestRange == 0 then
        local items = player:getInventory():getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item:getCategory() == "Communications" and item:getIsTwoWay() then
                local name, range = DT_RadioScannerManager.GetDeviceInfo(item)
                if range > bestRange then
                    bestRange = range
                    bestName = name
                    bestDevice = item
                    if DT_RadioScannerManager.GetDeviceProfile then
                        bestProfile = DT_RadioScannerManager.GetDeviceProfile(item)
                    end
                end
            end
        end
    end

    if bestProfile and self.signalDisplayPanel then
        local leftColumnWidth = self.signalDisplayPanel:getWidth()
        local targetPadding = math.max(6, math.floor(leftColumnWidth * 0.05))
        self.signalDisplayPanel.padding = targetPadding
    end

    local function formatExpireCountdown(hoursRemaining)
        if not hoursRemaining or hoursRemaining <= 0 then
            return "now"
        end
        local totalSeconds = math.max(1, math.floor(hoursRemaining * 3600))
        local totalMinutes = math.floor(totalSeconds / 60)
        local remainingSeconds = totalSeconds % 60
        local wholeHours = math.floor(totalMinutes / 60)
        local remainingMinutes = totalMinutes % 60

        if wholeHours > 0 then
            return string.format("%dh %02dm", wholeHours, remainingMinutes)
        end
        if totalMinutes > 0 then
            return string.format("%dm %02ds", totalMinutes, remainingSeconds)
        end
        return string.format("%ds", totalSeconds)
    end

    local function normalizeText(value)
        local text = tostring(value or "")
        if text == "" then
            return nil
        end
        return string.lower(text)
    end

    local function isCallableTradeActiveForPlayer(contact)
        if not contact or contact.contactVisitActive ~= true then
            return false
        end

        local playerID = player.getOnlineID and player:getOnlineID() or nil
        local requestedByID = contact.contactVisitRequestedByID
        local username = normalizeText(player.getUsername and player:getUsername() or nil)
        local requestedByName = normalizeText(contact.contactVisitRequestedBy)
        local isRequestedByPlayer = false

        if playerID ~= nil and requestedByID ~= nil and tonumber(requestedByID) == tonumber(playerID) then
            isRequestedByPlayer = true
        elseif username and requestedByName == username then
            isRequestedByPlayer = true
        end

        if not isRequestedByPlayer then
            return false
        end

        local status = tostring(contact.status or "")
        local state = tostring(contact.state or "")
        local returnStatus = tostring(contact.returnStatus or "")
        local visitMode = tostring(contact.contactVisitMode or "")

        return (status == "Away" and returnStatus == "Trading")
            or status == "Trading"
            or state == "Departure"
            or state == "Trading"
            or state == "Follow"
            or visitMode == "Departure"
            or visitMode == "Trading"
            or visitMode == "Follow"
    end

    if DT_RadioScannerManager and DT_RadioScannerManager.Cleanup then
        DT_RadioScannerManager.Cleanup(player)
    end

    self.headerPanel:updateSignalInfo(bestName, bestRange)
    if self.headerPanel.updateScanStats then
        local scanPreview = DT_RadioScannerManager.GetScanPreview and DT_RadioScannerManager.GetScanPreview(bestDevice, player) or nil
        self.headerPanel:updateScanStats(scanPreview)
    end
    self:updateSignalDisplayState(bestRange)

    if self.statusPanel and DT_RadioScannerManager and DT_RadioScannerManager.GetScanStatus then
        self.statusPanel:setStatus(DT_RadioScannerManager.GetScanStatus(self.device, player))
    end

    if self.currentCategory == "Quest" then
        local questEntries = {}
        if DynamicObjectives and DynamicObjectives.UI then
            if self.skipQuestServerRefresh == true then
                self.skipQuestServerRefresh = false
            elseif DynamicObjectives.UI.RequestScannerQuestRefresh then
                DynamicObjectives.UI.RequestScannerQuestRefresh(player)
            end
            if DynamicObjectives.UI.GetScannerQuestEntries then
                questEntries = DynamicObjectives.UI.GetScannerQuestEntries(player) or {}
            end
        end

        for _, entry in ipairs(questEntries) do
            listbox:addItem(entry.name or "Quest", {
                uuid = entry.uuid,
                hookId = entry.hookId,
                incidentId = entry.incidentId,
                questID = entry.questID,
                entryKind = entry.entryKind,
                name = entry.name,
                faction = entry.faction,
                factionName = entry.factionName or entry.faction or "Independent",
                archetype = entry.archetype or "Quest",
                gender = entry.gender or "Unknown",
                identitySeed = tonumber(entry.identitySeed) or 1,
                distText = entry.distText or "Signal: Quest",
                expireText = entry.expireText or "",
                rewardText = entry.rewardText or "",
                detailText = entry.detailText or "",
                isLive = entry.isLive == true,
                x = entry.x,
                y = entry.y,
                z = entry.z,
                locked = false,
                canLock = false,
                offerBlueprintId = entry.offerBlueprintId,
                traderContext = entry.traderContext,
            })

            if selectedUUID == entry.uuid and #listbox.items > 0 then
                listbox.selected = #listbox.items
            end
        end

        local selectedData = nil
        if listbox.selected and listbox.selected ~= -1 then
            local selectedItem = listbox.items[listbox.selected]
            selectedData = selectedItem and selectedItem.item or nil
        end

        if self.actionPanel and self.actionPanel.updateSelectionState then
            self.actionPanel:updateSelectionState(selectedData)
        end

        if self.refreshTrackingPresentation then
            self:refreshTrackingPresentation(false)
        end
        return
    end

    if self.currentCategory == "Location" then
        if DT_RadioScannerLocationHandler then
            DT_RadioScannerLocationHandler.PopulateList(listbox, player)
        else
            listbox:addItem("Module Missing: LocationHandler", {})
        end
        if self.actionPanel and self.actionPanel.updateSelectionState then
            self.actionPanel:updateSelectionState(nil)
        end
        if self.refreshTrackingPresentation then
            self:refreshTrackingPresentation(false)
        end
        return
    end
    local tempList = {}

    local function isOwnedTravelCompanion(npcData)
        if not npcData then return false end

        local isCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            or tostring(npcData.linkedWorkerID or "") ~= ""
        if not isCompanion then return false end

        local playerID = player.getOnlineID and player:getOnlineID() or nil
        if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end

        local username = normalizeText(player.getUsername and player:getUsername() or nil)
        if not username then return false end

        return normalizeText(npcData.master) == username
            or normalizeText(npcData.ownerUsername) == username
            or normalizeText(npcData.dcCompanionOwner) == username
    end

    local function buildDistanceEntry(uuid, data, soul)
        local tx, ty, tz, isLive = DT_RadioScannerManager.GetTraderCoords(uuid)
        local dist = 99999
        local distText = "Distance: Unknown"

        if tx and ty then
            local dx = tx - player:getX()
            local dy = ty - player:getY()
            dist = math.sqrt(dx * dx + dy * dy)
            distText = string.format("Distance: %.0fm", dist)
        end

        return {
            uuid = uuid,
            data = data,
            soul = soul,
            tx = tx,
            ty = ty,
            tz = tz,
            isLive = isLive,
            dist = dist,
            distText = distText,
        }
    end

    local function shouldShowCallableContact(contact)
        if not contact or tostring(contact.status or "") == "Dead" then
            return false
        end

        local refreshed = DT_TraderContacts and DT_TraderContacts.RefreshContactData and DT_TraderContacts.RefreshContactData(contact) or contact
        return isCallableTradeActiveForPlayer(refreshed)
    end

    if self.currentCategory == "Discovered" then
        for uuid, data in pairs(DT_RadioScannerManager.FoundTraders) do
            table.insert(tempList, buildDistanceEntry(uuid, data, DT_RadioScannerManager.GetSoul(uuid)))
        end
    elseif self.currentCategory == "Linked" then
        local seenUUIDs = {}
        local cache = DTNPCClient and DTNPCClient.NPCCache or nil
        if cache then
            for uuid, cached in pairs(cache) do
                local npcData = cached and cached.npcData or nil
                if uuid and npcData and isOwnedTravelCompanion(npcData) and not seenUUIDs[uuid] then
                    seenUUIDs[uuid] = true
                    table.insert(tempList, buildDistanceEntry(uuid, {
                        name = npcData.name or "Companion",
                        faction = npcData.factionID or npcData.faction or "Independent",
                    }, npcData))
                end
            end
        end

        local metadataCache = DTNPCClient and DTNPCClient.MetadataCache or nil
        if metadataCache then
            for uuid, meta in pairs(metadataCache) do
                if uuid and meta and meta.isCallableCompanion == true and not seenUUIDs[uuid] then
                    seenUUIDs[uuid] = true
                    table.insert(tempList, buildDistanceEntry(uuid, {
                        name = meta.name or "Companion",
                        faction = meta.factionID or meta.faction or "Independent",
                    }, meta))
                end
            end
        end

        if DT_TraderContacts and DT_TraderContacts.GetAllContacts and DT_TraderContacts.RefreshContactData then
            for _, savedContact in ipairs(DT_TraderContacts.GetAllContacts(player)) do
                local contact = DT_TraderContacts.RefreshContactData(savedContact)
                local uuid = contact and tostring(contact.id or contact.uuid or "") or nil
                if uuid and uuid ~= "" and not seenUUIDs[uuid] and shouldShowCallableContact(contact) then
                    seenUUIDs[uuid] = true
                    table.insert(tempList, buildDistanceEntry(uuid, {
                        name = contact.name or "Contact",
                        faction = contact.factionID or contact.faction or "Independent",
                        factionName = contact.factionName,
                        archetype = contact.archetype or contact.archetypeID,
                        gender = contact.gender,
                        identitySeed = contact.identitySeed,
                        occupation = contact.occupation,
                    }, contact))
                end
            end
        end
    end

    table.sort(tempList, function(a, b)
        return (a.dist or 999999) < (b.dist or 999999)
    end)

    for _, entry in ipairs(tempList) do
        local uuid = entry.uuid
        local data = entry.data
        local soul = entry.soul or DT_RadioScannerManager.GetSoul(uuid) or (DTNPCClient and DTNPCClient.GetMetadata and DTNPCClient.GetMetadata(uuid) or nil)
        local archetypeID = (soul and (soul.archetypeID or soul.archetype)) or data.archetype or data.occupation or "General"
        local gender = data.gender or ((soul and soul.isFemale) and "Female" or "Male")
        local identitySeed = tonumber(data.identitySeed) or (soul and soul.identitySeed) or 1

        local factionData = DT_RadioScannerManager.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.factionName or data.faction or "Independent"
        if self.currentCategory == "Linked" and DT_TraderContacts and DT_TraderContacts.GetFactionDisplayName then
            factionName = DT_TraderContacts.GetFactionDisplayName(soul or data)
        end

        local expireText = ""
        if soul and soul.isCallableCompanion == true then
            expireText = soul.state and ("State: " .. tostring(soul.state)) or "Companion"
        elseif self.currentCategory == "Linked" and DT_TraderContacts and DT_TraderContacts.GetStatusText then
            expireText = DT_TraderContacts.GetStatusText(soul)
        elseif soul and soul.returnTime and soul.returnTime > 0 then
            local hoursRemaining = soul.returnTime - getGameTime():getWorldAgeHours()
            if hoursRemaining < 0 then hoursRemaining = 0 end
            expireText = "Expires: " .. formatExpireCountdown(hoursRemaining)
        end

        listbox:addItem(data.name, {
            uuid = uuid,
            name = data.name,
            faction = data.faction,
            factionName = factionName,
            archetype = archetypeID,
            gender = gender,
            identitySeed = identitySeed,
            distText = entry.distText,
            expireText = expireText,
            isLive = entry.isLive,
            x = entry.tx,
            y = entry.ty,
            z = entry.tz,
            locked = DT_RadioScannerManager and DT_RadioScannerManager.IsLocked and DT_RadioScannerManager.IsLocked(uuid) or (data.locked == true),
            canLock = self.currentCategory == "Discovered",
        })

        if selectedUUID == uuid and #listbox.items > 0 then
            listbox.selected = #listbox.items
        end
    end

    local selectedData = nil
    if listbox.selected and listbox.selected ~= -1 then
        local selectedItem = listbox.items[listbox.selected]
        selectedData = selectedItem and selectedItem.item or nil
    end

    if self.actionPanel and self.actionPanel.updateSelectionState then
        self.actionPanel:updateSelectionState(selectedData)
    end

    if self.refreshTrackingPresentation then
        self:refreshTrackingPresentation(false)
    end
end
