local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function Lantern()
    local stopObservingTag = Observers.observeTag("Lantern", function(lantern: BasePart)
        local bulb: BasePart = lantern:WaitForChild("Bulb")
        local light: PointLight = bulb:WaitForChild("PointLight")
        local ambientLight: PointLight = bulb:WaitForChild("AmbientLight")
        local originalBulbColor = bulb.Color

        local function EnableLantern()
            light.Enabled = true
            ambientLight.Enabled = true
            ambientLight.Shadows = lantern:GetAttribute("CastAmbientShadows") == true
            light.Shadows = lantern:GetAttribute("CastShadows") == true
            bulb.Color = originalBulbColor
        end

        local function DisableLantern()
            light.Enabled = false
            ambientLight.Enabled = false
            bulb.Color = originalBulbColor:Lerp(Color3.new(0, 0, 0), 0.6)
        end

        local stopObservingTime = Observers.observeProperty(Lighting, "ClockTime", function(clockTime: number)
            if lantern:GetAttribute("AlwaysOn") or clockTime >= 17.8 or clockTime <= 6.3 then
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