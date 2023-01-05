local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

return function(props)
    local isBold = (props.Bold == nil) and true or props.Bold
    return Text({
        Bold = true,
        Color = Color3.new(1,1,1),
        FontSize = 24,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        LayoutOrder = props.LayoutOrder,
        RichText = true,
        Text = props.Label or "EMPTY",
    })
end