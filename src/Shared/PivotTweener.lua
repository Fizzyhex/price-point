local function PivotTweener(instance: Instance)
    local tweener = Instance.new("CFrameValue")

    tweener:GetPropertyChangedSignal("Value"):Connect(function()
        instance:PivotTo(tweener.Value)
    end)

    return tweener
end

return PivotTweener