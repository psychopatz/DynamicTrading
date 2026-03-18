require "DT/UI/Labour/DT_LabourUI"

local function openLabourWindow()
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Labour", "UI", "Context menu requested Labour Management window.")
    end
    DT_LabourUI.OpenWindow()
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test then return end

    local player = getSpecificPlayer(playerNum)
    if not player then return end

    context:addOption("Labour Management", nil, openLabourWindow)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
