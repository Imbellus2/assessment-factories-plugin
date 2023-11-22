local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local ControlPoint = require(script.Parent.ControlPoint)
local BeltSegment = require(script.Parent.BeltSegment)

local getOrCreateFolder = require(script.Parent.Parent.Parent.Helpers.getOrCreateFolder)
local worldPositionToVector3 = require(script.Parent.Parent.Parent.Helpers.worldPositionToVector3)

local Types = require(script.Parent.Parent.Parent.Types)

type Props = {
    ClickRect:Rect,
	CornerRadius:number,
    Creating:boolean,
	Editing:boolean,
    Name:string,
	Subdivisions:number,
	Machine:Types.Machine,
	SourceMachine:Types.Machine
}

type ControlPoint = {
	Name:string,
	Position:Vector3,
}

type BeltSegment = {
	Name:string,
	StartPoint:ControlPoint,
	EndPoint:ControlPoint,
}

local function getControlPointIndex(name): string
	local _,suffix = name:find("ControlPoint")
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

local function refreshControlPoints(conveyor:Model): { ControlPoint }
	local controlPoints = {}
	local controlPointParts = conveyor.ControlPoints:GetChildren()
	table.sort(controlPointParts, function(a,b)
		return a.Name < b.Name
	end)
	for _,controlPointPart in controlPointParts do
		controlPoints[controlPointPart.Name] = {
			Position = controlPointPart.Position,
			Name = controlPointPart.Name,
		}
	end
	return controlPoints
end

local function refreshBeltSegments(controlPoints): { BeltSegment }
	local beltSegments = {}

	for _,point in controlPoints do
		local prevIndex = getPreviousIndex(point.Name)
		if not prevIndex then
			continue
		end
		local prevPoint = controlPoints["ControlPoint"..prevIndex]
		local beltSegmentName = prevPoint.Name.."-"..point.Name
	
		beltSegments[beltSegmentName] = {
			Name = beltSegmentName,
			EndPoint = point,
			StartPoint = prevPoint,
		}
	end

	return beltSegments
end

function Conveyor(props:Props)
    local conveyorModel: Model, setConveyorModel: (Model) -> nil = React.useState(nil)
    local controlPoints: {ControlPoint}, setControlPoints: ({ControlPoint}) -> nil = React.useState({})

	props.CornerRadius = props.CornerRadius or 0

	local children = {}

    React.useEffect(function()
        --Create a model to hold the control points
        local folder = getOrCreateFolder("ConveyorBelts", game.Workspace)
		local model:Model = folder:FindFirstChild(props.Name)
		if model then
			controlPoints = refreshControlPoints(model)
		else
			model = Instance.new("Model")
            model.Name = props.Name
            model.Parent = folder

			controlPoints["ControlPoint1"] = {}
			controlPoints["ControlPoint1"].Name = "ControlPoint1"
			-- controlPoints["ControlPoint1"].Position = Vector3.new(-10, 0, 25)
			controlPoints["ControlPoint1"].Position = worldPositionToVector3(props.Machine.worldPosition)
			controlPoints["ControlPoint2"] = {}
			controlPoints["ControlPoint2"].Name = "ControlPoint2"
			controlPoints["ControlPoint2"].Position = props.SourceMachine and worldPositionToVector3(props.SourceMachine.worldPosition) or Vector3.new(10, 0, -25)
        end

		local controlPointsFolder = model:FindFirstChild("ControlPoints")
		if not controlPointsFolder then
			controlPointsFolder = Instance.new("Folder")
			controlPointsFolder.Name = "ControlPoints"
			controlPointsFolder.Parent = model
		end

		local beltsFolder = model:FindFirstChild("BeltSegments")
		if not beltsFolder then
			beltsFolder = Instance.new("Folder")
			beltsFolder.Name = "BeltSegments"
			beltsFolder.Parent = model
		end

		setConveyorModel(model)
		setControlPoints(controlPoints)
		
    end, {})

	--Subdivide hook
	React.useEffect(function()
		if not conveyorModel then
			return
		end

		local newControlPoints = {}
		--Subdivide the conveyor belt.
		local keys:table = Dash.keys(controlPoints)
		table.sort(keys, function(a,b)
			return a < b
		end)

		local startPoint = table.clone(controlPoints[keys[1]])
		local endPoint = table.clone(controlPoints[keys[#keys]])

		local numPoints = 2 + props.Subdivisions
		endPoint.Name = "ControlPoint"..numPoints

		newControlPoints[startPoint.Name] = startPoint
		newControlPoints[endPoint.Name] = endPoint

		for i = 1, numPoints, 1 do
			newControlPoints["ControlPoint"..i] = {
				Name = "ControlPoint"..i,
				Position = startPoint.Position:Lerp(endPoint.Position, (i-1)/(numPoints-1))
			}
		end

		conveyorModel:FindFirstChild("BeltSegments"):ClearAllChildren()

		setControlPoints(newControlPoints)
		
	end, { props.Subdivisions })

    local controlPointComponents = {}
	for _,point in controlPoints do
		controlPointComponents[point.Name] = ControlPoint({
			Name = point.Name,
            Parent = conveyorModel.ControlPoints,
			PartRef = point.PartRef,
			Position = point.Position,
			UpdatePosition = function(controlPointName:string, position:Vector3)
				local updatedControlPoints = table.clone(controlPoints)
				updatedControlPoints[controlPointName].Position = position
				setControlPoints(updatedControlPoints)
			end
		})
	end

	local beltSegmentComponents = {}
	for _,segment in refreshBeltSegments(controlPoints) do
		beltSegmentComponents[segment.Name] = BeltSegment({
			CornerRadius = props.CornerRadius,
			Name = segment.Name,
			Parent = conveyorModel.BeltSegments,
			StartPoint = table.clone(segment.StartPoint),
			EndPoint = table.clone(segment.EndPoint),
		})
	end

	children = Dash.join(controlPointComponents, beltSegmentComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(Conveyor, props)
end