-- Shared Dynamic Trading trader notification payloads.
--
-- Core owns the bounded toast queue and portrait widget.  This module owns
-- the trader-facing payload and actions so DTAbstract and DTHoomans cannot
-- drift into separate notification contracts.

DTCommon = DTCommon or {}
DTCommon.TraderNotification = DTCommon.TraderNotification or {}

local Notification = DTCommon.TraderNotification
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

local function coreClient()
    local ok, value = pcall(
        require,
        "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
    )
    return ok and type(value) == "table" and value or nil
end

local function toastSurface()
    local toast = PsychopatzCore
        and PsychopatzCore.ActorNotifications
    if toast and type(toast.Show) == "function" then return toast end
    local ok, value = pcall(
        require,
        "PsychopatzCore/UI/PsychopatzActorNotificationToast"
    )
    if ok and type(value) == "table" then return value end
    return nil
end

local function traderManager()
    local manager = DTCommon and DTCommon.TraderManager or nil
    if manager then return manager end
    local ok, value = pcall(
        require,
        "DTCommon/DTCommon_TraderManager"
    )
    return ok and value or nil
end

local function viewFor(traderID, actorID)
    if actorID and type(Presentation.GetTraderViewForActor) == "function" then
        local view = Presentation.GetTraderViewForActor(actorID, false)
        if view then return view end
    end
    if type(Presentation.GetTraderView) == "function" then
        return Presentation.GetTraderView(traderID, false)
    end
    return nil
end

local function rosterFor(traderID)
    if type(Presentation.ListTraderViews) ~= "function" then
        return {}
    end
    local rows = Presentation.ListTraderViews(false) or {}
    local roster = {}
    for _, row in ipairs(rows) do
        if row and tostring(row.traderID or "") == tostring(traderID) then
            roster[#roster + 1] = row
        end
    end
    return roster
end

local function nextRosterView(traderID, actorID)
    local roster = rosterFor(traderID)
    if #roster < 2 then return nil end
    local currentIndex
    for index, row in ipairs(roster) do
        if tostring(row.actorID or "") == tostring(actorID or "") then
            currentIndex = index
            break
        end
    end
    if not currentIndex then return roster[1] end
    local nextIndex = currentIndex + 1
    if nextIndex > #roster then nextIndex = 1 end
    return roster[nextIndex]
end

local function badgeFor(view)
    local faction = view and view.factionPresentation or nil
    if type(faction) ~= "table" then return nil end
    return faction.badge or faction
end

local function actionFor(actionID, label, traderID, actorID, options)
    return {
        id = actionID,
        label = label,
        callback = function()
            local manager = traderManager()
            if not manager or type(manager.Request) ~= "function" then
                return false, "trader_manager_unavailable"
            end
            local ok, reason = manager.Request(
                actionID,
                traderID,
                {
                    mode = options.mode or "nearby",
                    actorID = actorID,
                    npcID = actorID,
                    provider = options.provider,
                }
            )
            if not ok and type(manager.SetNotice) == "function" then
                manager.SetNotice(reason)
            end
            return ok, reason
        end,
    }
end

function Notification.Build(traderID, message, options)
    traderID = tostring(traderID or "")
    if type(message) == "table" and options == nil then
        options = message
        message = options.message
    end
    options = type(options) == "table" and options or {}
    local view = viewFor(traderID, options.actorID)
    local actorID = tostring(options.actorID
        or view and view.actorID or "")
    if actorID == "" then actorID = nil end
    local portraitSpec = options.portraitSpec
        or view and view.portraitSpec or nil
    if not portraitSpec and actorID then
        local client = coreClient()
        local actor = client and client.GetActor
            and client.GetActor(actorID) or nil
        if client and type(client.GetPortraitSpec) == "function" then
            portraitSpec = client.GetPortraitSpec(actor or actorID)
        end
    end

    local id = tostring(options.id or options.notificationID or "")
    if id == "" then
        id = "dt_trader:" .. traderID .. ":" .. tostring(actorID or "leader")
    end

    local actions = {}
    if type(options.actions) == "table" then
        for index = 1, math.min(#options.actions, 2) do
            actions[#actions + 1] = options.actions[index]
        end
    else
        if options.includeTalk ~= false then
            actions[#actions + 1] = actionFor(
                "talk", "Talk", traderID, actorID, options)
        end
        if options.includeTrade == true
            and view and view.tradeAvailable ~= false
        then
            actions[#actions + 1] = actionFor(
                "trade", "Trade", traderID, actorID, options)
        end
        if options.includeNext == true and #actions < 2 then
            local nextView = nextRosterView(traderID, actorID)
            if nextView then
                actions[#actions + 1] = {
                    id = "next",
                    label = tostring(options.nextLabel or "Next"),
                    callback = function()
                        local nextActorID = tostring(nextView.actorID or "")
                        if nextActorID == "" then
                            return false, "trader_roster_actor_missing"
                        end
                        local nextName = tostring(
                            nextView.name or nextActorID
                        )
                        local nextMessage = options.nextMessage
                        if type(nextMessage) ~= "string"
                            or nextMessage == ""
                        then
                            if options.mode == "nearby" then
                                nextMessage = nextName
                                    .. " is operating nearby."
                            else
                                nextMessage = "You are speaking with "
                                    .. nextName .. "."
                            end
                        end
                        local nextOptions = {}
                        for key, value in pairs(options) do
                            nextOptions[key] = value
                        end
                        nextOptions.id = id
                        nextOptions.actorID = nextActorID
                        nextOptions.message = nextMessage
                        nextOptions.includeNext = true
                        local shown, reason = Notification.Show(
                            traderID,
                            nextMessage,
                            nextOptions
                        )
                        return shown, reason
                    end,
                }
            end
        end
    end

    return {
        id = id,
        actorID = actorID,
        name = tostring(view and view.name or options.name
            or traderID or "Dynamic Trading"),
        message = tostring(message or options.message or ""),
        secondary = options.secondary,
        portraitSpec = portraitSpec,
        factionBadge = options.factionBadge or badgeFor(view),
        persistent = options.persistent == true,
        durationMs = options.durationMs,
        actions = actions,
    }
end

function Notification.Show(traderID, message, options)
    local definition = Notification.Build(traderID, message, options)
    local toast = toastSurface()
    if not toast then return false, "actor_notification_unavailable" end
    if type(toast.Update) == "function" then
        local updated = toast.Update(definition.id, definition)
        if updated == true then return true, definition end
    end
    if type(toast.Show) ~= "function" then
        return false, "actor_notification_unavailable"
    end
    local shown, reason = toast.Show(definition)
    return shown, reason or definition
end

function Notification.Dismiss(notificationID)
    local toast = toastSurface()
    if not toast or type(toast.Dismiss) ~= "function" then
        return false, "actor_notification_unavailable"
    end
    return toast.Dismiss(notificationID)
end

return Notification
