-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_TimedAction.lua
-- Timed context-menu bandaging action for incapacitated revives.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.TimedAction then
    return
end

modules.TimedAction = true

require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISTimedActionQueue"

local function getCharacterBandageAnim()
    if CharacterActionAnims and CharacterActionAnims.Bandage then
        return CharacterActionAnims.Bandage
    end
    return "Bandage"
end

local DTNPCReviveBandageAction = ISBaseTimedAction:derive("DTNPCReviveBandageAction")

function DTNPCReviveBandageAction:isValid()
    if not self.character or not self.npc then
        return false
    end

    local npcData = ReviveUI.GetNPCData(self.npc)
    if not npcData or not DTNPCHealth or not DTNPCHealth.CanPlayerRevive then
        return false
    end

    local canRevive, info = DTNPCHealth.CanPlayerRevive(self.character, npcData, {
        requiredFullType = self.itemFullType ~= "" and self.itemFullType or nil,
    })
    if canRevive ~= true then
        return false
    end

    if info and info.requiresItems ~= true then
        return true
    end
    if not self.itemFullType or self.itemFullType == "" then
        return false
    end

    return ReviveUI.CountSupplyType(self.character, self.itemFullType) >= self.requiredCount
end

function DTNPCReviveBandageAction:waitToStart()
    if self.character and self.npc then
        self.character:faceThisObject(self.npc)
    end
    return self.character and self.character:shouldBeTurning()
end

function DTNPCReviveBandageAction:update()
    if self.character and self.npc then
        self.character:faceThisObject(self.npc)
    end
end

function DTNPCReviveBandageAction:start()
    local npcData = ReviveUI.GetNPCData(self.npc)
    sendClientCommand(self.character, "DTNPC", "ReviveStart", {
        uuid = npcData and npcData.uuid or nil,
        durationMs = (tonumber(self.maxTime) or 0) * 50 + 3000,
    })

    self:setActionAnim(getCharacterBandageAnim())
    if self.character and self.character.reportEvent then
        self.character:reportEvent("EventBandage")
    end
    if self.setOverrideHandModels then
        self:setOverrideHandModels(nil, nil)
    end
    if self.setMetabolicTarget and Metabolics and Metabolics.LightDomestic then
        self:setMetabolicTarget(Metabolics.LightDomestic)
    end
end

function DTNPCReviveBandageAction:stop()
    local npcData = ReviveUI.GetNPCData(self.npc)
    sendClientCommand(self.character, "DTNPC", "ReviveCancel", {
        uuid = npcData and npcData.uuid or nil,
    })
    ISBaseTimedAction.stop(self)
end

function DTNPCReviveBandageAction:perform()
    local npcData = ReviveUI.GetNPCData(self.npc)
    ReviveUI.RememberPending(nil, self.npc, self.character, npcData, self.itemFullType)

    sendClientCommand(self.character, "DTNPC", "ReviveRequest", {
        uuid = npcData and npcData.uuid or nil,
        requiredFullType = self.itemFullType ~= "" and self.itemFullType or nil,
    })

    ISBaseTimedAction.perform(self)
end

function DTNPCReviveBandageAction:new(character, npc, itemFullType, requiredCount)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.npc = npc
    o.itemFullType = tostring(itemFullType or "")
    o.requiredCount = math.max(1, math.floor(tonumber(requiredCount) or 1))
    o.stopOnWalk = true
    o.stopOnRun = true
    o.stopOnAim = true
    o.useProgressBar = true
    o.maxTime = 110 + (o.requiredCount * 25)
    return o
end

ReviveUI.TimedActionClass = DTNPCReviveBandageAction

function ReviveUI.StartTimedRevive(playerObj, npc, fullType, requiredCount)
    if not playerObj or not npc or not ReviveUI.TimedActionClass then
        return false
    end

    ISTimedActionQueue.add(ReviveUI.TimedActionClass:new(playerObj, npc, fullType, requiredCount))
    return true
end

function ReviveUI.AddDisabledContextAction(menu, label, texture)
    local option = menu and menu.addOption and menu:addOption(label, nil, nil) or nil
    if option then
        option.notAvailable = true
        option.iconTexture = texture
    end
    return option
end

function ReviveUI.AddContextMenuOptions(context, ui, npc, playerObj, npcData)
    npcData = npcData or ReviveUI.GetNPCData(npc)
    if not context or not npc or not playerObj or not npcData then
        return false
    end
    if not DTNPCHealth or not DTNPCHealth.GetHealthState or DTNPCHealth.GetHealthState(npcData) ~= "Incapacitated" then
        return false
    end

    local canRevive, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
        ignoreItems = true,
    })
    if canRevive ~= true and not (info and info.reason == "need_supplies") then
        return false
    end

    local requiresItems = info and info.requiresItems == true
    local requiredCount = tonumber(info and info.requiredCount) or tonumber(ReviveUI.GetRequiredCount(npcData)) or 1
    local name = tostring(npcData.name or "Survivor")

    if not requiresItems then
        context:addOption(ReviveUI.T("DTNPC_UI_HelpUpName", {
            name = name,
        }, "Help Up {name}"), nil, function()
            ReviveUI.StartTimedRevive(playerObj, npc, nil, 1)
        end)
        return true
    end

    local rootOption = context:addOption(ReviveUI.T("DTNPC_UI_BandageName", {
        name = name,
    }, "Bandage {name}"))
    local subMenu = context:getNew(context)
    context:addSubMenu(rootOption, subMenu)

    local entries = ReviveUI.GetSupplyEntries(playerObj)
    if #entries == 0 then
        ReviveUI.AddDisabledContextAction(subMenu, ReviveUI.T("DTNPC_UI_NeedBandagesCount", {
            count = tostring(requiredCount),
        }, "Need {count} bandages or rags"))
        return true
    end

    local hasUsableEntry = false
    for i = 1, #entries do
        local entry = entries[i]
        local label = ReviveUI.FormatEntryLabel(entry, requiredCount)
        local texture = ReviveUI.GetEntryTexture(entry)
        if ReviveUI.CanUseEntry(entry, requiredCount) then
            hasUsableEntry = true
            local option = subMenu:addOption(label, nil, function()
                ReviveUI.StartTimedRevive(playerObj, npc, entry.fullType, requiredCount)
            end)
            if option then
                option.iconTexture = texture
            end
        else
            ReviveUI.AddDisabledContextAction(subMenu, label, texture)
        end
    end

    if not hasUsableEntry then
        ReviveUI.AddDisabledContextAction(subMenu, ReviveUI.T("DTNPC_UI_NeedMatchingMaterial", nil, "You need one matching material type for the full treatment"))
    end

    return true
end
