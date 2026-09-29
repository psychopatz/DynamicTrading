DTHoomans = DTHoomans or {}
DTHoomans.VERSION = 1
DTHoomans.MOD_ID = "DTHoomans"
DTHoomans.SPAWN_COMMAND = "SpawnTrader"

-- Conversation definitions and the shared eligibility provider are loaded
-- after Project Hoomans so both client menu composition and server authority
-- use the same caravan-role contract.
require "DTHoomans/DTHoomans_Conversation"

return DTHoomans
