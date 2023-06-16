local ModelUtil = {}

function ModelUtil.ConvertToModel(instance: Instance)
    local model = Instance.new("Model")
    model.Name = instance.Name

    if instance:IsA("Accessory") then
        for _, child in instance:GetDescendants() do
            if child.Name == "Handle" and child:IsA("BasePart") then
                model.PrimaryPart = child
            end

            child.Parent = model
        end
    else
        instance.Parent = model
    end

    if instance:IsA("BasePart") then
        model.PrimaryPart = instance
    end

    return model
end

return ModelUtil