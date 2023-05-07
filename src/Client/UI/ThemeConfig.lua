local THEME_COLORS = {
    accent = {
        light = Color3.fromRGB(30, 243, 65),
        dark = Color3.fromRGB(43, 217, 72)
    },

    background = {
        light = Color3.fromRGB(255, 255, 255),
        dark = Color3.fromRGB(20, 20, 20)
    },

    background_2 = {
        light = Color3.fromRGB(235, 235, 235),
        dark = Color3.fromRGB(40, 40, 40)
    },

    background_3 = {
        light = Color3.fromRGB(225, 225, 225),
        dark = Color3.fromRGB(60, 60, 60)
    },

    header = {
        light = Color3.fromRGB(20, 20, 20),
        dark = Color3.fromRGB(230, 230, 230)
    },

    body = {
        light = Color3.fromRGB(20, 20, 20),
        dark = Color3.fromRGB(230, 230, 230)
    },

    error = {
        light = Color3.fromRGB(255, 0, 0),
        dark = Color3.fromRGB(255, 0, 0)
    }
}

THEME_COLORS.accent_contrast_body = {
    light = THEME_COLORS.body.dark,
    dark = THEME_COLORS.body.light
}

THEME_COLORS.accent_contrast_header = {
    light = THEME_COLORS.header.dark,
    dark = THEME_COLORS.header.light
}

local FONT_FACES = {
    header = {
        default = Font.fromName("GothamSSm", Enum.FontWeight.ExtraBold)
    },

    body = {
        default = Font.fromName("GothamSSm", Enum.FontWeight.Regular)
    },

    bold = {
        default = Font.fromName("GothamSSm", Enum.FontWeight.Bold)
    },

    medium = {
        default = Font.fromName("GothamSSm", Enum.FontWeight.SemiBold)
    },
}

local FONT_SIZES = {
    header = {
        default = 28,
        cinema = 48
    },
    body = {
        default = 18,
        cinema = 38
    },
}

-- Contains information about the games themes.
-- This information should be accessed via the `ThemeProvider` module.
local export = {
    THEME_COLORS = THEME_COLORS,
    FONT_FACES = FONT_FACES,
    FONT_SIZES = FONT_SIZES,
}

return export