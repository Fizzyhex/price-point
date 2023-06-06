local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local mannequinIdle = ServerStorage.Assets.Animations.MannequinIdle

local function GetLargestScalar(vector: Vector3)
    return math.max(math.max(vector.X,   vector.Y), vector.Z)
end

local function ResizeModel(model: Model, scale: number)
    local pivot = model:GetPivot().Position

	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Position = pivot:Lerp(child.Position, scale)
			child.Size *= scale
        elseif child:IsA("SpecialMesh") then
            child.Scale *= scale
		end
	end
end

local function ScaleHumanoid(humanoid: Humanoid, scaleBy: number)
    local scalers = {
        humanoid:FindFirstChild("BodyDepthScale"),
        humanoid:FindFirstChild("BodyWidthScale"),
        humanoid:FindFirstChild("BodyHeightScale"),
        humanoid:FindFirstChild("HeadScale")
    } :: { ObjectValue }

    local scales = {"DepthScale", "HeadScale", "HeightScale", "WidthScale"}
    local newDescription = humanoid:GetAppliedDescription():Clone()

    for _, scale in scales do
        newDescription[scale] *= scaleBy
    end

    humanoid:ApplyDescription(newDescription)
end

local function SetModelScale(model: Model, scale: number)
    local extentsSize = model:GetExtentsSize()
    local largestScalar = GetLargestScalar(extentsSize)
    local scaleBy = scale / largestScalar

    local humanoid = model:FindFirstChildWhichIsA("Humanoid")

    if humanoid and humanoid.RigType == Enum.RigType.R15 then
        local rootPart = humanoid.RootPart

        if rootPart then
            print("Scaling humanoid")
            ScaleHumanoid(humanoid, scaleBy)
            return
        end
    end

    ResizeModel(model, scaleBy)
end

local ServerItemProjector = Component.new { Tag = "ItemProjector" }

function ServerItemProjector:Construct()
    self._trove = Trove.new()
    self._root = assert(
        self.Instance:FindFirstChild("Root"),
        "The ItemProjector component requires a BasePart named Root parented underneath the Instance"
    )

    if self.Instance:FindFirstChild("Container") then
        self._container = self.Instance.Container
    else
        self._container = Instance.new("Folder")
        self._container.Name = "Container"
        self._container.Parent = self.Instance
        self._trove:Add(self._container)
    end
end

function ServerItemProjector:_DestroyCurrentModel()
    local currentModel = self._container:GetChildren()[1]

    if currentModel then
        currentModel:Destroy()
    end
end

function ServerItemProjector:_HandleCharacter(character, humanoidDescription: HumanoidDescription?)
    local humanoid: Humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if humanoid.RootPart then
        humanoid.RootPart.Anchored = true
    end

    if humanoidDescription then
        humanoid:ApplyDescription(humanoidDescription)
    else
        -- Reapply descriptions for heads
        humanoid:ApplyDescription(humanoid:GetAppliedDescription())
    end
end

function ServerItemProjector:_LoadIdleAnimation(humanoid: Humanoid)
    local animator = humanoid:FindFirstChildWhichIsA("Animator")

    if not animator then
        return
    end

    local animationTrack = animator:LoadAnimation(mannequinIdle) :: AnimationTrack
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Core
    animationTrack:Play()
end

function ServerItemProjector:SetModel(model: BasePart | Model, humanoidDescription: HumanoidDescription?)
    self:_DestroyCurrentModel()

    if not model then
        return
    end

    local humanoid = model:FindFirstChildWhichIsA("Humanoid")

    if humanoid then
        -- We need to parent characters before we can mess with humanoid descriptions
        model.Parent = self._container
    end

    self:_HandleCharacter(model)

    -- This turns parts into models, but is it needed?
    -- if model:IsA("BasePart") then
    --     local primaryPart = model
    --     model = Instance.new("Model")
    --     model.Name = primaryPart.Name
    --     model.PrimaryPart = primaryPart
    --     primaryPart.Parent = model
    -- end

    if humanoidDescription then
        humanoid:ApplyDescription(humanoidDescription)
    end

    SetModelScale(model, GetLargestScalar(self._root.Size))
    model:PivotTo(self._root:GetPivot())
    model.Parent = self._container

    if humanoidDescription == nil and humanoid and humanoid.RootPart  then
        -- Reapply the current description for heads
        humanoid:ApplyDescription(humanoid:GetAppliedDescription())
    end

    if humanoid then
        local animation = model:FindFirstChildWhichIsA("Animation")
        local animator = humanoid:FindFirstChildWhichIsA("Animator")

        if animator and animation then
            local animationTrack = animator:LoadAnimation(animation) :: AnimationTrack
            animationTrack.Looped = true
            animationTrack.Priority = Enum.AnimationPriority.Action
            animationTrack:Play()
            local idleAnimationTrack = animator:LoadAnimation(mannequinIdle) :: AnimationTrack
            idleAnimationTrack.Looped = true
            idleAnimationTrack.Priority = Enum.AnimationPriority.Core
            idleAnimationTrack:Play(0)
        end
    end
end

function ServerItemProjector:Stop()
    self._trove:Destroy()
end

return ServerItemProjector