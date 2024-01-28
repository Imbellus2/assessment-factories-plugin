local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

-- local Dataset = require(script.Parent.Dataset)
local Utilities = require(script.Parent.Packages.Utilities)
local MapData = require(script.Parent.MapData)
local Constants = require(script.Parent.Constants)
local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)
local Types = require(script.Parent.Types)

local function registerDebugId(instance: Instance)
    instance:SetAttribute("debugId", instance:GetDebugId())
end

local Scene = {}

function Scene.isLoaded()
    return game.Workspace:FindFirstChild("Scene") ~= nil
end

function Scene.setCamera()
    local Camera = game.Workspace.Camera
    Camera.FieldOfView = 25.676
    Camera.CameraType = Enum.CameraType.Scriptable
    local cf = CFrame.new(
        -128.214401,
        206.470215,
        -6.83965349,
        -4.37113883e-08,
        0.855725706,
        -0.51742965,
        0,
        0.51742965,
        0.855725706,
        1,
        3.74049591e-08,
        -2.26175683e-08
    )
    Camera.CFrame = cf
    Camera.CameraType = Enum.CameraType.Custom
end

function Scene.initScene()
    if not game.Workspace:FindFirstChild("Scene") then
        local scene = script.Parent.Assets.SceneHierarchy.Scene:Clone()
        scene.Parent = game.Workspace
    end

    if game.Workspace:FindFirstChild("Baseplate") then
        game.Workspace.Baseplate:Destroy()
    end
    if game.Workspace:FindFirstChild("SpawnLocation") then
        game.Workspace.SpawnLocation:Destroy()
    end

    local pluginDataFolder = getOrCreateFolder("FactoriesPluginData", ReplicatedStorage)
    local mapsFolder = getOrCreateFolder("Maps", pluginDataFolder)
    for i = 1, 2, 1 do
        local mapFolder = getOrCreateFolder(tostring(i), mapsFolder)
    end

    --Update the lighting and camera
    local Lighting = game:GetService("Lighting")
    Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    Lighting.Brightness = 5
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    Lighting.ShadowSoftness = 0.2
    -- Lighting.Technology = Enum.Technology.ShadowMap --Not scriptable
    Lighting.ClockTime = 14.5
    Lighting.GeographicLatitude = 0

    Scene.setCamera()

    -- ChangeHistoryService:SetWaypoint("Instantiated Scene Hierarchy")
end

function Scene.getMachinesFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Machines")
end

function Scene.getCurrentMapIndexAccordingToScene()
    local currentMapIndex = 2
    local datasetInstance = Utilities.getValueAtPath(game.Workspace, "Dataset")
    if datasetInstance then
        if datasetInstance:GetAttribute("CurrentMapIndex") then
            currentMapIndex = datasetInstance:GetAttribute("CurrentMapIndex")
        end
    end
    return currentMapIndex
end

-- function Scene.getMachineAnchorFromCoordinates(x:number, y:number)
--     local machines = Scene.getMachineAnchors()
--     for _,v in machines do
--         local nameX, nameY = Dataset:getCoordinatesFromAnchorName(v.Name)
--         if nameX == x and nameY == y then
--             return v
--         end
--     end
--     return nil
-- end
function Scene.isMachineAnchor(obj)
    if not obj then
        return false
    end
    if obj.Parent.Name == "Machines" then
        return true
    end
    return false
end

function Scene.getMachineAnchors()
    local machinesFolder = Scene.getMachinesFolder()
    return (Scene.isLoaded() and machinesFolder) and machinesFolder:GetChildren() or {}
end
-- function Scene.getAnchorFromMachine(machine: table)
--     local result = nil
--     local machineAnchors = Scene.getMachineAnchors()
--     local machineAnchorId = machine["machineAnchor"]
--     for _, machineAnchor in machineAnchors do
--         local debugId = machineAnchor:GetAttribute("debugId")
--         if debugId == machineAnchorId then
--             result = machineAnchor
--         end
--     end
--     return result
-- end

function Scene.getAnchorFromMachine(machine: Types.Machine)
    local anchor = nil
    if machine["machineAnchor"] then
        for _, anchorInScene in Scene.getMachineAnchors() do
            local debugId = anchorInScene:GetAttribute("debugId")
            if debugId == machine["machineAnchor"] then
                anchor = anchorInScene
            end
        end
    end
    return anchor
end

