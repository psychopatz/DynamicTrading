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
function ISButton:new()
    local value = { visible = true }
    setmetatable(value, { __index = self })
    return value
end
function ISButton:initialise() end
function ISButton:instantiate() end
function ISButton:setX() end
function ISButton:setY() end
function ISButton:setHeight() end
function ISButton:setVisible(v) self.visible = v end
function ISButton:setEnable() end
function ISButton:setTitle() end

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
DTCommon = {
    SettlementDirectory = { List = function() return {} end },
    TraderService = { ForEach = function() end },
}
DTCommon.TraderPresentation = {
    GetPosition = function() return nil end,
    ListTraderRecords = function() return {} end,
}
DTAbstract = {}

-- Reverse order: Dynamic Trading initializes the Core host first.
T.truthy(require "DTAbstract/DTAbstract_WorldMap",
    "DTAbstract world map did not load first")

PNC = { Core = {} }
local Layers = require "PNC/UI/Map/PNC_MapLayerRegistry"
T.truthy(Layers.Register("reverse_fixture", {
    render = function() end,
}), "Hoomans reverse-order registration failed")

local Host = require "PsychopatzCore/UI/Map/PsychopatzMapHost"
local ids = {}
for _, entry in ipairs(Host.Overlays.List()) do ids[entry.id] = true end
T.truthy(ids["DynamicTrading:DTAbstract"],
    "DTAbstract registration disappeared")
T.truthy(ids["ProjectHoomans:reverse_fixture"],
    "Hoomans failed to register after DTAbstract")
T.truthy(ISWorldMap._psychopatzCoreMapHostPatched,
    "reverse load order did not retain Core host")
T.falsy(ISWorldMap._pncMapLayersPatched,
    "reverse load order restored Hoomans legacy patch")
T.falsy(ISWorldMap._dtAbstractMapPatched,
    "reverse load order restored DT legacy patch")

T.finish("dt_core_map_host_dt_first_smoke")
