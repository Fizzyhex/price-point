local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local AnimatorUtil = require(ReplicatedStorage.Shared.Util.AnimatorUtil)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local LOCAL_PLAYER = Players.LocalPlayer

local logger = CreateLogger(script)

local function PoseFolderFromName(name: string)
    return ReplicatedStorage.Assets.Animations.Seats:FindFirstChild(name)
end

local function PoseSeat()
    Observers.observeTag("PoseSeat", function(seat: Seat)
        if not (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
            warn(`Non-seat tagged with PoseSeat: {seat:GetFullName()}`)
            return function() end
        end

        local currentOccupant: Humanoid?
        local animationTrack: AnimationTrack?

        local function OnOccupantChanged()
            local occupant = seat.Occupant

            if occupant and LOCAL_PLAYER.Character and occupant:IsDescendantOf(LOCAL_PLAYER.Character) then
                currentOccupant = occupant
                local poseFolder = seat:GetAttribute("PoseFolder") and PoseFolderFromName(seat:GetAttribute("PoseFolder"))

                if poseFolder then
                    local children = poseFolder:GetChildren()
                    local animation = children[math.random(1, #children)]
                    animationTrack = AnimatorUtil.GetAnimator(occupant):LoadAnimation(animation)
                    animationTrack:Play(0.2)
                else
                    logger.warn(`{seat:GetFullName()}'s PoseFolder could not be found'`)
                end
            elseif currentOccupant then
                currentOccupant = nil

                if animationTrack then
                    animationTrack:Stop()
                end
            end
        end

        OnOccupantChanged()
        local occupantConnection = seat:GetPropertyChangedSignal("Occupant"):Connect(OnOccupantChanged)

        return function()
            occupantConnection:Disconnect()

            if animationTrack then
                animationTrack:Stop()
            end
        end
    end, { workspace })
end

return PoseSeat