function Scene.instantiateMachineAnchor(machine: table)
    local folder = Scene.getMachinesFolder()
    print("Instantiating...", machine.id)

    -- local assetPath = string.split(machine["asset"], ".")[3]
    local position = Vector3.new()
    if machine["worldPosition"] then
        position =
            Vector3.new(machine["worldPosition"]["X"], machine["worldPosition"]["Y"], machine["worldPosition"]["Z"])
    end
    -- local asset = script.Parent.Assets.Machines[assetPath]:Clone()
    --TODO: Figure out why mesh machines are not importing correctly
    local anchor = Scene.getAnchorFromMachine(machine)
    if not anchor then
        -- anchor = script.Parent.Assets.Machines["PlaceholderMachine"]:Clone()
        anchor = Instance.new("Part")
        anchor.Anchored = true
        anchor.Size = Vector3.new(8, 2, 12)
        anchor.Color = Color3.new(0.1, 0.1, 0.1)
        anchor.Transparency = 0.1
        local cframe = CFrame.new(position)
        anchor:PivotTo(cframe)
        anchor.Name = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
        anchor.Parent = folder
    end

    local debugId = anchor:GetDebugId()
    machine["machineAnchor"] = debugId
    registerDebugId(anchor)

    return anchor
end

--TODO: Ideally, this would be handled by the components.
function Scene.updateAllMapAssets(map: table)
    Scene.getMachinesFolder():ClearAllChildren()
    Scene.getBeltsFolder():ClearAllChildren()
    -- Scene.getBeltDataFolder():ClearAllChildren()

    -- for _, machine in map["machines"] do
    --     Scene.instantiateMachineAnchor(machine)
    -- end
end

function Scene.getPluginDataFolder()
    return Utilities.getValueAtPath(ReplicatedStorage, "FactoriesPluginData")
end

function Scene.getMapFolder(mapIndex)
    local folder = Utilities.getValueAtPath(Scene.getPluginDataFolder(), "Maps." .. tostring(mapIndex))
    return folder
end

function Scene.getCurrentMapFolder()
    local folder = Scene.getMapFolder(Scene.getCurrentMapIndexAccordingToScene())
    return folder
end

function Scene.getMidpointAdjustmentsFolder(conveyorName)
    local folder = Utilities.getValueAtPath(Scene.getConveyorFolder(conveyorName), "MidpointAdjustments")
    return folder
end

function Scene.getBeltsFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Belts")
end

function Scene.getBeltDataFolder()
    return Utilities.getValueAtPath(game.Workspace, "BeltData")
end

function Scene.getConveyorFolder(name: string)
    local folder = Scene.getCurrentMapFolder()
    local beltFolder = folder:FindFirstChild(name)
    if beltFolder then
        return beltFolder
    end
    return nil
end

function Scene.getConveyorMeshFromName(conveyorName: string)
    local beltSegment = Utilities.getValueAtPath(Scene.getBeltsFolder(), conveyorName)
    if beltSegment then
        return beltSegment
    end
    return nil
end

function Scene.getMidpointAdjustment(conveyorName: string): NumberValue
    local midpointAdjustmentsFolder = Scene.getMidpointAdjustmentsFolder(conveyorName)
    -- local conveyorFolder: Folder = Utilities.getValueAtPath(game.Workspace, "BeltData." .. conveyorName)
    -- if conveyorFolder then
    if not midpointAdjustmentsFolder then
        print("No midpoint adjustments folder")
        return nil
    end
    local midpointAdjustment: NumberValue = midpointAdjustmentsFolder:FindFirstChild(conveyorName)
    if midpointAdjustment then
        return midpointAdjustment
    end
    -- end
    return nil
end

function Scene.getConveyorBeltName(machine1, machine2)
    local machine1Anchor = Scene.getAnchorFromMachine(machine1)
    local machine2Anchor = machine2 and Scene.getAnchorFromMachine(machine2) or nil
    if machine1Anchor and machine2Anchor then
        return machine1Anchor.Name .. "-" .. machine2Anchor.Name
    elseif machine1Anchor then
        return machine1Anchor.Name
    else
        return nil
    end
end

function Scene.removeConveyors(machine: Types.Machine)
    local conveyorName = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
    local folder = Utilities.getConveyorFolder(conveyorName)
    for _, conveyor: Folder in folder:GetChildren() do
        local splitName = conveyor.Name:split("-")
        if splitName[1] == conveyorName then
            conveyor:Destroy()
        end
        if #splitName > 1 and splitName[2] == conveyorName then
            conveyor:Destroy()
        end
    end
end

return Scene
