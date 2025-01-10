local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local StudioService = game:GetService("StudioService")

local Root = script.Parent.Parent
local Packages = Root.Packages

local Dash = require(Packages.Dash)

local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Column = FishBloxComponents.Column
local Text = FishBloxComponents.Text
local Icon = FishBloxComponents.Icon
local Row = FishBloxComponents.Row
local Panel = FishBloxComponents.Panel
local Button = FishBloxComponents.Button
local TextInput = FishBloxComponents.TextInput

local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
-- local EditItemsListUI = require(script.Parent.EditItemsListUI)
local EditItemUI = require(script.Parent.EditItemUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local ConfirmationModal = require(script.Parent.Modals.ConfirmationModal)
local MachineAnchorBillboardGuis = require(script.Parent.MachineAnchorBillboardGuis)
local SelectThumbnailUI = require(script.Parent.SelectThumbnailUI)

local Constants = require(script.Parent.Parent.Constants)
local Dataset = require(script.Parent.Parent.Dataset)
local Panels = Constants.Panels
local Scene = require(script.Parent.Parent.Scene)
local DatasetInstance = require(script.Parent.Parent.DatasetInstance)
local Studio = require(script.Parent.Parent.Studio)

local App = React.Component:extend("PluginGui")

local add = require(script.Parent.Parent.Helpers.add)
-- local Manifest = require(script.Parent.Parent.Manifest)
local FactoryFloor = require(script.Parent.FactoryFloor)

local Types = require(script.Parent.Parent.Types)
local SelectMachineUI = require(script.Parent.SelectMachineUI)
local SelectItemUI = require(script.Parent.SelectItemUI)
local GetMapData = require(script.Parent.Parent.GetMapData)

local pluginVersion = require(script.Parent.Parent.Version)
local TextItem = require(script.Parent.SubComponents.TextItem)
local EditPowerupsUI = require(script.Parent.EditPowerupsUI)
local ImageManifest = require(script.Parent.Parent.ImageManifest)

function App:setPanel()
    Studio.setSelectionTool()
    self:setState({
        currentPanel = self.state.panelStack[#self.state.panelStack],
        showModal = false,
        highlightedMachineAnchor = React.None,
    })
end

function App:changePanel(panelId)
    if not panelId then
        warn("Trying to show a panel that does not exist!")
    end
    Studio.setSelectionTool()
    if panelId == self.state.panelStack[#self.state.panelStack] then
        return
    end
    if panelId == Panels.EditDatasetUI then
        table.clear(self.state.panelStack)
    end
    table.insert(self.state.panelStack, panelId)
    self:setPanel()
end

function App:showPreviousPanel()
    local stack = self.state.panelStack
    table.remove(stack, #stack)
    self:setPanel()
end

function App:importImageManifest()
    --Import the Manifest.lua file from the Factories project
    local file = StudioService:PromptImportFile()
    if not file then
        return nil
    end

    local newManifestInstance = Instance.new("ModuleScript")
    newManifestInstance.Source = file:GetBinaryContents()
    newManifestInstance.Name = "Factories Plugin Manifest"
    newManifestInstance.Parent = ServerStorage

    self:updateDataset(self.state.dataset)
end

function App:init()
    Studio.setSelectionTool()

    Scene.initScene()

    local dataset = "NONE"
    local datasetIsLoaded = false
    local currentMap = nil
    --If the map index has been saved as an attribute, load this map when reloading the plugin.
    -- local currentMapIndex = (game.Workspace:FindFirstChild("Dataset") and game.Workspace.Dataset:GetAttribute("CurrentMapIndex")) or 1
    local currentMapIndex = Scene.getCurrentMapIndexAccordingToScene()

    if DatasetInstance.checkIfDatasetInstanceExists() then
        dataset = Dataset:getDataset()
        if not dataset then
            warn("Dataset error!")
        else
            datasetIsLoaded = true
            currentMap = dataset["maps"][currentMapIndex]
            Dataset:updateDataset(dataset, currentMapIndex)
        end
    else
        --if there's no scene and no dataset instance, then load everything.
        local templateDataset, newDatasetInstance = DatasetInstance.loadTemplateDataset()

        if not newDatasetInstance then
            return
        end

        currentMap = templateDataset["maps"][currentMapIndex]
        Scene.updateAllMapAssets(currentMap)
        self:setState({ datasetIsLoaded = true })
        self:updateDataset(templateDataset)
    end

    --Init the image manifest
    local existingManifest = ServerStorage:FindFirstChild("Factories Plugin Manifest")
    if existingManifest == nil then
        existingManifest = script.Parent.Parent.Assets.Manifest:Clone()
        existingManifest.Name = "Factories Plugin Manifest"
        existingManifest.Parent = ServerStorage
    end

    local currentPanel = Panels.EditDatasetUI
    self:setState({
        currentMap = currentMap, --TODO: remove this, use index instead
        currentMapIndex = currentMapIndex,
        currentPanel = currentPanel,
        datasetError = Dataset:checkForErrors(),
        dataset = dataset,
        datasetIsLoaded = datasetIsLoaded,
        highlightedMachineAnchor = nil,
        modalCancellationCallback = Dash.noop(),
        modalConfirmationCallback = Dash.noop(),
        modalTitle = "",
        panelStack = { currentPanel },
        requirementItemHovered = nil,
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
        showModal = false,
    })
end

--TODO: Anything that modifies the dataset should be done via the Dataset class. Currently the dataset is being modified here
--and passed around. This could cause problems down the road.
function App:updateDataset(dataset, currentMapIndex: number?)
    local map = currentMapIndex and currentMapIndex or self.state.currentMapIndex
    Dataset:updateDataset(dataset, map)
    self:setState({
        dataset = dataset,
        datasetError = Dataset:checkForErrors(),
    })
end

function App:deleteMachine(machine: Types.Machine, anchor)
    self:setState({
        showModal = true,
        modalTitle = "Would you like to delete " .. machine["id"] .. "from the dataset?",

        modalConfirmationCallback = function()
            Dataset:removeMachine(machine)
            self:showPreviousPanel()
            self:setState({ showModal = false })
            self:updateDataset(self.state.dataset)
        end,
        modalCancellationCallback = function()
            Scene.instantiateMachineAnchor(machine)
            self:setState({ showModal = false })
            self:updateDataset(self.state.dataset)
        end,
    })
end

function App:setCurrentMap(mapIndex)
    game.Workspace.Dataset:SetAttribute("CurrentMapIndex", mapIndex)

    local currentMap = self.state.dataset["maps"][mapIndex]
    -- self.state.currentMapIndex = mapIndex
    Scene.updateAllMapAssets(currentMap)
    self:updateDataset(self.state.dataset, mapIndex)
    self:setState({
        currentMapIndex = mapIndex,
        currentMap = currentMap,
        selectedItem = nil,
        selectedMachine = nil,

        selectedMachineAnchor = nil,
        showModal = false,
    })
end

function App:render()
    Studio.setSelectionTool()
    -- print("Rerender:", self.state.dataset)
    return React.createElement("ScreenGui", {}, {
        TopBar = Block({
            BackgroundColor = Color3.fromRGB(32, 36, 42),
            Size = UDim2.new(1, 0, 0, 42),
        }),
        PluginRoot = self.state.datasetIsLoaded
            and Block({
                PaddingLeft = 10,
                PaddingRight = 10,
                PaddingTop = 10,
                PaddingBottom = 10,
                Size = UDim2.new(1, 0, 1, -42),
                Position = UDim2.new(0, 0, 0, 42),
                AutomaticSize = Enum.AutomaticSize.X,
            }, {
                VersionBlock = Block({
                    Position = UDim2.fromScale(1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                }, {
                    Version = TextItem({
                        Text = "Version: " .. pluginVersion,
                        TextSize = 10,
                        LayoutOrder = 1,
                        OnActivate = function() end,
                    }),
                }),
                AddMachineButton = Block({
                    AnchorPoint = Vector2.new(1, 1),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor = Color3.fromRGB(27, 42, 53),
                    Corner = UDim.new(0, 24),
                    Padding = 12,
                    Position = UDim2.new(1, 0, 1, 0),
                    Size = UDim2.new(0, 200, 0, 50),
                }, {
                    Button = Button({
                        Label = "Add Machine",
                        TextXAlignment = Enum.TextXAlignment.Center,
                        OnActivated = function()
                            local newMachine = Dataset:addMachine()
                            local anchor = Scene.instantiateMachineAnchor(newMachine)
                            self:setState({ selectedMachine = newMachine, selectedMachineAnchor = anchor })

                            self:changePanel(Panels.EditMachineUI)
                            Selection:Set({ anchor })
                            self:updateDataset(self.state.dataset)
                        end,
                    }),
                }),

                EditDatasetUI = (self.state.currentPanel == Panels.EditDatasetUI)
                    and React.createElement(EditDatasetUI, {
                        CurrentMap = self.state.currentMap,
                        CurrentMapIndex = self.state.currentMapIndex,
                        Dataset = self.state.dataset,
                        Error = self.state.datasetError,
                        Title = self.state.currentPanel,

                        SetCurrentMap = function(mapIndex)
                            self:setCurrentMap(mapIndex)
                        end,

                        ShowEditFactoryUI = function()
                            self:changePanel(Panels.EditFactoryUI)
                        end,

                        ShowEditPowerupsUI = function()
                            self:changePanel(Panels.EditPowerupsUI)
                        end,

                        ExportDataset = function()
                            DatasetInstance.write(self.state.dataset)
                            local datasetInstance = DatasetInstance.getDatasetInstance()
                            local saveFile = datasetInstance:Clone()
                            saveFile.Source = string.sub(saveFile.Source, #"return [[" + 1, #saveFile.Source - 2)
                            saveFile.Name = saveFile.Name
                            saveFile.Parent = datasetInstance.Parent
                            Selection:Set({ saveFile })
                            local fileSaved = self.props.Plugin:PromptSaveSelection()
                            if fileSaved then
                                print("File saved")
                            end
                            Selection:Set({})
                            saveFile:Destroy()
                        end,

                        ImportDataset = function()
                            local dataset, newDatasetInstance = DatasetInstance.instantiateNewDatasetInstance()

                            if not newDatasetInstance then
                                return
                            end

                            --if for some reason the dataset is deleted, then make sure that the app state reflects that.
                            newDatasetInstance.AncestryChanged:Connect(function(_, _)
                                self:setState({ dataset = "NONE", datasetIsLoaded = false })
                            end)

                            local currentMap = dataset["maps"][self.state.currentMapIndex]
                            Scene.updateAllMapAssets(currentMap)
                            self:setState({ dataset = dataset, datasetIsLoaded = true, currentMap = currentMap })
                            self:updateDataset(dataset)
                        end,

                        ExportMapData = function()
                            local mapData = GetMapData()
                            local tempMapDataInstance = Instance.new("ModuleScript")
                            tempMapDataInstance.Source = "return "
                                .. Dash.pretty(mapData, { multiline = true, indent = "\t", depth = 10 })
                            tempMapDataInstance.Name = self.state.dataset.maps[self.state.currentMapIndex].scene
                                .. "-Data"
                            tempMapDataInstance.Parent = game.Workspace
                            Selection:Set({ tempMapDataInstance })
                            local fileSaved = self.props.Plugin:PromptSaveSelection()
                            if fileSaved then
                                print("MapData File saved")
                            end
                            Selection:Set({})
                            tempMapDataInstance:Destroy()
                        end,

                        ImportManifest = function()
                            --Destroy existing manifest
                            local existingManifest = ServerStorage:FindFirstChild("Factories Plugin Manifest")
                            if existingManifest then
                                existingManifest:Destroy()
                            end

                            --Import the Manifest.lua file from the Factories project
                            local file = StudioService:PromptImportFile()
                            if not file then
                                return nil
                            end

                            local newManifestInstance = Instance.new("ModuleScript")
                            newManifestInstance.Source = file:GetBinaryContents()
                            newManifestInstance.Name = "Factories Plugin Manifest"
                            newManifestInstance.Parent = ServerStorage

                            self:updateDataset(self.state.dataset)
                        end,

                        UpdateDataset = function(dataset)
                            self:updateDataset(dataset)
                        end,

                        UpdateSceneName = function(name)
                            self.state.dataset["maps"][self.state.currentMapIndex]["scene"] = name
                            self:updateDataset(self.state.dataset)
                        end,

                        UpdateDatasetName = function(name) end,
                    }),

                EditFactoryUI = self.state.currentPanel == Panels.EditFactoryUI
                    and React.createElement(EditFactoryUI, {
                        CurrentMap = self.state.currentMap,
                        Dataset = self.state.dataset,
                        OnClosePanel = function()
                            self:showPreviousPanel()
                        end,
                        UpdateDataset = function(dataset)
                            self:updateDataset(dataset)
                        end,
                    }, {}),

                EditPowerupsUI = self.state.currentPanel == Panels.EditPowerupsUI
                    and EditPowerupsUI({
                        Powerups = self.state.dataset.maps[self.state.currentMapIndex].powerups,
                        OnClosePanel = function()
                            self:showPreviousPanel()
                        end,
                        UpdateDataset = function()
                            self:updateDataset(self.state.dataset)
                        end,
                    }),

                EditMachineUI = self.state.currentPanel == Panels.EditMachineUI
                    and React.createElement(EditMachineUI, {
                        CurrentMapIndex = self.state.currentMapIndex,
                        Dataset = self.state.dataset,
                        Machine = self.state.selectedMachine,

                        MachineAnchor = self.state.selectedMachineAnchor,

                        OnClosePanel = function()
                            Selection:Set({})
                            self:setState({
                                selectedMachine = React.None,
                                selectedItem = React.None,
                            })
                            self:showPreviousPanel()
                        end,
                        OnAddInputMachine = function()
                            self:changePanel(Panels.SelectMachineUI)
                        end,
                        OnAddOutput = function(machine: Types.Machine)
                            self:changePanel(Panels.SelectOutputItemUI)
                        end,
                        OnClickEditItem = function(item: Types.Item)
                            self:setState({ selectedItem = item })
                            self:changePanel(Panels.EditItemUI)
                        end,
                        OnHover = function(anchor)
                            if not anchor then
                                anchor = React.None
                            end
                            self:setState({ highlightedMachineAnchor = anchor })
                        end,
                        OnRequirementItemHovered = function(itemId: string)
                            if not itemId then
                                itemId = React.None
                            end
                            self:setState({ requirementItemHovered = itemId })
                        end,
                        UpdateDataset = function()
                            self:updateDataset(self.state.dataset)
                        end,
                    }, {}),

                SelectMachineUI = self.state.currentPanel == Panels.SelectMachineUI
                    and SelectMachineUI({
                        Machines = self.state.dataset.maps[self.state.currentMapIndex].machines,
                        SelectedMachine = self.state.selectedMachine,

                        OnClosePanel = function()
                            self:showPreviousPanel()
                        end,

                        OnNewInputMachineChosen = function()
                            self:updateDataset(self.state.dataset)
                            self:showPreviousPanel()
                        end,
                        OnHover = function(anchor)
                            if not anchor then
                                anchor = React.None
                            end
                            self:setState({ highlightedMachineAnchor = anchor })
                        end,
                    }),

                SelectOutputItemUI = self.state.currentPanel == Panels.SelectOutputItemUI and SelectItemUI({
                    Title = "Select Output Item",
                    Items = Dataset:getValidItems(false),
                    SelectedMachine = self.state.selectedMachine,
                    SelectedItem = self.state.selectedItem,
                    ShowAsListOfRequirements = false,

                    OnClickEditItem = function(item: Types.Item)
                        self:setState({ selectedItem = item })
                        self:changePanel(Panels.EditItemUI)
                    end,
                    OnChooseItem = function(item: Types.Item)
                        if self.state.selectedMachine then
                            Dataset:addOutputToMachine(self.state.selectedMachine, item)
                            self:updateDataset(self.state.dataset)
                            self:showPreviousPanel()
                        else
                            warn("Cannot add output item. No machine selected.")
                            self:showPreviousPanel()
                        end
                        -- self:showPreviousPanel()
                    end,
                    OnClosePanel = function()
                        self:showPreviousPanel()
                    end,
                    OnHover = function(anchor)
                        if not anchor then
                            anchor = React.None
                        end
                        self:setState({ highlightedMachineAnchor = anchor })
                    end,
                    UpdateDataset = function()
                        self:updateDataset(self.state.dataset)
                    end,
                }),

                SelectRequirementItemUI = self.state.currentPanel == Panels.SelectRequirementItemUI and SelectItemUI({
                    Title = "Select Requirement Item",
                    Items = self.state.dataset.maps[self.state.currentMapIndex].items,
                    -- SelectedMachine = nil,
                    -- SelectedItem = nil,
                    HideEditButtons = true,
                    HideDeleteButtons = true,
                    ShowAsListOfRequirements = true,

                    OnChooseItem = function(item: Types.Item)
                        Dataset:addRequirementToItem(self.state.selectedItem, item)
                        self:updateDataset(self.state.dataset)
                        self:showPreviousPanel()
                    end,
                    OnClosePanel = function()
                        self:showPreviousPanel()
                    end,
                    OnHover = function() end,
                    UpdateDataset = function()
                        self:updateDataset(self.state.dataset)
                    end,
                }),

                EditItemUI = self.state.currentPanel == Panels.EditItemUI and EditItemUI({
                    CurrentMapIndex = self.state.currentMapIndex,
                    Dataset = self.state.dataset,
                    Item = self.state.selectedItem,

                    OnAddRequirement = function(item: Types.Item)
                        self:setState({ selectedItem = item })
                        self:changePanel(Panels.SelectRequirementItemUI)
                    end,
                    OnClosePanel = function()
                        self:setState({ selectedItem = React.None })
                        self:showPreviousPanel()
                    end,
                    OnDeleteRequirementClicked = function(title, callback)
                        self:setState({
                            showModal = true,
                            modalConfirmationCallback = function()
                                callback()
                                self:setState({
                                    showModal = false,
                                })
                            end,
                            modalCancellationCallback = function()
                                self:setState({ showModal = false })
                            end,
                            modalTitle = title,
                        })
                    end,

                    OnClickThumbnail = function()
                        self:changePanel(Panels.SelectThumbnailUI)
                    end,
                    SetNewItemAsSelectedItem = function(item: Types.Item)
                        self:setState({ selectedItem = item })
                    end,
                    UpdateDataset = function()
                        self:updateDataset(self.state.dataset)
                    end,
                }),
                SelectThumbnailUI = self.state.currentPanel == Panels.SelectThumbnailUI and SelectThumbnailUI({
                    OnClosePanel = function()
                        self:showPreviousPanel()
                    end,
                    OnClick = function(imageKey)
                        local item =
                            self.state.dataset["maps"][self.state.currentMapIndex]["items"][self.state.selectedItem["id"]]
                        item["thumb"] = imageKey
                        self:updateDataset(self.state.dataset)
                        self:showPreviousPanel()
                    end,
                }),

                EditPowerupUI = nil,

                MachineBillboardGUIs = self.state.datasetIsLoaded and MachineAnchorBillboardGuis({
                    ImageManifest = ImageManifest.getManifest(),
                    Items = self.state.dataset["maps"][self.state.currentMapIndex]["items"],
                    HighlightedAnchor = self.state.highlightedMachineAnchor,
                    HighlightedRequirementItem = self.state.requirementItemHovered,
                }),

                ConfirmationModal = self.state.showModal
                    and (self.state.selectedMachine or self.state.selectedItem)
                    and ConfirmationModal({

                        Title = self.state.modalTitle,
                        OnConfirm = function()
                            self.state.modalConfirmationCallback()
                        end,
                        OnCancel = function()
                            self.state.modalCancellationCallback()
                        end,
                    }),

                FactoryFloor = FactoryFloor({
                    Machines = self.state.dataset.maps[self.state.currentMapIndex].machines,
                    OnMachineSelect = function(machine, selectedObj)
                        self:setState({
                            selectedMachineAnchor = selectedObj,
                            selectedMachine = machine,
                        })
                        if machine then
                            self:changePanel(Panels.EditMachineUI)
                        end
                    end,
                    OnClearSelection = function()
                        self:setState({
                            selectedMachineAnchor = nil,
                            selectedMachine = nil,
                            selectedItem = nil,
                        })
                        self:changePanel(Panels.EditDatasetUI)
                    end,
                    UpdateDataset = function()
                        self:updateDataset(self.state.dataset)
                    end,
                    DeleteMachine = function(machine: Types.Machine)
                        self:deleteMachine(machine)
                    end,
                }),
            }),
    })
end

function App:componentWillUnmount()
    --Nothing
end

return App
