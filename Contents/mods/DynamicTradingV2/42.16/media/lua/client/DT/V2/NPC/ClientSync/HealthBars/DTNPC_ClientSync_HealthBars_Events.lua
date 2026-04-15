-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Events.lua
-- Player initialization and event wiring for health bars.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Events then
    return
end

modules.Events = true

local Helpers = HealthBars.Helpers

local function initForPlayer(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    if DTNPCClient.HealthBarManagers[playerIndex] then return end

    local manager = ISDTNPCHealthBarManager:new(playerIndex, player)
    manager:initialise()
    DTNPCClient.HealthBarManagers[playerIndex] = manager
end

local function onCreatePlayer(playerIndex)
    initForPlayer(playerIndex)
end

local function onGameStart()
    for i = 0, getNumActivePlayers() - 1 do
        initForPlayer(i)
    end
end

local function onPreUIDraw()
    for _, manager in pairs(DTNPCClient.HealthBarManagers or {}) do
        if manager and manager.active then
            manager:update()
            manager:prerender()
            manager:render()
        end
    end
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not attacker or not target then return end
    if attacker:getObjectName() ~= "Player" then return end

    local modData = target:getModData()
    if not modData or not modData.IsDTNPC then return end

    DTNPCClient.MarkNPCCombatForHealthBars(
        modData.DTNPC_UUID,
        target,
        Helpers.getNPCData(target),
        target:getPersistentOutfitID()
    )

    if DT_Reputation then
        local npcData = Helpers.getNPCData(target)
        local maxHealth = npcData and npcData.combatHealth and npcData.combatHealth.max or nil
        if DT_Reputation.RecordNPCDamage then
            DT_Reputation.RecordNPCDamage(modData.DTNPC_UUID, npcData and npcData.factionID, damage, maxHealth)
        else
            DT_Reputation.RecordNPCHit(modData.DTNPC_UUID, npcData and npcData.factionID)
        end
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnPreUIDraw.Add(onPreUIDraw)
Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
