local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Computed = Fusion.Computed
local ThemeConfig = require(ReplicatedStorage.Client.UI.ThemeConfig)
local THEME_COLORS = ThemeConfig.THEME_COLORS
local FONT_FACES = ThemeConfig.FONT_FACES
local FONT_SIZES = ThemeConfig.FONT_SIZES

local currentColors = {}
local currentFontFaces = {}
local currentFontSizes = {}

local function WarnTraceback(message: string)
    warn(`Theme Provider: {message}\n{debug.traceback()}`)
end

local ThemeProvider = {
    _currentColorScheme = Value("dark"),
    _currentTextScale = Value(1),
}

for colorName, colorOptions in THEME_COLORS do
    currentColors[colorName] = Computed(function()
        return colorOptions[ThemeProvider._currentColorScheme:get()]
    end)
end

for fontName, fontFaces in FONT_FACES do
    local values = {}
    currentFontFaces[fontName] = values

    for mode, fontFace in fontFaces do
        values[mode] = Value(fontFace)
    end
end

for fontSizeName, fontSizes in FONT_SIZES do
    local values = {}
    currentFontSizes[fontSizeName] = values

    for mode, fontSize in fontSizes do
        values[mode] = Computed(function()
            return fontSize * ThemeProvider._currentTextScale:get()
        end)
    end
end

function ThemeProvider:GetColor(key: string, themeOverride: string)
    if themeOverride then
        local value = THEME_COLORS[key][themeOverride]
        return value
    else
        local value = currentColors[key]
        return value
    end
end

function ThemeProvider:GetFontFace(key: string, sizingMode: string?)
    sizingMode = sizingMode or "default"
    local value =
        currentFontFaces[key][sizingMode]
        or currentFontFaces[key]["default"]
    return value
end

function ThemeProvider:GetFontSize(key: string, sizingMode: string?)
    sizingMode = sizingMode or "default"
    local value =
        currentFontSizes[key][sizingMode]
        or currentFontSizes[key]["default"]
    return value
end

return ThemeProvider