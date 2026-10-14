-- Offline UI mock. Verifies navigation and drawing calls; not native Build42.
local modulePath, manifestPath = assert(arg[1]), assert(arg[2])
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
function base:drawSubTexture(...) self.draws=(self.draws or 0)+1 end
function base:drawRect(...)end
function base:drawRectBorder(...)end
function base:drawText(...)end
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
package.preload['DTAbstract/UI/DTA_Walkie_Manifest']=function()return dofile(manifestPath)end
_G.UIFont={Small=1}
_G.getTexture=function()return {}end
_G.getCore=function()return {getScreenWidth=function()return 1280 end,getScreenHeight=function()return 900 end}end
local radioOS=dofile(modulePath)
assert(radioOS)
local ui=assert(radioOS.OpenPreview(0,'Base.WalkieTalkie5'))
assert(ui.skin.id=='walkie_usarmy_shell')
assert(ui.page=='home' and ui.cursor==1 and ui.added)
assert(#ui.children==5,'3 hardware plus 2 screen buttons')
ui:prerender();assert(ui.draws>=2,'LCD background and shell drawn')
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
print('PASS: preview navigation, 3 hardware softkeys, 2 LCD hotspots and atlas drawing')
