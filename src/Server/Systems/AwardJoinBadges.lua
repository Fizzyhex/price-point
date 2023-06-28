local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local BadgeIds = require(ReplicatedStorage.Shared.Data.BadgeIds)

local AWARD_TESTER_BADGE = false

local function AwardJoinBadges()
    Observers.observePlayer(function(player: Player)
        if AWARD_TESTER_BADGE then
            BadgeService:AwardBadge(player.UserId, BadgeIds.earlyTester)
        end
    end)
end

return AwardJoinBadges