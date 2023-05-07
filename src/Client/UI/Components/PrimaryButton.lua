local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Button = require(ReplicatedStorage.Client.UI.Components.Button)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local function PrimaryButton(props)
    local buttonProps = TableUtil.Reconcile({
        BackgroundColor3 = ThemeProvider:GetColor("accent"),
        TextColor3 = Color3.new(0, 0, 0),
        Name = "PrimaryButton",
    }, props)

    return Button(buttonProps)
end

return PrimaryButton