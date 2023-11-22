local Packages = script.Parent.Parent.Parent.Packages

local React = require(Packages.React)

local PathGenerator = require(script.Parent.Parent.Parent.PathGenerator)
local thickness = 1
local width = 2

type Props = {
    Parent:Model,
    Name:string,
    EndPoint:table,
    StartPoint:table,
}

function BeltSegment(props:Props)

    local beltPart, setBeltPart = React.useState(nil)
    local children = {}

    React.useEffect(function()

        local part = PathGenerator.GenerateBasicPath(props.StartPoint.Position, props.EndPoint.Position, width, thickness)
        if part then
            part.Parent = props.Parent
            setBeltPart(part)
        else
            print("Belt Segment part is invalid. Check to see if the segment length was too short.")
        end


    end, {})

    React.useEffect(function()
        if beltPart then
            beltPart:Destroy()

            local newPart = PathGenerator.GenerateBasicPath(props.StartPoint.Position, props.EndPoint.Position, width, thickness)
            newPart.Parent = props.Parent
            setBeltPart(newPart)
        end
    end, {props.StartPoint, props.EndPoint})

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(BeltSegment, props)
end