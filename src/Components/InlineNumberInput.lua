local React = require(script.Parent.Parent.Packages.React)
local Packages = script.Parent.Parent.Packages
local FishBlox = require(Packages.FishBlox)
local ReactRoblox = require(script.Parent.Parent.Packages.ReactRoblox)
local FishBloxComponents = FishBlox.Components

type Props = {
    Label: string,
    LayoutOrder: number,
    Value: string,
    OnReset: () -> nil,
    OnChanged: () -> number,
}

local function InlineNumberInput(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        textInput = React.createElement("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 100, 1, 0),
        }, {
            input = FishBloxComponents.TextInput({
                Value = props.Value,
                Size = UDim2.new(1, 0, 0, 50),
                HideLabel = true,
                MultiLine = false,
                OnChanged = function(value)
                    props.OnChanged(value)
                end,
            }),
            -- input = React.createElement("TextBox", {
            --     FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            --     PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
            --     PlaceholderText = "0",
            --     Text = "0",
            --     TextColor3 = Color3.fromRGB(255, 255, 255),
            --     TextSize = 16,
            --     TextXAlignment = Enum.TextXAlignment.Right,
            --     BackgroundTransparency = 1,
            --     Size = UDim2.fromScale(1, 1),
            -- }, {
            --     uICorner = React.createElement("UICorner"),
            -- }),

            -- uIStroke = React.createElement("UIStroke", {
            --     Color = Color3.fromRGB(79, 159, 243),
            --     Thickness = 2,
            -- }),

            -- uICorner1 = React.createElement("UICorner", {
            --     CornerRadius = UDim.new(0, 6),
            -- }),

            -- uIPadding = React.createElement("UIPadding", {
            --     PaddingLeft = UDim.new(0, 8),
            --     PaddingRight = UDim.new(0, 8),
            -- }),
        }),

        label = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.6, 1),
        }, {
            label1 = React.createElement("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                Text = props.Label,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
            }),

            imageButton = React.createElement("ImageButton", {
                Image = "rbxassetid://15626193282",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(15, 15),
                [ReactRoblox.Event.Activated] = function()
                    props.OnReset()
                end,
            }, {
                -- uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
            }),

            uIListLayout = React.createElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
        }),
    })
end

return function(props: Props)
    return React.createElement(InlineNumberInput, props)
end
