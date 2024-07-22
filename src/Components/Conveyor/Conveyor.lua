local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local ControlPoint = require(script.Parent.ControlPoint)
local BeltSegment = require(script.Parent.BeltSegment)

local getOrCreateFolder = require(script.Parent.Parent.Parent.Helpers.getOrCreateFolder)
local worldPositionToVector3 = require(script.Parent.Parent.Parent.Helpers.worldPositionToVector3)

local Types = require(script.Parent.Parent.Parent.Types)
local Scene = require(script.Parent.Parent.Parent.Scene)
local Utilities = require(script.Parent.Parent.Parent.Packages.Utilities)

type Props = {
    ClickRect: Rect,
    Creating: boolean,
    Editing: boolean,
    Name: string,
    StartPosition: Vector3,
    EndPosition: Vector3,
}

type ControlPoint = {
    Name: string,
    Position: Vector3,
}

type BeltSegment = {
    Name: string,
    StartPoint: ControlPoint,
    EndPoint: ControlPoint,
}

local function getControlPointIndex(name): string
    local _, suffix = name:find("ControlPoint")
    return name:sub(suffix + 1, #name)
end

local function getPreviousIndex(name): number
    local index = getControlPointIndex(name)
    local prevIndex = index - 1
    if prevIndex == 0 then
        return nil
    end

    return prevIndex
end

local function refreshControlPoints(conveyor: Model): { ControlPoint }
    local controlPoints = {}
    local controlPointParts = conveyor.ControlPoints:GetChildren()
    table.sort(controlPointParts, function(a, b)
        return a.Name < b.Name
    end)
    for _, controlPointPart in controlPointParts do
        controlPoints[controlPointPart.Name] = {
            Position = controlPointPart.Position,
            Name = controlPointPart.Name,
        }
    end
    return controlPoints
end

local function refreshBeltSegments(controlPoints): { BeltSegment }
    local beltSegments = {}

    for _, point in controlPoints do
        local prevIndex = getPreviousIndex(point.Name)
        if not prevIndex then
            continue
        end
        local prevPoint = controlPoints["ControlPoint" .. prevIndex]
        local beltSegmentName = prevPoint.Name .. "-" .. point.Name

        beltSegments[beltSegmentName] = {
            Name = beltSegmentName,
            EndPoint = point,
            StartPoint = prevPoint,
        }
    end

    return beltSegments
end

function Conveyor(props: Props)
    local conveyorFolder: Model, setConveyorFolder: (Model) -> nil = React.useState(nil)
    local controlPoints: { ControlPoint }, setControlPoints: ({ ControlPoint }) -> nil = React.useState({})
    local midpointAdjustment: NumberValue, setMidpointAdjustment: (NumberValue) -> nil = React.useState(nil)
    local midpointValue: number, setMidpointValue: (number) -> nil = React.useState(nil)

    local children = {}

    React.useEffect(function()
        --Create a model to hold the control points

        local conveyorFolder: Folder = getOrCreateFolder(props.Name, Scene.getBeltInfoFolderForCurrentMap())
        local controlPointsFolder: Folder = Utilities.getValueAtPath(conveyorFolder, "ControlPoints")
        if controlPointsFolder and #controlPointsFolder:GetChildren() > 1 then
            controlPoints = refreshControlPoints(conveyorFolder)
        else
            getOrCreateFolder("ControlPoints", conveyorFolder)

            controlPoints["ControlPoint1"] = {}
            controlPoints["ControlPoint1"].Name = "ControlPoint1"
            controlPoints["ControlPoint1"].Position = props.StartPosition
            controlPoints["ControlPoint2"] = {}
            controlPoints["ControlPoint2"].Name = "ControlPoint2"
            controlPoints["ControlPoint2"].Position = props.EndPosition
        end

        setConveyorFolder(conveyorFolder)
        setControlPoints(controlPoints)

        --Create a value object to capture the conveyor midpoint adjustment.
        local midpointAdjustmentsFolder = getOrCreateFolder("MidpointAdjustments", conveyorFolder)
        midpointAdjustment = Scene.getMidpointAdjustment(props.Name)
        if not midpointAdjustment then
            midpointAdjustment = Instance.new("NumberValue")
            midpointAdjustment.Value = 0.5
            midpointAdjustment.Name = props.Name
            midpointAdjustment.Parent = midpointAdjustmentsFolder
        end
        setMidpointAdjustment(midpointAdjustment)
        setMidpointValue(midpointAdjustment.Value)

        local connection: RBXScriptConnection = midpointAdjustment.Changed:Connect(function(number)
            setMidpointValue(number)
        end)

        return function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end, {})

    React.useEffect(function()
        local keys: table = Dash.keys(controlPoints)
        table.sort(keys, function(a, b)
            return a < b
        end)

        if #keys > 1 then
            local startPoint = controlPoints[keys[1]]
            startPoint.Position = props.StartPosition
            local endPoint = controlPoints[keys[#keys]]
            endPoint.Position = props.EndPosition

            setControlPoints(table.clone(controlPoints))
        end
    end, {
        props.StartPosition.X,
        props.StartPosition.Z,
        props.EndPosition.X,
        props.EndPosition.Z,
    })

    local controlPointComponents = {}
    for _, point in controlPoints do
        controlPointComponents[point.Name] = ControlPoint({
            Name = point.Name,
            Conveyor = conveyorFolder,
            Position = point.Position,
            UpdatePosition = function(controlPointName: string, position: Vector3)
                local updatedControlPoints = table.clone(controlPoints)
                updatedControlPoints[controlPointName].Position = position
                setControlPoints(updatedControlPoints)
            end,
        })
    end

    local beltSegmentComponents = {}
    local beltSegments = refreshBeltSegments(controlPoints)
    for _, segment in beltSegments do
        beltSegmentComponents[segment.Name] = BeltSegment({
            Name = conveyorFolder.Name,
            StartPoint = table.clone(segment.StartPoint),
            EndPoint = table.clone(segment.EndPoint),
            MidpointAdjustment = midpointValue,
        })
    end

    children = Dash.join(controlPointComponents, beltSegmentComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(Conveyor, props)
end
