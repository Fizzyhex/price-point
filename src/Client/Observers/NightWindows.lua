local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Promise = require(ReplicatedStorage.Packages.Promise)

local COLOR1 = Color3.fromRGB(222, 250, 255)
local COLOR2 = Color3.fromRGB(255, 225, 194)
local RANDOM = Random.new()
local TAG = "NightWindows"

local function MultiplyColor(color: Color3, amount: number)
    return Color3.new(color.R * amount, color.B * amount, color.G * amount)
end

-- Lights up windows when it's dark
local function NightWindows()
    local updatePromise
    local clockTime = Fusion.Value(0)
    local instances = {}
    local isDark = Fusion.Computed(function()
        return clockTime:get() >= 17.8 or clockTime:get() <= 2
    end)

    Fusion.Hydrate(Lighting) {
        [Fusion.Out "ClockTime"] = clockTime
    }

    local function GetBaseColor(texture: Texture)
        local baseColor = texture.Parent:GetAttribute("BaseColor")

        if not baseColor then
            baseColor = COLOR1:Lerp(COLOR2, RANDOM:NextNumber())
            texture.Parent:SetAttribute("BaseColor", baseColor)
        end

        return baseColor
    end

    local function Update(texture: Texture)
        texture.Transparency = if isDark:get() then 0 else 1
    end

    local i = 0

    Fusion.Observer(isDark):onChange(function()
        print("isdark", isDark:get())
        if updatePromise then
            updatePromise:cancel()
            updatePromise = nil
        end

        i += 1

        updatePromise = Promise.new(function(resolve, reject, onCancel)
            local thread = task.spawn(function()
                local updated = {}
                local updateList = table.clone(instances)

                for index, instance in updateList do
                    if not instance:IsDescendantOf(workspace) then
                        table.remove(updateList, index)
                    end
                end

                while #updateList > 0 do
                    for _ = 1, 3 do
                        local instance = table.remove(updateList)

                        if instance and updated[instance.Parent] ~= true then
                            for _, child in instance.Parent:GetChildren() do
                                if CollectionService:HasTag(child, TAG) then
                                    child:SetAttribute("update", i)
                                    Update(child)
                                end
                            end

                            updated[instance.Parent] = true
                        elseif not instance then
                            print("Done updating")
                            resolve()
                            return
                        end
                    end

                    task.wait(0.1)
                end
            end)

            onCancel(function()
                task.cancel(thread)
            end)

            for _, tagged in CollectionService:GetTagged(TAG) do
                Update(tagged)
                task.wait(0.3)
            end
        end)
    end)

    Observers.observeTag(TAG, function(texture: Texture)
        if texture:IsA("Texture") == false and texture:IsA("Decal") == false then
            warn(`{texture:GetFullName()} is mistagged with {TAG}!`)
            CollectionService:RemoveTag(texture, TAG)
        else
            Update(texture)
        end

        texture.Color3 = MultiplyColor(GetBaseColor(texture), 12)
        table.insert(instances, texture)

        return function()
            table.remove(instances, table.find(instances, texture))
        end
    end, { workspace })
end

return NightWindows