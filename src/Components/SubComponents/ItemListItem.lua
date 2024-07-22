local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Types = require(script.Parent.Parent.Parent.Types)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)
local TextItem = require(script.Parent.TextItem)
local Dataset = require(script.Parent.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Parent.Scene)
local InlineNumberInput = require(script.Parent.InlineNumberInput)
local Incrementer = require(script.Parent.Parent.Parent.Incrementer)
local FormatText = require(script.Parent.Parent.Parent.FormatText)
local SmallLabel = require(script.Parent.SmallLabel)
local ImageManifest = require(script.Parent.Parent.Parent.ImageManifest)
local FishBloxComponents = FishBlox.Components

type Props = {
    HideArrows: boolean,
    HideEditButton: boolean,
    HideDeleteButton: boolean,
    Item: Types.Item,
    Label: string,
    RequirementCount: number,
    Requirements: table,
    LayoutOrder: number,
    Thumbnail: string,
    Unavailable: boolean,
    OnActivated: any,
    OnClickUp: () -> nil,
    OnClickDown: () -> nil,
    OnClickEdit: () -> nil,
    OnClickRemove: () -> nil,
    OnHover: () -> nil,
    OnRequirementCountChanged: () -> nil,
    OnRequirementItemHovered: () -> nil,
    OnSalePriceChanged: () -> nil,
    OnCostChanged: () -> nil,
    ShowCost: boolean,
    ShowSalePrice: boolean,
}

function Requirement(requirement: table, layoutOrder: number, requirementCallback: () -> nil, hoverCallback: () -> nil)
    local itemId = requirement.itemId
    local item = Dataset:getItemFromId(itemId)
    local itemLocName = item.locName.singular
    local thumb = item.thumb
    local count = requirement.count
    return React.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        Size = UDim2.new(1, 0, 0, 64),
        [ReactRoblox.Event.MouseEnter] = function()
            hoverCallback(requirement.itemId)
        end,
        [ReactRoblox.Event.MouseLeave] = function()
            hoverCallback(nil)
        end,
    }, {
        uICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),

        uIStroke = React.createElement("UIStroke", {
            Color = Color3.fromRGB(243, 243, 243),
            Thickness = 2,
            Transparency = 0.85,
        }),

        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
        }),

        labels = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
        }, {
            uIListLayout = React.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            imageLabel = React.createElement("ImageLabel", {
                Image = ImageManifest.getImage(thumb),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 35),
            }, {
                uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
            }),

            label = React.createElement("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                Text = itemLocName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.None,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Position = UDim2.new(0.414, 60, 0, 0),
                Size = UDim2.new(0, 80, 1, 0),
            }),
        }),
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
                Value = count,
                Size = UDim2.new(1, 0, 0, 50),
                HideLabel = true,
                MultiLine = false,
                OnChanged = function(value)
                    requirementCallback(value)
                end,
            }),
        }),

        -- textInput = React.createElement("Frame", {
        --     AnchorPoint = Vector2.new(1, 0),
        --     BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        --     BackgroundTransparency = 1,
        --     BorderColor3 = Color3.fromRGB(0, 0, 0),
        --     BorderSizePixel = 0,
        --     Position = UDim2.fromScale(1, 0),
        --     Size = UDim2.new(0, 70, 1, 0),
        -- }, {

        --     uIStroke1 = React.createElement("UIStroke", {
        --         Color = Color3.fromRGB(79, 159, 243),
        --         Thickness = 2,
        --     }),

        --     uICorner2 = React.createElement("UICorner", {
        --         CornerRadius = UDim.new(0, 6),
        --     }),

        --     uIPadding1 = React.createElement("UIPadding", {
        --         PaddingLeft = UDim.new(0, 8),
        --         PaddingRight = UDim.new(0, 8),
        --     }),
        -- }),
    })
end

