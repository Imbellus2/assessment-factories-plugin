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

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)
local ItemListItem = require(script.Parent.ItemListItem)
local ListItemButton = require(script.Parent.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
type Props = {

}

local Errors = {
    ItemIsNotRequiredByAnother = "Item is not required by another!"
}


local function EditItemsListUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local getLayoutOrderIndex = function()
        index = index + 1
        return index
    end
    
    local dataset = props.Dataset
    local map = props.CurrentMap
    local items = map["items"]
    local children = {}
    
    add(children, Button({
        Label = "Add Item",
			TextXAlignment = Enum.TextXAlignment.Center,
			OnActivated = function()
                local newItem = Dataset:addItem()
				props.UpdateDataset(dataset)
				props.ShowEditItemPanel(newItem["id"])
			end,
			Size = UDim2.fromScale(1, 0),
    }))

    -- --Sort the template items and the non-template items, so that template items show up at the top of the list.
    -- local newItems = table.clone(items)
    -- local templateItems = {}
    -- for key,item in items do
    --     if string.match(key, "templateItem") then
    --         templateItems[key] = {}
    --         table.insert(templateItems[key], newItems[key])
    --         newItems[key] = nil
    --     end
    -- end
    local itemIndex = 1
    -- --Add template items separately, so they show up at the top of the list.
    -- for key,_ in templateItems do
    --     add(children, ListItemButton({
    --         Index = itemIndex,
    --         Image = items[key]["thumb"],
    --         Label = items[key]["id"],
    --         LayoutOrder = getLayoutOrderIndex(),
    --     }))
    --     itemIndex += 1
    -- end

    local itemKeys = Dash.keys(items)
    table.sort(itemKeys, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)
    for i,key in itemKeys do
        add(children, ListItemButton({
            Index = itemIndex,
            Image = items[key]["thumb"],
            Label = items[key]["id"],
            LayoutOrder = getLayoutOrderIndex(),
        }))
        itemIndex += 1
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = "Edit Items List",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props)
    return React.createElement(EditItemsListUI, props)
end