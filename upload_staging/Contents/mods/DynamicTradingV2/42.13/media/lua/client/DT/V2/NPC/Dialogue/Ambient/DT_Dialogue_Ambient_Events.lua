-- ==============================================================================
-- DT_Dialogue_Ambient_Events.lua
-- Player initialization and event wiring for ambient dialogue.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPCClient.DialogueAmbient = DTNPCClient.DialogueAmbient or DTNPCClient.AmbientDialogue or {}
DTNPCClient.AmbientDialogue = DTNPCClient.DialogueAmbient

local function initForPlayer(playerIndex)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    if DTNPCClient.DialogueAmbientManagers[playerIndex] then return end

    local manager = ISDTNPCAmbientDialogueManager:new(playerIndex, player)
    manager:initialise()
    DTNPCClient.DialogueAmbientManagers[playerIndex] = manager
    DTNPCClient.AmbientDialogueManagers = DTNPCClient.DialogueAmbientManagers
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
    for _, manager in pairs(DTNPCClient.DialogueAmbientManagers or DTNPCClient.AmbientDialogueManagers or {}) do
        if manager and manager.active then
            manager:update()
            manager:prerender()
            manager:render()
        end
    end
end

if not (DTNPCClient.DialogueAmbientEventsRegistered or DTNPCClient.AmbientDialogueEventsRegistered) then
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.OnGameStart.Add(onGameStart)
    Events.OnPreUIDraw.Add(onPreUIDraw)
    DTNPCClient.DialogueAmbientEventsRegistered = true
    DTNPCClient.AmbientDialogueEventsRegistered = true
end
