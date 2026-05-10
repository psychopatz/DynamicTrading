-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_ContextMenu.lua
-- Context menu actions for travel companion orders.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.ContextMenu then
    return
end

modules.ContextMenu = true

function CompanionUI.AddCompanionContextAction(menu, label, callback)
    menu:addOption(label, nil, callback)
end

function CompanionUI.AddDisabledContextAction(menu, label)
    local option = menu:addOption(label, nil, nil)
    if option then
        option.notAvailable = true
    end
end

function CompanionUI.AddAttackTypeContextMenu(parentMenu, npc, player)
    local option = parentMenu:addOption("Attack Type")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    local liveData = CompanionUI.GetNPCData(npc)
    local currentMode = CompanionUI.GetAttackTypeMode(liveData)
    local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
    local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "ProtectAuto" or currentMode == "ProtectRanged")

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Auto", currentMode == "ProtectAuto", showAmmo and currentMode == "ProtectAuto", ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectAuto", {
                state = "ProtectAuto",
                combatOrder = "ProtectAuto",
                returnStatus = "Resting",
            })
        end
    )

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Ranged", currentMode == "ProtectRanged", showAmmo and currentMode == "ProtectRanged", ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectRanged", {
                state = "ProtectRanged",
                combatOrder = "ProtectRanged",
                returnStatus = "Resting",
            })
        end
    )

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Melee", currentMode == "ProtectMelee", false, ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "ProtectMelee", {
                state = "ProtectMelee",
                combatOrder = "ProtectMelee",
                returnStatus = "Resting",
            })
        end
    )
end

function CompanionUI.AddGuardAttackTypeContextMenu(parentMenu, npc, player)
    local option = parentMenu:addOption("Guard Attack Type")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    local liveData = CompanionUI.GetNPCData(npc)
    local currentMode = CompanionUI.GetGuardAttackTypeMode(liveData)
    local ammoSnapshot = CompanionUI.GetRangedAmmoSnapshot(liveData)
    local showAmmo = ammoSnapshot.hasRangedWeapon and (currentMode == "GuardAuto" or currentMode == "GuardRanged")

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Auto", currentMode == "GuardAuto", showAmmo and currentMode == "GuardAuto", ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = "GuardAuto",
                returnStatus = "Resting",
            })
        end
    )

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Ranged", currentMode == "GuardRanged", showAmmo and currentMode == "GuardRanged", ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = "GuardRanged",
                returnStatus = "Resting",
            })
        end
    )

    CompanionUI.AddCompanionContextAction(
        subMenu,
        CompanionUI.BuildModeOptionLabel("Melee", currentMode == "GuardMelee", false, ammoSnapshot.ammoCount),
        function()
            CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
                state = "Guard",
                guardCombatOrder = "GuardMelee",
                returnStatus = "Resting",
            })
        end
    )
end

function CompanionUI.AddPatchUpContextMenu(parentMenu, npc, player, worker)
    if not worker then
        CompanionUI.AddCompanionContextAction(parentMenu, "Patch Up", function()
            CompanionUI.SendPatchUpOrder(player, npc)
        end)
        return
    end

    local supplies, total = CompanionUI.CollectMedicalSupplies(worker)
    local label = total > 0 and ("Patch Up (" .. tostring(total) .. " medical)") or "Patch Up (No medicine)"
    local option = parentMenu:addOption(label)
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    if total > 0 then
        for _, supply in ipairs(supplies) do
            local itemOption = subMenu:addOption(
                tostring(supply.displayName or supply.fullType or "Medical Supply") .. " x" .. tostring(supply.units or 0),
                nil,
                nil
            )
            if itemOption then
                itemOption.notAvailable = true
                itemOption.iconTexture = supply.texture
            end
        end
        CompanionUI.AddCompanionContextAction(subMenu, "Use Medical Supply", function()
            CompanionUI.SendPatchUpOrder(player, npc)
        end)
        return
    end

    CompanionUI.AddDisabledContextAction(subMenu, "No bandages, rags, or first-aid supplies packed.")
    CompanionUI.AddCompanionContextAction(subMenu, "Ask Anyway", function()
        CompanionUI.SendPatchUpOrder(player, npc)
    end)
end

function CompanionUI.AddTransferCommandContextMenu(parentMenu, worker, player)
    local candidates = CompanionUI.CollectTransferCandidates(player, worker)
    local option = parentMenu:addOption("Transfer Command")
    local subMenu = parentMenu:getNew(parentMenu)
    parentMenu:addSubMenu(option, subMenu)

    if #candidates == 0 then
        CompanionUI.AddDisabledContextAction(subMenu, "No faction members available")
        return
    end

    for _, username in ipairs(candidates) do
        CompanionUI.AddCompanionContextAction(subMenu, username, function()
            if CompanionUI.SendTransferCommand(worker, username) then
                CompanionUI.PlayCompanionCommandCue(player, "TransferCommand")
                CompanionUI.RefreshCompanionWorker(worker)
            end
        end)
    end
