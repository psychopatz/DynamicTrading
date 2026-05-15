-- ==============================================================================
-- DT_ColonyArchiveDebugWindow.lua
-- Admin UI for player-made Dynamic Colonies faction recovery and archives.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"

require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugData"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugActions"

DT_ColonyArchiveDebugWindow = ISPanel:derive("DT_ColonyArchiveDebugWindow")

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    if activated and activated.contains and activated:contains("DynamicColonies") then
        return true
    end
    return rawget(_G, "DC_Colony") ~= nil
end

local function getDynamicColoniesDebugWindow()
    local windowClass = rawget(_G, "DC_DebugArchiveWindow")
    if windowClass then
        return windowClass
    end

    local ok = pcall(require, "DC/UI/Colony/DebugArchive/DC_DebugArchiveWindow")
    if ok then
        return rawget(_G, "DC_DebugArchiveWindow")
    end

    return nil
end

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function copyArray(values)
    local copied = {}
    if type(values) ~= "table" then
        return copied
    end
    for _, value in ipairs(values) do
        copied[#copied + 1] = tostring(value)
    end
    return copied
end

local function joinArray(values, emptyText)
    local copied = copyArray(values)
    if #copied == 0 then
        return emptyText or "None"
    end
    return table.concat(copied, ", ")
end

local function getLeadershipState(faction)
    return tostring(faction and faction.leadershipState or "Active")
end

local function isArchiveState(faction)
    local state = getLeadershipState(faction)
    return state == "AdminReview" or state == "Archived"
end

local function resolveDebugOwnerUsername(faction)
    if type(faction) ~= "table" then
        return ""
    end

    local leader = trim(faction.leaderUsername)
    local previousLeader = trim(faction.previousLeaderUsername)
    local owner = leader

    if owner == "" or string.find(owner, "^AdminReview_", 1, false) then
        owner = previousLeader
    end

    if owner == "" then
        owner = leader
    end

    return owner
end

local function getPlayerColonyEntries(factionData)
    local entries = {}
    if type(factionData) ~= "table" then
        return entries
    end

    for factionID, faction in pairs(factionData) do
        if type(faction) == "table" and faction.playerOwned == true then
            faction.id = faction.id or factionID
            entries[#entries + 1] = {
                id = factionID,
                data = faction
            }
        end
    end

    table.sort(entries, function(a, b)
        local aState = getLeadershipState(a.data)
        local bState = getLeadershipState(b.data)
        if aState ~= bState then
            if aState == "AdminReview" then return true end
            if bState == "AdminReview" then return false end
            if aState == "Archived" then return true end
            if bState == "Archived" then return false end
        end
        return tostring(a.data.name or a.id) < tostring(b.data.name or b.id)
    end)

    return entries
end

local function formatCounts(faction)
    local members = type(faction.memberUsernames) == "table" and #faction.memberUsernames or 0
    local invites = type(faction.inviteUsernames) == "table" and #faction.inviteUsernames or 0
    local workers = type(faction.linkedWorkerIDs) == "table" and #faction.linkedWorkerIDs or 0
    return tostring(members) .. " members | " .. tostring(invites) .. " invites | " .. tostring(workers) .. " workers"
end

function DT_ColonyArchiveDebugWindow.drawArchiveItem(listbox, y, item, alt)
    local faction = item.item
    if not faction then
        return y + listbox.itemheight
    end

    if item.selected then
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.35, 0.35, 0.55, 0.85)
    elseif alt then
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, listbox.width, listbox.itemheight, 0.08, 0, 0, 0)
    end

    local state = getLeadershipState(faction)
    local r, g, b = 0.85, 1.0, 0.85
    if state == "AdminReview" then
        r, g, b = 1.0, 0.82, 0.35
    elseif state == "Archived" then
        r, g, b = 0.75, 0.75, 0.85
    end

    local leader = trim(faction.leaderUsername)
    if leader == "" then
        leader = "(no leader)"
    end

    listbox:drawText(tostring(faction.name or faction.id or "Player Colony"), 10, y + 4, r, g, b, 1, UIFont.Medium)
    listbox:drawText(state .. " | Leader: " .. leader, 10, y + 24, 0.78, 0.78, 0.78, 1, UIFont.Small)
    listbox:drawText(formatCounts(faction), 10, y + 40, 0.62, 0.62, 0.62, 1, UIFont.Small)

    return y + listbox.itemheight
