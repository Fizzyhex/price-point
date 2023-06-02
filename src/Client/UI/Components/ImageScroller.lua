local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local Computed = Fusion.Computed
local Cleanup = Fusion.Cleanup

local IS_SERVER = RunService:IsServer()
local IS_RUN_MODE = RunService:IsRunMode()
local STRIPPED_PROPS = { "Velocity", "Position" }
local perFrameEvent = if IS_SERVER and IS_RUN_MODE then RunService.Stepped else RunService.RenderStepped

local function ImageScroller(props: table)
    local tileSize = props.TileSize
    local velocity = props.Velocity
    local scrollingOffset = Value(UDim2.new())
    local position = props.Position or UDim2.new()

    local function Update()
        local currentTileSize = Unwrap(tileSize)
        local currentVelocity = Unwrap(velocity)
        local now = tick()
        scrollingOffset:set(UDim2.fromOffset(
            (now * currentVelocity.X) % currentTileSize.X.Offset,
            (now * currentVelocity.Y) % currentTileSize.Y.Offset)
        )
    end

    Update()

    local updateConnection = RunService.RenderStepped:Connect(Update)
    local imageLabel = New "ImageLabel" {
        Name = "ImageScroller",
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = tileSize,
        Position = Computed(function()
            return Unwrap(position) + scrollingOffset:get()
        end),
        [Cleanup] = { updateConnection }
    }

    return Hydrate(imageLabel)(StripProps(props, STRIPPED_PROPS))
end

return ImageScroller