local THEME_COLORS = {
    accent = {
        light = Color3.fromRGB(107, 183, 60),
        dark = Color3.fromRGB(110, 247, 132)
    },

    primary = {
        light = Color3.fromRGB(196, 196, 196),
        dark = Color3.fromRGB(255, 255, 255)
    },

    background = {
        light = Color3.fromRGB(240, 240, 240),
        dark = Color3.fromRGB(20, 20, 20)
    },

    background_2 = {
        light = Color3.fromRGB(215, 215, 215),
        dark = Color3.fromRGB(40, 40, 40)
    },

    background_3 = {
        light = Color3.fromRGB(205, 205, 205),
        dark = Color3.fromRGB(60, 60, 60)
    },

    header = {
        light = Color3.fromRGB(26, 47, 26),
        dark = Color3.fromRGB(230, 230, 230)
    },

    body = {
        light = Color3.fromRGB(20, 20, 20),
        dark = Color3.fromRGB(230, 230, 230)
    },

    subtext = {
        light = Color3.fromRGB(50, 50, 50),
        dark = Color3.fromRGB(200, 200, 200)
    },

    error = {
        light = Color3.fromRGB(255, 0, 0),
        dark = Color3.fromRGB(255, 0, 0)
    }
}

THEME_COLORS.accent_contrast_body = {
    light = THEME_COLORS.body.light,
    dark = THEME_COLORS.body.light
}

THEME_COLORS.accent_contrast_header = {
    light = THEME_COLORS.header.light,
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

local SURFACE_GUI_BRIGHTNESS = {
    light = 1,
    dark = 1.8
}

-- Contains information about the games themes.
-- This information should be accessed via the `ThemeProvider` module.
local export = {
    THEME_COLORS = THEME_COLORS,
    FONT_FACES = FONT_FACES,
    FONT_SIZES = FONT_SIZES,
    SURFACE_GUI_BRIGHTNESS = SURFACE_GUI_BRIGHTNESS
}

return export