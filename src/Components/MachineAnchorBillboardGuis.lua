local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local Root = script.Parent.Parent
local Packages = Root.Packages

local Utilities = require(Packages.Utilities)
local Dash = require(Packages.Dash)

local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Column = FishBloxComponents.Column
local Text = FishBloxComponents.Text
local Icon = FishBloxComponents.Icon
local Row = FishBloxComponents.Row

local Constants = require(script.Parent.Parent.Constants)
local Dataset = require(script.Parent.Parent.Dataset)
local Panels = Constants.Panels
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Types = require(script.Parent.Parent.Types)
local ImageManifest = require(script.Parent.Parent.ImageManifest)

type Props = {
    ImageManifest: table,
    Items: table,
    HighlightedAnchor: Model,
    HighlightedRequirementItem: string,
}

local function MachineAnchorBillboardGuis(props: Props)
    local billboardGuis = {}
    for _, machineAnchor in Scene.getMachineAnchors() do
        local machine = Dataset:getMachineFromMachineAnchor(machineAnchor)
        if machine then
            local duplicateCoordinatesExist = Dataset:duplicateCoordinatesExist(machine.coordinates)
            local machineIsInvalid = machine["type"] == Constants.MachineTypes.invalid
            local outputs = machine["outputs"]
            local icons = {}
            if outputs then
                for _, output in outputs do
                    local item: Types.Item = props.Items[output]
                    local image = item["thumb"]
                    local imageSize = UDim2.fromOffset(50, 50)
                    if item.id == props.HighlightedRequirementItem then
                        imageSize = UDim2.fromOffset(70, 70)
                    end
                    table.insert(
                        icons,
                        React.createElement("ImageLabel", {
                            Size = imageSize,
                            BackgroundTransparency = 1,
                            -- Image = Manifest.images[image] or "rbxassetid://7553285523",
                            -- Image = props.ImageManifest.images[image],
                            Image = ImageManifest.getImage(image),
                            -- Image = manifest.images[image],
                        })
                    )
                end
            end

            local outputsString = ""
            for i, output in machine["outputs"] do
                local separator = i > 1 and ", " or ""
                outputsString = outputsString .. separator .. output
            end
            add(
                billboardGuis,
                React.createElement("BillboardGui", {
                    Adornee = machineAnchor,
                    AlwaysOnTop = true,
                    Size = UDim2.new(0, 150, 0, 100),
                }, {
                    Column = Column({
                        AutomaticSize = Enum.AutomaticSize.Y,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }, {
                        Row = Row({
                            Gaps = 4,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            LayoutOrder = 0,
                            Size = UDim2.new(1, 0, 0, 25),
                        }, icons),
                        Text1 = Text({
                            Color = Color3.new(1, 1, 1),
                            FontSize = 16,
                            LayoutOrder = 1,
                            Text = machine.locName,
                        }),
                        -- Text2 = Text({
                        --     Color = machineIsInvalid and Color3.new(1, 0, 0) or Color3.new(1, 1, 1),
                        --     FontSize = 16,
                        --     LayoutOrder = 2,
                        --     Text = "Makes: " .. outputsString,
                        -- }),
                        Text3 = Text({
                            Color = duplicateCoordinatesExist and Color3.new(1, 0, 0) or Color3.new(1, 1, 1),
                            FontSize = 16,
                            LayoutOrder = 3,
                            Text = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")",
                        }),
                    }),
                    HighlightBox = React.createElement("Highlight", {
                        Adornee = props.HighlightedAnchor,
                        FillColor = Color3.fromRGB(0, 255, 21),
                        FillTransparency = 0.25,
                    }),
                })
            )
        end
    end

    return React.createElement("Folder", {
        ["Name"] = "BillboardGUIs",
    }, billboardGuis)
end

return function(props: Props)
    return React.createElement(MachineAnchorBillboardGuis, props)
end
