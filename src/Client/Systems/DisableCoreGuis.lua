local StarterGui = game:GetService("StarterGui")
-- Disables unwanted CoreGuis
local function DisableCoreGuis()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end

return DisableCoreGuis