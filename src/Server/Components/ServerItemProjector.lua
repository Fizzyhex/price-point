local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ItemModelChannel = require(ServerStorage.Server.EventChannels.ItemModelChannel)

local mannequinIdle = ServerStorage.Assets.Animations.MannequinIdle

local function GetLargestScalar(vector: Vector3)
    return math.max(math.max(vector.X, vector.Y), vector.Z)
end

local function PartToModel(part: BasePart): Model
    local model = Instance.new("Model")
    model.Name = part.Name
    model.PrimaryPart = part
    part.Parent = model
    return model
end

local function GetAnimator(controller: Humanoid | AnimationController): Animator
    local animator = controller:FindFirstChildWhichIsA("Animator")

    if animator then
        return animator
    else
        return Instance.new("Animator", controller)
    end
end

local function GetProjectionAnimator(model: Model)
    local animatorContainer = model:FindFirstChildWhichIsA("Humanoid") or model:FindFirstChildWhichIsA("AnimationController")

    if not animatorContainer then
        return
    end

    local animator = GetAnimator(animatorContainer)
    return animator
end

local function LoadIdleAnimation(humanoid: Humanoid)
    local animator = GetAnimator(humanoid)
    local animationTrack = animator:LoadAnimation(mannequinIdle) :: AnimationTrack
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Core
    animationTrack:Play()
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

local function LoadProjectionAnimation(animator: Animator, animation: Animation)
    local track = animator:LoadAnimation(animation)
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = true
    return track
end

local function ScaleHumanoid(humanoid: Humanoid, scaleBy: number)
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

    -- local humanoid = model:FindFirstChildWhichIsA("Humanoid")

    -- if humanoid and (humanoid.RigType == Enum.RigType.R15 or model:FindFirstChild("LowerTorso")) then
    --     local rootPart = humanoid.RootPart

    --     if rootPart then
    --         print("Scaling humanoid")
    --         ScaleHumanoid(humanoid, scaleBy)
    --         return
    --     end
    -- end

    model:ScaleTo(scaleBy)
end

local ServerItemProjector = Component.new { Tag = "ItemProjector" }

function ServerItemProjector:Construct()
    self._trove = Trove.new()
    self._root = assert(
        self.Instance:FindFirstChild("Root"),
        "The ItemProjector component requires a BasePart named Root parented underneath the Instance"
    )
    self._root.Transparency = 1

    if self.Instance:FindFirstChild("Container") then
        self._container = self.Instance.Container
    else
        self._container = Instance.new("Folder")
        self._container.Name = "Container"
        self._container.Parent = self.Instance
        self._trove:Add(self._container)
    end

    self._trove:Add(ItemModelChannel.ObserveItemChanged(function(item)
        self:SetModel(item)
    end))
end

function ServerItemProjector:_DestroyCurrentModel()
    local currentModel = self._container:GetChildren()[1]

    if currentModel then
        currentModel:Destroy()
    end
end

function ServerItemProjector:_HandleProjectionCharacter(character, humanoidDescription: HumanoidDescription?)
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

    LoadIdleAnimation(humanoid)
end

function ServerItemProjector:SetModel(projection: BasePart | Model, humanoidDescription: HumanoidDescription?)
    self:_DestroyCurrentModel()

    if projection == nil then
        return
    end

    if projection:IsA("BasePart") then
        projection = PartToModel(projection)
    end

    projection:PivotTo(self._root:GetPivot())
    --[!] We need to parent characters before we can mess with humanoid descriptions
    projection.Parent = self._container
    --SetModelScale(projection, GetLargestScalar(self._root.Size))

    if projection:FindFirstChildWhichIsA("Humanoid") then
        self:_HandleProjectionCharacter(projection)
    end

    SetModelScale(projection, GetLargestScalar(self._root.Size))

    local animation = projection:FindFirstChildWhichIsA("Animation")

    if animation then
        local animator = GetProjectionAnimator(projection)

        if animator then
            LoadProjectionAnimation(animator, animation):Play()
        end
    end
end

function ServerItemProjector:Stop()
    self._trove:Destroy()
end

return ServerItemProjector