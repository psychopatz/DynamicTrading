-- [DYNAMIC TRADING] Quest Server
-- Handles server-side quest item spawning requests from clients.

require "DT/Common/Quests/DT_QuestManager"

local function OnClientCommand(module, command, player, args)
    if module == "DT_Quest" then
        if command == "spawnItem" then
            local itemID = args.itemID
            local difficulty = args.difficulty
            local questID = args.questID
            
            DynamicTrading.Quests.CreateQuestItem(player, itemID, questID, difficulty)
        end
    end
end

Events.OnClientCommand.Add(OnClientCommand)
DynamicTrading.Log("DTCommons", "Init", "Quest", "Quest Server Commands Loaded")
