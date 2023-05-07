local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TicketBooth = require(ReplicatedStorage.Shared.TicketBooth)

local ContainerPrototype = Instance.new("Folder")
ContainerPrototype.Name = "ItemContainer"

local function GetContainer(projection: Instance)
    local container = projection:FindFirstChild(ContainerPrototype.Name)

    if container then
        return container
    else
        container = ContainerPrototype:Clone()
        container.Parent = projection
        return container
    end
end

local ItemProjectionUtil = {}
ItemProjectionUtil.tag = "ItemProjection"

function ItemProjectionUtil.ObserveModel(projection: Instance, callback: (Instance) -> (() -> ()))
    local container = GetContainer(projection)
    local cleanupFn
    local connection

    local function RunCallback(...)
        if cleanupFn then
            task.spawn(cleanupFn)
            cleanupFn = nil
        end

        cleanupFn = callback(...)
    end

    if container then
        connection = container.ChildAdded:Connect(RunCallback)
    else
        connection = projection.ChildAdded:Connect(function(child: Instance)
            if child.Name == ContainerPrototype.Name then
                connection:Disconnect()
                connection = child.ChildAdded:Connect(RunCallback)
            end
        end)
    end

    local currentModel = container:GetChildren()[1]

    if currentModel then
        RunCallback(currentModel)
    end

    return function()
        connection:Disconnect()
    end
end

function ItemProjectionUtil.SetModel(projection: Instance, model: any)
    local container = GetContainer(projection)
    container:ClearAllChildren()

    model.Parent = container
end

return ItemProjectionUtil