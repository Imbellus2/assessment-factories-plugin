local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Row = FishBloxComponents.Row
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text

export type Props = {
    OnClosePanel: any,
    Title: string,
    ShowClose: boolean,
}

return function(props, children)
    children = children or {}
    local showClose = props.ShowClose
    if props.ShowClose == nil then
        showClose = true
    end

    return Block({
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundColor = Color3.fromRGB(32, 36, 42),
        Size = UDim2.new(0, 300, 1, 0),
        Padding = UDim.new(0, 12),
        Corner = UDim.new(0, 12),
        ClipsDescendants = true,
    }, {
        --Click Blocker
        Block({
            Size = UDim2.fromScale(1, 1),
            BlockClicks = true,
            ZIndex = -1,
        }),
        Column({
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            TitleBlock = Block({
                Size = UDim2.new(1, 0, 0, 25),
            }, {
                Text = React.createElement("TextLabel", {
                    AnchorPoint = Vector2.new(0, 0),
                    FontFace = Font.new(
                        "rbxasset://fonts/families/GothamSSm.json",
                        Enum.FontWeight.Bold,
                        Enum.FontStyle.Normal
                    ),
                    Text = props.Title,
                    TextColor3 = Color3.fromRGB(218, 218, 218),
                    TextSize = 20,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                }),
                CloseButtonBlock = Block({
                    AnchorPoint = Vector2.new(1, 0),
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.new(1, 0, 0, 0),
                    LayoutOrder = 2,
                }, {
                    CloseButton = props.ShowClose and Button({
                        Size = UDim2.fromScale(1, 1),
                        Padding = 4,
                        Appearance = "Borderless",
                        OnActivated = props.OnClosePanel,
                        ZIndex = 1,
                    }, {
                        Image = Roact.createElement("ImageLabel", {
                            Size = UDim2.fromOffset(10, 10),
                            AutomaticSize = Enum.AutomaticSize.None,
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6990919691",
                            ImageColor3 = Color3.fromRGB(79, 159, 243),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            ZIndex = props.ZIndex or 1,
                        }),
                    }),
                }),
            }),
            Gap = Block({ Size = UDim2.new(1, 0, 0, 5) }),
            ContentColumn = Column({
                LayoutOrder = 2,
                Gaps = 8,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Size = UDim2.new(1, 0, 1, 0),
            }, children),
        }),
    })
end
