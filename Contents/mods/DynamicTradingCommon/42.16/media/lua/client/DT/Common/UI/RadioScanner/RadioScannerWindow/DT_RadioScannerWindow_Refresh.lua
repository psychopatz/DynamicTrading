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

    if foundCount > 0 then
        state = "found"
    elseif (bestRange or 0) > 0 and totalTrading > foundCount and hasReusableSlots then
        state = "search"
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
    if self.device then
        bestName, bestRange = DT_RadioScannerManager.GetDeviceInfo(self.device)
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
                end
            end
        end
    end

    self.headerPanel:updateSignalInfo(bestName, bestRange)
    self:updateSignalDisplayState(bestRange)

    if self.statusPanel and DT_RadioScannerManager and DT_RadioScannerManager.GetScanStatus then
        self.statusPanel:setStatus(DT_RadioScannerManager.GetScanStatus(self.device, player))
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
        return
    end

    DT_RadioScannerManager.Cleanup()

    local tempList = {}

    local function normalizeText(value)
        local text = tostring(value or "")
        if text == "" then
            return nil
        end
        return string.lower(text)
    end

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
        return contact and tostring(contact.status or "") ~= "Dead"
    end

    if self.currentCategory == "Stationary" then
        for uuid, data in pairs(DT_RadioScannerManager.FoundTraders) do
            table.insert(tempList, buildDistanceEntry(uuid, data, DT_RadioScannerManager.GetSoul(uuid)))
        end
    elseif self.currentCategory == "Callable" then
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
        local archetypeID = soul and soul.archetypeID or "General"
        local gender = (soul and soul.isFemale) and "Female" or "Male"
        local identitySeed = soul and soul.identitySeed or 1

        local factionData = DT_RadioScannerManager.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.factionName or data.faction or "Independent"
        if self.currentCategory == "Callable" and DT_TraderContacts and DT_TraderContacts.GetFactionDisplayName then
            factionName = DT_TraderContacts.GetFactionDisplayName(soul or data)
        end

        local expireText = ""
        if soul and soul.isCallableCompanion == true then
            expireText = soul.state and ("State: " .. tostring(soul.state)) or "Companion"
        elseif self.currentCategory == "Callable" and DT_TraderContacts and DT_TraderContacts.GetStatusText then
            expireText = DT_TraderContacts.GetStatusText(soul)
        elseif soul and soul.returnTime and soul.returnTime > 0 then
            local hours = math.ceil(soul.returnTime - getGameTime():getWorldAgeHours())
            if hours < 0 then hours = 0 end
            expireText = "Expires: " .. hours .. "h"
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
            canLock = self.currentCategory == "Stationary",
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
end