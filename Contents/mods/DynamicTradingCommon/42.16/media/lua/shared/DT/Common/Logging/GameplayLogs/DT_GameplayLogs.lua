local context = require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_Context"

require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_Definitions"(context)
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_Queue"(context)
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_Local"(context)
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_Write"(context)
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs_ClientSync"(context)

return context.Logs
