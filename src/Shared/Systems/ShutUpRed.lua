local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ShutUpRed()
    ReplicatedStorage:SetAttribute("RedDebug", false)
end

return ShutUpRed
