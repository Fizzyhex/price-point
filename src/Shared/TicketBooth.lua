-- A system that only accepts the last 'ticket'
local function TicketBooth()
    local value = 0

    return function()
        value += 1
        local ourTicket = value

        return function()
            return ourTicket == value
        end
    end
end

return TicketBooth