local PhysicsService = game:GetService("PhysicsService")

local SELECTABLE_GROUP = "StudioSelectable"
local UNSELECTABLE_GROUP = "Unselectable"

local CollisionGroupMgr = {}

function CollisionGroupMgr:MakeUnselectable(model: Model)
    if not PhysicsService:IsCollisionGroupRegistered(UNSELECTABLE_GROUP) and not self:MaxCollisionGroupsReached() then
        PhysicsService:RegisterCollisionGroup(UNSELECTABLE_GROUP)
        PhysicsService:CollisionGroupSetCollidable("Default", UNSELECTABLE_GROUP, false)
        PhysicsService:CollisionGroupSetCollidable(SELECTABLE_GROUP, UNSELECTABLE_GROUP, false)
    end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CollisionGroup = UNSELECTABLE_GROUP
        end
    end
end

function CollisionGroupMgr:HasTooManyExistingGroups(): boolean
    local neededGroups = 0
    if not PhysicsService:IsCollisionGroupRegistered(UNSELECTABLE_GROUP) then
        neededGroups += 1
    end
    if not PhysicsService:IsCollisionGroupRegistered(SELECTABLE_GROUP) then
        neededGroups += 1
    end
    local existingGroups = #PhysicsService:GetRegisteredCollisionGroups()
    local maxGroups = PhysicsService:GetMaxCollisionGroups()
    return existingGroups + neededGroups > maxGroups
end

function CollisionGroupMgr:MaxCollisionGroupsReached()
    if CollisionGroupMgr:HasTooManyExistingGroups() then
        warn(
            "Factories Plugin: Cannot hide object because you've reached the max allowable CollisionGroups (32). Remove a CollisionGroup to proceed"
        )
        return true
    else
        return false
    end
end

return CollisionGroupMgr