end

function DT_ColonyArchiveDebugWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_ColonyArchiveDebugWindow:createChildren()
    local pad = 10
    self.labelTitle = ISLabel:new(self.width / 2, 10, 25, "COLONY ARCHIVE MANAGER", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    self.statusLabel = ISLabel:new(pad, 38, 18, "", 0.8, 0.8, 0.8, 1, UIFont.Small, false)
    self.statusLabel:initialise()
    self:addChild(self.statusLabel)

    local listWidth = 330
    local contentY = 62
    local contentHeight = self.height - 150

    self.listbox = ISScrollingListBox:new(pad, contentY, listWidth, contentHeight)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 60
    self.listbox.doDrawItem = DT_ColonyArchiveDebugWindow.drawArchiveItem
    self.listbox.onmousedown = function(_, item)
        if DT_ColonyArchiveDebugWindow.instance then
            DT_ColonyArchiveDebugWindow.instance:onColonySelected(item)
        end
    end
    self:addChild(self.listbox)

    local detailsX = pad + listWidth + pad
    local detailsWidth = self.width - detailsX - pad
    self.details = ISRichTextPanel:new(detailsX, contentY, detailsWidth, contentHeight)
    self.details:initialise()
    self.details.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.details:addScrollBars()
    self.details:setText("Select a player colony.")
    self:addChild(self.details)

    local entryY = self.height - 78
    self.usernameLabel = ISLabel:new(detailsX, entryY, 18, "Restore/Reassign leader username:", 0.9, 0.9, 0.9, 1, UIFont.Small, false)
    self.usernameLabel:initialise()
    self:addChild(self.usernameLabel)

    self.usernameEntry = ISTextEntryBox:new("", detailsX + 210, entryY - 2, 220, 24)
    self.usernameEntry:initialise()
    self.usernameEntry:instantiate()
    self:addChild(self.usernameEntry)

    local btnY = self.height - 42
    local btnW = 118
    local btnGap = 8
    local startX = pad

    self.btnRefresh = ISButton:new(startX, btnY, btnW, 25, "REFRESH", self, DT_ColonyArchiveDebugWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = { r = 0.2, g = 0.45, b = 0.25, a = 1 }
    self:addChild(self.btnRefresh)

    self.btnRestore = ISButton:new(startX + (btnW + btnGap), btnY, btnW + 20, 25, "RESTORE LEADER", self, DT_ColonyArchiveDebugWindow.onRestoreClick)
    self.btnRestore:initialise()
    self.btnRestore.backgroundColor = { r = 0.2, g = 0.35, b = 0.65, a = 1 }
    self:addChild(self.btnRestore)

    self.btnReview = ISButton:new(startX + (btnW + btnGap) * 2 + 20, btnY, btnW, 25, "ADMIN REVIEW", self, DT_ColonyArchiveDebugWindow.onReviewClick)
    self.btnReview:initialise()
    self.btnReview.backgroundColor = { r = 0.55, g = 0.42, b = 0.15, a = 1 }
    self:addChild(self.btnReview)

    self.btnArchive = ISButton:new(startX + (btnW + btnGap) * 3 + 20, btnY, btnW, 25, "ARCHIVE", self, DT_ColonyArchiveDebugWindow.onArchiveClick)
    self.btnArchive:initialise()
    self.btnArchive.backgroundColor = { r = 0.38, g = 0.38, b = 0.5, a = 1 }
    self:addChild(self.btnArchive)

    self.btnDelete = ISButton:new(startX + (btnW + btnGap) * 4 + 20, btnY, btnW + 12, 25, "DELETE ARCHIVE", self, DT_ColonyArchiveDebugWindow.onDeleteClick)
    self.btnDelete:initialise()
    self.btnDelete.backgroundColor = { r = 0.6, g = 0.18, b = 0.18, a = 1 }
    self:addChild(self.btnDelete)

    self.btnColonyDebug = ISButton:new(self.width - pad - btnW - 130, btnY, 120, 25, "COLONY DEBUG", self, DT_ColonyArchiveDebugWindow.onColonyDebugClick)
    self.btnColonyDebug:initialise()
    self.btnColonyDebug.backgroundColor = { r = 0.22, g = 0.28, b = 0.58, a = 1 }
    self:addChild(self.btnColonyDebug)

    self.btnClose = ISButton:new(self.width - pad - btnW, btnY, btnW, 25, "CLOSE", self, function(window)
        window:setVisible(false)
        window:removeFromUIManager()
    end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:updateControls()
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:getSelectedFaction()
    local selected = self.listbox and self.listbox.items and self.listbox.items[self.listbox.selected] or nil
    return (selected and selected.item) or self.currentFaction
end

function DT_ColonyArchiveDebugWindow:refreshList()
    DT_FactionDebugData.refreshFactionList(function(factionData)
        local window = DT_ColonyArchiveDebugWindow.instance
        if window and window:getIsVisible() then
            window:populateList(factionData)
        end
    end)
end

function DT_ColonyArchiveDebugWindow:populateList(factionData)
    self.listbox:clear()
    self.selectedFactionID = nil
    self.currentFaction = nil

    local entries = getPlayerColonyEntries(factionData)
    local activeCount = 0
    local reviewCount = 0
    local archiveCount = 0

    for _, entry in ipairs(entries) do
        local state = getLeadershipState(entry.data)
        if state == "AdminReview" then
            reviewCount = reviewCount + 1
        elseif state == "Archived" then
            archiveCount = archiveCount + 1
        else
            activeCount = activeCount + 1
        end
        self.listbox:addItem(entry.data.name or entry.id, entry.data)
    end

    local coloniesText = isDynamicColoniesActive() and "Dynamic Colonies: enabled" or "Dynamic Colonies: required"
    self.statusLabel:setName(coloniesText .. " | Active: " .. tostring(activeCount) .. " | Review: " .. tostring(reviewCount) .. " | Archives: " .. tostring(archiveCount))

    if #entries == 0 then
        self.details:setText(" <RGB:1,1,0> No player-made colony factions found. <LINE> ")
        self.details:paginate()
    else
        self.details:setText("Select a player colony.")
        self.details:paginate()
    end

    self:updateControls()
end

function DT_ColonyArchiveDebugWindow:formatFactionDetails(faction)
    if not faction then
        return "Select a player colony."
    end

    local state = getLeadershipState(faction)
    local leader = trim(faction.leaderUsername)
    local previousLeader = trim(faction.previousLeaderUsername)
    local controlMode = tostring(faction.controlMode or "Active")
    local reason = tostring(faction.regencyReason or "N/A")
    local archiveOwner = "AdminReview_" .. tostring(faction.id or "")

    if leader == "" then leader = "(no leader)" end
    if previousLeader == "" then previousLeader = "N/A" end

    local text = " <RGB:1,1,0> " .. tostring(faction.name or faction.id or "Player Colony") .. " <LINE> "
    text = text .. " <RGB:1,1,1> ID: " .. tostring(faction.id or "N/A") .. " <LINE> "
    text = text .. "Leadership State: <RGB:0.8,0.9,1> " .. state .. " <LINE> "
    text = text .. "Control Mode: " .. controlMode .. " <LINE> "
    text = text .. "Leader: " .. leader .. " <LINE> "
    text = text .. "Previous Leader: " .. previousLeader .. " <LINE> "
    text = text .. "Admin Review Owner Key: " .. archiveOwner .. " <LINE> "
    text = text .. "Reason: " .. reason .. " <LINE> "
    text = text .. " <LINE> <RGB:0.6,1,0.6> MEMBERS <LINE> "
    text = text .. joinArray(faction.memberUsernames, "None") .. " <LINE> "
    text = text .. " <LINE> <RGB:0.6,0.85,1> PENDING INVITES <LINE> "
    text = text .. joinArray(faction.inviteUsernames, "None") .. " <LINE> "
    text = text .. " <LINE> <RGB:1,0.85,0.45> LINKED WORKERS <LINE> "
    text = text .. joinArray(faction.linkedWorkerIDs, "None") .. " <LINE> "
    text = text .. " <LINE> <RGB:0.75,0.75,0.75> Notes: AdminReview and Archived colonies are hidden from normal player management and should not simulate or trade. Delete Archive is intentionally limited to those states. <LINE> "
    return text
end

function DT_ColonyArchiveDebugWindow:onColonySelected(faction)
    self.currentFaction = faction
    self.selectedFactionID = faction and faction.id or nil
    self.details:setText(self:formatFactionDetails(faction))
    self.details:paginate()

    local leader = trim(faction and faction.leaderUsername)
    if leader == "" then
        leader = trim(faction and faction.previousLeaderUsername)
    end
    self.usernameEntry:setText(leader)
    self:updateControls()
end

function DT_ColonyArchiveDebugWindow:updateControls()
    local faction = self:getSelectedFaction()
    local coloniesActive = isDynamicColoniesActive()
    local hasSelection = faction ~= nil
    local archiveState = hasSelection and isArchiveState(faction)
    local debugWindow = hasSelection and getDynamicColoniesDebugWindow() or nil
    local debugOwner = hasSelection and resolveDebugOwnerUsername(faction) or ""

    if self.btnRestore then self.btnRestore:setEnable(coloniesActive and hasSelection) end
    if self.btnReview then self.btnReview:setEnable(coloniesActive and hasSelection and not archiveState) end
    if self.btnArchive then self.btnArchive:setEnable(coloniesActive and hasSelection and getLeadershipState(faction) ~= "Archived") end
    if self.btnDelete then self.btnDelete:setEnable(coloniesActive and hasSelection and archiveState) end
    if self.btnColonyDebug then
        self.btnColonyDebug:setEnable(coloniesActive and hasSelection and debugWindow ~= nil and debugOwner ~= "")
    end
end

function DT_ColonyArchiveDebugWindow:announce(message)
    local playerObj = getPlayer and getPlayer() or nil
    if playerObj then
        playerObj:Say(message)
    elseif HaloTextHelper and playerObj then
        HaloTextHelper.addText(playerObj, message)
    end
end

function DT_ColonyArchiveDebugWindow:onRefreshClick()
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:onRestoreClick()
    local faction = self:getSelectedFaction()
    local username = trim(self.usernameEntry:getText())
    if not faction or username == "" then
        self:announce("Select a colony and enter a leader username.")
        return
    end
    DT_FactionDebugActions.restorePlayerFactionLeader(faction.id, username)
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:onReviewClick()
    local faction = self:getSelectedFaction()
    if not faction then return end
    DT_FactionDebugActions.adminReviewPlayerFaction(faction.id)
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:onArchiveClick()
    local faction = self:getSelectedFaction()
    if not faction then return end
    DT_FactionDebugActions.archivePlayerFaction(faction.id)
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:onDeleteClick()
    local faction = self:getSelectedFaction()
    if not faction or not isArchiveState(faction) then
        self:announce("Only Admin Review or Archived colonies can be deleted here.")
        return
    end
    DT_FactionDebugActions.deletePlayerFactionArchive(faction.id)
    self:refreshList()
end

function DT_ColonyArchiveDebugWindow:onColonyDebugClick()
    local faction = self:getSelectedFaction()
    if not faction then
        self:announce("Select a colony first.")
        return
    end

    local debugWindow = getDynamicColoniesDebugWindow()
    if not debugWindow or not debugWindow.Open then
        self:announce("Dynamic Colonies debugger window is not available.")
        return
    end

    local ownerUsername = resolveDebugOwnerUsername(faction)
    if ownerUsername == "" then
        self:announce("This colony has no valid owner username for debugging.")
        return
    end

    debugWindow.Open(self, {
        ownerUsername = ownerUsername,
    })
end

if not DT_ColonyArchiveDebugWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key)
        if key == "DynamicTrading_Factions"
            and DT_ColonyArchiveDebugWindow.instance
            and DT_ColonyArchiveDebugWindow.instance:getIsVisible() then
            DT_ColonyArchiveDebugWindow.instance:refreshList()
        end
    end)
    DT_ColonyArchiveDebugWindow.EventsAdded = true
end

function DT_ColonyArchiveDebugWindow.Open()
    if DT_ColonyArchiveDebugWindow.instance then
        DT_ColonyArchiveDebugWindow.instance:setVisible(true)
        DT_ColonyArchiveDebugWindow.instance:addToUIManager()
        DT_ColonyArchiveDebugWindow.instance:refreshList()
        return
    end

    local window = DT_ColonyArchiveDebugWindow:new(120, 120, 940, 560)
    window:initialise()
    window:addToUIManager()
    DT_ColonyArchiveDebugWindow.instance = window
    window:refreshList()
end

function DT_ColonyArchiveDebugWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.86 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 1 }
    o.moveWithMouse = true
    o.selectedFactionID = nil
    o.currentFaction = nil
    return o
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Colony Archive Debug Window Loaded")
