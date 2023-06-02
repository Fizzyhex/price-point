local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local shootAnimation: Animation = ReplicatedStorage.Assets.Animations.StageConfettiCannon.Shoot

local function GetAnimator(target: Instance): Animator
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
        local onFire: BindableEvent = cannon:WaitForChild("ConfettiPart"):WaitForChild("OnFire")
        local animator = GetAnimator(cannon:WaitForChild("AnimationController"))
        local shootAnimationTrack = animator:LoadAnimation(shootAnimation)
        local smoke: ParticleEmitter = cannon
            :WaitForChild("Tube")
            :WaitForChild("SmokeAttachment")
            :WaitForChild("Smoke")

        local onFireConnection = onFire.Event:Connect(function()
            smoke:Emit(20)
            shootAnimationTrack:Play(0)
        end)

        return function()
            onFireConnection:Disconnect()
        end
    end)
end

return StageConfettiCannon