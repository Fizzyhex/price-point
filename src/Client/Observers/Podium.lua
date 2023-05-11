local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)

local function Podium()
    local STORAGE = Instance.new("Folder")
    STORAGE.Name = "ClientPodiumStorage"
    STORAGE.Parent = ReplicatedStorage
    local ANCESTORS = { workspace, STORAGE }

    local SHOW_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0)
    local HIDE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)

    return Observers.observeTag("Podium", function(podium: Model)
        local basePivot = podium:GetPivot()
        local baseParent = podium.Parent
        local tweener = Instance.new("CFrameValue")
        tweener.Value = basePivot
        local binAdd, binEmpty = Red.Bin()
        local currentTween

        local function CancelCurrentTween()
            if currentTween then
                currentTween:Cancel()
                currentTween:Destroy()
                currentTween = nil
            end
        end

        binAdd(Observers.observeAttribute(podium, "isVisible", function(isVisible)
            CancelCurrentTween()

            if isVisible then
                currentTween = TweenService:Create(tweener, SHOW_TWEEN, {Value = basePivot})

                if podium.Parent == STORAGE then
                    podium.Parent = baseParent
                end

                currentTween:Play()
            else
                local podiumSize = podium:GetExtentsSize()
                currentTween = TweenService:Create(
                    tweener,
                    HIDE_TWEEN,
                    { Value = basePivot - Vector3.new(0, podiumSize.Y + 1, 0) }
                )
                currentTween:Play()
                currentTween.Completed:Connect(function()
                    if podium.Parent ~= STORAGE then
                        baseParent = podium.Parent
                        podium.Parent = STORAGE
                    end
                end)
            end

            return function()
                CancelCurrentTween()
            end
        end))

        binAdd(Observers.observeProperty(tweener, "Value", function(value: CFrame)
            podium:PivotTo(value)
        end))

        binAdd(CancelCurrentTween)

        return function()
            podium:PivotTo(basePivot)

            if podium.Parent == STORAGE then
                pcall(function()
                    podium.Parent = baseParent
                end)
            end

            binEmpty()
        end
    end, ANCESTORS)
end

return Podium