function ItemListItem(props: Props)
    local hovered, setHovered = React.useState(false)
    local requirementCount, setRequirementCount = React.useState(props.RequirementCount)

    local layoutOrder = Incrementer.new()

    local showRequirements = props.Requirements and #props.Requirements > 0

    local showHoverButtons = true
    if props.Unavailable then
        showHoverButtons = false
    else
        showHoverButtons = hovered
    end

    local requirements = {}
    if showRequirements then
        table.insert(
            requirements,
            SmallLabel({
                Bold = false,
                Label = "Needs:",
                LayoutOrder = layoutOrder:Increment() + 10,
                FontSize = 18,
            })
        )
        for _, requirement in props.Requirements do
            table.insert(
                requirements,
                Requirement(requirement, layoutOrder:Increment() + 10, function(value)
                    value = FormatText.numbersOnly(value)
                    props.OnRequirementCountChanged(value, requirement)
                end, function(value)
                    props.OnRequirementItemHovered(value)
                end)
            )
        end
    end

    local itemCost = 0
    if props.Item.requirements then
        for _, requirement in props.Item.requirements do
            if requirement.itemId == "currency" then
                itemCost = requirement.count
            end
        end
    end
    local itemSalePrice = props.Item.value and props.Item.value.count or 0

    local mainLabelUDim2 = UDim2.new(0, 200, 1, 0)
    if showHoverButtons then
        mainLabelUDim2 = UDim2.new(0, 100, 1, 0)
    end

    return React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = props.Unavailable and 1 or (hovered and 0.93 or 0.95),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        LayoutOrder = props.LayoutOrder,
        [ReactRoblox.Event.MouseEnter] = function()
            if props.Unavailable then
                local anchor = nil
                local machineWithOutput: Types.Machine = Dataset:getMachineFromOutputItem(props.Item)
                if machineWithOutput then
                    anchor = Scene.getAnchorFromMachine(machineWithOutput)
                end
                props.OnHover(anchor)
            end
            setHovered(true)
        end,
        [ReactRoblox.Event.MouseLeave] = function()
            if props.Unavailable then
                props.OnHover(nil)
            end
            setHovered(false)
        end,
    }, {
        uICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),

        uIStroke = React.createElement("UIStroke", {
            Color = Color3.fromRGB(243, 243, 243),
            Thickness = 2,
            Transparency = props.Unavailable and 0.95 or 0.85,
        }),
        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
        }),

        Column = FishBloxComponents.Column({
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 1),
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Gaps = 12,
        }, {
            MainFrame = React.createElement("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                LayoutOrder = layoutOrder:Increment(),
            }, {

                HoverButtons = showHoverButtons
                    and React.createElement("ImageButton", {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 50),
                        [ReactRoblox.Event.Activated] = function()
                            props.OnActivated(props.Item)
                        end,
                    }, {
                        uIPadding = React.createElement("UIPadding", {
                            PaddingBottom = UDim.new(0, 4),
                            PaddingLeft = UDim.new(0, 8),
                            PaddingRight = UDim.new(0, 8),
                            PaddingTop = UDim.new(0, 4),
                        }),
                        uIListLayout = React.createElement("UIListLayout", {
                            Padding = UDim.new(0, 12),
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                        }),

                        delete = not props.HideDeleteButton
                            and React.createElement("Frame", {
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 2,
                                Size = UDim2.fromOffset(25, 30),
                            }, {
                                imageLabel = React.createElement("ImageButton", {
                                    Image = "rbxassetid://6990919691",
                                    ImageColor3 = Color3.fromRGB(79, 159, 243),
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    Size = UDim2.fromOffset(15, 15),

                                    [ReactRoblox.Event.Activated] = function()
                                        props.OnClickRemove(props.Item)
                                    end,
                                }, {
                                    uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
                                }),
                            }),

                        edit = not props.HideEditButton
                            and React.createElement("Frame", {
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromOffset(25, 30),
                                LayoutOrder = 1,
                            }, {
                                imageLabel1 = React.createElement("ImageButton", {
                                    Image = "rbxassetid://15627733392",
                                    ImageColor3 = Color3.fromRGB(79, 159, 243),
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    Size = UDim2.fromOffset(15, 20),

                                    [ReactRoblox.Event.Activated] = function()
                                        props.OnClickEdit(props.Item)
                                    end,
                                }, {
                                    uIAspectRatioConstraint1 = React.createElement("UIAspectRatioConstraint", {
                                        AspectRatio = 0.74,
                                    }),
                                }),
                            }),
                    }),

                Frame = React.createElement("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 50),
                }, {

                    imageLabel = React.createElement("ImageLabel", {
                        Image = ImageManifest.getImage(props.Thumbnail),
                        ImageTransparency = props.Unavailable and 0.6 or 0,
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.new(1, 0, 0, 50),
                    }, {
                        uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
                    }),

                    uIListLayout = React.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),
                    label = React.createElement("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                        Text = props.Label,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 16,
                        TextTransparency = props.Unavailable and 0.6 or 0,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextWrapped = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AnchorPoint = Vector2.new(1, 0),
                        -- AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Position = UDim2.new(0.781, 60, 0, 0),
                        Size = mainLabelUDim2,
                    }),
                }),
            }),

            Count = requirementCount and InlineNumberInput({
                LayoutOrder = layoutOrder:Increment(),
                Label = "Count",
                Value = requirementCount,
                OnChanged = function(value)
                    value = FormatText.numbersOnly(value)

                    setRequirementCount(value)
                    props.OnRequirementCountChanged(value)
                end,
                OnReset = function()
                    setRequirementCount(5)
                    props.OnRequirementCountChanged(5)
                end,
            }),

            SalePrice = props.ShowSalePrice and FishBloxComponents.Block({
                Size = UDim2.new(1, 0, 0, 50),
                PaddingLeft = 8,
                LayoutOrder = layoutOrder:Increment(),
            }, {
                InlineNumberInput({
                    LayoutOrder = layoutOrder:Increment(),
                    Label = "Sale Price",
                    Value = itemSalePrice,

                    OnReset = nil,
                    OnChanged = function(value)
                        value = FormatText.numbersOnly(value)
                        props.OnSalePriceChanged(value)
                    end,
                }),
            }),

            Cost = props.ShowCost and FishBloxComponents.Block({
                Size = UDim2.new(1, 0, 0, 50),
                PaddingLeft = 8,
                LayoutOrder = layoutOrder:Increment(),
            }, {
                InlineNumberInput({

                    Label = "Cost",
                    Value = itemCost,
                    OnReset = nil,
                    OnChanged = function(value)
                        value = FormatText.numbersOnly(value)
                        props.OnCostChanged(value)
                    end,
                }),
            }),

            RequirementColumn = #requirements > 0 and FishBloxComponents.Column({
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.fromScale(1, 0),
                FillDirection = Enum.FillDirection.Vertical,
                Gaps = 12,
                LayoutOrder = layoutOrder:Increment(),
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }, requirements),
        }),
    })
end

return function(props: Props)
    return React.createElement(ItemListItem, props)
end
