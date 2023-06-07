local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin
local PivotTweener = require(ReplicatedStorage.Shared.PivotTweener)

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
            local goalPivot = instance:GetPivot()
            local startPivot = goalPivot - Vector3.new(0, root.Size.Y, 0)
            local pivotTweener = PivotTweener(child)
            local tween = TweenService:Create(
                pivotTweener,
                TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Value = goalPivot }
            )
            pivotTweener.Value = startPivot
            child:PivotTo(startPivot)
            tween:Play()
            tween.Completed:Wait()
            pivotTweener:Destroy()
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