require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"

DT_PlayerFactionMembersModal = ISCollapsableWindow:derive("DT_PlayerFactionMembersModal")
DT_PlayerFactionMembersModal.instance = nil

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function trimName(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function isDynamicColoniesActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("DynamicColonies") or false
end

local function getLocalUsername()
    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    return player and player.getUsername and tostring(player:getUsername() or "") or "local"
end

local function containsValue(array, value)
    for _, existing in ipairs(array or {}) do
        if tostring(existing) == tostring(value) then
            return true
        end
    end
    return false
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

local function getOnlineUsernames(status)
    local usernames = {}
    local seen = {}
    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    local localUsername = getLocalUsername()
    local faction = status and status.faction or nil
    local leader = tostring((faction and faction.leaderUsername) or "")
    local members = status and status.memberUsernames or {}
    local invites = status and status.inviteUsernames or {}

    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            local username = player and player.getUsername and tostring(player:getUsername() or "") or ""
            if username ~= ""
                and username ~= localUsername
                and username ~= leader
                and not containsValue(members, username)
                and not containsValue(invites, username)
                and not seen[username] then
                seen[username] = true
                usernames[#usernames + 1] = username
            end
        end
    end

    table.sort(usernames)
    return usernames
end

function DT_PlayerFactionMembersModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_PlayerFactionMembersModal:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local th = self:titleBarHeight()
    local contentY = th + pad

    self.summaryLabel = ISLabel:new(pad, contentY, 20, T("DTCommon_UI_Faction_Membership", nil, "Faction membership"), 1, 1, 1, 1, UIFont.Small, true)
    self.summaryLabel:initialise()
    self:addChild(self.summaryLabel)

    self.memberList = ISScrollingListBox:new(pad, contentY + 26, self.width - (pad * 2), 210)
    self.memberList:initialise()
    self.memberList:instantiate()
    self.memberList.itemheight = 32
    self.memberList.doDrawItem = self.doDrawMemberItem
    self.memberList.target = self
    self.memberList.onmousedown = self.onMemberClick
    self:addChild(self.memberList)

    self.usernameEntry = ISTextEntryBox:new("", pad, contentY + 246, self.width - (pad * 2), 24)
    self.usernameEntry:initialise()
    self.usernameEntry:instantiate()
    self:addChild(self.usernameEntry)

    self.statusLabel = ISLabel:new(pad, contentY + 276, 20, "", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self.statusLabel:initialise()
    self:addChild(self.statusLabel)

    local buttonY = self.height - 70
    self.btnInvite = ISButton:new(pad, buttonY, 90, 24, T("DTCommon_UI_Faction_Invite", nil, "Invite"), self, self.onInvite)
    self.btnInvite:initialise()
    self:addChild(self.btnInvite)

    self.btnAccept = ISButton:new(pad + 96, buttonY, 90, 24, T("DTCommon_UI_Faction_Accept", nil, "Accept"), self, self.onAcceptInvite)
    self.btnAccept:initialise()
    self:addChild(self.btnAccept)

    self.btnDecline = ISButton:new(pad + 192, buttonY, 90, 24, T("DTCommon_UI_Faction_Decline", nil, "Decline"), self, self.onDeclineInvite)
    self.btnDecline:initialise()
    self:addChild(self.btnDecline)

    self.btnKick = ISButton:new(pad + 288, buttonY, 90, 24, T("DTCommon_UI_Faction_KickRevoke", nil, "Kick/Revoke"), self, self.onKickOrRevoke)
    self.btnKick:initialise()
    self:addChild(self.btnKick)

    self.btnTransfer = ISButton:new(pad + 384, buttonY, 120, 24, T("DTCommon_UI_Faction_Transfer", nil, "Transfer"), self, self.onTransfer)
    self.btnTransfer:initialise()
    self:addChild(self.btnTransfer)

    self.btnLeave = ISButton:new(pad, buttonY + 32, 150, 24, T("DTCommon_UI_Faction_Leave", nil, "Leave Faction"), self, self.onLeaveOrAbandon)
    self.btnLeave:initialise()
    self:addChild(self.btnLeave)

    self.btnKickRetain = ISButton:new(pad + 160, buttonY + 32, 120, 24, T("DTCommon_UI_Faction_KickKeep", nil, "Kick + Keep"), self, self.onKickRetain)
    self.btnKickRetain:initialise()
    self:addChild(self.btnKickRetain)

    self.btnClose = ISButton:new(self.width - 110, buttonY + 32, 100, 24, T("DTCommon_UI_Faction_Close", nil, "Close"), self, self.onClose)
    self.btnClose:initialise()
    self:addChild(self.btnClose)
end

function DT_PlayerFactionMembersModal:setStatus(message)
    self.lastStatus = tostring(message or "")
    if self.statusLabel then
        self.statusLabel:setName(self.lastStatus)
    end
end

function DT_PlayerFactionMembersModal:getStatus()
    return self.status or (DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus) or nil
end

function DT_PlayerFactionMembersModal:buildRows(status)
    local rows = {}
    status = status or {}
    local faction = status.faction
    local pendingInvites = status.pendingInvites or {}

    if faction then
        rows[#rows + 1] = {
            type = "leader",
            username = faction.leaderUsername,
            text = T("DTCommon_UI_Faction_LeaderRow", { name = tostring(faction.leaderUsername or T("DTCommon_UI_Faction_DefaultLeader", nil, "Unknown")) }, "Leader: " .. tostring(faction.leaderUsername or "Unknown"))
        }

        for _, username in ipairs(status.memberUsernames or {}) do
            rows[#rows + 1] = {
                type = "member",
                username = username,
                text = T("DTCommon_UI_Faction_MemberRow", { name = tostring(username) }, "Member: " .. tostring(username))
            }
        end

        for _, username in ipairs(status.inviteUsernames or {}) do
            rows[#rows + 1] = {
                type = "invite",
                username = username,
                text = T("DTCommon_UI_Faction_PendingInviteRow", { name = tostring(username) }, "Pending invite: " .. tostring(username))
            }
        end

        if status.isLeader then
            for _, username in ipairs(getOnlineUsernames(status)) do
                rows[#rows + 1] = {
                    type = "online",
                    username = username,
                    text = T("DTCommon_UI_Faction_OnlinePlayerRow", { name = tostring(username) }, "Online player: " .. tostring(username))
                }
            end
        end
    elseif #pendingInvites > 0 then
        for _, invite in ipairs(pendingInvites) do
            rows[#rows + 1] = {
                type = "pendingInvite",
                factionID = invite.factionID,
                username = invite.leaderUsername,
                text = T(
                    "DTCommon_UI_Faction_InviteRow",
                    {
                        faction = tostring(invite.name or invite.factionID),
                        leader = tostring(invite.leaderUsername or T("DTCommon_UI_Faction_DefaultLeader", nil, "Unknown"))
                    },
                    "Invite: " .. tostring(invite.name or invite.factionID) .. " by " .. tostring(invite.leaderUsername or "Unknown")
                )
            }
        end
    end

    return rows
end

function DT_PlayerFactionMembersModal:refresh()
    local status = self:getStatus()
    self.status = status
    self.selectedRow = nil
    if self.memberList then
        self.memberList:clear()
    end

    if not isDynamicColoniesActive() then
        if self.summaryLabel then
            self.summaryLabel:setName(T("DTCommon_UI_Faction_DynamicColoniesRequired", nil, "Dynamic Colonies is required for player faction membership."))
        end
        self:updateButtons()
        return
    end

    status = status or {}
    local faction = status.faction
    if self.summaryLabel then
        if faction then
            self.summaryLabel:setName(
                T(
                    "DTCommon_UI_Faction_Summary",
                    {
                        name = tostring(faction.name or faction.id or T("DTCommon_UI_Faction_DefaultFaction", nil, "Faction")),
                        role = tostring(status.role or T("DTCommon_UI_Faction_DefaultRole", nil, "none")),
                        leader = tostring(faction.leaderUsername or T("DTCommon_UI_Faction_DefaultLeader", nil, "Unknown"))
                    },
                    tostring(faction.name or faction.id or "Faction")
                        .. " | Role: "
                        .. tostring(status.role or "none")
                        .. " | Leader: "
                        .. tostring(faction.leaderUsername or "Unknown")
                )
            )
        elseif status.pendingInvites and #status.pendingInvites > 0 then
            self.summaryLabel:setName(T("DTCommon_UI_Faction_PendingInvitations", nil, "Pending colony invitations"))
        else
            self.summaryLabel:setName(T("DTCommon_UI_Faction_None", nil, "No player faction or pending invitations."))
        end
    end

    local rows = self:buildRows(status)
    for _, row in ipairs(rows) do
        self.memberList:addItem(row.text, row)
    end

    self:updateButtons()
end

function DT_PlayerFactionMembersModal:onMemberClick(row)
    self.selectedRow = row
    if row and row.username and self.usernameEntry and (row.type == "online" or row.type == "member" or row.type == "invite") then
        self.usernameEntry:setText(tostring(row.username))
    end
    self:updateButtons()
end

function DT_PlayerFactionMembersModal:getTargetUsername()
    local entryText = self.usernameEntry and trimName(self.usernameEntry:getText()) or ""
    if entryText ~= "" then
        return entryText
    end
    return self.selectedRow and self.selectedRow.username or ""
end

function DT_PlayerFactionMembersModal:updateButtons()
    local status = self:getStatus() or {}
    local faction = status.faction
    local permissions = status.permissions or {}
    local selected = self.selectedRow
    local isLeader = permissions.canInviteMembers == true

    if self.btnInvite then
        self.btnInvite:setEnable(faction ~= nil and isLeader)
    end
    if self.btnAccept then
        self.btnAccept:setEnable(selected and selected.type == "pendingInvite")
    end
    if self.btnDecline then
        self.btnDecline:setEnable(selected and selected.type == "pendingInvite")
    end
    if self.btnKick then
        self.btnKick:setEnable(faction ~= nil and isLeader and selected and (selected.type == "member" or selected.type == "invite"))
    end
    if self.btnKickRetain then
        self.btnKickRetain:setEnable(faction ~= nil and isLeader and selected and selected.type == "member")
    end
    if self.btnTransfer then
        self.btnTransfer:setEnable(faction ~= nil and isLeader and selected and selected.type == "member")
    end
    if self.btnLeave then
        if faction and status.isLeader then
            self.btnLeave:setTitle(T("DTCommon_UI_Faction_AbandonLeadership", nil, "Abandon Leadership"))
            self.btnLeave:setEnable(#(status.memberUsernames or {}) == 0)
        else
            self.btnLeave:setTitle(T("DTCommon_UI_Faction_Leave", nil, "Leave Faction"))
            self.btnLeave:setEnable(faction ~= nil and status.isMember == true)
        end
    end
end

function DT_PlayerFactionMembersModal:onInvite()
    local username = self:getTargetUsername()
    if username == "" then
        self:setStatus(T("DTCommon_UI_Faction_EnterOrSelectUsername", nil, "Enter or select a username to invite."))
        return
    end
    sendFactionCommand("InvitePlayerToFaction", { username = username })
    self:setStatus(T("DTCommon_UI_Faction_InvitationRequestSent", nil, "Invitation request sent."))
end

function DT_PlayerFactionMembersModal:onAcceptInvite()
    local row = self.selectedRow
    if not row or row.type ~= "pendingInvite" then
        return
    end
    sendFactionCommand("AcceptFactionInvite", { factionID = row.factionID })
    self:setStatus(T("DTCommon_UI_Faction_AcceptRequestSent", nil, "Accept request sent."))
end

function DT_PlayerFactionMembersModal:onDeclineInvite()
    local row = self.selectedRow
    if not row or row.type ~= "pendingInvite" then
        return
    end
    sendFactionCommand("DeclineFactionInvite", { factionID = row.factionID })
    self:setStatus(T("DTCommon_UI_Faction_DeclineRequestSent", nil, "Decline request sent."))
end

function DT_PlayerFactionMembersModal:onKickOrRevoke()
    local username = self:getTargetUsername()
    if username == "" then
        return
    end
    sendFactionCommand("KickFactionMember", { username = username, workerTransferAction = "return" })
    self:setStatus(T("DTCommon_UI_Faction_MembershipUpdateSent", nil, "Membership update sent."))
end

function DT_PlayerFactionMembersModal:onKickRetain()
    local username = self:getTargetUsername()
    if username == "" then
        return
    end
    sendFactionCommand("KickFactionMember", { username = username, workerTransferAction = "retain" })
    self:setStatus(T("DTCommon_UI_Faction_MembershipUpdateRetain", nil, "Membership update sent. Transferred workers will stay with the faction."))
end

function DT_PlayerFactionMembersModal:onTransfer()
    local username = self:getTargetUsername()
    if username == "" then
        return
    end
    sendFactionCommand("TransferFactionLeadership", { username = username })
    self:setStatus(T("DTCommon_UI_Faction_LeadershipTransferSent", nil, "Leadership transfer request sent."))
end

function DT_PlayerFactionMembersModal:onLeaveOrAbandon()
    local status = self:getStatus() or {}
    if status.isLeader then
        sendFactionCommand("AbandonFactionLeadership", {})
        self:setStatus(T("DTCommon_UI_Faction_AbandonLeadershipSent", nil, "Abandon leadership request sent."))
    else
        sendFactionCommand("LeavePlayerFaction", {})
        self:setStatus(T("DTCommon_UI_Faction_LeaveRequestSent", nil, "Leave request sent."))
    end
end

function DT_PlayerFactionMembersModal:onClose()
    self:close()
end

function DT_PlayerFactionMembersModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_PlayerFactionMembersModal:doDrawMemberItem(y, item, alt)
    local row = item.item
    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.35, 0.45, 0.65, 0.65)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    end

    local r, g, b = 0.8, 0.8, 0.8
    if row and row.type == "leader" then
        r, g, b = 1, 0.82, 0.25
    elseif row and row.type == "member" then
        r, g, b = 0.45, 0.85, 0.6
    elseif row and (row.type == "invite" or row.type == "pendingInvite") then
        r, g, b = 0.65, 0.75, 1
    elseif row and row.type == "online" then
        r, g, b = 0.8, 0.8, 0.8
    end

    self:drawText(item.text, 8, y + 7, r, g, b, 1, UIFont.Small)
    return y + self.itemheight
end

function DT_PlayerFactionMembersModal.Open(status)
    local modal = DT_PlayerFactionMembersModal.instance
    if not modal then
        local width = 540
        local height = 420
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2
        modal = DT_PlayerFactionMembersModal:new(x, y, width, height)
        modal:initialise()
        modal:instantiate()
        DT_PlayerFactionMembersModal.instance = modal
    end

    modal.status = status or (DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus) or nil
    modal:setVisible(true)
    modal:addToUIManager()
    modal:bringToTop()
    modal:refresh()
    return modal
end

function DT_PlayerFactionMembersModal:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = T("DTCommon_UI_Faction_MembersTitle", nil, "Colony Members")
    o.resizable = false
    o.status = nil
    o.selectedRow = nil
    o.lastStatus = ""
    return o
end

return DT_PlayerFactionMembersModal
