local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Dash = require(Packages.Dash)
local Block = FishBloxComponents.Block
local Row = FishBloxComponents.Row
local Column = FishBloxComponents.Column
local Text = FishBloxComponents.Text
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local Incrementer = require(script.Parent.Parent.Incrementer)
local ImageManifest = require(script.Parent.Parent.ImageManifest)

--use this to create a consistent layout order that plays nice with Roact
local index = 0
local incrementLayoutOrder = function()
    index = index + 1
    return index
end
type Props = {
    OnClick: any,
}

local function ImageButton(imageKey, onClick)
    local hover, setHover = React.useState(false)

    local prefix = imageKey:split("-")[1]
    local imageLabel = imageKey:gsub(prefix, ""):sub(2)
    return Block({
        BackgroundTransparency = hover and 0.85 or 0.9,
        Corner = UDim.new(0, 8),
        HasStroke = true,
        StrokeThickness = 2,
        StrokeColor = Color3.new(1, 1, 1),
        StrokeTransparency = hover and 0.7 or 0.8,
        LayoutOrder = incrementLayoutOrder(),
        Size = UDim2.new(0, 80, 0, 100),
        OnClick = function()
            onClick(imageKey)
        end,
        OnMouseEnter = function()
            setHover(true)
        end,
        OnMouseLeave = function()
            setHover(false)
        end,
    }, {
        Column = Column({
            Padding = UDim.new(0, 8),
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, {
            Image = React.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = ImageManifest.getImage(imageKey),
                LayoutOrder = 1,
                Size = UDim2.fromScale(0.9, 0.9),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
            }),
            Text = Text({
                Color = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 2,
                Text = imageLabel,
            }),
        }),
    })
end

local function ImageButtonRow(imageNames: { string }, onClick)
    local rowButtons = {}
    for _, v in imageNames do
        table.insert(rowButtons, ImageButton(v, onClick))
    end
    return Row({ Gaps = 12 }, rowButtons)
end

local function SelectThumbnailUI(props: Props)
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

    local imageButtons = {}
    local thumbnails = {}
    local manifest = ImageManifest.getManifest()
    if manifest then
        for imageKey, _ in manifest.images do
            if imageKey:split("-")[1] == "icon" then
                table.insert(thumbnails, imageKey)
            end
        end
        table.sort(thumbnails, function(a, b) --Do this to make sure buttons show in alphabetical order
            return a:lower() < b:lower()
        end)

        local count = 0
        local imagesToShow = {}
        for _, imageKey in thumbnails do
            count = count + 1
            if count % 3 == 0 then
                table.insert(imagesToShow, imageKey)
                table.insert(imageButtons, ImageButtonRow(imagesToShow, props.OnClick))
                table.clear(imagesToShow)
            else
                table.insert(imagesToShow, imageKey)
            end
        end
    end

    scrollingFrameChildren = Dash.join(scrollingFrameChildren, imageButtons)

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
            LayoutOrder = layoutOrder:Increment(),
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
            Title = "Choose a thumbnail",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props: Props)
    return React.createElement(SelectThumbnailUI, props)
end
