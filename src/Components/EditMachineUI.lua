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

local SidePanel = require(script.Parent.SubComponents.SidePanel)

local Constants = require(script.Parent.Parent.Constants)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
-- local Manifest = require(script.Parent.Parent.Manifest)
local Dataset = require(script.Parent.Parent.Dataset)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
local Separator = require(script.Parent.SubComponents.Separator)
local ErrorText = require(script.Parent.SubComponents.ErrorText)
local Types = require(script.Parent.Parent.Types)
local Incrementer = require(script.Parent.Parent.Incrementer)
local InlineTextInput = require(script.Parent.SubComponents.InlineTextInput)
local FormatText = require(script.Parent.Parent.FormatText)
local TextItem = require(script.Parent.SubComponents.TextItem)
local InlineNumberInput = require(script.Parent.SubComponents.InlineNumberInput)
local LabeledAddButton = require(script.Parent.SubComponents.LabeledAddButton)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)
local ItemListItem = require(script.Parent.SubComponents.ItemListItem)
local Utilities = require(script.Parent.Parent.Packages.Utilities)
local RadioButtonGroup = require(script.Parent.SubComponents.RadioButtonGroup)

type Props = {
    AddMachineAnchor: any,
    CurrentMapIndex: number,
    Dataset: table,
    Machine: Types.Machine,
    MachineAnchor: Instance,
    OnClosePanel: any,
    OnAddInputMachine: (Types.Machine) -> nil,
    OnClickEditItem: (Types.Item) -> nil,
    OnRequirementItemHovered: () -> nil,
    UpdateDataset: any,
}

local MachineTypes = {
    purchaser = 1,
    maker = 2,
    makerSeller = 3,
    invalid = 0,
}

