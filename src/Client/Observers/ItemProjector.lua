local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin
local CustomTweener = require(ReplicatedStorage.Shared.CustomTweener)

local deletionEffect = ReplicatedStorage.Assets.ParticleEffects.Deletion

local function DoDeletionEffect(parts: {BasePart})
    for _, part in parts do
        local emitter = deletionEffect:Clone()
        emitter.Parent = part
        emitter:Emit(math.min(part.Size.Magnitude * 3, 300))
    end

    task.delay(5, function()
        for _, part in parts do
            part:Destroy()
        end
    end)
end

local function HasPart(model: Model)
    for _, descendant in model:GetDescendants() do
        if descendant:IsA("BasePart") then
            return true
        end
    end

    return false
end

local function YieldForPart(model, timeout)
    local isChildAdded = true
    local start = tick()
    local childConnection = model.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            isChildAdded = true
        end
    end)

    while isChildAdded == false and tick() - start < timeout do
        task.wait()
    end

    childConnection:Disconnect()
    return isChildAdded
end

local ANCESTORS = { workspace }

local function ItemProjector()
    return Observers.observeTag("ItemProjector", function(instance: Model)
        local binAdd, binEmpty = Bin()
        local container = instance:WaitForChild("Container")
        local effectContainer = Instance.new("Folder")
        effectContainer.Name = "ClientEffectContainer"
        effectContainer.Parent = instance
        local root: BasePart = instance:WaitForChild("Root")

        binAdd(container.ChildAdded:Connect(function(child: Model | BasePart)
            if not HasPart(child) then
                YieldForPart(child, 3)
            end

            local goalPivot = instance:GetPivot()
            local startPivot = goalPivot - Vector3.new(0, root.Size.Y, 0)

            local customTweener = CustomTweener(child, function(cframe: CFrame)
                if child.PrimaryPart then
                    child:SetPrimaryPartCFrame(cframe)
                else
                    child:PivotTo(cframe)
                end
            end)

            local tween = TweenService:Create(
                customTweener,
                TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Value = goalPivot }
            )

            customTweener.Value = startPivot
            child:PivotTo(startPivot)
            tween:Play()
            tween.Completed:Wait()
            customTweener:Destroy()
        end))

        binAdd(container.ChildRemoved:Connect(function(child: Instance)
            local parts = {}

            for _, descendant in child:GetDescendants() do
                if descendant:IsA("BasePart") then
                    local effectPart = descendant:Clone()
                    effectPart.Transparency = 1

                    for _, tag in CollectionService:GetTags(effectPart) do
                        CollectionService:RemoveTag(effectPart, tag)
                    end

                    effectPart.Anchored = true
                    effectPart.CanCollide = false
                    effectPart.CanTouch = false
                    effectPart.CanQuery = false
                    effectPart:ClearAllChildren()
                    effectPart.Parent = effectContainer
                    table.insert(parts, effectPart)
                end
            end

            DoDeletionEffect(parts)
        end))

        binAdd(effectContainer)

        return function()
            binEmpty()
        end
    end, ANCESTORS)
end

return ItemProjector