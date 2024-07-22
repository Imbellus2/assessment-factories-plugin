local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local Types = require(script.Parent.Parent.Parent.Types)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)
local ImageManifest = require(script.Parent.Parent.Parent.ImageManifest)
local FishBloxComponents = FishBlox.Components

type Props = {
    Label: string,
    Thumbnail: string,
    OnActivated: () -> nil,
}

local function InlineThumbnailSelect(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 150),
        Size = UDim2.new(1, 0, 0, 100),
        LayoutOrder = props.LayoutOrder,
    }, {
        thumbnail = React.createElement("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 100, 1, 0),
        }, {
            uIStroke = React.createElement("UIStroke", {
                Color = Color3.fromRGB(79, 159, 243),
                Thickness = 2,
            }),

            uICorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),

            imageLabel = React.createElement("ImageButton", {
                Image = ImageManifest.getImage(props.Thumbnail),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                [ReactRoblox.Event.Activated] = function()
                    props.OnActivated()
                end,
            }, {
                uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
            }),

            uIPadding = React.createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        }),

        label = React.createElement("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = props.Label,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
        }),
    })
end

return function(props: Props)
    return React.createElement(InlineThumbnailSelect, props)
end
