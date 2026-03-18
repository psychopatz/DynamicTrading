if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

-- Keep explicit load order so dependent helpers are registered before consumers.
require "DT/Common/Reputation/DT_Reputation_Core"
require "DT/Common/Reputation/DT_Reputation_Values"
require "DT/Common/Reputation/DT_Reputation_Identity"
require "DT/Common/Reputation/DT_Reputation_Persistence"
require "DT/Common/Reputation/DT_Reputation_Query"
require "DT/Common/Reputation/DT_Reputation_Trade"
require "DT/Common/Reputation/DT_Reputation_Penalties"
require "DT/Common/Reputation/DT_Reputation_Combat"
require "DT/Common/Reputation/DT_Reputation_Debug"
require "DT/Common/Reputation/DT_Reputation_Events"

return DT_Reputation
