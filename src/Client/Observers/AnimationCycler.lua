local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin

local ANCESTORS = { workspace }
local CYCLE_SPEED = 3

-- Cycles through a Folder of animations. The folder must be parented underneath an Animator object
local function AnimationCycler()
    return Observers.observeTag("AnimationCycler", function(container: Folder)
        local animator: Animator = container.Parent
        
        if not animator:IsA("Animator") then
            error("AnimationCyclers must be parented to an Animator object")
        end

        local binAdd, binEmpty = Bin()

        local cycleThread = task.spawn(function()
            local animationIndex = 0
            local animationTracks = {}
            local animations = {}
            local lastAnimationTrack: AnimationTrack

            local function UpdateAnimationTracks()
                for _, child in container:GetChildren() do
                    if child:IsA("Animation") and animationTracks[child] == nil then
                        table.insert(animations, child)
                        animationTracks[child] = animator:LoadAnimation(child)
                    end
                end
            end

            binAdd(container.ChildAdded:Connect(function(child)
                if child:IsA("Animation") then
                    table.insert(animations, child)
                    animationTracks[child] = animator:LoadAnimation(child)
                end
            end))

            binAdd(container.ChildRemoved:Connect(function(child)
                if animationTracks[child] then
                    animationTracks[child]:Destroy()
                    animationTracks[child] = nil

                    for index, value in animations do
                        if value == child then
                            table.remove(animations, index)
                            break
                        end
                    end
                end
            end))

            UpdateAnimationTracks()

            while true do
                if #animations == 0 then
                    task.wait()
                    continue
                end

                animationIndex += 1

                if animationIndex > #animations then
                    animationIndex = 1
                end

                local animationTrack = animationTracks[animations[animationIndex]]

                if lastAnimationTrack then
                    lastAnimationTrack:Stop(0)
                end

                print("Playing", animationTrack)
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