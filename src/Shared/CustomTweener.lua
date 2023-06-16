local function CustomTweener(instance: Instance, fn)
    local tweener = Instance.new("CFrameValue")

    tweener:GetPropertyChangedSignal("Value"):Connect(function()
        fn(tweener.Value)
    end)

    return tweener
end

return CustomTweener