local AnimatorUtil = {}

function AnimatorUtil.GetAnimator(target: Humanoid | AnimationController): Animator
    local animator = target:FindFirstChildWhichIsA("Animator")

    if animator then
        return animator
    else
        animator = Instance.new("Animator")
        animator.Parent = target
        return animator
    end
end

return AnimatorUtil