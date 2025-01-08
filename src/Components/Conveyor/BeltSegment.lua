local Packages = script.Parent.Parent.Parent.Packages

local React = require(Packages.React)

local PathGenerator = require(script.Parent.Parent.Parent.PathGenerator)
local getOrCreateFolder = require(script.Parent.Parent.Parent.Helpers.getOrCreateFolder)
local Scene = require(script.Parent.Parent.Parent.Scene)
local thickness = 0.5
local width = 1.1
local desiredRadius = 4

type Props = {
    Name: string,
    EndPoint: table,
    StartPoint: table,
    MidpointAdjustment: number,
}

function BeltSegment(props: Props)
    local beltPart, setBeltPart = React.useState(nil)
    local children = {}
    local beltsFolder = Scene.getBeltPartsFolder()
    local conveyorFolder: Folder = Scene.getConveyorFolder(props.Name)

    React.useEffect(function()
        for _, child in beltsFolder:GetChildren() do
            if child.Name == props.Name then
                child:Destroy()
            end
        end
        local part = PathGenerator.GenerateBasicPath(
            props.StartPoint.Position,
            props.EndPoint.Position,
            props.MidpointAdjustment,
            width,
            thickness,
            desiredRadius,
            conveyorFolder
        )
        if part then
            part.Name = props.Name
            part.Parent = beltsFolder
            setBeltPart(part)
        else
            print("Belt Segment part is invalid. Check to see if the segment length was too short.")
        end

        return function()
            --get the belt part by the name of the belt segment
            local beltSegmentToDestroy = beltsFolder:FindFirstChild(props.Name)
            if beltSegmentToDestroy then
                beltSegmentToDestroy:Destroy()
            else
                print("Error! Could not find Belt Segment to destroy!")
            end
            local nodeFolder = game.Workspace.BeltData:FindFirstChild(props.Name)
            if nodeFolder then
                nodeFolder:Destroy()
            else
                print("Error! Could not find Belt Data folder to destroy!")
            end
        end
    end, {})

    React.useEffect(function()
        if not conveyorFolder then
            return
        end

        if beltPart then
            beltPart:Destroy()

            local newPart = PathGenerator.GenerateBasicPath(
                props.StartPoint.Position,
                props.EndPoint.Position,
                props.MidpointAdjustment,
                width,
                thickness,
                desiredRadius,
                conveyorFolder
            )
            newPart.Name = props.Name
            newPart.Parent = beltsFolder
            setBeltPart(newPart)
        end
    end, {
        props.StartPoint.Position.X,
        props.StartPoint.Position.Z,
        props.EndPoint.Position.X,
        props.EndPoint.Position.Z,
        props.MidpointAdjustment,
    })

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(BeltSegment, props)
end
