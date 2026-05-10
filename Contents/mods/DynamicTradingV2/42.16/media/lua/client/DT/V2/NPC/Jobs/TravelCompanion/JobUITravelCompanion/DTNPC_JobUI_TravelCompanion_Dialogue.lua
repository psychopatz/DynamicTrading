-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Dialogue.lua
-- Dialogue flow for travel companion interactions.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Dialogue then
    return
end

modules.Dialogue = true

function CompanionUI.OpenCompanionDialogue(npc, player)
    if DTNPC_TraderDialogue_Hub and DTNPC_TraderDialogue_Hub.Init then
        DTNPC_TraderDialogue_Hub.Init(nil, npc, player)
        return true
    end
    return false
end

function CompanionUI.OpenLootSearchWindow(player, npcData)
    if not player or not npcData or not npcData.uuid or not DTNPCLootSearchClient then
        return false
    end

    DTNPCLootSearchClient.OpenForNPC(player:getPlayerNum(), npcData)
    DTNPCLootSearchClient.RequestSync(player, npcData)
    return true
end

function CompanionUI.GenerateRootOptions(ui, npc, player, worker)
    ui.isCompanionConversation = true
    if ui.refreshFactionInfo then
        ui:refreshFactionInfo()
    end

    local npcData = CompanionUI.GetNPCData(npc)
    local commander = CompanionUI.GetCommanderUsername(npcData, worker)
    local commanderText = "Commander: " .. tostring(commander or "No commander")
    local usesCommandAuthority = worker ~= nil and tostring(npcData and npcData.dcCompanionJob or "") == "TravelCompanion"
    if usesCommandAuthority and not CompanionUI.IsLocalCommander(player, npcData, worker) then
        local options = {
            {
                text = commanderText,
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak(commander and ("I'm taking orders from " .. commander .. ".") or "No one is commanding me right now.")
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            },
            {
                text = "Chat",
                message = "How are you holding up?",
                onSelect = function(innerUI)
                    innerUI:speak("I'm here, but command has to be claimed first.")
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            }
        }

        if worker and CompanionUI.CanClaimCommand(player, npc) then
            options[#options + 1] = {
                text = "Claim Command",
                message = "I'm taking command. Follow my lead.",
                onSelect = function(innerUI)
                    if CompanionUI.SendClaimCommand(worker) then
                        CompanionUI.PlayCompanionCommandCue(player, "ClaimCommand")
                        local liveData = CompanionUI.GetNPCData(npc)
                        if liveData then
                            liveData.dcCommanderUsername = CompanionUI.GetLocalUsername(player)
                            liveData.master = CompanionUI.GetLocalUsername(player)
                            liveData.masterID = player and player.getOnlineID and player:getOnlineID() or liveData.masterID
                            CompanionUI.AttachNPCData(npc, liveData)
                        end
                        innerUI:speak("Command claimed. I'll follow you.")
                        CompanionUI.RefreshCompanionWorker(worker)
                    else
                        innerUI:speak("I couldn't claim command right now.")
                    end
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            }
        else
            options[#options + 1] = {
                text = "Move closer to claim command.",
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak("Move within a few steps, then claim command.")
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            }
        end

        local footerAction = CompanionUI.BuildLeaveFooterAction()
        local _, navBlock = CompanionUI.AttachNavigationBlock(options, footerAction, {
            resetHistory = true,
            debugLabel = "CompanionClaimRoot",
            requireExplicitNavigation = true,
        })
        ui:updateOptions(options, navBlock)
        return
    end

    local options = {}
    if usesCommandAuthority then
        options[#options + 1] = {
            text = commanderText,
            message = "",
            onSelect = function(innerUI)
                innerUI:speak("You're my current commander.")
                CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = "Chat",
        message = "How are you holding up?",
        onSelect = function(innerUI)
            innerUI:speak("I'm with you. Just say the word.")
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Follow Me",
        message = "Stay close and move with me.",
        onSelect = function(innerUI)
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Follow", {
                state = "Follow",
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll stay close.")
            else
                innerUI:speak("I couldn't follow you right now.")
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Hold Position",
        message = "Stay put until I tell you otherwise.",
        onSelect = function(innerUI)
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
                state = "Stay",
                clearGuardMode = true,
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll hold here.")
            else
                innerUI:speak("I couldn't hold position right now.")
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Guard Position",
        message = "Hold this area and engage nearby threats.",
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = (liveData and (liveData.guardCombatOrder or liveData.guardAttackMode)) or "GuardAuto",
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll guard this position.")
            else
                innerUI:speak("I couldn't take up guard duty right now.")
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = (npcData and npcData.state == "LootNearby") and "Stop Loot Search" or "Search Nearby Loot",
        message = "Search nearby sources, reveal their contents, then tell me what to collect.",
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            if liveData and liveData.state == "LootNearby" then
                if CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
                    state = "Stay",
                    returnStatus = "Resting",
                }) then
                    innerUI:speak("Looting paused.")
                else
                    innerUI:speak("I couldn't stop looting right now.")
                end
                CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                return
            end

            if CompanionUI.IssueCompanionStateOrder(player, npc, "LootNearby", {
                state = "LootNearby",
                x = npc:getX(),
                y = npc:getY(),
                z = npc:getZ(),
                lootRadius = liveData and liveData.dcLootConfig and liveData.dcLootConfig.radius or nil,
                combatOrder = CompanionUI.GetLootCombatOrder(liveData),
                returnStatus = "Resting",
            }) then
                innerUI:speak("I'll search nearby sources and wait for your pickup orders.")
                CompanionUI.OpenLootSearchWindow(player, liveData)
            else
                innerUI:speak("I couldn't start looting right now.")
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    local patchUpLabel, patchUpSupplyTotal = CompanionUI.GetPatchUpLabel(worker)
    options[#options + 1] = {
        text = patchUpLabel,
        message = "Take a moment to bandage yourself.",
        onSelect = function(innerUI)
            local sent = CompanionUI.SendPatchUpOrder(player, npc)
            if sent then
                if patchUpSupplyTotal > 0 then
                    innerUI:speak("I'll patch myself up.")
                else
                    innerUI:speak("I don't have any bandages or rags packed.")
                end
            else
                innerUI:speak("I couldn't patch up right now.")
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = "Attack Type",
        message = "Let's talk combat.",
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            local currentLabel = CompanionUI.GetAttackTypeLabel(liveData)
            local currentMode = CompanionUI.GetAttackTypeMode(liveData)
            local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "ProtectAuto" or currentMode == "ProtectRanged")
            innerUI:speak("Current attack type: " .. currentLabel .. ".")
            local attackOptions = {
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        "Auto",
                        currentMode == "ProtectAuto",
                        showAmmo and currentMode == "ProtectAuto",
                        ammoSnapshot
                    ),
                    message = "Use whichever weapon fits the fight.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectAuto", "auto"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectAuto", {
                            state = "ProtectAuto",
                            combatOrder = "ProtectAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll switch between range and melee as needed.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        "Ranged",
                        currentMode == "ProtectRanged",
                        showAmmo and currentMode == "ProtectRanged",
                        ammoSnapshot
                    ),
                    message = "Cover me from range.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectRanged", {
                            state = "ProtectRanged",
                            combatOrder = "ProtectRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll keep some distance and cover you.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel("Melee", currentMode == "ProtectMelee", false, ammoSnapshot),
                    message = "Stay close and fight up front.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectMelee", "melee"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectMelee", {
                            state = "ProtectMelee",
                            combatOrder = "ProtectMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll stay close and handle threats up front.")
                        else
                            choiceUI:speak("I couldn't switch attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
            }
            local footerAction = CompanionUI.BuildBackFooterAction({
                onSelect = function(backUI)
                    CompanionUI.GenerateRootOptions(backUI, npc, player, worker)
                end
            })
            local _, navBlock = CompanionUI.AttachNavigationBlock(attackOptions, footerAction, {
                debugLabel = "CompanionAttackType",
                requireExplicitNavigation = true,
            })
            innerUI:updateOptions(attackOptions, navBlock)
        end
    }

    options[#options + 1] = {
        text = "Guard Attack Type",
        message = "How should you fight while guarding?",
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            local currentLabel = CompanionUI.GetGuardAttackTypeLabel(liveData)
            local currentMode = CompanionUI.GetGuardAttackTypeMode(liveData)
            local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "GuardAuto" or currentMode == "GuardRanged")
            innerUI:speak("Current guard attack type: " .. currentLabel .. ".")
            local guardOptions = {
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        "Auto",
                        currentMode == "GuardAuto",
                        showAmmo and currentMode == "GuardAuto",
                        ammoSnapshot
                    ),
                    message = "Use whichever weapon fits the threat while guarding.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardAuto", "auto"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll guard this spot and adapt as needed.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        "Ranged",
                        currentMode == "GuardRanged",
                        showAmmo and currentMode == "GuardRanged",
                        ammoSnapshot
                    ),
                    message = "Guard from a distance.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll hold this spot and engage from range.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel("Melee", currentMode == "GuardMelee", false, ammoSnapshot),
                    message = "Hold the line up close.",
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardMelee", "melee"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak("I'll hold this spot and fight up close.")
                        else
                            choiceUI:speak("I couldn't switch guard attack type right now.")
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
            }
            local footerAction = CompanionUI.BuildBackFooterAction({
                onSelect = function(backUI)
                    CompanionUI.GenerateRootOptions(backUI, npc, player, worker)
                end
            })
            local _, navBlock = CompanionUI.AttachNavigationBlock(guardOptions, footerAction, {
                debugLabel = "CompanionGuardAttackType",
                requireExplicitNavigation = true,
            })
            innerUI:updateOptions(guardOptions, navBlock)
        end
    }

    if usesCommandAuthority then
        options[#options + 1] = {
            text = "Transfer Command",
            message = "I'm assigning you to someone else.",
            onSelect = function(innerUI)
                local candidates = CompanionUI.CollectTransferCandidates(player, worker)
                if #candidates == 0 then
                    innerUI:speak("There isn't another faction member to transfer command to.")
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                    return
                end

                local choices = {}
                for _, username in ipairs(candidates) do
                    choices[#choices + 1] = {
                        text = tostring(username),
                        message = "Report to " .. tostring(username) .. ".",
                        onSelect = function(choiceUI)
                            if CompanionUI.SendTransferCommand(worker, username) then
                                CompanionUI.PlayCompanionCommandCue(player, "TransferCommand")
                                choiceUI:speak("Command transferred to " .. tostring(username) .. ".")
                                CompanionUI.RefreshCompanionWorker(worker)
                            else
                                choiceUI:speak("I couldn't transfer command right now.")
                            end
                            CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                        end
                    }
                end
                local footerAction = CompanionUI.BuildBackFooterAction({
                    onSelect = function(backUI)
                        CompanionUI.GenerateRootOptions(backUI, npc, player, worker)
                    end
                })
                local _, navBlock = CompanionUI.AttachNavigationBlock(choices, footerAction, {
                    debugLabel = "CompanionTransferCommand",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(choices, navBlock)
            end
        }
    end

    if worker then
        options[#options + 1] = {
            text = "Manage Inventory",
            message = "Let me check what you're carrying.",
            onSelect = function(innerUI)
                if CompanionUI.OpenCompanionInventory(innerUI, worker, npc, CompanionUI.GetNPCData(npc)) then
                    return
                else
                    innerUI:speak("I couldn't open my inventory right now.")
                    CompanionUI.DebugCompanionUI(
                        "Manage Inventory failed workerID="
                            .. tostring(worker and worker.workerID or nil)
                            .. " linkedWorkerID="
                            .. tostring(CompanionUI.GetNPCData(npc) and CompanionUI.GetNPCData(npc).linkedWorkerID or nil)
                    )
                end
                CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = "Go Home",
        message = "Head back home and stand down.",
        onSelect = function(innerUI)
            local workerCommandSent = worker and CompanionUI.SendCompanionHome(worker) or true
            local returnOrderSent = CompanionUI.OrderCompanionReturnHome(player, npc)
            if workerCommandSent and returnOrderSent then
                CompanionUI.PlayCompanionCommandCue(player, "GoHome")
                innerUI:speak("Understood. I'll head home.")
                local doneOptions = {}
                local footerAction = CompanionUI.BuildExitFooterAction()
                local _, navBlock = CompanionUI.AttachNavigationBlock(doneOptions, footerAction, {
                    resetHistory = true,
                    debugLabel = "CompanionGoHomeResolved",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(doneOptions, navBlock)
            else
                innerUI:speak("I couldn't head home right now.")
                CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
            end
        end
    }

    local footerAction = CompanionUI.BuildLeaveFooterAction()
    local _, navBlock = CompanionUI.AttachNavigationBlock(options, footerAction, {
        resetHistory = true,
        debugLabel = "CompanionRoot",
        requireExplicitNavigation = true,
    })
    ui:updateOptions(options, navBlock)
end
