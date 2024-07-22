local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = require(script.Parent.Packages.Utilities)

local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)
local Types = require(script.Parent.Types)
local Constants = require(script.Parent.Constants)

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
        local scene = script.Parent.Assets.SceneHierarchy:Clone()
        scene.Name = "Scene"
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

    local position = Vector3.new()
    if machine["worldPosition"] then
        position =
            Vector3.new(machine["worldPosition"]["X"], machine["worldPosition"]["Y"], machine["worldPosition"]["Z"])
    end
    local anchor = Scene.getAnchorFromMachine(machine)
    local anchorName = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
    local anchorSize = Constants.MachineAnchorSizes[machine["type"]]
    if not anchor then
        anchor = Instance.new("Part")
        anchor.Anchored = true
        anchor.Size = anchorSize
        anchor.Color = Color3.new(0.1, 0.1, 0.1)

        local cframe = CFrame.new(position)
        anchor:PivotTo(cframe)
        anchor.Name = anchorName
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
    Scene.getBeltPartsFolder():ClearAllChildren()
end

function Scene.getPluginDataFolder()
    return Utilities.getValueAtPath(ReplicatedStorage, "FactoriesPluginData")
end

function Scene.getMapFolder(mapIndex)
    local folder = Utilities.getValueAtPath(Scene.getPluginDataFolder(), "Maps." .. tostring(mapIndex))
    return folder
end

function Scene.getBeltInfoFolderForCurrentMap()
    local folder = Scene.getMapFolder(Scene.getCurrentMapIndexAccordingToScene())
    return folder
end

function Scene.getMidpointAdjustmentsFolder(conveyorName)
    local folder = Utilities.getValueAtPath(Scene.getConveyorFolder(conveyorName), "MidpointAdjustments")
    return folder
end

function Scene.getBeltPartsFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Belts")
end

function Scene.getBeltMapDataFolder()
    return Utilities.getValueAtPath(game.Workspace, "BeltData")
end

function Scene.getConveyorFolder(name: string)
    local folder = Scene.getBeltInfoFolderForCurrentMap()
    local beltFolder = folder:FindFirstChild(name)
    if beltFolder then
        return beltFolder
    end
    return nil
end

function Scene.getConveyorMeshFromName(conveyorName: string)
    local beltSegment = Utilities.getValueAtPath(Scene.getBeltPartsFolder(), conveyorName)
    if beltSegment then
        return beltSegment
    end
    return nil
end

function Scene.getMidpointAdjustment(conveyorName: string): NumberValue
    local midpointAdjustmentsFolder = Scene.getMidpointAdjustmentsFolder(conveyorName)

    if not midpointAdjustmentsFolder then
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
    --find a conveyor with this name
    local beltInfoFolder = Scene.getBeltInfoFolderForCurrentMap()
    local beltPartsFolder = Scene.getBeltPartsFolder()
    local beltMapDataFolder = Scene.getBeltMapDataFolder()
    for _, conveyor in beltInfoFolder:GetChildren() do
        local splitName = conveyor.Name:split("-")
        if splitName[1] == conveyorName or (#splitName > 1 and splitName[2] == conveyorName) then
            local conveyorPart = beltPartsFolder:FindFirstChild(conveyor.Name)
            if conveyorPart then
                conveyorPart:Destroy()
            end
            local beltMapData = beltMapDataFolder:FindFirstChild(conveyor.Name)
            if beltMapData then
                beltMapData:Destroy()
            end
            conveyor:Destroy()
        end
    end
end

return Scene
