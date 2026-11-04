-- DTAbstract remote conversation bridge.
--
-- DTAbstract does not depend on ProjectHoomans.
-- It requests server authorization, then opens the Core-owned conversation UI
-- for the canonical Core actor. ProjectHoomans and DTHoomans are incompatible
-- with DTAbstract by activation policy.

DTAbstract = DTAbstract or {}
DTAbstract.CoreConversation =
    DTAbstract.CoreConversation or {}

local Bridge = DTAbstract.CoreConversation
local CoreConversation = DTCommon
    and DTCommon.CoreTraderConversation
    or require "DTCommon/DTCommon_CoreTraderConversation"

Bridge.Pending = Bridge.Pending or {}

local function currentPlayer()
    return getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
end

local function send(command, args)
    local player = currentPlayer()
    if not player or type(sendClientCommand) ~= "function" then
        return false, "send_command_unavailable"
    end
    sendClientCommand(
        player,
        "DTAbstract",
        command,
        args or {}
    )
    return true
end

local function traderRecord(traderID)
    local service = DTCommon and DTCommon.TraderService or nil
    if not service or type(service.GetRecord) ~= "function" then
        return nil
    end
    return service.GetRecord(tostring(traderID or ""))
end

local function actorIDFor(traderID, hintedActorID)
    if hintedActorID ~= nil and tostring(hintedActorID) ~= "" then
        return tostring(hintedActorID)
    end
    local record = traderRecord(traderID)
    local ca = record and record.ca or nil
    return ca and ca.actorID
        and tostring(ca.actorID) or nil
end

function Bridge.Request(
    traderID,
    mode,
    options
)
    traderID = tostring(traderID or "")
    mode = tostring(mode or "radio")
    options = type(options) == "table"
        and options or {}
    if traderID == "" then
        return false, "trader_required"
    end
    if mode ~= "radio" and mode ~= "debug" then
        return false, "conversation_mode_invalid"
    end

    Bridge.Pending[traderID] = {
        traderID = traderID,
        actorID = actorIDFor(
            traderID,
            options.actorID
        ),
        displayName = options.displayName,
        mode = mode,
    }
    local sent, reason = send(
        "ConversationAccessRequest",
        {
            traderID = traderID,
            mode = mode,
        }
    )
    if not sent then
        Bridge.Pending[traderID] = nil
        return false, reason
    end
    return true, "access_requested"
end

function Bridge.HandleAccessResult(args)
    args = type(args) == "table" and args or {}
    local traderID = tostring(args.traderID or "")
    if traderID == "" then
        return false, "trader_required"
    end
    local pending = Bridge.Pending[traderID]
    Bridge.Pending[traderID] = nil

    if args.accepted ~= true then
        return false, args.reason
            or "conversation_access_denied"
    end

    local actorID = actorIDFor(
        traderID,
        args.actorID
            or pending and pending.actorID
    )
    if not actorID then
        return false, "core_actor_required"
    end

    return CoreConversation.Open(
        traderID,
        actorID,
        {
            displayName = pending
                and pending.displayName or nil,
            mode = args.mode
                or pending and pending.mode,
        }
    )
end

local function onServerCommand(module, command, args)
    if module ~= "DTAbstract"
        or command ~= "ConversationAccessResult"
    then
        return
    end
    local view, reason = Bridge.HandleAccessResult(args)
    Bridge.LastResult = {
        accepted = view ~= nil,
        traderID = args and args.traderID or nil,
        actorID = args and args.actorID or nil,
        mode = args and args.mode or nil,
        reason = view and "conversation_opened"
            or reason,
        view = view,
    }
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not Bridge._serverHook
then
    Bridge._serverHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

return Bridge
