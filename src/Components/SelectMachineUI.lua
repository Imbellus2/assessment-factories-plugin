local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Dash = require(Packages.Dash)
local Block = FishBloxComponents.Block
local Row = FishBloxComponents.Row
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)
-- local Manifest = require(script.Parent.Parent.Manifest)
local Types = require(script.Parent.Parent.Types)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)
local Incrementer = require(script.Parent.Parent.Incrementer)
local LabeledAddButton = require(script.Parent.SubComponents.LabeledAddButton)

--use this to create a consistent layout order that plays nice with Roact
local index = 0
local incrementLayoutOrder = function()
    index = index + 1
    return index
end
type Props = {
    OnClick: () -> nil,
    OnClosePanel: () -> nil,
    OnNewInputMachineChosen: () -> nil,

    Machines: any,
    SelectedMachine: Types.Machine,
}

local function SelectMachineUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local layoutOrder = Incrementer.new()

    local scrollingFrameChildren = {
        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 80),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 8),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    local machineChoices = {}
    for i, machine in props.Machines do
        local ignoreMachine = false
        if machine.id == props.SelectedMachine.id then
            ignoreMachine = true
        end
        if props.SelectedMachine.sources then
            for _, sourceId in props.SelectedMachine.sources do
                if sourceId == machine.id then
                    ignoreMachine = true
                end
            end
        end
        if ignoreMachine then
            continue
        end

        table.insert(
            machineChoices,
            MachineListItem({
                Label = machine.locName,
                LayoutOrder = i,
                OnActivated = function(machineId)
                    Dataset:addSourceToMachine(props.SelectedMachine, machineId)
                    props.OnNewInputMachineChosen()
                end,
                Machine = machine,

                OnClickUp = Dash.noop(),
                OnClickDown = Dash.noop(),
                OnClickEdit = Dash.noop(),
                OnClickRemove = Dash.noop(),
                OnHover = function(hoveredMachine: Types.Machine)
                    local anchor = hoveredMachine and Scene.getAnchorFromMachine(hoveredMachine)
                    props.OnHover(anchor)
                end,

                HideArrows = true,
                HideEditButton = true,
                HideRemoveButton = true,
            })
        )
    end

    scrollingFrameChildren = Dash.join(scrollingFrameChildren, machineChoices)

    local children = {

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
            }, scrollingFrameChildren),
        }),
    }

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Gaps = 12,
            Title = "Select Machine",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props: Props)
    return React.createElement(SelectMachineUI, props)
end
