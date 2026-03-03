-- =============================================================================
-- DT_QuestDebugInit: Client-side Initialization for Quest Debug Tools
-- =============================================================================

require "DT/Common/UI/Debug/DT_QuestDebugUI"

local function OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    if not isDebugEnabled() then return end
    
    -- Add a sub-menu for Dynamic Trading Debug if it doesn't exist
    -- Or just add the option directly for now as per user request
    context:addOption("[DEBUG] Dynamic Trading: Quest Spawner", nil, DT_QuestDebugUI.OnOpen)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)

print("[DynamicTrading] Quest Debug System Hooked.")
