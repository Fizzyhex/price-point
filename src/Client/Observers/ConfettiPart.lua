local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

-- A part that contains confetti `ParticleEmitters`
local function ConfettiPart()
    Observers.observeTag("ConfettiPart", function(part: BasePart)
        local shootEvent = Instance.new("BindableEvent")
        shootEvent.Name = "OnFire"
        shootEvent.Parent = part

        local function ShootConfetti()
            local emitters = {}

            for _, child in part:GetChildren() do
                if child:IsA("ParticleEmitter") then
                    child.Enabled = true
                    table.insert(emitters, child)
                elseif child.Name == "ConfettiSound" and child:IsA("Sound") then
                    child:Play()
                end
            end

            task.delay(part:GetAttribute("FireTime"), function()
                for _, emitter in emitters do
                    emitter.Enabled = false
                end
            end)
        end

        local stopObservingGameOver = GameStateChannel.ObserveGameOver(ShootConfetti)
        local stopObservingFireAttribute = Observers.observeAttribute(part, "DebugFire", function(isEnabled: boolean)
            if isEnabled then
                ShootConfetti()
                part:SetAttribute("DebugFire", false)
            end

            return function() end
        end)

        if part:GetAttribute("DebugFire") == nil then
            part:SetAttribute("DebugFire", false)
        end

        return function()
            shootEvent:Destroy()
            part:SetAttribute("DebugFire", nil)
            stopObservingGameOver()
            stopObservingFireAttribute()
        end
    end)
end

return ConfettiPart