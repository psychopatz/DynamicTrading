function DT_NPCPortraitPanel:clearModelTarget()
    if not self.modelView then
        return
    end

    if self.modelView.javaObject then
        self.modelView.javaObject:clearVariables()
    end
end

function DT_NPCPortraitPanel:applyResolvedPortrait(resolved)
    self.currentMode = resolved and resolved.mode or "legacy"
    self.currentTexture = resolved and resolved.texture or nil
    self.currentDescriptor = resolved and resolved.survivorDesc or nil

    if self.currentMode == "3d" and (resolved.character or resolved.survivorDesc) then
        if self:ensureModelView() then
            self.modelView:setVisible(true)
            self:clearModelTarget()

            if resolved.character then
                self.modelView:setCharacter(resolved.character)
            else
                self.modelView:setCharacter(nil)
                self.modelView:setSurvivorDesc(resolved.survivorDesc)
            end

            self:applyViewState()
        end
    else
        self:clearModelTarget()
        if self.modelView then
            self.modelView:setCharacter(nil)
            self.modelView:setVisible(false)
        end
    end
end

function DT_NPCPortraitPanel:refreshPortrait(force)
    local requestedMode = self:getResolvedMode()
    local resolved = DT_NPCPortraitResolver.Resolve(self.targetData, self.targetCharacter, {
        provider = self.legacyProvider,
        forceLegacy = requestedMode == "legacy"
    })

    self:applyResolvedPortrait(resolved)
end
