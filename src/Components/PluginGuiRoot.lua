local Selection = game:GetService("Selection")

local Root = script.Parent.Parent
local Packages = Root.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local ThemeProvider = FishBloxComponents.ThemeProvider
local themes = FishBloxComponents.Themes
local Panel = FishBloxComponents.Panel

local DebugUI = require(script.Parent.DebugUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)

local Scene = require(script.Parent.Parent.Scene)

local PluginGuiRoot = React.Component:extend("PluginGui")

function PluginGuiRoot:setCurrentPanel(panelId)
    self:setState({currentPanel = panelId})
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())
end

function PluginGuiRoot:init()
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())

    self.machines = Scene.getMachines()
    
    self:setState({
        currentPanel = not Scene.isLoaded() and 1 or 2
    })
    
    self.onSelectionChanged = function()
        if #Selection:Get() >= 1 then
            local obj = Selection:Get()[1]
            if Scene.isMachine(obj) then
                self:setState({selectedMachine = obj})
                self:setCurrentPanel(3)
            end
        else
            self:setCurrentPanel(2)
        end
    end
    
    self.connections = {}
    table.insert(self.connections, Selection.SelectionChanged:Connect(self.onSelectionChanged))
end

function PluginGuiRoot:componentDidMount() end

function PluginGuiRoot:render()
    --TODO: Figure out why the ribbon tool keeps getting set to None
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())

    return React.createElement("ScreenGui", {}, {
        Block({
            PaddingLeft = 20,
            PaddingRight = 20,
            PaddingTop = 20,
            PaddingBottom = 20,
            Size = UDim2.new(0, 300, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X
        }, {
            -- DebugPanel = Scene.isLoaded() and React.createElement(DebugUI, {
            --     SetCurrentPanel = pluginGuiProps.setCurrentPanel
            -- }, {}),
    
            InitializeFactoryUI = self.state.currentPanel == 1 and React.createElement(InitializeFactoryUI, {
                ShowEditFactoryPanel = function()
                    self:setCurrentPanel(2)
                end
            }, {}),
            EditFactoryUI = self.state.currentPanel == 2 and React.createElement(EditFactoryUI, {}, {}),
            EditMachineUI = self.state.currentPanel == 3 and React.createElement(EditMachineUI, {
                SelectedMachine = self.state.selectedMachine,
                OnClosePanel = function()
                    Selection:Set({})
                    self:setCurrentPanel(2)
                end
            }, {}),
            EditProductListUI = nil,
            EditPowerupListUI = nil
        })
    })
end

function PluginGuiRoot:componentWillUnmount()
    for _,v in self.connections do
        v:Disconnect()
        v = nil
    end
    table.clear(self.connections)
end

return PluginGuiRoot

-- buttons.InitializeSceneButton = not self.state.sceneIsLoaded and Button({
--     Label = "Initialize Scene",
--     OnActivated = function()
--         Scene.loadScene()
--         self:setState({sceneIsLoaded = Scene.isLoaded()})
--     end
-- }) or nil

-- buttons.AddMachineButton = self.state.sceneIsLoaded and Button({
--     Label = "Add Machine",
--     OnActivated = function()
--         print("Machine added")
--     end
-- }) or nil

-- for i,_ in ipairs(self.state.machines) do
--     table.insert(buttons, Button({Label = "Machine "..i}))
-- end

-- local panel = Panel({Size = UDim2.new(0, 300, 1, 0)}, buttons)

-- if not self.state.sceneIsLoaded then
    --     children.InitializeSceneButton = Button({
    --         Label = "Initialize Scene",
    --         OnActivated = function()
    --             Scene.loadScene()
    --             self:setState({sceneIsLoaded = Scene.isLoaded()})
    --         end
    --     })
    -- end

    -- if self.state.sceneIsLoaded then 
    --     children.InitializeSceneButton = Button({
    --         Label = "Add Machine",
    --         OnActivated = function()
    --             print("Machine added")
    --         end
    --     })
    -- end
    
    -- children.Panel.Column = Column({
        --     Size = UDim2.fromScale(1, 0),
    --     AutomaticSize = Enum.AutomaticSize.Y,
    --     -- Gaps = theme.Tokens.Sizes.Registered.Small.Value,
    --     HorizontalAlignment = Enum.HorizontalAlignment.Center,
    --     VerticalAlignment = Enum.VerticalAlignment.Top,
    --     -- ZIndex = self.props.ZIndex,
    -- })
    
    -- if not self.state.sceneIsLoaded then
    --     children.Panel.Column.InitializeScene = React.createElement("TextButton", {
    --         Text = "Intialize Scene",
    --         TextColor3 = Color3.fromRGB(0, 0, 0),
    --         TextSize = 14,
    --         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    --         Size = self.state.buttonSize,
    --         [React.Event.MouseButton1Click] = function()
    --             Scene.loadScene()
    --             self:setState({sceneIsLoaded = Scene.isLoaded()})
    --         end
    --     })
    -- end

    -- if self.state.sceneIsLoaded then
    --     children.Panel.Column.CreateMachine = React.createElement("TextButton", {
    --         Text = "Create Machine",
    --         TextColor3 = Color3.fromRGB(0, 0, 0),
    --         TextSize = 14,
    --         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    --         Size = self.state.buttonSize,
    --         [React.Event.MouseButton1Click] = function()
    --             Scene.loadScene()
    --         end
    --     })

    --     local butt = React.createElement(Button, {Size = self.state.buttonSize})
    --     children.Panel.Column.TestButton = Block({Size = self.state.buttonSize}, butt)
    -- end
    