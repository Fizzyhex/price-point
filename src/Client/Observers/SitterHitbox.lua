local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function SitterHitbox()
    Observers.observeTag("SitterHitbox", function(seat: Seat)
        if not (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
            warn(`Non-seat tagged with SitterHitbox: {seat:GetFullName()}`)
            return function() end
        end

        local hitbox: BasePart = seat.Parent:WaitForChild("SitterHitbox")
        hitbox.AssemblyLinearVelocity = hitbox.CFrame.LookVector * 1
        hitbox.AssemblyAngularVelocity = Vector3.new(1, 0, 0)

        local function OnOccupantChanged()
            hitbox.CanCollide = seat.Occupant ~= nil
        end

        OnOccupantChanged()
        local sitConnection = seat:GetPropertyChangedSignal("Occupant"):Connect(OnOccupantChanged)

        return function()
            sitConnection:Disconnect()
        end
    end)
end

return SitterHitbox