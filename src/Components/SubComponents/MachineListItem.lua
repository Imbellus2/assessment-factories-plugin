local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local Types = require(script.Parent.Parent.Parent.Types)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)
local MachineThumbnails = require(script.Parent.Parent.Parent.MachineThumbnails)
local Constants = require(script.Parent.Parent.Parent.Constants)
local FishBloxComponents = FishBlox.Components

-- local SmallLabel = require(script.Parent.SmallLabel)
-- local SmallButton = require(script.Parent.SmallButton)
-- return React.createElement

type Props = {
    Label: string,
    LayoutOrder: number,
    OnActivated: any,
    Machine: Types.Machine,
    OnClickUp: () -> nil,
    OnClickDown: () -> nil,
    OnClickEdit: () -> nil,
    OnClickRemove: () -> nil,
    OnHover: () -> nil,
    HideArrows: boolean,
    HideEditButton: boolean,
    HideRemoveButton: boolean,
}

function MachineListItem(props: Props)
    local hovered, setHovered = React.useState(false)

    return React.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = hovered and 0.93 or 0.95,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        LayoutOrder = props.LayoutOrder,
        [ReactRoblox.Event.MouseEnter] = function()
            props.OnHover(props.Machine)
            setHovered(true)
        end,
        [ReactRoblox.Event.MouseLeave] = function()
            props.OnHover(nil)
            setHovered(false)
        end,
    }, {
        HoverButtons = hovered
            and React.createElement("ImageButton", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                [ReactRoblox.Event.Activated] = function()
                    props.OnActivated(props.Machine.id)
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

                delete = not props.HideRemoveButton
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
                                props.OnClickRemove(props.Machine.id)
                            end,
                        }, {
                            uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
                        }),
                    }),

                edit = React.createElement("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(25, 30),
                    LayoutOrder = 1,
                }, {
                    imageLabel1 = not props.HideEditButton
                        and React.createElement("ImageButton", {
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
                                props.OnClickEdit()
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

            uICorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),

            uIStroke = React.createElement("UIStroke", {
                Color = Color3.fromRGB(243, 243, 243),
                Thickness = 2,
                Transparency = 0.85,
            }),
            uIPadding = React.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 4),
            }),

            -- imageLabel = React.createElement("ImageLabel", {
            --     Image = MachineThumbnails[props.Machine.asset] or Constants.NoImage,
            --     AnchorPoint = Vector2.new(0, 0.5),
            --     BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            --     BackgroundTransparency = 1,
            --     BorderColor3 = Color3.fromRGB(0, 0, 0),
            --     BorderSizePixel = 0,
            --     LayoutOrder = 1,
            --     Position = UDim2.fromScale(0, 0.5),
            --     Size = UDim2.new(1, 0, 0, 50),
            -- }, {
            --     uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
            -- }),

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
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                AnchorPoint = Vector2.new(1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Position = UDim2.new(0.781, 60, 0, 0),
                Size = UDim2.fromScale(0, 1),
            }),

            -- sortArrows = not props.HideArrows
            --     and React.createElement("Frame", {
            --         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            --         BackgroundTransparency = 1,
            --         BorderColor3 = Color3.fromRGB(0, 0, 0),
            --         BorderSizePixel = 0,
            --         Position = UDim2.fromScale(0, 0.479),
            --         Size = UDim2.new(0, 25, 1, 4),
            --     }, {
            --         imageButton = React.createElement("ImageButton", {
            --             Image = "rbxassetid://7901794424",
            --             ImageColor3 = Color3.fromRGB(106, 106, 106),
            --             BackgroundColor3 = Color3.fromRGB(79, 159, 243),
            --             BackgroundTransparency = 1,
            --             BorderColor3 = Color3.fromRGB(0, 0, 0),
            --             BorderSizePixel = 0,
            --             Size = UDim2.fromOffset(20, 20),
            --             [ReactRoblox.Event.Activated] = function()
            --                 props.OnClickUp(props.Machine, props.LayoutOrder)
            --             end,
            --         }, {
            --             uIAspectRatioConstraint1 = React.createElement("UIAspectRatioConstraint"),
            --         }),

            --         imageButton1 = React.createElement("ImageButton", {
            --             Image = "rbxassetid://7901781271",
            --             ImageColor3 = Color3.fromRGB(106, 106, 106),
            --             AnchorPoint = Vector2.new(0, 1),
            --             BackgroundColor3 = Color3.fromRGB(79, 159, 243),
            --             BackgroundTransparency = 1,
            --             BorderColor3 = Color3.fromRGB(0, 0, 0),
            --             BorderSizePixel = 0,
            --             Position = UDim2.fromScale(0, 1),
            --             Size = UDim2.fromOffset(20, 20),

            --             [ReactRoblox.Event.Activated] = function()
            --                 props.OnClickDown(props.Machine, props.LayoutOrder)
            --             end,
            --         }, {
            --             uIAspectRatioConstraint2 = React.createElement("UIAspectRatioConstraint"),
            --         }),
            --     }),
        }),
    })
end

return function(props: Props)
    return React.createElement(MachineListItem, props)
end
