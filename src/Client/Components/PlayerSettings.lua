local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)

local PlayerSettings = Component.new({ Tag = "PlayerSettings" })

-- TODO: Store Fusion Value objects that describe the local player's settings.
function PlayerSettings:Construct()
end

return PlayerSettings