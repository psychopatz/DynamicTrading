require "DT/UI/Labour/Buildings/Utils/DT_BuildingsUIUtils"

DT_BuildingsDetailsFormatter = DT_BuildingsDetailsFormatter or {}

function DT_BuildingsDetailsFormatter.BuildPlotText(plot)
    if not plot then
        return " <RGB:0.65,0.65,0.65>Select a plot to inspect it. "
    end

    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Medium> Plot " .. tostring(plot.x or 0) .. "," .. tostring(plot.y or 0) .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> Type: <RGB:1,1,1> " .. tostring(plot.kind or "Standard") .. " <LINE> "
    text = text .. " <RGB:0.72,0.72,0.72> State: <RGB:1,1,1> " .. tostring(plot.state or "Unknown") .. " <LINE> "

    if plot.project then
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Active Project <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Building: <RGB:1,1,1> " .. tostring(plot.project.buildingType or "Project") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Builder: <RGB:1,1,1> " .. tostring(plot.project.assignedBuilderName or "Unknown") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Progress: <RGB:1,1,1> "
            .. tostring(math.floor((tonumber(plot.project.progressWorkPoints) or 0) + 0.5))
            .. " / "
            .. tostring(plot.project.requiredWorkPoints or 0)
            .. " WP <LINE> "
    end

    if plot.building then
        local building = plot.building
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> " .. tostring(building.displayName or building.buildingType or "Building") .. " <LINE> "
        text = text .. " <RGB:0.72,0.72,0.72> Level: <RGB:1,1,1> " .. tostring(building.level or 0) .. " <LINE> "
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Occupants <LINE> "
        local occupants = building.occupants or {}
        if #occupants <= 0 then
            text = text .. " <RGB:0.62,0.62,0.62> No occupants assigned. <LINE> "
        else
            for _, occupant in ipairs(occupants) do
                text = text .. " <RGB:0.82,0.82,0.82> - " .. tostring(occupant.name or occupant.workerID or "Worker") .. " <LINE> "
            end
        end

        local upgradePreview = building.upgradePreview
        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Upgrade <LINE> "
        if not upgradePreview or upgradePreview.available ~= true then
            text = text .. " <RGB:0.9,0.65,0.65> " .. tostring(upgradePreview and upgradePreview.reason or "No upgrade available.") .. " <LINE> "
        else
            text = text .. " <RGB:0.72,0.72,0.72> Target Level: <RGB:1,1,1> " .. tostring(upgradePreview.targetLevel or 0) .. " <LINE> "
            for _, line in ipairs(DT_BuildingsUIUtils.BuildRecipeLines(upgradePreview.recipeAvailability and upgradePreview.recipeAvailability.entries or {})) do
                text = text .. " " .. line .. " <LINE> "
            end
        end

        text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Destroy <LINE> "
        if building.canDestroy == true then
            text = text .. " <RGB:0.88,0.72,0.72> This building can be destroyed after confirmation. <LINE> "
        else
            text = text .. " <RGB:0.72,0.62,0.62> " .. tostring(building.destroyReason or "This building cannot be destroyed.") .. " <LINE> "
        end
    elseif plot.state == "Empty" then
        text = text .. " <LINE> <RGB:0.82,0.82,0.82> This plot is available for construction. <LINE> "
    elseif plot.state == "Locked" then
        text = text .. " <LINE> <RGB:0.72,0.62,0.62> Upgrade Headquarters to unlock more plots. <LINE> "
    end

    return text
end

return DT_BuildingsDetailsFormatter
