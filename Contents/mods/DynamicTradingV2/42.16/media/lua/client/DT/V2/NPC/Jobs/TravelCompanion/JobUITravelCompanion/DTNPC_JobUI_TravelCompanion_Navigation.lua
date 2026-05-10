-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Navigation.lua
-- Conversation footer and navigation helpers.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Navigation then
    return
end

modules.Navigation = true

function CompanionUI.BuildNavigationBlock(footerAction, overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildNavigationBlock then
        return DT_ConversationUI.BuildNavigationBlock(footerAction, overrides)
    end

    local block = {
        explicitFooter = true,
        footerAction = footerAction,
        defaultFooterAction = footerAction,
    }
    for key, value in pairs(overrides or {}) do
        block[key] = value
    end
    return block
end

function CompanionUI.BuildLeaveFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildLeaveFooterAction then
        return DT_ConversationUI.BuildLeaveFooterAction(overrides)
    end

    local action = {
        kind = "leave",
        title = "Leave",
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

function CompanionUI.BuildExitFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildExitFooterAction then
        return DT_ConversationUI.BuildExitFooterAction(overrides)
    end

    local action = CompanionUI.BuildLeaveFooterAction(overrides)
    if not overrides or overrides.title == nil then
        action.title = "Exit"
    end
    return action
end

function CompanionUI.BuildBackFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildBackFooterAction then
        return DT_ConversationUI.BuildBackFooterAction(overrides)
    end

    local action = {
        kind = "back",
        title = "Back",
        closeAfter = false,
        exitAfter = false,
    }
    for key, value in pairs(overrides or {}) do
        action[key] = value
    end
    return action
end

function CompanionUI.AttachNavigationBlock(options, footerAction, overrides)
    options = type(options) == "table" and options or {}

    local navBlock = CompanionUI.BuildNavigationBlock(footerAction, overrides)
    options._dtFooterAction = footerAction
    options._dtNavigationBlock = navBlock

    return options, navBlock
end
