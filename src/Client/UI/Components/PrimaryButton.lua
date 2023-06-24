local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Button = require(ReplicatedStorage.Client.UI.Components.Button)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate

local function PrimaryButton(props)
    local newProps = table.clone(props)
    newProps.BackgroundColor3 = newProps.BackgroundColor3 or ThemeProvider:GetColor("accent")
    newProps.TextColor3 = props.TextColor3 or ThemeProvider:GetColor("accent_contrast_body")
    newProps.Name = newProps.Name or "PrimaryButton"
    return Button(newProps)
end

return PrimaryButton