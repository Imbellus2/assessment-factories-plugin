local React = require(script.Parent.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)

type Props = {
    Text: string,
    LayoutOrder: number,
    OnActivate: () -> any,
}

local function TextItem(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 30),
    }, {
        label = React.createElement("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = props.Text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 1),

            [ReactRoblox.Event.Activated] = function()
                props.OnActivate()
            end,
        }),
    })
end

return function(props: Props)
    return React.createElement(TextItem, props)
end