-- Offline UI mock. Verifies navigation and drawing calls; not native Build42.
local modulePath, runtimeManifestPath = assert(arg[1]), assert(arg[2])
local coreRoot = string.match(runtimeManifestPath,
  "^(.*)/Contents/mods/PsychopatzCore/")
assert(coreRoot, "runtime manifest path must be inside the Core checkout")
package.path = coreRoot .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
  .. coreRoot .. "/Contents/mods/PsychopatzCore/42.20/media/lua/client/?.lua;"
  .. package.path
getModFileReader = function(_, filename, _)
  local handle = assert(io.open(coreRoot .. "/Contents/mods/PsychopatzCore/common/"
    .. filename, "r"))
  return {
    readLine = function() return handle:read("*l") end,
    close = function() handle:close() end,
  }
end
local base = {}
function base:derive(name)
  local cls = setmetatable({}, { __index=self })
  cls.__index = cls
  return cls
end
function base:new(x,y,w,h)
  return setmetatable({x=x,y=y,width=w,height=h,children={}},self)
end
function base:initialise()end
function base:createChildren()end
function base:instantiate()self:createChildren()end
function base:addToUIManager()self.added=true end
function base:setVisible(v)self.visible=v end
function base:removeFromUIManager()self.added=false end
function base:addChild(c)self.children[#self.children+1]=c end
function base:drawSubTexture(texture, ...)
 self.draws=(self.draws or 0)+1
 self.events=self.events or {}
 self.events[#self.events+1]={kind='texture',path=texture and texture.path}
end
function base:drawRect(...)end
function base:drawRectBorder(...)end
function base:drawText(...)
 self.events=self.events or {}
 self.events[#self.events+1]={kind='text'}
end
package.preload['ISUI/ISPanel']=function() _G.ISPanel=base;return base end
package.preload['ISUI/ISButton']=function()
 local b={}
 function b:new(x,y,w,h,label,target,onclick)
  return setmetatable({x=x,y=y,w=w,h=h,target=target,onclick=onclick},{__index=self})
 end
 function b:initialise()end
 function b:instantiate()end
 function b:setDisplayBackground(v)end
 _G.ISButton=b
 return b
end
package.preload['PsychopatzCore/UI/Radio/OS/PsychopatzRadioRuntimeManifest']=function()
  return dofile(runtimeManifestPath)
end
_G.UIFont={Small=1}
_G.getTexture=function(path)return {path=path}end
_G.getCore=function()return {getScreenWidth=function()return 1280 end,getScreenHeight=function()return 900 end}end
local radioOS=dofile(modulePath)
assert(radioOS)
local ui=assert(radioOS.OpenPreview(0,'Base.WalkieTalkie5'))
assert(ui.skin.id=='walkie_5')
assert(ui.page=='home' and ui.cursor==1 and ui.added)
assert(#ui.children==10,'8 hardware plus 2 screen buttons')
ui:prerender();assert(ui.draws>=2,'LCD background and shell drawn')
local glassEvent,textEvent
for i,event in ipairs(ui.events or {}) do
 if event.kind=='texture' and event.path and string.find(event.path,'/LCD/Glass.png',1,true) then
  glassEvent=glassEvent or i
 elseif event.kind=='text' then
  textEvent=textEvent or i
 end
end
assert(glassEvent and textEvent and glassEvent<textEvent,
 'LCD glass is composited below preview text')
ui:onPower()
ui.events={}
ui:prerender()
local iconEvent
for _,event in ipairs(ui.events or {}) do
 if event.kind=='texture' and event.path and string.find(event.path,'/Radio/OS/Icons.png',1,true) then
  iconEvent=true
  break
 end
end
assert(iconEvent, 'preview uses Core runtime icon atlas')
ui.screenHotspots[2].onclick();assert(ui.page=='scanner')
ui:onBack();assert(ui.page=='home')
ui.cursor=1
ui:onLeft();assert(ui.cursor==2)
ui:onSelect();assert(ui.page=='scanner')
ui:onBack();assert(ui.page=='home')
ui:onSelect();assert(ui.page=='scanner')
ui:onBack();ui:onLeft();assert(ui.cursor==1)
ui:onSelect();assert(ui.page=='contacts')
ui:onBack();ui:onBack();assert(radioOS._preview==nil and not ui.added)
local none,reason=radioOS.OpenPreview(0,'Base.InvalidDevice')
assert(none==nil and reason=='unsupported walkie item')
print('PASS: preview navigation, Core manifest controls, LCD hotspots and modular drawing')
