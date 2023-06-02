local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local shootAnimation: Animation = ReplicatedStorage.Assets.Animations.StageConfettiCannon.Shoot

local function GetAnimator(target: Instance)
    local animator = target:FindFirstChildWhichIsA("Animator")

    if animator then
        return animator
    else
        animator = Instance.new("Animator")
        animator.Parent = target
        return animator
    end
end

-- Animates stage confetti cannons on the client
local function StageConfettiCannon()
    Observers.observeTag("StageConfettiCannon", function(cannon: Model)
        local fireEvent: BindableEvent = cannon:WaitForChild("ConfettiPart"):WaitForChild("OnFire")
        local animator = GetAnimator(cannon:WaitForChild("AnimationController"))
        local shootAnimationTrack = animator:LoadAnimation(shootAnimation)

        fireEvent:Connect(function()
            shootAnimationTrack:Play()
        end)
    end)
end

return StageConfettiCannon