local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local BadgeIds = require(ReplicatedStorage.Shared.Data.BadgeIds)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local AWARD_TESTER_BADGE = false

local function TesterBadgeHandler()
    local logger = CreateLogger(script)

    Observers.observePlayer(function(player: Player)
        local hasBadge = false

        if AWARD_TESTER_BADGE then
            hasBadge = true
            BadgeService:AwardBadge(player.UserId, BadgeIds.earlyTester)
        end

        if not hasBadge then
            local ok, result = pcall(function()
                return BadgeService:UserHasBadgeAsync(player.UserId, BadgeIds.earlyTester)
            end)

            if ok then
                hasBadge = result
            else
                logger.warn(`UserHasBadgeAsync failed for {player.UserId}: {result}`)
            end
        end

        if hasBadge then
            player:SetAttribute("ChatTags", "tester")
        end
    end)
end

return TesterBadgeHandler