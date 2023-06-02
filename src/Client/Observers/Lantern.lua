local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function Lantern()
    local stopObservingTag = Observers.observeTag("Lantern", function(lantern: BasePart)
        local bulb: BasePart = lantern:WaitForChild("Bulb")
        local light: PointLight = bulb:WaitForChild("PointLight")
        local originalBulbColor = bulb.Color

        local function EnableLantern()
            print("lantern on")
            light.Enabled = true
            bulb.Color = originalBulbColor
        end

        local function DisableLantern()
            print("lantern off")
            light.Enabled = false
            bulb.Color = originalBulbColor:Lerp(Color3.new(0, 0, 0), 0.5)
        end

        local stopObservingTime = Observers.observeProperty(Lighting, "ClockTime", function(clockTime: number)
            if clockTime >= 17.8 or clockTime <= 6.3 then
                EnableLantern()
            else
                DisableLantern()
            end
        end)

        return function()
            stopObservingTime()
        end
    end)

    return function()
        stopObservingTag()
    end
end

return Lantern