-- ==============================================================================
-- DTNPC_JobUI_TraderHelpEscort_Navigation.lua
-- Conversation footer and navigation helpers.
-- ==============================================================================

DTNPC_JobUI_TraderHelpEscort = DTNPC_JobUI_TraderHelpEscort or {}

local EscortUI = DTNPC_JobUI_TraderHelpEscort
local modules = EscortUI.Modules or {}
local Helpers = EscortUI.Helpers or {}

EscortUI.Modules = modules
EscortUI.Helpers = Helpers

if modules.Navigation then
    return
end

modules.Navigation = true

function Helpers.buildNavigationBlock(footerAction, overrides)
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

function Helpers.buildLeaveFooterAction(overrides)
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

function Helpers.buildExitFooterAction(overrides)
    if DT_ConversationUI and DT_ConversationUI.BuildExitFooterAction then
        return DT_ConversationUI.BuildExitFooterAction(overrides)
    end

    local action = Helpers.buildLeaveFooterAction(overrides)
    if not overrides or overrides.title == nil then
        action.title = "Exit"
    end
    return action
end

function Helpers.buildBackFooterAction(overrides)
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

function Helpers.attachNavigationBlock(options, footerAction, overrides)
    options = type(options) == "table" and options or {}

    local navBlock = Helpers.buildNavigationBlock(footerAction, overrides)
    options._dtFooterAction = footerAction
    options._dtNavigationBlock = navBlock

    return options, navBlock
end
