local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin

local ANCESTORS = { workspace }
local CYCLE_SPEED = 3

-- Cycles through a Folder of animations. The folder must be parented underneath an Animator object
local function AnimationCycler()
    return Observers.observeTag("AnimationCycler", function(container: Folder)
        local animator: Animator = container.Parent
        
        if not container.Parent:IsA("Animator") then
            error("AnimationCyclers must be parented to an Animator object")
        end

        local binAdd, binEmpty = Bin()

        local cycleThread = task.spawn(function()
            local index = 0
            local animationTracks = {}
            local lastAnimationTrack: AnimationTrack

            local function UpdateAnimationTracks()
                for _, child in container:GetChildren() do
                    if child:IsA("Animation") and animationTracks[child] == nil then
                        animationTracks[child] = animator:LoadAnimation(child)
                    end
                end
            end

            binAdd(container.ChildAdded:Connect(function(child)
                if child:IsA("Animation") then
                    animationTracks[child] = animator:LoadAnimation(child)
                end
            end))

            binAdd(container.ChildRemoved:Connect(function(child)
                if animationTracks[child] then
                    animationTracks[child]:Destroy()
                    animationTracks[child] = nil
                end
            end))

            UpdateAnimationTracks()

            while true do
                if not next(animationTracks) then
                    task.wait()
                    continue
                end

                index += 1

                local isOutOfRange, animationTrack = pcall(function()
                    return next(animationTracks, if index == 1 then nil else index - 1)
                end)

                if isOutOfRange then
                    index = 1
                    continue
                end

                if lastAnimationTrack then
                    lastAnimationTrack:Stop(0)
                end

                animationTrack:Play(0)

                task.wait(CYCLE_SPEED)
            end
        end)

        return function()
            binEmpty()
            task.cancel(cycleThread)
        end
    end, ANCESTORS)
end

return AnimationCycler