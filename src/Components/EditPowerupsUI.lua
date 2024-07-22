local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SelectFromListModal = require(script.Parent.Modals.SelectFromListModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Separator = require(script.Parent.SubComponents.Separator)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
local FormatText = require(script.Parent.Parent.FormatText)
local TextItem = require(script.Parent.SubComponents.TextItem)
local Incrementer = require(script.Parent.Parent.Incrementer)
local InlineThumbnailSelect = require(script.Parent.SubComponents.InlineThumbnailSelect)
local Types = require(script.Parent.Parent.Types)
local InlineNumberInput = require(script.Parent.SubComponents.InlineNumberInput)
local LabeledAddButton = require(script.Parent.SubComponents.LabeledAddButton)
local ItemListItem = require(script.Parent.SubComponents.ItemListItem)
local Constants = require(script.Parent.Parent.Constants)
local ImageManifest = require(script.Parent.Parent.ImageManifest)

type Props = {
    Powerups: { Types.Powerup },
    UpdateDataset: () -> nil,
}

local function EditPowerupsUI(props: Props)
    local layoutOrder = Incrementer.new()
    local children = {}

    local scrollingFrameChildren = {
        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, layoutOrder:Increment() * 10),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 8),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    for i, powerup in ipairs(props.Powerups) do
        children[powerup.id .. "-" .. i] = FishBloxComponents.Column({
            LayoutOrder = layoutOrder:Increment(),
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
        }, {
            TitleRow = FishBloxComponents.Row({
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
            }, {
                Thumb = React.createElement("ImageLabel", {
                    LayoutOrder = layoutOrder:Increment(),
                    Size = UDim2.new(0, 40, 0, 40),
                    Image = ImageManifest.getImage(powerup.thumb),
                    BackgroundTransparency = 1,
                }, {}),

                ID = TextItem({
                    Text = powerup.locName,
                    LayoutOrder = layoutOrder:Increment(),
                    OnActivate = function(input)
                        print(Dash.pretty(powerup, { multiline = true, indent = "\t", depth = 10 }))
                    end,
                }),
                -- Title = FishBloxComponents.Text({
                --     LayoutOrder = layoutOrder:Increment(),
                --     Text = powerup.locName,
                --     FontSize = 24,
                --     Bold = true,
                --     TextColor3 = Color3.fromRGB(255, 255, 255),
                --     Size = UDim2.new(0, 100, 0, 40),
                --     TextXAlignment = Enum.TextXAlignment.Left,
                --     TextYAlignment = Enum.TextYAlignment.Center,
                -- }),
            }),

            Cost = InlineNumberInput({
                LayoutOrder = layoutOrder:Increment(),
                Label = "Cost",
                Value = powerup.cost.count,

                OnReset = function() end,
                OnChanged = function(value)
                    value = FormatText.numbersOnly(value)
                    powerup.cost.count = value
                    props.UpdateDataset()
                end,
            }) or TextItem({
                Text = "Cost: An item only has a cost if it is the output of a purchaser.",
                TextSize = 12,
                LayoutOrder = layoutOrder:Increment(),
            }),

            Gap = React.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = layoutOrder:Increment(),
            }),
        })
    end

    children = Dash.join(scrollingFrameChildren, children)

    return React.createElement(React.Fragment, {}, {
        EditPowerupsUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Edit Powerups",
        }, {
            ScrollingList = React.createElement("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 4,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                VerticalScrollBarInset = Enum.ScrollBarInset.Always,
                Active = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
            }, {
                frame = React.createElement("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                }, children),
            }),
        }),
    })
end

return function(props)
    return React.createElement(EditPowerupsUI, props)
end
