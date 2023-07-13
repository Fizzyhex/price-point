local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local TAGS = {
    tester = {
        text = "[Tester]",
        color = Color3.fromRGB(113, 159, 237)
    }
}

local function TextChatHandler()
    TextChatService.OnIncomingMessage = function(message: TextChatMessage)
        local props = Instance.new("TextChatMessageProperties")
        local player = message.TextSource and Players:GetPlayerByUserId(message.TextSource.UserId)
        local chatTags = player and player:GetAttribute("ChatTags")

        if chatTags then
            local tagData = TAGS[chatTags]

            if tagData then
                props.PrefixText = `<font color='#{tagData.color:ToHex()}'>{tagData.text}</font> {message.PrefixText}`
            end
        end

        return props
    end
end

return TextChatHandler