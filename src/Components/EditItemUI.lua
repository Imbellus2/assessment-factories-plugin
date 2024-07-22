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
local Row = FishBloxComponents.Row
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SelectFromListModal = require(script.Parent.Modals.SelectFromListModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
-- local Manifest = require(script.Parent.Parent.Manifest)
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
local getTemplateItem = require(script.Parent.Parent.Helpers.getTemplateItem)
type Props = {
    CurrentMapIndex: number,
    Dataset: table,
    Item: Types.Item,
    OnClosePanel: any,
    OnDeleteRequirementClicked: any,
    OnClickThumbnail: () -> nil,
    OnAddRequirement: (Types.Item) -> nil,
    SetNewItemAsSelectedItem: (Types.Item) -> nil,
    UpdateDataset: () -> nil,
}

local function EditItemUI(props: Props)
    local itemId, setItemId = React.useState(props.Item.id)
    -- local itemCost, setItemCost = React.useState(nil) --Item has a "requirement" of type "currency"
    -- local itemSalePrice, setItemSalePrice = React.useState(nil) --Item has a "value"
    local numRequirements, setNumRequirements =
        React.useState(props.Item.requirements and #props.Item.requirements or 0)

    local layoutOrder = Incrementer.new()
    local items = Dataset:getValidItems(false)
    local item: Types.Item = props.Dataset.maps[props.CurrentMapIndex].items[itemId]
    local itemSalePrice = item.value and item.value.count or 0

    local itemCost = 0
    if item.requirements then
        for _, requirement in item.requirements do
            if requirement.itemId == "currency" then
                itemCost = requirement.count
                -- setItemCost(itemCost)
            end
        end
    end

    -- if not itemCost then
    --     if item.requirements then
    --         for _, requirement: Types.RequirementItem in item.requirements do
    --             if requirement.itemId == "currency" then
    --                 itemCost = requirement.count
    --             end
    --         end
    --     else
    --         item.requirements = {
    --             {
    --                 itemId = "currency",
    --                 count = 0,
    --             },
    --         }
    --     end
    -- end
    -- if not itemSalePrice then
    --     if not item.value then
    --         item.value = { itemId = "currency", count = 0 }
    --     end
    --     itemSalePrice = item.value.count
    -- end

    local requirementItems = {}

    if item.requirements then
        for _, requirement in item.requirements do
            if requirement.itemId == "currency" or requirement.itemId == "none" then
                continue
            end
            local requirementItem = items[requirement.itemId]
            table.insert(
                requirementItems,
                ItemListItem({
                    HideArrows = true,
                    HideEditButton = true,
                    Item = requirementItem,
                    Label = requirementItem.locName.singular,
                    LayoutOrder = layoutOrder:Increment() + 100,
                    Thumbnail = requirementItem.thumb,
                    RequirementCount = requirement.count,
                    OnRequirementCountChanged = function(value)
                        for _, changedRequirement in ipairs(item.requirements) do
                            if changedRequirement.itemId == requirement.itemId then
                                requirement.count = value
                            end
                        end
                        props.UpdateDataset()
                    end,
                    OnActivated = function() end,
                    OnClickUp = function() end,
                    OnClickDown = function() end,
                    OnClickEdit = function() end,
                    OnClickRemove = function()
                        Dataset:removeRequirementFromItem(item, requirement.itemId)
                        setNumRequirements(#item.requirements)
                        props.UpdateDataset()
                    end,
                    OnHover = function() end,
                    OnCostChanged = function() end,
                    OnSalePriceChanged = function() end,
                })
            )
        end
    end

    local machineType = Dataset:getMachineTypeFromItemId(item.id)
    local showCost = (machineType == Constants.None) or (machineType == Constants.MachineTypes.purchaser)
    local showSalePrice = (machineType == Constants.None) or (machineType == Constants.MachineTypes.makerSeller)
    local hideRequirements = machineType == Constants.MachineTypes.purchaser

    local children = {
        ID = TextItem({
            Text = "ID: " .. item.id,
            LayoutOrder = layoutOrder:Increment(),
            OnActivate = function(input)
                print(Dash.pretty(item, { multiline = true, indent = "\t", depth = 10 }))
            end,
        }),
        LocNameSingularLabel = TextItem({
            Text = "LocName Singular:",
            LayoutOrder = layoutOrder:Increment(),
        }),
        LocNameSingular = FishBloxComponents.TextInput({
            HideLabel = true,
            LayoutOrder = layoutOrder:Increment(),
            Placeholder = "Enter Localized Name",
            Size = UDim2.new(1, 0, 0, 50),
            Value = item.locName.singular,

            OnChanged = function(text)
                local newText = text
                --prevent the id from being empty
                if #text < 1 then
                    return
                end
                --Check for invalid characters
                --Auto update ID based on LocName
                local updated, newItem = Dataset:updateItemId(item, FormatText.convertToIdText(newText))
                if updated then
                    newItem.locName.singular = newText
                    setItemId(newItem.id)
                    props.SetNewItemAsSelectedItem(newItem)
                    props.UpdateDataset()
                end
            end,
        }),

        LocNamePluralLabel = TextItem({
            Text = "LocName Plural:",
            LayoutOrder = layoutOrder:Increment(),
        }),
        LocNamePlural = FishBloxComponents.TextInput({
            HideLabel = true,
            LayoutOrder = layoutOrder:Increment(),
            Placeholder = "Enter Localized Name",
            Size = UDim2.new(1, 0, 0, 50),
            Value = item.locName.plural,

            OnChanged = function(text)
                local newText = text
                --prevent the id from being empty
                if #text < 1 then
                    return
                end
                --Check for invalid characters
                --Auto update ID based on LocName
                item.locName.plural = newText
                props.UpdateDataset()
            end,
        }),

        ThumbnailSelect = InlineThumbnailSelect({
            Label = "Thumbnail",
            LayoutOrder = layoutOrder:Increment(),
            Thumbnail = item.thumb,
            OnActivated = function()
                props.OnClickThumbnail()
            end,
        }),

        SalePrice = showSalePrice
                and InlineNumberInput({
                    LayoutOrder = layoutOrder:Increment(),
                    Label = "Sale Price",
                    Value = itemSalePrice,

                    OnReset = function() end,
                    OnChanged = function(value)
                        value = tonumber(FormatText.numbersOnly(value))
                        if value then
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
                        end
                    end,
                })
            or TextItem({
                Text = "Sale Price: An item will only have a sale price if it is the output of a makerSeller.",
                TextSize = 12,
                LayoutOrder = layoutOrder:Increment(),
            }),

        Cost = showCost
                and InlineNumberInput({
                    LayoutOrder = layoutOrder:Increment(),
                    Label = "Cost",
                    Value = itemCost,

                    OnReset = function()
                        item.requirements = getTemplateItem().requirements
                        props.UpdateDataset()
                    end,
                    OnChanged = function(value)
                        value = FormatText.numbersOnly(value)
                        if tonumber(value) then
                            for _, requirement in ipairs(item.requirements) do
                                if requirement.itemId == "currency" then
                                    requirement.count = value
                                end
                            end
                            -- setItemCost(value)
                            props.UpdateDataset()
                        end
                    end,
                })
            or TextItem({
                Text = "Cost: An item only has a cost if it is the output of a purchaser.",
                TextSize = 12,
                LayoutOrder = layoutOrder:Increment(),
            }),

        AddRequirements = not hideRequirements and LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Requirements",

            OnActivated = function()
                props.OnAddRequirement(item)
            end,
        }) or TextItem({
            Text = "Requirements: An item outputted by a purchaser should not have any requirements.",
            TextSize = 12,
            LayoutOrder = layoutOrder:Increment(),
        }),

        RequirementItems = Column({
            Gaps = 8,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = layoutOrder:Increment(),
        }, requirementItems),
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

    children = Dash.join(scrollingFrameChildren, children)

    return React.createElement(React.Fragment, {}, {
        EditItemUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Editing Item",
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

    -- return React.createElement(React.Fragment, {}, {
    -- EditMachineUI = SidePanel({
    --     OnClosePanel = props.OnClosePanel,
    --     ShowClose = true,
    --     Title = "Editing Item",
    -- }, children),

    -- })
end

return function(props)
    return React.createElement(EditItemUI, props)
end
