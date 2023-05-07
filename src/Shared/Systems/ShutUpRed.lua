local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShutUpRed = {}

function ShutUpRed:OnInit()
    ReplicatedStorage:SetAttribute("RedDebug", false)
end

return ShutUpRed