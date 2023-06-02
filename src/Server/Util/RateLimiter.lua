local Players = game:GetService("Players")

local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(requests: number, per: number)
    local self = setmetatable({
        _histories = {},
        _limitPer = per,
        _limitRequests = requests,
    }, RateLimiter)

    self._playerConnection = Players.PlayerRemoving:Connect(function(player: Player)
        self._histories[player] = nil
    end)

    return self
end

function RateLimiter:IsInBudget(player: Player)
    local history = self._histories[player]

    if not history then
        return true
    end

    local spent = 0

    for index, entry in history do
        if tick() - entry > self._limitPer then
            table.remove(history, index)
        else
            spent += 1
        end
    end

    return spent < self._limitRequests
end

function RateLimiter:LogRequest(player: Player)
    local isInBudget = self:IsInBudget(player)

    if isInBudget then
        local history = self._histories[player]

        if not history then
            history = {}
            self._histories[player] = history
        end

        table.insert(history, tick())
    end

    return isInBudget
end

function RateLimiter:Destroy()
    self._playerConnection:Disconnect()
end

return RateLimiter