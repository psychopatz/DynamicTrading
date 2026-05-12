-- =============================================================================
-- DT_TracerSystem.lua
-- Manages and renders screen-space bullet tracers (flying bullets).
-- =============================================================================

DT_TracerSystem = DT_TracerSystem or {}
DT_TracerSystem.ActiveTracers = DT_TracerSystem.ActiveTracers or {}

--- Spawns a new bullet tracer.
--- @param sx, sy, sz number (Source world coordinates)
--- @param tx, ty, tz number (Target world coordinates)
--- @param color table (Optional, {r,g,b})
function DT_TracerSystem.AddTracer(sx, sy, sz, tx, ty, tz, color)
    if isServer() then return end
    
    local tracer = {
        s = {x = sx, y = sy, z = sz},
        t = {x = tx, y = ty, z = tz},
        ticks = 8, -- Existence duration
        maxTicks = 8,
        color = color or {r = 1.0, g = 0.85, b = 0.3}
    }
    
    table.insert(DT_TracerSystem.ActiveTracers, tracer)
end

--- Render hook for OnPreUIDraw
function DT_TracerSystem.OnPreUIDraw()
    local tracers = DT_TracerSystem.ActiveTracers
    if #tracers == 0 then return end
    
    local renderer = getRenderer()
    if not renderer then return end
    
    for i = #tracers, 1, -1 do
        local tracer = tracers[i]
        
        -- Convert 3D ISO to Screen Pixels
        local x1 = ISCoordConversion.ToScreenX(tracer.s.x, tracer.s.y, tracer.s.z)
        local y1 = ISCoordConversion.ToScreenY(tracer.s.x, tracer.s.y, tracer.s.z)
        local x2 = ISCoordConversion.ToScreenX(tracer.t.x, tracer.t.y, tracer.t.z)
        local y2 = ISCoordConversion.ToScreenY(tracer.t.x, tracer.t.y, tracer.t.z)
        
        -- Calculate alpha fade
        local alpha = tracer.ticks / tracer.maxTicks
        
        -- Draw the tracer line
        -- renderer:renderline(texture, x1, y1, x2, y2, r, g, b, a)
        renderer:renderline(nil, x1, y1, x2, y2, tracer.color.r, tracer.color.g, tracer.color.b, alpha)
        
        -- Update lifecycle
        tracer.ticks = tracer.ticks - 1
        if tracer.ticks <= 0 then
            table.remove(tracers, i)
        end
    end
end

-- Initialize the system
if not DT_TracerSystem.Initialized and not isServer() then
    Events.OnPreUIDraw.Add(DT_TracerSystem.OnPreUIDraw)
    DT_TracerSystem.Initialized = true
    print("DT_TracerSystem: Bullet Renderer Initialized")
end

return DT_TracerSystem
