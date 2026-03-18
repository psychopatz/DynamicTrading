require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Registry"

DT_Labour = DT_Labour or {}
DT_Labour.Sites = DT_Labour.Sites or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Sites = DT_Labour.Sites

local function getSquare(x, y, z)
    local cell = getCell()
    if not cell then return nil end
    return cell:getGridSquare(x, y, z or 0)
end

local function getZoneType(square)
    if not square then return nil end
    local zone = square.getZone and square:getZone() or nil
    if zone and zone.getType then
        return zone:getType()
    end
    return nil
end

function Sites.ValidateSite(site, jobType)
    if not site then
        return true, "Workplace validation is deferred for now."
    end

    site.siteType = site.siteType or Config.GetJobProfile(jobType).siteType
    return true, "Workplace validation is deferred for now."
end

function Sites.AssignSiteForWorker(worker, x, y, z, radius)
    if not worker then
        return nil, "Missing worker."
    end

    local profile = Config.GetJobProfile(worker.jobType)
    local site = {
        ownerUsername = worker.ownerUsername,
        workerID = worker.workerID,
        siteType = profile.siteType,
        x = math.floor(x or 0),
        y = math.floor(y or 0),
        z = math.floor(z or 0),
        radius = math.floor(radius or worker.radius or Config.DEFAULT_SITE_RADIUS),
        lastValidatedHour = Config.GetCurrentHour()
    }

    local isValid, reason = Sites.ValidateSite(site, worker.jobType)
    site.valid = isValid
    site.reason = reason
    Registry.AssignSiteToWorker(worker, site)
    worker.siteState = "Deferred"

    return site, reason
end

function Sites.RefreshWorkerSite(worker)
    if not worker then
        return true, "Workplace validation is deferred for now."
    end

    if not worker.assignedSiteID then
        worker.siteState = "Deferred"
        return true, "No workplace required yet."
    end

    local site = Registry.GetSite(worker.assignedSiteID)
    if not site then
        worker.siteState = "Deferred"
        return true, "Missing workplace data is ignored for now."
    end

    local isValid, reason = Sites.ValidateSite(site, worker.jobType)
    site.valid = isValid
    site.reason = reason
    site.lastValidatedHour = Config.GetCurrentHour()
    worker.siteState = "Deferred"
    worker.workX = site.x
    worker.workY = site.y
    worker.workZ = site.z or 0
    worker.radius = site.radius or worker.radius
    return true, reason
end

return Sites
