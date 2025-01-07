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
local RadioButtonGroup = FishBloxComponents.RadioButtonGroup
local Row = FishBloxComponents.Row
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local Constants = require(script.Parent.Parent.Constants)

local SmallButton = require(script.Parent.SubComponents.SmallButton)
local DatasetInstance = require(script.Parent.Parent.DatasetInstance)
local TextItem = require(script.Parent.SubComponents.TextItem)
local Incrementer = require(script.Parent.Parent.Incrementer)
local Separator = require(script.Parent.SubComponents.Separator)
type Props = {
    Dataset: table,
    CurrentMap: table,
    CurrentMapIndex: number,
    Error: string,
    Title: string,
    UpdateSceneName: any,
    ShowEditFactoryUI: any,
    ShowEditItemsListUI: any,
    ExportDataset: any,
    ImportDataset: any,
}

local function EditDatasetUI(props: Props)
    local layoutOrder = Incrementer.new()

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = props.CurrentMap

    local buttonSize = UDim2.new(1, 0, 0, 0)

    local children = {}

    if datasetIsLoaded then
        children["DatasetName"] = TextInput({
            Label = "Dataset ID",
            LayoutOrder = layoutOrder:Increment(),
            Size = UDim2.new(1, 0, 0, 50),
            Value = DatasetInstance.getDatasetInstanceName(),
            OnChanged = function(value)
                DatasetInstance.updateDatasetInstanceName(value)
            end,
        })

        children["Separator1"] = React.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder:Increment(),
        })

        children["SceneName"] = TextInput({
            Label = "Scene Name",
            LayoutOrder = layoutOrder:Increment(),
            Size = UDim2.new(1, 0, 0, 50),
            Value = map["scene"],
            OnChanged = props.UpdateSceneName,
        })

        children["Separator2"] = React.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder:Increment(),
        })

        children["EditFactoryButton"] = Button({
            Label = "Edit Factory",
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = props.ShowEditFactoryUI,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        })

        children["EditPowerups"] = Button({
            Label = "Edit Powerups",
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = props.ShowEditPowerupsUI,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        })

        if props.Error == Constants.Errors.None then
            children["ExportDatasetButton"] = Button({
                -- Active = false,
                Label = "Export Dataset",
                LayoutOrder = layoutOrder:Increment(),
                OnActivated = props.ExportDataset,
                Size = buttonSize,
                TextXAlignment = Enum.TextXAlignment.Center,
            })

            children["ExportMapDataButton"] = Button({
                -- Active = false,
                Label = "Export MapData",
                LayoutOrder = layoutOrder:Increment(),
                OnActivated = props.ExportMapData,
                Size = buttonSize,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        else
            children["Error"] = Text({
                LayoutOrder = layoutOrder:Increment(),
                Text = props.Error .. "!",
                Color = Color3.new(1, 0, 0),
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Center,
            })

            children["Error2"] = Text({
                LayoutOrder = layoutOrder:Increment(),
                Text = "You must fix this before exporting.",
                Color = Color3.new(1, 0, 0),
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        end

        children["ImportDatasetButton"] = Button({
            Label = "Import Dataset",
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = props.ImportDataset,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        })

        children["ImportManifestButton"] = Button({
            Label = "Import Image Manifest",
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = props.ImportManifest,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
    end

    if datasetIsLoaded then
        children["Prints"] = Column({
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            LayoutOrder = layoutOrder:Increment(),
            Size = UDim2.new(1, 0, 0, 100),
        }, {

            PrintDataset = TextItem({
                Text = "Print Dataset to Console",
                LayoutOrder = layoutOrder:Increment(),
                OnActivate = function()
                    print(Dash.pretty(dataset, { multiline = true, indent = "\t", depth = 10 }))
                end,
            }),

            PrintMachines = TextItem({
                Text = "Print Machines to Console",
                LayoutOrder = layoutOrder:Increment(),
                OnActivate = function()
                    print(Dash.pretty(map["machines"], { multiline = true, indent = "\t", depth = 10 }))
                end,
            }),

            PrintItems = TextItem({
                Text = "Print Items to Console",
                LayoutOrder = layoutOrder:Increment(),
                OnActivate = function()
                    print(Dash.pretty(map["items"], { multiline = true, indent = "\t", depth = 10 }))
                end,
            }),
        })
    end

    return SidePanel({
        ShowClose = false,
        Title = props.Title,
    }, children)
end

return function(props)
    return React.createElement(EditDatasetUI, props)
end
