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

local Modal = require(script.Parent.Modal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)

type Props = {

}

local function EditItemsListUI(props: Props)
    print("EditItemsListUI: ", props)
    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    
    local dataset = props.Dataset
    local map = props.CurrentMap
    local machines = props.CurrentMap["machines"]
    local items = map["items"]

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local getLayoutOrderIndex = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string, itemObject:table)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(itemObject[key]),
            Label = key,
            LayoutOrder = getLayoutOrderIndex(),
            OnActivated = function()
                --set modal enabled
                setModalEnabled(true)
                setCurrentFieldKey(key)
                setCurrentFieldValue(itemObject[key])
                setCurrentFieldCallback(function()
                    return function(newValue)
                        local previousValue = itemObject[key]
                        print(previousValue, newValue)
                        if newValue ~= previousValue then
                            --The "items" table is a dictionary. So the key needs to be replaced, as well as the contents.
                            items[newValue] = table.clone(items[previousValue])
                            items[newValue]["id"] = newValue
                            items[previousValue] = nil
                            print("Items: ", items)

                            for i,machine in machines do
                                if machine["outputs"] then
                                    
                                    for j,output in machine["outputs"] do
                                        if output == previousValue then
                                            machines[i]["outputs"][j] = newValue
                                        end
                                    end
                                end
                            end
                        end
                        
                        Studio.setSelectionTool()
                    end
                end)
            end,
        })
    end


    local children = {}
    local item = props.Item
    add(children, createTextChangingButton("id", item))

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = props.Item["id"],
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
        Modal = modalEnabled and Modal({
            Key = currentFieldKey,
            OnConfirm = function(value)
                currentFieldCallback(value)
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                props.UpdateItem(value)
                props.UpdateDataset(dataset)
            end,
            OnClosePanel = function()
                setCurrentFieldCallback(nil)
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
            end,
            Value = currentFieldValue,
    })})

end

return function(props)
    return React.createElement(EditItemsListUI, props)
end