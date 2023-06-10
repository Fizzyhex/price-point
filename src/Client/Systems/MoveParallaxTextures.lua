local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Responsible for moving parallax textures every frame
local function MoveParallaxTextures()
    RunService:BindToRenderStep("ParallaxTextures", Enum.RenderPriority.Last.Value + 126, function()
        local now = tick()

        for _, texture: Texture in CollectionService:GetTagged("ParallaxTexture") do
            local scrollSpeed = texture:GetAttribute("ScrollSpeed") or Vector2.zero
            texture.OffsetStudsV = ((now * scrollSpeed.X) % texture.StudsPerTileV)
            texture.OffsetStudsU = ((now * scrollSpeed.Y) % texture.StudsPerTileU)
        end
    end)
end

return MoveParallaxTextures