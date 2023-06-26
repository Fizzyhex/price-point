local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local ItemModelChannel = require(ServerStorage.Server.EventChannels.ItemModelChannel)
local ModelUtil = require(ServerStorage.Server.Util.ModelUtil)

local BALL_TAG = "ItemBall"
local MAX_BALLS = 6
local RANDOM = Random.new()
local BallPrefab = ServerStorage.Assets.ItemBall
local ALLOWED_ASSET_TYPES = {
    [Enum.AssetType.Gear] = true,
    [Enum.AssetType.Head] = true,
    [Enum.AssetType.Hat] = true
}

local function GetLargestScalar(vector: Vector3)
    return math.max(math.max(vector.X, vector.Y), vector.Z)
end

local function PickRandomSpawnCFrame(): CFrame?
    local spawnParts = CollectionService:GetTagged("ItemBallSpawn")

    for index, spawnPart in spawnParts do
        if not spawnPart:IsDescendantOf(workspace) then
            table.remove(spawnParts, index)
        end
    end

    if #spawnParts == 0 then
        return nil
    end

    local spawnPart = spawnParts[RANDOM:NextInteger(1, #spawnParts)]
    local randomOffset = RANDOM:NextUnitVector() * (spawnPart.Size / 2)
    return CFrame.new(spawnPart.CFrame * randomOffset)
end

local function ItemBallSpawner(props)
    local function InforceBallLimit()
        local existingBalls = CollectionService:GetTagged(BALL_TAG)

        if #existingBalls >= MAX_BALLS and RANDOM:NextInteger(1, 2) == 1 then
            existingBalls[1]:Destroy()
        end
    end

    local function OnItemChanged(item: Instance, assetType: Enum.AssetType)
        if item == nil or assetType == nil then
            return
        end

        if ALLOWED_ASSET_TYPES[assetType] ~= true and string.find(assetType.Name, "Accessory") == nil then
            return
        end

        if item:FindFirstChildWhichIsA("Humanoid") then
            return
        end

        local ball = BallPrefab:Clone()
        CollectionService:AddTag(ball, BALL_TAG)
        local model = item:Clone()

        if not model:IsA("Model") then
            model = ModelUtil.ConvertToModel(item)
        end

        if not model.PrimaryPart then
            return
        end

        local spawnCFrame = PickRandomSpawnCFrame()

        if not spawnCFrame then
            return
        end

        local lastPart

        for _, child in model:GetDescendants() do
            if child:IsA("BasePart") then
                child.Massless = true
                child.Anchored = false
                child.CanCollide = false
                child.CanTouch = false
                child.CanQuery = false

                if lastPart then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = lastPart
                    weld.Part1 = child
                    weld.Parent = child
                end

                lastPart = child
            end
        end

        InforceBallLimit()

        local modelCFrame, modelSize = model:GetBoundingBox()
        local ballScale = math.clamp(GetLargestScalar(modelSize) + 2, 7, 16)
        ballScale += RANDOM:NextNumber(1, 3)
        ball:PivotTo(modelCFrame)
        ball.PrimaryPart.Size = Vector3.new(ballScale, ballScale, ballScale)
        model.Parent = ball
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = ball.PrimaryPart
        weld.Part1 = model.PrimaryPart
        weld.Parent = ball
        ball.PrimaryPart.AssemblyAngularVelocity = RANDOM:NextUnitVector() * 10
        ball.PrimaryPart.CollideSound:Play()
        ball:PivotTo(spawnCFrame)
        ball.Parent = workspace
    end

    ItemModelChannel.ObserveItemChanged(OnItemChanged)
end

return ItemBallSpawner