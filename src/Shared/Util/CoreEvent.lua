local function CoreEvent(requiresSubscriber: boolean?, areArgumentsSaved: boolean?)
    local subscriptions = {}
    local lastArguments = nil

    -- Fires all subscripters of the event
    local function Raise(...)
        if areArgumentsSaved then
            lastArguments = {...}
        end

        if requiresSubscriber and next(subscriptions) == nil then
            error("No subscribers")
        end

        for _, subscription in subscriptions do
            task.spawn(subscription, ...)
        end
    end

    -- Subscribes to the event, returning a function to unsubscribe
    local function Subscribe(callback)
        table.insert(subscriptions, callback)

        if areArgumentsSaved and lastArguments then
            task.spawn(callback, unpack(lastArguments))
        end

        -- Unsubscribes from the event
        return function()
            for index, subscription in subscriptions do
                if subscription == callback then
                    subscriptions[index] = nil
                    break
                end
            end
        end
    end

    return Raise, Subscribe
end

return CoreEvent