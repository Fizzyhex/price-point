local CollectionService = game:GetService("CollectionService")
local GearPropUtil = {}

-- Converts gear into a harmless prop
function GearPropUtil.Propify(gear: Tool)
    for _, child: Instance in gear:GetDescendants() do
        if child:IsA("BasePart") then
            child.CanTouch = false
            child.CanQuery = false
            child.CanCollide = false
        elseif child:IsA("BodyMover") or child:IsA("Constraint") then
            child:Destroy()
        elseif child:IsA("Script") or child:IsA("LocalScript") then
            child.Enabled = false
        elseif child:IsA("Sound") then
            child:Stop()
        end
    end

    CollectionService:AddTag(gear, "GearProp")
    return gear
end

function GearPropUtil.GetPropFromPlayer(player: Player)
    local backpack = player:FindFirstChildWhichIsA("Backpack")

    if backpack then
        for _, child in backpack:GetChildren() do
            if CollectionService:HasTag(child, "GearProp") then
                return child
            end
        end
    end

    if player.Character then
        for _, child in player.Character:GetChildren() do
            if CollectionService:HasTag(child, "GearProp") then
                return child
            end
        end
    end
end

return GearPropUtil