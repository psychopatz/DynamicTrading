DTAbstract = DTAbstract or {}
DTAbstract.Client = DTAbstract.Client or {}

local function hasRadio(player)
    if not DTAbstract.RequireRadio then return true end
    local radioState = PsychopatzCore and PsychopatzCore.RadioDeviceState
    if radioState and type(radioState.FindActivePlayerDevice) == "function"
        and radioState.FindActivePlayerDevice(player)
    then
        return true
    end
    local inventory = player and player.getInventory and player:getInventory() or nil
    if not inventory or type(inventory.containsTypeRecurse) ~= "function" then
        return false
    end
    return inventory:containsTypeRecurse("Base.WalkieTalkie")
        or inventory:containsTypeRecurse("Base.HamRadio1")
end

local function addRadioOption(playerNum, context)
    local player = getSpecificPlayer and getSpecificPlayer(playerNum) or nil
    local candidates = {}
    if not player or not hasRadio(player) then return end
    if not DTCommon or not DTCommon.TraderService
        or type(DTCommon.TraderService.ForEach) ~= "function"
    then
        return
    end
    DTCommon.TraderService.ForEach(function(traderID, record)
        local status = record and record.s or DTCommon.STATUS_READY
        if record and record.a == 1
            and status ~= DTCommon.STATUS_AWAY
            and (record.p or record.l)
        then
            candidates[#candidates + 1] = {
                id = traderID,
                name = tostring(record.n or traderID),
            }
        end
    end)
    table.sort(candidates, function(left, right)
        return tostring(left.id) < tostring(right.id)
    end)
    for _, candidate in ipairs(candidates) do
        context:addOption(
            DTCommon.T("DTAbstract_Radio_ContactCaravanTrader",
                "[Radio] Contact Caravan Trader")
                .. ": " .. candidate.name
                .. " [" .. tostring(candidate.id) .. "]",
            nil,
            function()
                if DTCommon and DTCommon.Client then
                    DTCommon.Client.OpenTrader(candidate.id, {
                        mode = "trade",
                    })
                end
            end
        )
    end
end

local function onFillWorldObjectContextMenu(playerNum, context, _, test)
    if test or not DTAbstract.Enabled or not context then return end
    addRadioOption(playerNum, context)
    -- Opt-in UI-only preview: no remote access, trading, or power bypass.
    -- Deliberately accessible as a development tool without a radio item.
    if DTAbstract.EnableRadioOSPreview == true
        and DTAbstract.RadioOS and DTAbstract.RadioOS.OpenPreview
    then
        context:addOption("[Radio OS] Preview (development)", nil,
            function()
                DTAbstract.RadioOS.OpenPreview(playerNum, "Base.WalkieTalkie5")
            end)
    end
end

if Events and Events.OnFillWorldObjectContextMenu
    and type(Events.OnFillWorldObjectContextMenu.Add) == "function"
then
    Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
end

return DTAbstract.Client
