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
        local npcData = CompanionUI.GetNPCData(npc)
        local worker = CompanionUI.GetCompanionWorker(nil, npc, npcData)
        local isResident = CompanionUI.IsPlayerZoneResident(npcData, worker)
        DTNPC_TraderDialogue_Hub.Init(nil, npc, player, {
            initialGreeting = isResident and CompanionUI.T("DTNPC_Dialogue_NeedSomethingFromColony", nil, "Need something from the colony?") or nil
        })
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
    local commanderText = CompanionUI.T("DTNPC_UI_CommanderLabel", {
        name = tostring(commander or CompanionUI.T("DTNPC_UI_NoCommander", nil, "No commander")),
    }, "Commander: {name}")
    local usesCommandAuthority = worker ~= nil and tostring(npcData and npcData.dcCompanionJob or "") == "TravelCompanion"
    local isResident = CompanionUI.IsPlayerZoneResident(npcData, worker)
    if usesCommandAuthority and not CompanionUI.IsLocalCommander(player, npcData, worker) then
        local options = {
            {
                text = commanderText,
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak(commander
                        and CompanionUI.T("DTNPC_Dialogue_TakingOrdersFrom", { name = commander }, "I'm taking orders from {name}.")
                        or CompanionUI.T("DTNPC_Dialogue_NoOneCommanding", nil, "No one is commanding me right now."))
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            },
            {
                text = CompanionUI.T("DTNPC_UI_Chat", nil, "Chat"),
                message = CompanionUI.T("DTNPC_Dialogue_HowHoldingUp", nil, "How are you holding up?"),
                onSelect = function(innerUI)
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CommandClaimFirst", nil, "I'm here, but command has to be claimed first."))
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            }
        }

        if worker and CompanionUI.CanClaimCommand(player, npc) then
            options[#options + 1] = {
                text = CompanionUI.T("DTNPC_UI_ClaimCommand", nil, "Claim Command"),
                message = CompanionUI.T("DTNPC_Dialogue_TakingCommand", nil, "I'm taking command. Follow my lead."),
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
                        innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CommandClaimed", nil, "Command claimed. I'll follow you."))
                        CompanionUI.RefreshCompanionWorker(worker)
                    else
                        innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotClaimCommand", nil, "I couldn't claim command right now."))
                    end
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                end
            }
        else
            options[#options + 1] = {
                text = CompanionUI.T("DTNPC_UI_MoveCloserClaim", nil, "Move closer to claim command."),
                message = "",
                onSelect = function(innerUI)
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_MoveWithinStepsClaim", nil, "Move within a few steps, then claim command."))
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
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_YouAreCommander", nil, "You're my current commander."))
                CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
            end
        }
    end

    options[#options + 1] = {
        text = CompanionUI.T("DTNPC_UI_Chat", nil, "Chat"),
        message = CompanionUI.T("DTNPC_Dialogue_HowHoldingUp", nil, "How are you holding up?"),
        onSelect = function(innerUI)
            innerUI:speak(isResident
                and CompanionUI.T("DTNPC_Dialogue_HoldingZone", nil, "Holding the zone. Just point me where you need me.")
                or CompanionUI.T("DTNPC_Dialogue_ImWithYou", nil, "I'm with you. Just say the word."))
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = CompanionUI.T("DTNPC_UI_FollowMe", nil, "Follow Me"),
        message = CompanionUI.T("DTNPC_Dialogue_StayCloseMoveWithMe", nil, "Stay close and move with me."),
        onSelect = function(innerUI)
            local latestData = CompanionUI.GetNPCData(npc) or npcData
            local followLabel = CompanionUI.GetFollowSpacingLabel and CompanionUI.GetFollowSpacingLabel(latestData) or "Near"
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Follow", CompanionUI.BuildFollowOrderArgs(latestData)) then
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_FollowingWithSpacing", {
                    mode = string.lower(tostring(followLabel)),
                }, "I'll follow on {mode} spacing."))
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotFollow", nil, "I couldn't follow you right now."))
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    if npcData and tostring(npcData.state or "") == "Follow" then
        options[#options + 1] = {
            text = CompanionUI.T("DTNPC_UI_FollowMethod", nil, "Follow Method"),
            message = CompanionUI.T("DTNPC_Dialogue_ChooseTrailDistance", nil, "Choose how closely to tail you."),
            onSelect = function(innerUI)
                local latestData = CompanionUI.GetNPCData(npc) or npcData
                local currentMode = CompanionUI.GetFollowSpacingMode and CompanionUI.GetFollowSpacingMode(latestData) or "near"
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CurrentFollowMethod", {
                    mode = currentMode == "far"
                        and CompanionUI.T("DTNPC_UI_Far", nil, "Far")
                        or CompanionUI.T("DTNPC_UI_Near", nil, "Near"),
                }, "Current follow method: {mode}."))
                local followOptions = {
                    {
                        text = CompanionUI.BuildModeOptionLabel(CompanionUI.T("DTNPC_UI_Near", nil, "Near"), currentMode == "near", false),
                        message = CompanionUI.T("DTNPC_Dialogue_StayTighter", nil, "Stay tighter on my position."),
                        onSelect = function(modeUI)
                            if CompanionUI.IssueCompanionStateOrder(player, npc, "Follow", CompanionUI.BuildFollowOrderArgs(latestData, {
                                followSpacingMode = "near",
                            })) then
                                modeUI:speak(CompanionUI.T("DTNPC_Dialogue_NearSpacingSet", nil, "Near spacing set."))
                            else
                                modeUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotChangeFollowMethod", nil, "I couldn't change follow method right now."))
                            end
                            CompanionUI.GenerateRootOptions(modeUI, npc, player, worker)
                        end
                    },
                    {
                        text = CompanionUI.BuildModeOptionLabel(CompanionUI.T("DTNPC_UI_Far", nil, "Far"), currentMode == "far", false),
                        message = CompanionUI.T("DTNPC_Dialogue_GiveMeRoomDuringFights", nil, "Give me more room during fights."),
                        onSelect = function(modeUI)
                            if CompanionUI.IssueCompanionStateOrder(player, npc, "Follow", CompanionUI.BuildFollowOrderArgs(latestData, {
                                followSpacingMode = "far",
                            })) then
                                modeUI:speak(CompanionUI.T("DTNPC_Dialogue_FarSpacingSet", nil, "Far spacing set."))
                            else
                                modeUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotChangeFollowMethod", nil, "I couldn't change follow method right now."))
                            end
                            CompanionUI.GenerateRootOptions(modeUI, npc, player, worker)
                        end
                    },
                }
                local footerAction = CompanionUI.BuildLeaveFooterAction()
                local _, navBlock = CompanionUI.AttachNavigationBlock(followOptions, footerAction, {
                    debugLabel = "CompanionFollowMethod",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(followOptions, navBlock)
            end
        }
    end

    options[#options + 1] = {
        text = CompanionUI.T("DTNPC_UI_HoldPosition", nil, "Hold Position"),
        message = CompanionUI.T("DTNPC_Dialogue_StayPutUntilTold", nil, "Stay put until I tell you otherwise."),
        onSelect = function(innerUI)
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
                state = "Stay",
                clearGuardMode = true,
                returnStatus = "Resting",
            }) then
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_HoldHere", nil, "I'll hold here."))
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotHoldPosition", nil, "I couldn't hold position right now."))
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = CompanionUI.T("DTNPC_UI_GuardPosition", nil, "Guard Position"),
        message = CompanionUI.T("DTNPC_Dialogue_GuardAreaThreats", nil, "Hold this area and engage nearby threats."),
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = (liveData and (liveData.guardCombatOrder or liveData.guardAttackMode)) or "GuardAuto",
                returnStatus = "Resting",
            }) then
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_GuardPositionSet", nil, "I'll guard this position."))
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotGuard", nil, "I couldn't take up guard duty right now."))
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = (npcData and npcData.state == "LootNearby")
            and CompanionUI.T("DTNPC_UI_StopLootSearch", nil, "Stop Loot Search")
            or CompanionUI.T("DTNPC_UI_SearchNearbyLoot", nil, "Search Nearby Loot"),
        message = CompanionUI.T("DTNPC_Dialogue_SearchNearbyExplain", nil, "Search nearby sources, reveal their contents, then tell me what to collect."),
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            if liveData and liveData.state == "LootNearby" then
                if CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
                    state = "Stay",
                    returnStatus = "Resting",
                }) then
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_LootingPaused", nil, "Looting paused."))
                else
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotStopLooting", nil, "I couldn't stop looting right now."))
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
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_LootNearbyStarted", nil, "I'll search nearby sources and wait for your pickup orders."))
                CompanionUI.OpenLootSearchWindow(player, liveData)
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotStartLooting", nil, "I couldn't start looting right now."))
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    local patchUpLabel, patchUpSupplyTotal = CompanionUI.GetPatchUpLabel(worker)
    options[#options + 1] = {
        text = patchUpLabel,
        message = CompanionUI.T("DTNPC_Dialogue_PatchYourself", nil, "Take a moment to bandage yourself."),
        onSelect = function(innerUI)
            local sent = CompanionUI.SendPatchUpOrder(player, npc)
            if sent then
                if patchUpSupplyTotal > 0 then
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_PatchingSelf", nil, "I'll patch myself up."))
                else
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_NoBandagesPacked", nil, "I don't have any bandages or rags packed."))
                end
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotPatchUp", nil, "I couldn't patch up right now."))
            end
            CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
        end
    }

    options[#options + 1] = {
        text = CompanionUI.T("DTNPC_UI_AttackType", nil, "Attack Type"),
        message = CompanionUI.T("DTNPC_Dialogue_LetsTalkCombat", nil, "Let's talk combat."),
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            local currentLabel = CompanionUI.GetAttackTypeLabel(liveData)
            local currentMode = CompanionUI.GetAttackTypeMode(liveData)
            local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "ProtectAuto" or currentMode == "ProtectRanged")
            innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CurrentAttackType", { mode = currentLabel }, "Current attack type: {mode}."))
            local attackOptions = {
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        CompanionUI.T("DTNPC_UI_Auto", nil, "Auto"),
                        currentMode == "ProtectAuto",
                        showAmmo and currentMode == "ProtectAuto",
                        ammoSnapshot
                    ),
                    message = CompanionUI.T("DTNPC_Dialogue_UseBestWeapon", nil, "Use whichever weapon fits the fight."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectAuto", "auto"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectAuto", {
                            state = "ProtectAuto",
                            combatOrder = "ProtectAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchAttackAuto", nil, "I'll switch between range and melee as needed."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchAttackType", nil, "I couldn't switch attack type right now."))
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        CompanionUI.T("DTNPC_UI_Ranged", nil, "Ranged"),
                        currentMode == "ProtectRanged",
                        showAmmo and currentMode == "ProtectRanged",
                        ammoSnapshot
                    ),
                    message = CompanionUI.T("DTNPC_Dialogue_CoverMeFromRange", nil, "Cover me from range."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectRanged", {
                            state = "ProtectRanged",
                            combatOrder = "ProtectRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchAttackRanged", nil, "I'll keep some distance and cover you."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchAttackType", nil, "I couldn't switch attack type right now."))
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(CompanionUI.T("DTNPC_UI_Melee", nil, "Melee"), currentMode == "ProtectMelee", false, ammoSnapshot),
                    message = CompanionUI.T("DTNPC_Dialogue_StayCloseFightFront", nil, "Stay close and fight up front."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "ProtectMelee", "melee"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectMelee", {
                            state = "ProtectMelee",
                            combatOrder = "ProtectMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchAttackMelee", nil, "I'll stay close and handle threats up front."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchAttackType", nil, "I couldn't switch attack type right now."))
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
        text = CompanionUI.T("DTNPC_UI_GuardAttackType", nil, "Guard Attack Type"),
        message = CompanionUI.T("DTNPC_Dialogue_HowGuardFight", nil, "How should you fight while guarding?"),
        onSelect = function(innerUI)
            local liveData = CompanionUI.GetNPCData(npc)
            local currentLabel = CompanionUI.GetGuardAttackTypeLabel(liveData)
            local currentMode = CompanionUI.GetGuardAttackTypeMode(liveData)
            local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
            local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "GuardAuto" or currentMode == "GuardRanged")
            innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CurrentGuardAttackType", { mode = currentLabel }, "Current guard attack type: {mode}."))
            local guardOptions = {
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        CompanionUI.T("DTNPC_UI_Auto", nil, "Auto"),
                        currentMode == "GuardAuto",
                        showAmmo and currentMode == "GuardAuto",
                        ammoSnapshot
                    ),
                    message = CompanionUI.T("DTNPC_Dialogue_UseBestGuardWeapon", nil, "Use whichever weapon fits the threat while guarding."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardAuto", "auto"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardAuto",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchGuardAuto", nil, "I'll guard this spot and adapt as needed."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchGuardAttackType", nil, "I couldn't switch guard attack type right now."))
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(
                        CompanionUI.T("DTNPC_UI_Ranged", nil, "Ranged"),
                        currentMode == "GuardRanged",
                        showAmmo and currentMode == "GuardRanged",
                        ammoSnapshot
                    ),
                    message = CompanionUI.T("DTNPC_Dialogue_GuardFromDistance", nil, "Guard from a distance."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardRanged", "ranged"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardRanged",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchGuardRanged", nil, "I'll hold this spot and engage from range."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchGuardAttackType", nil, "I couldn't switch guard attack type right now."))
                        end
                        CompanionUI.GenerateRootOptions(choiceUI, npc, player, worker)
                    end
                },
                {
                    text = CompanionUI.BuildModeOptionLabel(CompanionUI.T("DTNPC_UI_Melee", nil, "Melee"), currentMode == "GuardMelee", false, ammoSnapshot),
                    message = CompanionUI.T("DTNPC_Dialogue_HoldLineUpClose", nil, "Hold the line up close."),
                    style = CompanionUI.BuildModeOptionStyle(currentMode == "GuardMelee", "melee"),
                    onSelect = function(choiceUI)
                        if CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                            state = "Guard",
                            guardCombatOrder = "GuardMelee",
                            returnStatus = "Resting",
                        }) then
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_SwitchGuardMelee", nil, "I'll hold this spot and fight up close."))
                        else
                            choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotSwitchGuardAttackType", nil, "I couldn't switch guard attack type right now."))
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
            text = CompanionUI.T("DTNPC_UI_TransferCommand", nil, "Transfer Command"),
            message = CompanionUI.T("DTNPC_Dialogue_AssigningSomeoneElse", nil, "I'm assigning you to someone else."),
            onSelect = function(innerUI)
                local candidates = CompanionUI.CollectTransferCandidates(player, worker)
                if #candidates == 0 then
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_NoTransferCandidates", nil, "There isn't another faction member to transfer command to."))
                    CompanionUI.GenerateRootOptions(innerUI, npc, player, worker)
                    return
                end

                local choices = {}
                for _, username in ipairs(candidates) do
                    choices[#choices + 1] = {
                        text = tostring(username),
                        message = CompanionUI.T("DTNPC_Dialogue_ReportTo", { name = tostring(username) }, "Report to {name}."),
                        onSelect = function(choiceUI)
                            if CompanionUI.SendTransferCommand(worker, username) then
                                CompanionUI.PlayCompanionCommandCue(player, "TransferCommand")
                                choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CommandTransferred", { name = tostring(username) }, "Command transferred to {name}."))
                                CompanionUI.RefreshCompanionWorker(worker)
                            else
                                choiceUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotTransferCommand", nil, "I couldn't transfer command right now."))
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
            text = CompanionUI.T("DTNPC_UI_WarehouseInventory", nil, "Warehouse Inventory"),
            message = CompanionUI.T("DTNPC_Dialogue_OpenWarehouseInventory", nil, "Open your warehouse inventory."),
            onSelect = function(innerUI)
                if CompanionUI.OpenCompanionInventory(innerUI, worker, npc, CompanionUI.GetNPCData(npc)) then
                    return
                else
                    innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotOpenWarehouse", nil, "I couldn't open the warehouse inventory right now."))
                    CompanionUI.DebugCompanionUI(
                        "Warehouse Inventory failed workerID="
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
        text = CompanionUI.T("DTNPC_UI_GoHome", nil, "Go Home"),
        message = CompanionUI.T("DTNPC_Dialogue_HeadBackHome", nil, "Head back home and stand down."),
        onSelect = function(innerUI)
            local workerCommandSent = worker and CompanionUI.SendCompanionHome(worker) or true
            local returnOrderSent = CompanionUI.OrderCompanionReturnHome(player, npc)
            if workerCommandSent and returnOrderSent then
                CompanionUI.PlayCompanionCommandCue(player, "GoHome")
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_GoingHome", nil, "Understood. I'll head home."))
                local doneOptions = {}
                local footerAction = CompanionUI.BuildExitFooterAction()
                local _, navBlock = CompanionUI.AttachNavigationBlock(doneOptions, footerAction, {
                    resetHistory = true,
                    debugLabel = "CompanionGoHomeResolved",
                    requireExplicitNavigation = true,
                })
                innerUI:updateOptions(doneOptions, navBlock)
            else
                innerUI:speak(CompanionUI.T("DTNPC_Dialogue_CouldNotGoHome", nil, "I couldn't head home right now."))
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