end

function CompanionUI.AddCompanionContextMenu(context, ui, npc, player, npcData)
    if not context or not npc or not player then
        return false
    end

    local worker = CompanionUI.GetCompanionWorker(ui, npc, npcData or CompanionUI.GetNPCData(npc))
    local name = tostring((npcData and npcData.name) or (worker and worker.name) or "Companion")
    local liveData = npcData or CompanionUI.GetNPCData(npc)
    local commander = CompanionUI.GetCommanderUsername(liveData, worker)
    local isCommander = CompanionUI.IsLocalCommander(player, liveData, worker)
    local usesCommandAuthority = worker ~= nil and tostring(liveData and liveData.dcCompanionJob or "") == "TravelCompanion"

    local rootOption = context:addOption("Companion Orders: " .. name)
    local rootMenu = context:getNew(context)
    context:addSubMenu(rootOption, rootMenu)

    if usesCommandAuthority then
        CompanionUI.AddDisabledContextAction(rootMenu, "Commander: " .. tostring(commander or "No commander"))
    end

    CompanionUI.AddCompanionContextAction(rootMenu, "Talk", function()
        CompanionUI.OpenCompanionDialogue(npc, player)
    end)

    if usesCommandAuthority and not isCommander then
        if worker and CompanionUI.CanClaimCommand(player, npc) then
            CompanionUI.AddCompanionContextAction(rootMenu, "Claim Command", function()
                if CompanionUI.SendClaimCommand(worker) then
                    CompanionUI.PlayCompanionCommandCue(player, "ClaimCommand")
                    CompanionUI.RefreshCompanionWorker(worker)
                end
            end)
        else
            CompanionUI.AddDisabledContextAction(rootMenu, "Move closer to claim command.")
        end
        return true
    end

    CompanionUI.AddCompanionContextAction(rootMenu, "Follow Me", function()
        CompanionUI.IssueCompanionStateOrder(player, npc, "Follow", {
            state = "Follow",
            returnStatus = "Resting",
        })
    end)

    CompanionUI.AddCompanionContextAction(rootMenu, "Hold Position", function()
        CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
            state = "Stay",
            clearGuardMode = true,
            returnStatus = "Resting",
        })
    end)

    CompanionUI.AddCompanionContextAction(rootMenu, "Guard Position", function()
        CompanionUI.IssueCompanionStateOrder(player, npc, "Guard", {
            state = "Guard",
            guardCombatOrder = (liveData and (liveData.guardCombatOrder or liveData.guardAttackMode)) or "GuardAuto",
            returnStatus = "Resting",
        })
    end)

    local isLooting = liveData and liveData.state == "LootNearby"
    CompanionUI.AddCompanionContextAction(rootMenu, isLooting and "Stop Loot Search" or "Search Nearby Loot", function()
        local latestData = CompanionUI.GetNPCData(npc) or liveData
        if latestData and latestData.state == "LootNearby" then
            CompanionUI.IssueCompanionStateOrder(player, npc, "Stay", {
                state = "Stay",
                returnStatus = "Resting",
            })
            return
        end

        CompanionUI.IssueCompanionStateOrder(player, npc, "LootNearby", {
            state = "LootNearby",
            x = npc:getX(),
            y = npc:getY(),
            z = npc:getZ(),
            lootRadius = latestData and latestData.dcLootConfig and latestData.dcLootConfig.radius or nil,
            combatOrder = CompanionUI.GetLootCombatOrder(latestData),
            returnStatus = "Resting",
        })
        CompanionUI.OpenLootSearchWindow(player, latestData)
    end)

    CompanionUI.AddPatchUpContextMenu(rootMenu, npc, player, worker)

    CompanionUI.AddAttackTypeContextMenu(rootMenu, npc, player)
    CompanionUI.AddGuardAttackTypeContextMenu(rootMenu, npc, player)
    if usesCommandAuthority and worker then
        CompanionUI.AddTransferCommandContextMenu(rootMenu, worker, player)
    end

    if worker or (npcData and npcData.linkedWorkerID) then
        CompanionUI.AddCompanionContextAction(rootMenu, "Manage Inventory", function()
            CompanionUI.OpenCompanionInventory(ui, worker, npc, npcData)
        end)
    end

    if worker then
        CompanionUI.AddCompanionContextAction(rootMenu, "Go Home", function()
            local workerCommandSent = CompanionUI.SendCompanionHome(worker)
            local returnOrderSent = CompanionUI.OrderCompanionReturnHome(player, npc)
            if workerCommandSent and returnOrderSent then
                CompanionUI.PlayCompanionCommandCue(player, "GoHome")
            end
            return workerCommandSent and returnOrderSent
        end)
    end

    return true
end
