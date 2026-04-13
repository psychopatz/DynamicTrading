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

local function getLocalUsername(player)
    return normalizeText(player and player.getUsername and player:getUsername() or nil)
end

local function getCommanderUsername(npcData, worker)
    local companionData = type(worker and worker.companion) == "table" and worker.companion or {}
    return normalizeText(
        npcData and npcData.dcCommanderUsername
            or companionData.commanderUsername
            or worker and worker.companionCommanderUsername
            or nil
    )
end

local function isLocalCommander(player, npcData, worker)
    local username = getLocalUsername(player)
    local commander = getCommanderUsername(npcData, worker)
    return username ~= nil and commander ~= nil and username == commander
end

local function getDistanceToNPC(player, npc)
    if not player or not npc then
        return 999999, 999999
    end
    local dx = (tonumber(player:getX()) or 0) - (tonumber(npc:getX()) or 0)
    local dy = (tonumber(player:getY()) or 0) - (tonumber(npc:getY()) or 0)
    local dz = math.abs((tonumber(player:getZ()) or 0) - (tonumber(npc:getZ()) or 0))
    return math.sqrt((dx * dx) + (dy * dy)), dz
end

local function canClaimCommand(player, npc)
    local distance, dz = getDistanceToNPC(player, npc)
    return distance <= 6 and dz <= 1
end

