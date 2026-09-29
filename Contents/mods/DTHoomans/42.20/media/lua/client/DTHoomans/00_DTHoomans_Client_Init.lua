require "DTHoomans/DTHoomans_Context"
require "DTHoomans/DTHoomans_DebugTraderWindow"
require "DTHoomans/DTHoomans_DebugSpawnMenu"
require "DTHoomans/DTHoomans_Client"

-- Register the trader manager in the shared PsychopatzCore Debug Hub. The
-- context menu remains only a shortcut to that hub.
require "PsychopatzCore/UI/PsychopatzDebugHubWindow"

local DebugHub = PsychopatzCore and PsychopatzCore.DebugHub
local function canUseTraderDebug()
    local coreDebug = PsychopatzCore and PsychopatzCore.Debug
    if coreDebug and type(coreDebug.CanUse) == "function" then
        return coreDebug.CanUse(getPlayer and getPlayer() or nil) == true
    end
    return PNC and PNC.Client
        and type(PNC.Client.CanUseDebug) == "function"
        and PNC.Client.CanUseDebug() == true
end

if DebugHub and type(DebugHub.RegisterTool) == "function" then
    DebugHub.RegisterTool({
        id = "dthoomans.traderManager",
        source = "Dynamic Trading",
        order = 230,
        title = DTCommon.T(
            "DTHoomans_Debug_TraderManager_Title", "Trader Manager"),
        description = DTCommon.T(
            "DTHoomans_Debug_TraderManager_Description",
            "List, locate, teleport, and open spawned trader caravans."),
        available = canUseTraderDebug,
        action = function()
            if DTHoomans.DebugTraderWindow then
                return DTHoomans.DebugTraderWindow.Open()
            end
            return nil
        end,
    })
end
