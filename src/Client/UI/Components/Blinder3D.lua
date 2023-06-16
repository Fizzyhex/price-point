local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Cleanup = Fusion.Cleanup
local Value = Fusion.Value
local Observer = Fusion.Observer
local Hydrate = Fusion.Hydrate

local DEFAULT_ANIMATION_SPEED = 0.8

local sleep = Promise.promisify(task.wait)

local function TweenUntilCompletion(instance, tweenInfo: TweenInfo, goals: {[string]: any})
    return Promise.new(function(resolve, reject, onCancel)
        local tween = TweenService:Create(instance, tweenInfo, goals)

        if onCancel(function()
            tween:Cancel()
        end) then return end

        tween.Completed:Connect(resolve)
        tween:Play()
    end)
end

local function Blinder3D(props: {Part: BasePart, Display: any})
    local partBaseCFrame = Unwrap(props.Part).CFrame

    local lastDisplay = Value(Unwrap(props.Display))
    local currentAnimation
    local ui

    local function CancelCurrentAnimation()
        if currentAnimation then
            currentAnimation:cancel()
            currentAnimation = nil
        end
    end

    local function AnimateTransition(oldUi: Instance, newUi: Instance)
        CancelCurrentAnimation()

        local animationSpeed = Unwrap(props.AnimationSpeed) or DEFAULT_ANIMATION_SPEED

        local part = Unwrap(props.Part)
        local clone

        if newUi then
            newUi.Parent = ui
        end

        if oldUi then
            if oldUi:IsDescendantOf(ui) then
                oldUi.Parent = nil
            end

            clone = oldUi:Clone()

            -- We need the old UI to overlay the new one until we destroy it
            pcall(function()
                clone.ZIndex = 500
            end)

            clone.Parent = ui
        end

        currentAnimation = Promise.resolve()
            :finallyCall(
                TweenUntilCompletion,
                part,
                TweenInfo.new(animationSpeed * 0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {CFrame = partBaseCFrame * CFrame.Angles(math.rad(90), 0, 0)}
            )
            :finallyCall(function()
                if clone then
                    clone:Destroy()
                end

                -- Use 181 deg instead of 180 deg to influence the direction of the tween
                Unwrap(part).CFrame = partBaseCFrame * CFrame.Angles(math.rad(181), 0, 0)
            end)
            :finallyCall(
                TweenUntilCompletion,
                part,
                TweenInfo.new(animationSpeed * 0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {CFrame = partBaseCFrame}
            )
            :catch(warn)
    end

    local function OnDisplayChanged()
        AnimateTransition(lastDisplay:get(), props.Display:get())
        lastDisplay:set(props.Display:get())
    end

    local surfaceGui = Unwrap(props.SurfaceGui) or New("SurfaceGui")
    ui = Hydrate(surfaceGui) {
        PixelsPerStud = props.PixelsPerStud,
        Face = Enum.NormalId.Front,
        Parent = Unwrap(props.Part),
        [Children] = {
            -- Don't wrap the actual state to prevent auto-updating
            Unwrap(props.Display)
        },
        [Cleanup] = {
            Observer(props.Display):onChange(OnDisplayChanged),
            CancelCurrentAnimation
        }
    }

    return ui
end

return Blinder3D