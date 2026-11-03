local T = require "tests/support/test"
T.addPackagePaths({
    { "DTAbstract", "client" },
    { "DTCommon", "client" },
    { "DTCommon", "shared" },
    { "ProjectHoomans", "client" },
    { "PsychopatzCore", "common" },
    { "PsychopatzCore", "shared" },
    { "PsychopatzCore", "client" },
})

ISButton = {}
function ISButton:new(x, y, width, height, title, target, onclick)
    local button = {
        x = x, y = y, width = width, height = height,
        title = title, target = target, onclick = onclick,
        visible = true,
    }
    setmetatable(button, { __index = self })
    return button
end
function ISButton:initialise() end
function ISButton:instantiate() end
function ISButton:setX(v) self.x = v end
function ISButton:setY(v) self.y = v end
function ISButton:setHeight(v) self.height = v end
function ISButton:setVisible(v) self.visible = v end
function ISButton:setEnable(v) self.enable = v end
function ISButton:setTitle(v) self.title = v end

ISWorldMap = {
    createChildren = function(self)
        self.buttonPanel = { x = 300, y = 400, height = 32 }
    end,
    prerender = function() end,
    render = function() end,
    close = function() return true end,
}
package.preload["ISUI/Maps/ISWorldMap"] = function() return ISWorldMap end
package.preload["ISUI/ISButton"] = function() return ISButton end

PsychopatzCore = {}
PNC = { Core = {} }

-- Hoomans loads first and must adopt Core as its host rather than patching map.
local Layers =
    require "PNC/UI/Map/PNC_MapLayerRegistry"
T.truthy(Layers.Register("fixture", {
    order = 10,
    render = function() end,
}), "Hoomans layer registration failed")

DTCommon = {
    SettlementDirectory = { List = function() return {} end },
    TraderService = { ForEach = function() end },
}
DTCommon.TraderPresentation = {
    GetPosition = function() return nil end,
    ListTraderRecords = function() return {} end,
}
DTAbstract = {}
local WorldMap = require "DTAbstract/DTAbstract_WorldMap"
T.truthy(WorldMap, "DTAbstract map module did not load")

local Host = require "PsychopatzCore/UI/Map/PsychopatzMapHost"
local ids = {}
for _, entry in ipairs(Host.Overlays.List()) do
    ids[entry.id] = true
end

T.truthy(ids["ProjectHoomans:fixture"],
    "Hoomans did not register through Core host")
T.truthy(ids["DynamicTrading:DTAbstract"],
    "DTAbstract did not register through Core host")
T.truthy(ISWorldMap._psychopatzCoreMapHostPatched,
    "Core did not own vanilla map patch")
T.falsy(ISWorldMap._pncMapLayersPatched,
    "legacy Hoomans map-layer patch remains active")
T.falsy(ISWorldMap._dtAbstractMapPatched,
    "legacy DTAbstract map patch remains active")

T.finish("dt_core_map_host_combined_smoke")
