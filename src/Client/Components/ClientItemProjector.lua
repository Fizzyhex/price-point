local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ObserveChild = require(ReplicatedStorage.Shared.Util.ObserveChild)

local DISABLED = true

-- Not needed as of now, the server will handle everything.
local ClientItemProjector = Component.new { Tag = "ItemProjector" }

function ClientItemProjector:Construct()
    if DISABLED then
        return
    end

    self._trove = Trove.new()

    local function HandleRoot(child: BasePart)
        local function HandleContainer(container: Folder)
            local function Project(projectionModel: Model | BasePart)
                projectionModel:PivotTo(child:GetPivot())
            end

            container.ChildAdded:Connect(Project)
            local projectionModel = container:GetChildren()[1]

            if projectionModel then
                Project(projectionModel)
            end
        end

        local destroyContainerObserver = ObserveChild(self.Instance, "Container", HandleContainer)

        return function()
            destroyContainerObserver()
        end
    end

    self._trove:Add(ObserveChild(self.Instance, "Root", HandleRoot))
end

function ClientItemProjector:Stop()
    self._trove:Destroy()
end

return ClientItemProjector