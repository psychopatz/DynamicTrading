-- ==============================================================================
-- DT_V2_RadarWindow_Refresh.lua
-- Category handling and list refresh logic for the Trader Radar window.
-- ==============================================================================

function DT_V2_RadarWindow:setCategory(category)
    if self.currentCategory == category then
        return
    end

    self.currentCategory = category

    if self.listPanel and self.listPanel.setLayoutMode then
        self.listPanel:setLayoutMode(category)
    end

    self:refresh()
end

function DT_V2_RadarWindow:refresh()
    if not self.listPanel or not self.headerPanel or not self.actionPanel then
        return
    end

    local listbox = self.listPanel.listbox

    local selectedUUID = nil
    if listbox.selected and listbox.selected ~= -1 and listbox.items[listbox.selected] then
        if listbox.items[listbox.selected].item then
            selectedUUID = listbox.items[listbox.selected].item.uuid
        end
    end

    listbox:clear()
    listbox.selected = -1

    self.actionPanel.btnLocate.enable = (selectedUUID ~= nil)
    self.actionPanel:updateButtonState(selectedUUID)

    if not DT_V2_RadarManager then
        return
    end

    local player = getSpecificPlayer(0)
    if not player then
        return
    end

    local bestRange = 0
    local bestName = "Unknown"

    if self.device then
        bestName, bestRange = DT_V2_RadarManager.GetDeviceInfo(self.device)
    end

    if bestRange == 0 then
        local items = player:getInventory():getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item:getCategory() == "Communications" and item:getIsTwoWay() then
                local name, range = DT_V2_RadarManager.GetDeviceInfo(item)
                if range > bestRange then
                    bestRange = range
                    bestName = name
                end
            end
        end
    end

    self.headerPanel:updateSignalInfo(bestName, bestRange)

    if self.currentCategory == "Location" then
        if DT_V2_RadarLocationHandler then
            DT_V2_RadarLocationHandler.PopulateList(listbox, player)
        else
            listbox:addItem("Module Missing: LocationHandler", {})
        end
        self.actionPanel.btnLocate.enable = false
        return
    end

    DT_V2_RadarManager.Cleanup()

    local tempList = {}

    local function normalizeText(value)
        local text = tostring(value or "")
        if text == "" then
            return nil
        end
        return string.lower(text)
    end

    local function isOwnedTravelCompanion(npcData)
        if not npcData then
            return false
        end

        local isCompanion = tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
            or tostring(npcData.linkedWorkerID or "") ~= ""
        if not isCompanion then
            return false
        end

        local playerID = player.getOnlineID and player:getOnlineID() or nil
        if playerID ~= nil and npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end

        local username = normalizeText(player.getUsername and player:getUsername() or nil)
        if not username then
            return false
        end

        return normalizeText(npcData.master) == username
            or normalizeText(npcData.ownerUsername) == username
            or normalizeText(npcData.dcCompanionOwner) == username
    end

    local function buildDistanceEntry(uuid, data, soul)
        local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(uuid)
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

    if self.currentCategory == "Stationary" then
        for uuid, data in pairs(DT_V2_RadarManager.FoundTraders) do
            table.insert(tempList, buildDistanceEntry(uuid, data, DT_V2_RadarManager.GetSoul(uuid)))
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
    end

    table.sort(tempList, function(a, b)
        local d1 = a.dist or 999999
        local d2 = b.dist or 999999
        return d1 < d2
    end)

    for _, entry in ipairs(tempList) do
        local uuid = entry.uuid
        local data = entry.data
        local soul = entry.soul or DT_V2_RadarManager.GetSoul(uuid) or (DTNPCClient and DTNPCClient.GetMetadata and DTNPCClient.GetMetadata(uuid) or nil)
        local archetypeID = soul and soul.archetypeID or "General"
        local gender = (soul and soul.isFemale) and "Female" or "Male"
        local identitySeed = soul and soul.identitySeed or 1

        local factionData = DT_V2_RadarManager.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.faction or "Independent"

        local expireText = ""
        if soul and soul.isCallableCompanion == true then
            expireText = soul.state and ("State: " .. tostring(soul.state)) or "Companion"
        elseif soul and soul.returnTime and soul.returnTime > 0 then
            local hours = math.ceil(soul.returnTime - getGameTime():getWorldAgeHours())
            if hours < 0 then
                hours = 0
            end
            expireText = "Expires: " .. hours .. "h"
        end

        local item = {
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
        }

        listbox:addItem(data.name, item)

        if selectedUUID == uuid and #listbox.items > 0 then
            listbox.selected = #listbox.items
        end
    end
end