local function EditMachineUI(props: Props)
    local layoutOrder = Incrementer.new()

    local id, setMachineId = React.useState("") :: string
    local currentOutputCount, setCurrentOutputCount = React.useState(props.Machine.currentOutputCount)
    local machineTypeIndex, setMachineTypeIndex = React.useState(MachineTypes[props.Machine["type"]])

    local machine = props.Machine
    local machineType: string = props.Machine["type"]

    React.useEffect(function()
        setMachineTypeIndex(MachineTypes[props.Machine["type"]])
    end, { props.Machine["type"] })

    local showInputs = machineTypeIndex ~= 1
    local machineInputs = {}
    if showInputs and machine.sources then
        for i, sourceMachineId in machine.sources do
            local sourceMachine: Types.Machine = Dataset:getMachineFromId(sourceMachineId)
            table.insert(
                machineInputs,
                MachineListItem({
                    Machine = sourceMachine,
                    Label = sourceMachine.locName,
                    LayoutOrder = i,
                    OnActivated = function() end,
                    OnClickUp = function()
                        --
                    end,
                    OnClickDown = function()
                        --
                    end,
                    OnClickEdit = function()
                        --
                    end,
                    OnClickRemove = function(sourceToRemove)
                        Dataset:removeSourceFromMachine(machine, sourceToRemove)
                        props.UpdateDataset()
                    end,
                    OnHover = function(hoveredMachine: Types.Machine)
                        local anchor = hoveredMachine and Scene.getAnchorFromMachine(hoveredMachine)
                        props.OnHover(anchor)
                    end,

                    HideEditButton = true,
                })
            )
        end
    end

    local outputItems = {}
    if machine.outputs then
        for i, outputItem in machine.outputs do
            local item: Types.Item = props.Dataset.maps[props.CurrentMapIndex].items[outputItem]
            local validRequirements = Dataset:getValidRequirementsForItem(item)

            local itemMachineType = Dataset:getMachineTypeFromItemId(item.id)
            local showCost = (itemMachineType == Constants.None)
                or (itemMachineType == Constants.MachineTypes.purchaser)
            local showSalePrice = (itemMachineType == Constants.None)
                or (itemMachineType == Constants.MachineTypes.makerSeller)
            local hideRequirements = itemMachineType == Constants.MachineTypes.purchaser

            table.insert(
                outputItems,
                ItemListItem({
                    Item = item,
                    Label = item.locName.singular,
                    LayoutOrder = i,
                    Requirements = validRequirements,
                    Thumbnail = item.thumb,
                    ShowCost = showCost,
                    ShowSalePrice = showSalePrice,
                    OnClickUp = function()
                        --
                    end,
                    OnClickDown = function()
                        --
                    end,
                    OnClickEdit = function(itemToEdit: Types.Item)
                        props.OnClickEditItem(itemToEdit)
                    end,
                    OnClickRemove = function(itemToRemove: Types.Item)
                        Dataset:removeOutputFromMachine(props.Machine, itemToRemove)
                        props.UpdateDataset()
                    end,
                    OnActivated = function()
                        Dash.noop()
                    end,
                    OnRequirementCountChanged = function(value, requirement)
                        value = FormatText.numbersOnly(value)
                        if not value then
                            return
                        end
                        for _, changedRequirement in ipairs(item.requirements) do
                            if changedRequirement.itemId == requirement.itemId then
                                requirement.count = value
                            end
                        end
                        props.UpdateDataset()
                    end,
                    OnRequirementItemHovered = function(requirementItemId)
                        props.OnRequirementItemHovered(requirementItemId)
                    end,
                    OnSalePriceChanged = function(value)
                        value = FormatText.numbersOnly(value)
                        if not value then
                            return
                        end
                        if value == 0 then
                            item.value = nil
                        else
                            item.value = {
                                itemId = "currency",
                                count = value,
                            }
                        end
                        -- setItemSalePrice(value)
                        props.UpdateDataset()
                    end,
                    OnCostChanged = function(value)
                        value = FormatText.numbersOnly(value)
                        if not value then
                            return
                        end
                        if item.requirements then
                            for _, requirement in ipairs(item.requirements) do
                                if requirement.itemId == "currency" then
                                    requirement.count = value
                                end
                            end
                        end
                        -- setItemCost(value)
                        props.UpdateDataset()
                    end,
                })
            )
        end
    end

    local midpointAdjustments = {}
    local conveyorsConnected = {}
    if props.Machine.sources then
        for _, sourceId in props.Machine.sources do
            local otherMachine = Dataset:getMachineFromId(sourceId)
            local conveyorName: string = Scene.getConveyorBeltName(otherMachine, props.Machine)
            table.insert(conveyorsConnected, conveyorName)
        end
    end
    local machines = props.Dataset.maps[props.CurrentMapIndex].machines
    for _, otherMachine: Types.Machine in machines do
        if otherMachine.sources then
            for _, sourceId: string in otherMachine.sources do
                if sourceId == props.Machine.id then
                    local conveyorName: string = Scene.getConveyorBeltName(props.Machine, otherMachine)
                    table.insert(conveyorsConnected, conveyorName)
                end
            end
        end
    end
    if props.Machine["type"] == "purchaser" or props.Machine["type"] == "makerSeller" then
        table.insert(conveyorsConnected, Scene.getConveyorBeltName(props.Machine))
    end

    for _, conveyorName: string in conveyorsConnected do
        local midpoint: NumberValue = Scene.getMidpointAdjustment(conveyorName)
        local midpointValue = midpoint and midpoint.Value or 0.5
        table.insert(
            midpointAdjustments,
            InlineNumberInput({
                Value = midpointValue,
                LayoutOrder = layoutOrder:Increment() + 100,
                Label = "Conveyor",
                SubLabel = conveyorName,
                OnReset = function()
                    --The midpoint value object might not be created yet.
                    midpoint = Scene.getMidpointAdjustment(conveyorName)
                    midpoint.Value = 0.5
                end,
                OnHover = function(bool)
                    local hover = nil
                    if bool then
                        hover = Scene.getConveyorMeshFromName(conveyorName)
                    end
                    props.OnHover(hover)
                end,
                OnChanged = function(value)
                    if not tonumber(value) then
                        return
                    end
                    value = tonumber(value)
                    --The midpoint value object might not be created yet.
                    midpoint = Scene.getMidpointAdjustment(conveyorName)
                    midpoint.Value = value
                end,
            })
        )
    end

    local gapAmount = 16
    local children = {
        ID = TextItem({
            Text = "ID: " .. props.Machine.id,
            LayoutOrder = layoutOrder:Increment(),
            OnActivate = function(input)
                print(Dash.pretty(props.Machine, { multiline = true, indent = "\t", depth = 10 }))
            end,
        }),

        LocName = FishBloxComponents.TextInput({
            HideLabel = true,
            LayoutOrder = layoutOrder:Increment(),
            Placeholder = "Enter Localized Name",
            Size = UDim2.new(1, 0, 0, 50),
            Value = props.Machine.locName,
            --Events
            OnChanged = function(text)
                local newText = text
                --prevent the id from being empty
                if #text < 1 then
                    return
                end
                --Check for invalid characters
                --Auto update ID based on LocName
                local updated = Dataset:updateMachineId(props.Machine, FormatText.convertToIdText(newText))
                if updated then
                    props.Machine.locName = newText
                    setMachineId(props.Machine.id)
                    props.UpdateDataset()
                end
            end,
        }),

        MachineTypeButtons = RadioButtonGroup({
            ToggleIndex = machineTypeIndex,
            LayoutOrder = layoutOrder:Increment(),
            OnRadioButtonToggled = function(index)
                local newMachineType = nil
                for key, typeIndex in MachineTypes do
                    if typeIndex == index then
                        newMachineType = key
                    end
                end
                Dataset:setMachineType(props.Machine, newMachineType)
                -- setMachineTypeIndex(MachineTypes[newMachineType])
                props.UpdateDataset()
            end,
        }),

        Gap1 = showInputs and React.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, gapAmount),
            LayoutOrder = layoutOrder:Increment(),
        }),

        AddInputMachines = showInputs and LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Input Machines",

            OnActivated = function()
                props.OnAddInputMachine()
            end,
        }),

        InputMachines = showInputs and Column({
            Gaps = 8,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = layoutOrder:Increment(),
        }, machineInputs),

        Gap2 = React.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, gapAmount),
            LayoutOrder = layoutOrder:Increment(),
        }),

        AddOutputs = LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Outputs (Making)",

            OnActivated = function()
                props.OnAddOutput(machine)
            end,
        }),

        OutputItems = Column({
            Gaps = 12,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = layoutOrder:Increment(),
        }, outputItems),

        Gap3 = React.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, gapAmount),
            LayoutOrder = layoutOrder:Increment(),
        }),

        StartingOutput = InlineNumberInput({
            Value = props.Machine.currentOutputCount,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Starting Output",
            OnReset = function()
                Dataset:updateMachineProperty(
                    props.Machine,
                    "currentOutputCount",
                    Constants.Defaults.MachineDefaultOutput
                )
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)

                setCurrentOutputCount(value)
                Dataset:updateMachineProperty(props.Machine, "currentOutputCount", value)
                props.UpdateDataset()
            end,
        }),

        MinOutput = InlineNumberInput({
            Value = props.Machine.outputRange.min,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Min",
            OnReset = function()
                local defaultOutputRange = {
                    min = Constants.Defaults.MachineDefaultOutputRange.min,
                    max = props.Machine.outputRange.max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", defaultOutputRange)
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)
                local max = props.Machine.outputRange.max

                local newOutputRange = {
                    min = value,
                    max = max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", newOutputRange)

                props.UpdateDataset()
            end,
        }),

        MaxOutput = InlineNumberInput({
            Value = props.Machine.outputRange.max,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Max",
            OnReset = function()
                local defaultOutputRange = {
                    min = props.Machine.outputRange.min,
                    max = Constants.Defaults.MachineDefaultOutputRange.max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", defaultOutputRange)
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)
                local min = props.Machine.outputRange.min
                -- if value < min then
                --     value = min
                -- end
                local newOutputRange = {
                    min = min,
                    max = value,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", newOutputRange)
                -- if currentOutputCount > value then
                --     Dataset:updateMachineProperty(props.Machine, "currentStartingOutput", value)
                --     setCurrentOutputCount(value)
                -- end
                props.UpdateDataset()
            end,
        }),

        DefaultMaxStorage = InlineNumberInput({
            Value = props.Machine.defaultMaxStorage,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Storage",
            OnReset = function()
                Dataset:updateMachineProperty(
                    props.Machine,
                    "defaultMaxStorage",
                    Constants.Defaults.MachineDefaultMaxStorage
                )
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                value = FormatText.numbersOnly(value)
                if value < 1 then
                    value = 1
                end
                Dataset:updateMachineProperty(props.Machine, "defaultMaxStorage", value)
                props.UpdateDataset()
            end,
        }),

        DefaultProductionDelay = machineType == Constants.MachineTypes.maker and InlineNumberInput({
            LayoutOrder = layoutOrder:Increment(),
            Value = props.Machine.defaultProductionDelay,
            Label = "Delay",
            OnReset = function() end,
            OnChanged = function(value)
                value = FormatText.numbersOnly(value)
                if value < 0 then
                    value = 0
                end
                Dataset:updateMachineProperty(props.Machine, "defaultProductionDelay", value)
                props.UpdateDataset()
            end,
        }),

        Gap4 = React.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, gapAmount),
            LayoutOrder = layoutOrder:Increment(),
        }),
    }

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

    children = Dash.join(scrollingFrameChildren, children, midpointAdjustments)

    return React.createElement(React.Fragment, {}, {
        EditMachineUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Editing Machine",
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
                LayoutOrder = layoutOrder:Increment(),
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

return function(props: Props)
    return React.createElement(EditMachineUI, props)
end
