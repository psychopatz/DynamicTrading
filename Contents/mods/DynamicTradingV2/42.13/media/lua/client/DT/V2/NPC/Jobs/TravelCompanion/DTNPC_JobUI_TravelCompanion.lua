-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion.lua
-- Travel companion job UI and order handlers.
-- ==============================================================================

pcall(require, "DC/UI/Colony/System/DC_System")
pcall(require, "DC/UI/Colony/SupplyWindow/DC_SupplyWindow")

local function debugCompanionUI(message)
    local text = "[DTV2 Companion UI] " .. tostring(message or "")
    print(text)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "CompanionUI", tostring(message or ""))
    end
end

local function getNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end

local function normalizeText(value)
    value = value and tostring(value) or ""
    return value ~= "" and value or nil
end

local function getAuthorityUsername(player)
    if not player then
        return nil
    end

    local username = normalizeText(player.getUsername and player:getUsername() or nil)
    if DynamicTrading_Factions and DynamicTrading_Factions.GetPlayerFaction and username then
        local faction = DynamicTrading_Factions.GetPlayerFaction(username)
        local leader = normalizeText(faction and faction.leaderUsername or nil)
        if leader then
            return leader
        end
    end

    return username
end

local function buildWorkerLookupUI(ui, npc, npcData)
    if ui then
        return ui
    end

    return {
        interactionObj = npc,
        target = {
            id = npcData and npcData.uuid or nil,
            name = npcData and npcData.name or nil,
            factionID = npcData and npcData.factionID or nil,
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    }
end

local function resolveCompanionWorkerByID(workerID)
    if not workerID then
        return nil
    end

    local cache = DC_MainWindow and DC_MainWindow.cachedDetails or nil
    if type(cache) == "table" and type(cache[workerID]) == "table" then
        return cache[workerID]
    end

    local internal = DC_SupplyWindow and DC_SupplyWindow.Internal or nil
    if internal and internal.resolveWorkerDetail then
        local detail = internal.resolveWorkerDetail(workerID)
        if detail then
            return detail
        end
    end

    local registry = DC_Colony and DC_Colony.Registry or nil
    if registry and registry.GetWorker then
        local worker = registry.GetWorker(workerID)
        if worker then
            return worker
        end
    end

    if registry and registry.GetWorkerRaw then
        return registry.GetWorkerRaw(workerID)
    end

    return nil
end

local function getCompanionWorker(ui, npc, npcData)
    local lookupUI = buildWorkerLookupUI(ui, npc, npcData)
    if DC_System and DC_System.GetConversationCompanionWorker then
        local ok, worker = pcall(DC_System.GetConversationCompanionWorker, lookupUI)
        if ok and worker then
            return worker
        end
    end

    local target = lookupUI and lookupUI.target or nil
    local linkedWorkerID = (npcData and npcData.linkedWorkerID)
        or (target and target.linkedWorkerID)
        or nil
    if linkedWorkerID then
        local worker = resolveCompanionWorkerByID(linkedWorkerID)
        if worker then
            return worker
        end
    end

    return nil
end

local function isLegacyTravelCompanion(player, npcData)
    if not player or not npcData then
        return false
    end

    if tostring(npcData.dcCompanionJob or "") ~= "TravelCompanion" then
        return false
    end

    if npcData.dcCompanionActive ~= true then
        return false
    end

    local authority = normalizeText(getAuthorityUsername(player))
    local owner = normalizeText(npcData.dcCompanionOwner or npcData.ownerUsername or npcData.master or nil)
    return authority ~= nil and owner == authority
end

local function attachNPCData(npc, npcData)
    if npc and npcData and DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
end

local function sendCompanionOrder(player, npc, args)
    local npcData = getNPCData(npc)
    if not player or not npcData or not npcData.uuid then
        return false, npcData
    end

    args = type(args) == "table" and args or {}
    args.uuid = npcData.uuid
    sendClientCommand(player, "DTNPC", "Order", args)
    return true, npcData
end

local function updateCompanionState(player, npc, state, extraArgs)
    local sent, npcData = sendCompanionOrder(player, npc, extraArgs and extraArgs or { state = state })
    if not sent or not npcData then
        return false
    end

    if state ~= "PatchUp" then
        npcData.state = state or npcData.state
    end
    if extraArgs and extraArgs.combatOrder then
        npcData.combatOrder = extraArgs.combatOrder
    elseif state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.combatOrder = state
    elseif state ~= "PatchUp" then
        npcData.combatOrder = nil
    end

    if state == "Follow" or state == "ProtectAuto" or state == "ProtectRanged" or state == "ProtectMelee" then
        npcData.master = player and player.getUsername and player:getUsername() or npcData.master
        npcData.masterID = player and player.getOnlineID and player:getOnlineID() or npcData.masterID
    end

    npcData.tasks = {}
    attachNPCData(npc, npcData)
    return true
end

local function getAttackTypeLabel(npcData)
    local combatOrder = npcData and npcData.combatOrder or nil
    if combatOrder == "ProtectAuto" then
        return "Auto"
    end
    if combatOrder == "ProtectRanged" then
        return "Ranged"
    end
    if combatOrder == "ProtectMelee" then
        return "Melee"
    end
    return "Balanced"
end

local function openCompanionInventory(ui, worker, npc, npcData)
    if not DC_SupplyWindow or not DC_SupplyWindow.Open then
        debugCompanionUI("openCompanionInventory missing DC_SupplyWindow.Open")
        return false
    end

    local resolvedWorker = nil
    local liveNPCData = npcData or getNPCData(npc)

    if worker and worker.workerID then
        resolvedWorker = resolveCompanionWorkerByID(worker.workerID) or worker
    end

    if (not resolvedWorker or not resolvedWorker.workerID) and (liveNPCData and liveNPCData.linkedWorkerID) then
        resolvedWorker = resolveCompanionWorkerByID(liveNPCData.linkedWorkerID)
    end

    if not resolvedWorker or not resolvedWorker.workerID then
        debugCompanionUI(
            "openCompanionInventory failed to resolve worker linkedWorkerID="
                .. tostring(liveNPCData and liveNPCData.linkedWorkerID or nil)
        )
        return false
    end

    debugCompanionUI(
        "openCompanionInventory workerID=" .. tostring(resolvedWorker.workerID)
            .. " name=" .. tostring(resolvedWorker.name or resolvedWorker.workerID)
    )
    DC_SupplyWindow.Open(resolvedWorker, "inventory")

    if ui and ui.close then
        ui:close()
    end
    return true
end

local function sendCompanionHome(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    return DC_System.SendCommand("SetWorkerJobEnabled", {
        workerID = worker.workerID,
        enabled = false,
    }) == true
end

local function orderCompanionReturnHome(player, npc)
    local sent, npcData = sendCompanionOrder(player, npc, {
        state = "Idle",
        returnStatus = "Resting",
        startDeparture = true,
    })
    if not sent or not npcData then
        return false
    end

    npcData.state = "Departure"
    npcData.status = "Away"
    npcData.returnStatus = "Resting"
    npcData.requestedReturnStatus = "Resting"
    npcData.master = nil
    npcData.masterID = nil
    npcData.tasks = {}
    npcData.combatOrder = nil
    attachNPCData(npc, npcData)
    return true
end

local function openCompanionDialogue(npc, player)
    if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
        DTNPC_TraderDialogue_Hub.Init(nil, npc, player)
        return true
    end
    return false
end

local function addCompanionContextAction(menu, label, callback)
    menu:addOption(label, nil, callback)
end

local function addAttackTypeContextMenu(parentMenu, npc, player)
    local option = parentMenu:addOption("Attack Type")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    addCompanionContextAction(subMenu, "Auto", function()
        updateCompanionState(player, npc, "ProtectAuto", {
            state = "ProtectAuto",
            combatOrder = "ProtectAuto",
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(subMenu, "Ranged", function()
        updateCompanionState(player, npc, "ProtectRanged", {
            state = "ProtectRanged",
            combatOrder = "ProtectRanged",
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(subMenu, "Melee", function()
        updateCompanionState(player, npc, "ProtectMelee", {
            state = "ProtectMelee",
            combatOrder = "ProtectMelee",
            returnStatus = "Resting",
        })
    end)
end

local function addCompanionContextMenu(context, ui, npc, player, npcData)
    if not context or not npc or not player then
        return false
    end

    local worker = getCompanionWorker(ui, npc, npcData or getNPCData(npc))
    local name = tostring((npcData and npcData.name) or (worker and worker.name) or "Companion")

    local rootOption = context:addOption("Companion Orders: " .. name)
    local rootMenu = context:getNew(context)
    context:addSubMenu(rootOption, rootMenu)

    addCompanionContextAction(rootMenu, "Talk", function()
        openCompanionDialogue(npc, player)
    end)

    addCompanionContextAction(rootMenu, "Follow Me", function()
        updateCompanionState(player, npc, "Follow", {
            state = "Follow",
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(rootMenu, "Hold Position", function()
        updateCompanionState(player, npc, "Stay", {
            state = "Stay",
            returnStatus = "Resting",
        })
    end)

    addCompanionContextAction(rootMenu, "Patch Up", function()
        updateCompanionState(player, npc, "PatchUp", {
            state = "PatchUp",
        })
    end)

    addAttackTypeContextMenu(rootMenu, npc, player)

    if worker or (npcData and npcData.linkedWorkerID) then
        addCompanionContextAction(rootMenu, "Manage Inventory", function()
            openCompanionInventory(ui, worker, npc, npcData)
        end)
    end

    if worker then
        addCompanionContextAction(rootMenu, "Go Home", function()
            local workerCommandSent = sendCompanionHome(worker)
            local returnOrderSent = orderCompanionReturnHome(player, npc)
            return workerCommandSent and returnOrderSent
        end)
    end

    return true
end

local function generateRootOptions(ui, npc, player, worker)
    ui.isCompanionConversation = true
    if ui.refreshFactionInfo then
        ui:refreshFactionInfo()
    end

    ui:updateOptions({
        {
            text = "Chat",
            message = "How are you holding up?",
            onSelect = function(innerUI)
                innerUI:speak("I'm with you. Just say the word.")
                generateRootOptions(innerUI, npc, player, worker)
            end
        },
        {
            text = "Follow Me",
            message = "Stay close and move with me.",
            onSelect = function(innerUI)
                if updateCompanionState(player, npc, "Follow", {
                    state = "Follow",
                    returnStatus = "Resting",
                }) then
                    innerUI:speak("I'll stay close.")
                else
                    innerUI:speak("I couldn't follow you right now.")
                end
                generateRootOptions(innerUI, npc, player, worker)
            end
        },
        {
            text = "Hold Position",
            message = "Stay put until I tell you otherwise.",
            onSelect = function(innerUI)
                if updateCompanionState(player, npc, "Stay", {
                    state = "Stay",
                    returnStatus = "Resting",
                }) then
                    innerUI:speak("I'll hold here.")
                else
                    innerUI:speak("I couldn't hold position right now.")
                end
                generateRootOptions(innerUI, npc, player, worker)
            end
        },
        {
            text = "Patch Up",
            message = "Take a moment to bandage yourself.",
            onSelect = function(innerUI)
                local sent = updateCompanionState(player, npc, "PatchUp", {
                    state = "PatchUp",
                })
                if sent then
                    innerUI:speak("I'll patch myself up.")
                else
                    innerUI:speak("I couldn't patch up right now.")
                end
                generateRootOptions(innerUI, npc, player, worker)
            end
        },
        {
            text = "Attack Type",
            message = "Let's talk combat.",
            onSelect = function(innerUI)
                local npcData = getNPCData(npc)
                local currentLabel = getAttackTypeLabel(npcData)
                innerUI:speak("Current attack type: " .. currentLabel .. ".")
                innerUI:updateOptions({
                    {
                        text = "Auto",
                        message = "Use whichever weapon fits the fight.",
                        onSelect = function(choiceUI)
                            if updateCompanionState(player, npc, "ProtectAuto", {
                                state = "ProtectAuto",
                                combatOrder = "ProtectAuto",
                                returnStatus = "Resting",
                            }) then
                                choiceUI:speak("I'll switch between range and melee as needed.")
                            else
                                choiceUI:speak("I couldn't switch attack type right now.")
                            end
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    },
                    {
                        text = "Ranged",
                        message = "Cover me from range.",
                        onSelect = function(choiceUI)
                            if updateCompanionState(player, npc, "ProtectRanged", {
                                state = "ProtectRanged",
                                combatOrder = "ProtectRanged",
                                returnStatus = "Resting",
                            }) then
                                choiceUI:speak("I'll keep some distance and cover you.")
                            else
                                choiceUI:speak("I couldn't switch attack type right now.")
                            end
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    },
                    {
                        text = "Melee",
                        message = "Stay close and fight up front.",
                        onSelect = function(choiceUI)
                            if updateCompanionState(player, npc, "ProtectMelee", {
                                state = "ProtectMelee",
                                combatOrder = "ProtectMelee",
                                returnStatus = "Resting",
                            }) then
                                choiceUI:speak("I'll stay close and handle threats up front.")
                            else
                                choiceUI:speak("I couldn't switch attack type right now.")
                            end
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    },
                    {
                        text = "Back",
                        message = "",
                        onSelect = function(choiceUI)
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    }
                })
            end
        },
        {
            text = "Manage Inventory",
            message = "Let me check what you're carrying.",
            onSelect = function(innerUI)
                if openCompanionInventory(innerUI, worker, npc, getNPCData(npc)) then
                    return
                else
                    innerUI:speak("I couldn't open my inventory right now.")
                    debugCompanionUI(
                        "Manage Inventory failed workerID="
                            .. tostring(worker and worker.workerID or nil)
                            .. " linkedWorkerID="
                            .. tostring(getNPCData(npc) and getNPCData(npc).linkedWorkerID or nil)
                    )
                end
                generateRootOptions(innerUI, npc, player, worker)
            end
        },
        {
            text = "Go Home",
            message = "Head back home and stand down.",
            onSelect = function(innerUI)
                local workerCommandSent = worker and sendCompanionHome(worker) or true
                local returnOrderSent = orderCompanionReturnHome(player, npc)
                if workerCommandSent and returnOrderSent then
                    innerUI:speak("Understood. I'll head home.")
                    innerUI:updateOptions({
                        {
                            text = "Exit",
                            message = "",
                            onSelect = function(closeUI)
                                closeUI:close()
                            end
                        }
                    })
                else
                    innerUI:speak("I couldn't head home right now.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            end
        },
        {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:close()
            end
        }
    })
end

DTNPCJobUI.Register({
    id = "TravelCompanion",
    priority = 100,
    matches = function(ui, npc, player, npcData)
        npcData = npcData or getNPCData(npc)
        if not npcData then
            return false
        end

        if getCompanionWorker(ui, npc, npcData) then
            return true
        end

        return isLegacyTravelCompanion(player, npcData)
    end,
    getTalkLabel = function(ui, npc, player, npcData, defaultName)
        return "Talk to Companion " .. tostring(defaultName or (npcData and npcData.name) or "Survivor")
    end,
    getTraderProxyPatch = function(ui, npc, player, npcData)
        return {
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    end,
    generateOptions = function(ui, npc, player, npcData)
        local worker = getCompanionWorker(ui, npc, npcData or getNPCData(npc))
        generateRootOptions(ui, npc, player, worker)
        return true
    end,
    addContextMenuOptions = function(context, ui, npc, player, npcData)
        return addCompanionContextMenu(context, ui, npc, player, npcData or getNPCData(npc))
    end
})
