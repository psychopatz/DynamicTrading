-- ==============================================================================
-- DTNPC_ClientSync_HealthBars_Manager.lua
-- Manager class setup for the health bar overlay.
-- ==============================================================================

DTNPC_ClientSync_HealthBars = DTNPC_ClientSync_HealthBars or {}

local HealthBars = DTNPC_ClientSync_HealthBars
local modules = HealthBars.Modules or {}

HealthBars.Modules = modules

if modules.Manager then
    return
end

modules.Manager = true

ISDTNPCHealthBarManager = ISUIElement:derive("ISDTNPCHealthBarManager")

function ISDTNPCHealthBarManager:initialize()
    ISUIElement.initialise(self)
end

function ISDTNPCHealthBarManager:prerender()
    self:setStencilRect(0, 0, self.renderWidth, self.renderHeight)
end

function ISDTNPCHealthBarManager:new(playerIndex, player)
    local offsetX = getPlayerScreenLeft(playerIndex)
    local offsetY = getPlayerScreenTop(playerIndex)
    local o = ISUIElement:new(offsetX, offsetY, getPlayerScreenWidth(playerIndex), getPlayerScreenHeight(playerIndex))

    setmetatable(o, self)
    self.__index = self

    o.playerIndex = playerIndex
    o.player = player
    o.active = true
    o.renderWidth = getPlayerScreenWidth(playerIndex)
    o.renderHeight = getPlayerScreenHeight(playerIndex)
    o.updateCounter = 0
    o.barList = {}
    o.damageTexts = {}
    o:setCapture(false)

    return o
end
