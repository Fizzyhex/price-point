local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local SPEED = 800

local function SpinFanBlades()
    RunService:BindToRenderStep("SpinFanBlades", Enum.RenderPriority.Last.Value + 29, function()
        local now = tick()
        local rotation = CFrame.Angles(0, 0, math.rad(now * SPEED % 360))

        for _, part: BasePart in CollectionService:GetTagged("FanBlade") do
            if not part:IsDescendantOf(workspace) then
                continue
            end

            local initialPivot = part:GetAttribute("InitialPivot")

            if not initialPivot then
                initialPivot = part:GetPivot()
                part:SetAttribute("InitialPivot", initialPivot)
            end

            part:PivotTo(initialPivot * rotation)
        end
    end)
end

return SpinFanBlades