local function sendClaimCommand(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return false
    end
    return DC_System.SendCommand("ClaimCompanionCommand", {
        workerID = worker.workerID
    }) == true
end

local function sendTransferCommand(worker, username)
    if not worker or not worker.workerID or not username or not DC_System or not DC_System.SendCommand then
        return false
    end
    return DC_System.SendCommand("TransferCompanionCommand", {
        workerID = worker.workerID,
        username = username
    }) == true
end

local function collectTransferCandidates(player, worker)
    local currentUsername = getLocalUsername(player)
    local seen = {}
    local candidates = {}

    local function add(username)
        username = normalizeText(username)
        if not username or username == currentUsername or seen[username] then
            return
        end
        seen[username] = true
        candidates[#candidates + 1] = username
    end

    local status = DC_MainWindow and DC_MainWindow.cachedOwnedFactionStatus
        or DC_System and DC_System.ownedFactionStatusCache
        or nil
    local faction = status and status.faction or nil
    add(faction and faction.leaderUsername)
    for _, username in ipairs(status and status.memberUsernames or faction and faction.memberUsernames or {}) do
        add(username)
    end

    local ownerUsername = normalizeText(worker and worker.ownerUsername)
    if ownerUsername and ownerUsername ~= currentUsername then
        add(ownerUsername)
    end

    table.sort(candidates)
    return candidates
end

local function refreshCompanionWorker(worker)
    if not worker or not worker.workerID or not DC_System or not DC_System.SendCommand then
        return
    end
    DC_System.SendCommand("RequestCompanionCommandStatus", {
        workerID = worker.workerID
    })
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
        if DTNPCHealth and DTNPCHealth.CancelPendingSelfBandage then
            DTNPCHealth.CancelPendingSelfBandage(npc, npcData, state, {
                manualInterrupt = true,
                retryDelayMs = DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS,
                sync = false,
            })
        end
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

local function addDisabledContextAction(menu, label)
    local option = menu:addOption(label, nil, nil)
    if option then
        option.notAvailable = true
    end
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

local function addTransferCommandContextMenu(parentMenu, worker, player)
    local candidates = collectTransferCandidates(player, worker)
    local option = parentMenu:addOption("Transfer Command")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    if #candidates == 0 then
        addDisabledContextAction(subMenu, "No faction members available")
        return
    end

    for _, username in ipairs(candidates) do
        addCompanionContextAction(subMenu, username, function()
            sendTransferCommand(worker, username)
            refreshCompanionWorker(worker)
        end)
    end
end

local function addCompanionContextMenu(context, ui, npc, player, npcData)
    if not context or not npc or not player then
        return false
    end

    local worker = getCompanionWorker(ui, npc, npcData or getNPCData(npc))
    local name = tostring((npcData and npcData.name) or (worker and worker.name) or "Companion")
    local liveData = npcData or getNPCData(npc)
    local commander = getCommanderUsername(liveData, worker)
    local isCommander = isLocalCommander(player, liveData, worker)
    local usesCommandAuthority = worker ~= nil and tostring(liveData and liveData.dcCompanionJob or "") == "TravelCompanion"

    local rootOption = context:addOption("Companion Orders: " .. name)
    local rootMenu = context:getNew(context)
    context:addSubMenu(rootOption, rootMenu)

    if usesCommandAuthority then
        addDisabledContextAction(rootMenu, "Commander: " .. tostring(commander or "No commander"))
    end

    addCompanionContextAction(rootMenu, "Talk", function()
        openCompanionDialogue(npc, player)
    end)

    if usesCommandAuthority and not isCommander then
        if worker and canClaimCommand(player, npc) then
            addCompanionContextAction(rootMenu, "Claim Command", function()
                sendClaimCommand(worker)
                refreshCompanionWorker(worker)
            end)
        else
            addDisabledContextAction(rootMenu, "Move closer to claim command.")
        end
        return true
    end

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
    if usesCommandAuthority and worker then
        addTransferCommandContextMenu(rootMenu, worker, player)
    end

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

    local npcData = getNPCData(npc)
    local commander = getCommanderUsername(npcData, worker)
    local commanderText = "Commander: " .. tostring(commander or "No commander")
    local usesCommandAuthority = worker ~= nil and tostring(npcData and npcData.dcCompanionJob or "") == "TravelCompanion"
    if usesCommandAuthority and not isLocalCommander(player, npcData, worker) then
        local options = {
            {
                text = commanderText,
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak(commander and ("I'm taking orders from " .. commander .. ".") or "No one is commanding me right now.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            },
            {
                text = "Chat",
                message = "How are you holding up?",
                onSelect = function(innerUI)
                    innerUI:speak("I'm here, but command has to be claimed first.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        }

        if worker and canClaimCommand(player, npc) then
            options[#options + 1] = {
                text = "Claim Command",
                message = "I'm taking command. Follow my lead.",
                onSelect = function(innerUI)
                    if sendClaimCommand(worker) then
                        local liveData = getNPCData(npc)
                        if liveData then
                            liveData.dcCommanderUsername = getLocalUsername(player)
                            liveData.master = getLocalUsername(player)
                            liveData.masterID = player and player.getOnlineID and player:getOnlineID() or liveData.masterID
                            attachNPCData(npc, liveData)
                        end
                        innerUI:speak("Command claimed. I'll follow you.")
                        refreshCompanionWorker(worker)
                    else
                        innerUI:speak("I couldn't claim command right now.")
                    end
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        else
            options[#options + 1] = {
                text = "Move closer to claim command.",
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak("Move within a few steps, then claim command.")
                    generateRootOptions(innerUI, npc, player, worker)
                end
            }
        end

        options[#options + 1] = {
            text = "Leave",
            message = "",
            onSelect = function(innerUI)
                innerUI:close()
            end
        }
        ui:updateOptions(options)
        return
    end

    local options = {}
    if usesCommandAuthority then
        options[#options + 1] = {
            text = commanderText,
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("You're my current commander.")
                generateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = "Chat",
        message = "How are you holding up?",
        onSelect = function(innerUI)
            innerUI:speak("I'm with you. Just say the word.")
            generateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
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
    }

    options[#options + 1] = {
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
    }

    options[#options + 1] = {
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
    }

    options[#options + 1] = {
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
    }

    if usesCommandAuthority then
        options[#options + 1] = {
            text = "Transfer Command",
            message = "I'm assigning you to someone else.",
            onSelect = function(innerUI)
                local candidates = collectTransferCandidates(player, worker)
                if #candidates == 0 then
                    innerUI:speak("There isn't another faction member to transfer command to.")
                    generateRootOptions(innerUI, npc, player, worker)
                    return
                end

                local choices = {}
                for _, username in ipairs(candidates) do
                    choices[#choices + 1] = {
                        text = tostring(username),
                        message = "Report to " .. tostring(username) .. ".",
                        onSelect = function(choiceUI)
                            if sendTransferCommand(worker, username) then
                                choiceUI:speak("Command transferred to " .. tostring(username) .. ".")
                                refreshCompanionWorker(worker)
                            else
                                choiceUI:speak("I couldn't transfer command right now.")
                            end
                            generateRootOptions(choiceUI, npc, player, worker)
                        end
                    }
                end
                choices[#choices + 1] = {
                    text = "Back",
                    message = "",
                    onSelect = function(choiceUI)
                        generateRootOptions(choiceUI, npc, player, worker)
                    end
                }
                innerUI:updateOptions(choices)
            end
        }
    end

    if worker then
        options[#options + 1] = {
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
        }
    end

    options[#options + 1] = {
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
    }

    options[#options + 1] = {
        text = "Leave",
        message = "",
        onSelect = function(innerUI)
            innerUI:close()
        end
    }

    ui:updateOptions(options)
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
