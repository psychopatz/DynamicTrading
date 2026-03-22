require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DT/UI/Faction/DT_NPCProfilePanel"

DT_FactionInfoTab_Population = ISPanel:derive("DT_FactionInfoTab_Population")

local function buildWorkerSoul(worker)
    return {
        name = worker.name,
        archetypeID = worker.archetypeID or worker.profession or "General",
        identitySeed = worker.identitySeed,
        isFemale = worker.isFemale,
        status = worker.tradeActive and (worker.tradeStatus or "Trading") or (worker.tradeEligible and "Standby" or tostring(worker.state or "Idle"))
    }
end

function DT_FactionInfoTab_Population:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Population:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoTab_Population:createChildren()
    local topH = 170
    local padding = 5
    
    -- 1. PROFILE AREA (TOP) - Extracted Component
    self.profilePanel = DT_NPCProfilePanel:new(0, 0, self.width, topH)
    self.profilePanel:initialise()
    self.profilePanel:setAnchorRight(true)
    self:addChild(self.profilePanel)

    self.btnToggleEligibility = ISButton:new(10, topH - 34, 150, 24, "Allow Trade", self, self.onToggleEligibility)
    self.btnToggleEligibility:initialise()
    self.btnToggleEligibility:setEnable(false)
    self:addChild(self.btnToggleEligibility)

    self.btnDispatch = ISButton:new(170, topH - 34, 120, 24, "Dispatch Trade", self, self.onDispatchTrade)
    self.btnDispatch:initialise()
    self.btnDispatch:setEnable(false)
    self:addChild(self.btnDispatch)

    self.btnRecall = ISButton:new(300, topH - 34, 120, 24, "Recall Trade", self, self.onRecallTrade)
    self.btnRecall:initialise()
    self.btnRecall:setEnable(false)
    self:addChild(self.btnRecall)

    -- 2. ROSTER LIST
    local listY = topH + padding
    local listH = self.height - topH - padding -- Fill to bottom
    
    self.rosterlist = ISScrollingListBox:new(0, listY, self.width, listH)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 40 
    self.rosterlist.doDrawItem = self.doDrawRosterItem
    self.rosterlist.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.5}
    self.rosterlist.drawBorder = true
    self.rosterlist:setAnchorRight(true)
    self.rosterlist:setAnchorBottom(true)
    
    self.rosterlist.target = self
    self.rosterlist.onmousedown = self.onRosterClick
    self:addChild(self.rosterlist)
end

function DT_FactionInfoTab_Population:onRosterClick(data)
    if not data then return end

    self.selectedWorker = data.worker
    self.selectedSoul = data.soul
    self.selectedUUID = data.uuid

    -- Update Header UI via component
    if self.profilePanel then
        self.profilePanel:setNPC(data.soul, data.uuid)
    end
    self:updateActionButtons()
end

function DT_FactionInfoTab_Population:onOpenDetails()
    -- Reserved for future use or expanded view
    if self.selectedSoul then
        DynamicTrading.Log("DTCommons", "Faction", "UI", "Opening details for " .. tostring(self.selectedSoul.name))
    end
end

function DT_FactionInfoTab_Population:onResize()
    ISPanel.onResize(self)
    -- Anchors should handle resizing of subpanels
end

function DT_FactionInfoTab_Population:updateActionButtons()
    local worker = self.selectedWorker
    local faction = self.currentFaction
    local ownedStatus = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus or nil
    local isOwnedFaction = faction and faction.playerOwned and ownedStatus and ownedStatus.faction and ownedStatus.faction.id == faction.id
    local canControl = isOwnedFaction and tostring(faction.leadershipState or "Active") == "Active"
    local isDead = worker and tostring(worker.state or "") == "Dead"

    if not worker or not isOwnedFaction then
        self.btnToggleEligibility:setEnable(false)
        self.btnDispatch:setEnable(false)
        self.btnRecall:setEnable(false)
        return
    end

    self.btnToggleEligibility:setTitle(worker.tradeEligible and "Block Trade" or "Allow Trade")
    self.btnToggleEligibility:setEnable(canControl and not isDead)
    self.btnDispatch:setEnable(canControl and worker.tradeEligible == true and worker.tradeActive ~= true and not isDead)
    self.btnRecall:setEnable(canControl and worker.tradeActive == true)
end

local function sendFactionCommand(command, args)
    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if not player then
        return false
    end
    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args or {})
    elseif triggerEvent then
        triggerEvent("OnClientCommand", "DynamicTrading_V2", command, player, args or {})
    else
        return false
    end
    return true
end

function DT_FactionInfoTab_Population:onToggleEligibility()
    if not self.selectedWorker then
        return
    end
    sendFactionCommand("SetFactionWorkerTradeEligibility", {
        workerID = self.selectedWorker.workerID,
        enabled = self.selectedWorker.tradeEligible ~= true
    })
end

function DT_FactionInfoTab_Population:onDispatchTrade()
    if not self.selectedWorker then
        return
    end
    sendFactionCommand("DispatchFactionTrade", {
        workerID = self.selectedWorker.workerID
    })
end

function DT_FactionInfoTab_Population:onRecallTrade()
    if not self.selectedWorker then
        return
    end
    sendFactionCommand("RecallFactionTrader", {
        workerID = self.selectedWorker.workerID
    })
