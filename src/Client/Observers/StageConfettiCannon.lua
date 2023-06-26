local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local AnimatorUtil = require(ReplicatedStorage.Shared.Util.AnimatorUtil)

local shootAnimation: Animation = ReplicatedStorage.Assets.Animations.StageConfettiCannon.Shoot

-- Animates stage confetti cannons on the client
local function StageConfettiCannon()
    Observers.observeTag("StageConfettiCannon", function(cannon: Model)
        local onFire: BindableEvent = cannon:WaitForChild("ConfettiPart"):WaitForChild("OnFire")
        local animator = AnimatorUtil.GetAnimator(cannon:WaitForChild("AnimationController"))
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