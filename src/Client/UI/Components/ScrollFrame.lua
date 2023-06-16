local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local New = Fusion.New
local Hydrate = Fusion.Hydrate

local function ScrollFrame(props)
    local scrollingFrame = New "ScrollingFrame" {
        Name = "ScrollFrame",
        BackgroundColor3 = ThemeProvider:GetColor("background"),
        ScrollBarImageColor3 = ThemeProvider:GetColor("primary")
    }

    return Hydrate(scrollingFrame)(props)
end

return ScrollFrame