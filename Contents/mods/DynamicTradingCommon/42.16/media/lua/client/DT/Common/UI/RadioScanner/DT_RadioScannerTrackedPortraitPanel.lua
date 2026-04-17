require "ISUI/ISPanel"
require "DT/Common/UI/Portrait/Portrait"

DT_RadioScannerTrackedPortraitPanel = ISPanel:derive("DT_RadioScannerTrackedPortraitPanel")

function DT_RadioScannerTrackedPortraitPanel:initialise()
    ISPanel.initialise(self)
    self.targetData = nil
end

function DT_RadioScannerTrackedPortraitPanel:createChildren()
    ISPanel.createChildren(self)

    self.portraitPanel = DT_NPCPortraitPanel:new(0, 0, self.width, self.height, {
        overlayStyle = "radio",
        isRadioMode = true,
        animationProfile = "radio",
    })
    self.portraitPanel:initialise()
    self.portraitPanel:instantiate()
    self:addChild(self.portraitPanel)
end

function DT_RadioScannerTrackedPortraitPanel:setTrackingInfo(targetData, context, force)
    self.targetData = targetData

    if self.portraitPanel then
        self.portraitPanel:setOverlayMode("radio")
        self.portraitPanel:setRadioMode(true)
        self.portraitPanel:setAnimationProfile("radio")
        self.portraitPanel:setLegacyProvider(nil)
        self.portraitPanel:setTargetCharacter(targetData and targetData.npcRef or nil, targetData)
        if force then
            self.portraitPanel:refreshPortrait(true)
        end
    end
end

function DT_RadioScannerTrackedPortraitPanel:clearTrackingInfo(force)
    self.targetData = nil

    if self.portraitPanel then
        self.portraitPanel:setTargetData(nil)
        if force then
            self.portraitPanel:refreshPortrait(true)
        end
    end
end

function DT_RadioScannerTrackedPortraitPanel:pulseSpeechAnimation(durationTicks)
    if self.portraitPanel and self.portraitPanel.pulseSpeechAnimation then
        self.portraitPanel:pulseSpeechAnimation(durationTicks)
    end
end

function DT_RadioScannerTrackedPortraitPanel:refreshPortrait(force)
    if self.portraitPanel then
        self.portraitPanel:refreshPortrait(force == true)
    end
end

function DT_RadioScannerTrackedPortraitPanel:onResize()
    ISPanel.onResize(self)
    if self.portraitPanel then
        self.portraitPanel:setPortraitBounds(0, 0, self.width, self.height)
    end
end

function DT_RadioScannerTrackedPortraitPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end