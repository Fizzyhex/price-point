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
        end
    end

    return gear
end

function GearPropUtil.GetPropFromPlayer(player: Player)
    local backpack = player:FindFirstChildWhichIsA("Backpack")
    
    if backpack then
        for _, child in backpack:GetChildren() do
            if child:IsA("Tool") then
            end
        end
    end
end

return GearPropUtil