end

function DT_FactionInfoTab_Population:updateData(f, rosterData)
    self.rosterlist:clear()
    self.currentFaction = f
    self.selectedWorker = nil

    -- Reset selection
    if self.profilePanel then
        self.profilePanel:setNPC(nil)
    end
    self:updateActionButtons()

    if not f then return end

    if f.playerOwned then
        local ownedStatus = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus or nil
        if ownedStatus and ownedStatus.faction and ownedStatus.faction.id == f.id then
            for _, worker in ipairs(ownedStatus.linkedWorkers or {}) do
                local liveWorker = {}
                for key, value in pairs(worker) do
                    liveWorker[key] = value
                end

                if f.tradeEligibleWorkerIDs then
                    liveWorker.tradeEligible = f.tradeEligibleWorkerIDs[worker.workerID] == true
                else
                    liveWorker.tradeEligible = worker.tradeEligible == true
                end

                if f.activeTradeWorkerIDs then
                    liveWorker.tradeActive = f.activeTradeWorkerIDs[worker.workerID] == true
                else
                    liveWorker.tradeActive = worker.tradeActive == true
                end
                liveWorker.tradeSoulUUID = f.tradeWorkerSouls and f.tradeWorkerSouls[worker.workerID] or worker.tradeSoulUUID

                self.rosterlist:addItem(worker.name or worker.workerID, {
                    worker = liveWorker,
                    soul = buildWorkerSoul(liveWorker),
                    uuid = liveWorker.tradeSoulUUID or liveWorker.workerID
                })
            end
        elseif tonumber(f.memberCount or 0) > 0 then
            self.rosterlist:addItem("Known Recruits: " .. tostring(f.memberCount or 0), {
                worker = nil,
                soul = {
                    name = "Public Intel",
                    archetypeID = "Player Faction",
                    identitySeed = 1,
                    isFemale = false,
                    status = tostring(f.memberCount or 0) .. " linked labour recruits"
                },
                uuid = "public_count"
            })
        else
            self.rosterlist:addItem("Syncing player faction members...", nil)
        end
        return
    end

    -- [V1 SUPPORT]
    if f.isV1 then
        if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData then
            local data = DynamicTrading.Manager.GetData()
            if data and data.Traders then
                -- Sort by name for consistency
                local sorted = {}
                for id, trader in pairs(data.Traders) do table.insert(sorted, trader) end
                table.sort(sorted, function(a, b) return a.name < b.name end)

                for _, trader in ipairs(sorted) do
                    local soul = {
                        name = trader.name,
                        archetypeID = trader.archetype,
                        identitySeed = trader.identitySeed,
                        status = "Active",
                        isFemale = (trader.gender == "Female")
                    }
                    local dataEntry = { soul = soul, uuid = trader.id, worker = nil }
                    self.rosterlist:addItem(trader.name, dataEntry)
                end
            end
        end
        return
    end
    
    -- [V2 SUPPORT]
    if rosterData then
        local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id]
        if members and #members > 0 then
            local hasSouls = false
            for _, uuid in ipairs(members) do
                local soul = rosterData.Souls and rosterData.Souls[uuid]
                if soul then
                    local dataEntry = { soul = soul, uuid = uuid, worker = nil }
                    self.rosterlist:addItem(soul.name or uuid, dataEntry)
                    hasSouls = true
                end
            end
            
            -- [MP] Placeholder if data hasn't arrived from server yet
            if not hasSouls and isClient() and not isServer() then
                self.rosterlist:addItem("Syncing Frequency...", nil)
            end
        end
    end
end

function DT_FactionInfoTab_Population:doDrawRosterItem(y, item, alt)
    local data = item.item
    if not data then -- Placeholder for empty
        self:drawText(item.text, 10, y + 5, 0.7, 0.7, 0.7, 1, UIFont.Medium)
        return y + self.itemheight
    end
    
    local soul = data.soul
    if not soul then return y end

    local isMouseOver = self:isMouseOver() and self:getMouseY() >= y and self:getMouseY() < y + self.itemheight

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.4, 0.4, 0.9, 0.6)
    elseif isMouseOver then
        self:drawRect(0, y, self.width, self.itemheight, 0.2, 0.3, 0.5, 0.4)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.05, 1, 1, 1)
    end
    
    local status = soul.status or "Active"
    local r, g, b = 0.8, 0.8, 0.8
    if status == "Dead" then r,g,b = 0.6, 0.2, 0.2
    elseif status == "Away" then r,g,b = 0.4, 0.4, 0.9
    elseif status == "Trading" then r,g,b = 0.9, 0.8, 0.2
    elseif status == "Standby" then r,g,b = 0.4, 0.8, 0.4
    end
    
    local font = UIFont.Medium
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        local scale = self.parent.parent.fontScale
        if scale == "Large" then font = UIFont.Large
        elseif scale == "Small" then font = UIFont.Small end
    end
    
    self:drawText(soul.name, 10, y + 5, r, g, b, 1, font)
    self:drawText(status, self.width - 140, y + 5, r*0.8, g*0.8, b*0.8, 1, font)

    return y + self.itemheight
end
