local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local InputService = game:GetService("UserInputService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local Dash = require(Packages.Dash)
local Machine = require(script.Parent.Machine)
local Constants = require(script.Parent.Parent.Constants)
local Conveyor = require(script.Parent.Conveyor.Conveyor)
local worldPositionToVector3 = require(script.Parent.Parent.Helpers.worldPositionToVector3)
local Utilities = require(script.Parent.Parent.Packages.Utilities)
local Types = require(script.Parent.Parent.Types)
local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local getOrCreateFolder = require(script.Parent.Parent.Helpers.getOrCreateFolder)
local FishBloxComponents = FishBlox.Components

local conveyorDepthOffset = 0.95 --Scalar for how far inside the machine the conveyor should start or end
local conveyorSpacing = 1.8 --How far apart the conveyors should be from each other.
local conveyorXOffset = 1.6 --Adjustment so that belts don't end beneath the machine (in screen space)
local conveyorYOffset = -1 --Where to position relative to the ground

type Props = {
    Machines: { Types.Machine },
    OnMachineSelect: (Types.Machine, Instance) -> nil,
    OnClearSelection: () -> nil,
    UpdateDataset: () -> nil,
}

local function getConveyorPosition(index, numBelts, offsetX, offsetZScalar)
    return Vector3.new(
        (index - 1) * conveyorSpacing - ((numBelts - 1) * 3 / 2) + offsetX,
        conveyorYOffset,
        offsetZScalar
    )
end

local FactoryFloor = function(props: Props)
    --Instantiation Hook
    React.useEffect(function()
        local folder = Scene.getBeltPartsFolder()
    end, {})

    --Connections Hook.
    --Listen for machine selection and machine drag.
    React.useEffect(function()
        local connections: { RBXScriptConnection } = {}

        connections["ClearSelection"] = Selection.SelectionChanged:Connect(function()
            if #Selection:Get() == 0 then
                props.OnClearSelection()
            end
        end)

        connections["Selection"] = Selection.SelectionChanged:Connect(function()
            local selection = Selection:Get()
            if #selection >= 1 then
                local selectedObj = selection[1]
                if Scene.isMachineAnchor(selectedObj) then
                    local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                    props.OnMachineSelect(machine, selectedObj)
                end
            end
        end)

        connections["DragMachine"] = InputService.InputEnded:Connect(function(input: InputObject)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end

            local selectedObjs = Selection:Get()
            if #selectedObjs > 0 then
                for _, selectedObj in selectedObjs do
                    if Scene.isMachineAnchor(selectedObj) then
                        --Register that the machine may have been moved.
                        local position = selectedObj.CFrame.Position
                        position = Vector3.new(position.X, Constants.Defaults.MachineDefaultYPosition, position.Z)

                        local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                        local worldPosition = Vector3.new()
                        if machine and machine["worldPosition"] then
                            selectedObj.CFrame = CFrame.new(position)
                            worldPosition = Vector3.new(
                                machine["worldPosition"]["X"],
                                machine["worldPosition"]["Y"],
                                machine["worldPosition"]["Z"]
                            )
                            if position ~= worldPosition then
                                machine["worldPosition"]["X"] = position.X
                                machine["worldPosition"]["Y"] = position.Y
                                machine["worldPosition"]["Z"] = position.Z

                                props.UpdateDataset()
                            end
                        end
                    end
                end
            end
        end)

        connections["DeleteMachine"] = Scene.getMachinesFolder().ChildRemoved:Connect(function(child)
            local machine = Dataset:getMachineFromMachineAnchor(child)
            if machine then
                props.DeleteMachine(machine, child)
            end
        end)

        return function()
            for _, connection in connections do
                connection:Disconnect()
            end
        end
    end, {})

    local children = {}
    --Create machine and conveyor components
    local machineComponents = {}
    -- local conveyorData = {}
    for _, machine in props.Machines do
        machineComponents[machine.id] = Machine({
            Id = machine.id,
            OnHover = function(hoveredMachine, selectedObj)
                props.OnMachineSelect(hoveredMachine, selectedObj)
            end,
            MachineData = machine,
            UpdateDataset = function()
                props.UpdateDataset()
            end,
        })
    end

    local factoryConveyorMap = {}
    local factoryEntryPoints = {}
    local factoryExitPoints = {}
    for _, machine: Types.Machine in props.Machines do
        local machinePosition = worldPositionToVector3(machine.worldPosition)
        --For each machine, get information on the conveyors that enter from the left, and the conveyors that exit to the right.
        local machineConveyorMap = {}
        factoryConveyorMap[machine.id] = machineConveyorMap
        machineConveyorMap.beltsIn = {}
        local beltsIn = machineConveyorMap.beltsIn
        machineConveyorMap.beltsOut = {}
        local beltsOut = machineConveyorMap.beltsOut
        --Find the "in" belts, which are the belts that come in from the left side of the machine.
        --"Sources" should never be empty and always nil if there are no sources. But checking just in case.
        if machine.sources and #machine.sources > 0 then
            for _, sourceId in machine.sources do
                for _, sourceMachine in props.Machines do
                    if sourceId == sourceMachine.id then
                        --This machine is a source. Its belt will be coming in.
                        local conveyorName = Scene.getConveyorBeltName(sourceMachine, machine)
                        --conveyorName might be nil if we are in the process of deleting a machine.
                        if conveyorName then
                            table.insert(beltsIn, {
                                name = conveyorName,
                                sourceId = sourceId,
                                sortingPosition = worldPositionToVector3(sourceMachine.worldPosition),
                            })
                        end
                    end
                end
            end
        elseif machine["type"] == Constants.MachineTypes.purchaser then
            --If it's a purchaser, then its belt should be coming in from the left side of the Factory.
            local conveyorName = Scene.getConveyorBeltName(machine)
            if conveyorName then
                table.insert(beltsIn, {
                    name = conveyorName,
                    sourceId = "enter",
                    sortingPosition = machinePosition,
                })
                table.insert(factoryEntryPoints, {
                    name = conveyorName,
                    destinationId = machine.id,
                    sortingPosition = machinePosition,
                })
            end
        end

        table.sort(beltsIn, function(a, b)
            return a.sortingPosition.X < b.sortingPosition.X
        end)
        for i, belt in ipairs(beltsIn) do
            belt.inPosition = machinePosition
                + getConveyorPosition(
                    i,
                    #beltsIn,
                    conveyorXOffset,
                    (-Constants.MachineAnchorSizes[machine["type"]].Z / 2) * conveyorDepthOffset
                )
        end

        --Find the "out" belts, which are on the right side of the machine.
        for _, potentialDestinationMachine in props.Machines do
            --"Sources" should never be empty and always nil if there are no sources. But checking just in case.
            if potentialDestinationMachine.sources and #potentialDestinationMachine.sources > 0 then
                for _, sourceId in potentialDestinationMachine.sources do
                    if sourceId == machine.id then
                        --This machine is a destination. Its belt will be going out to the right.
                        local conveyorName = Scene.getConveyorBeltName(machine, potentialDestinationMachine)
                        if conveyorName then
                            table.insert(beltsOut, {
                                name = conveyorName,
                                destinationId = potentialDestinationMachine.id,
                                destinationPosition = worldPositionToVector3(potentialDestinationMachine.worldPosition), --This is just for sorting.
                            })
                        end
                    end
                end
            end
        end
        table.sort(beltsOut, function(a, b)
            return a.destinationPosition.X < b.destinationPosition.X
        end)
        for i, belt in ipairs(beltsOut) do
            belt.outPosition = machinePosition
                + getConveyorPosition(
                    i,
                    #beltsOut,
                    conveyorXOffset,
                    (Constants.MachineAnchorSizes[machine["type"]].Z / 2) * conveyorDepthOffset
                )
        end

        --If this machine is a makerSeller, then that means it outputs a product that has a value, and it also is not the source of any other machines.
        --Therefore, its belt should exit the factory.
        if machine["type"] == Constants.MachineTypes.makerSeller then
            local conveyorName = Scene.getConveyorBeltName(machine)
            --conveyorName might be nil because a machine is in the process of being deleted.
            if conveyorName then
                table.insert(factoryExitPoints, {
                    name = conveyorName,
                    sourceId = machine.id,
                    sortingPosition = machinePosition,
                })
            end
        end
    end

    table.sort(factoryEntryPoints, function(a, b)
        return a.sortingPosition.X > b.sortingPosition.X
    end)
    local beltEntryPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
    local entryNodes = beltEntryPart:GetChildren()
    table.sort(entryNodes, function(a, b)
        return a.WorldCFrame.X > b.WorldCFrame.X
    end)
    for i, point in ipairs(factoryEntryPoints) do
        local attachment = entryNodes[i]
        if not attachment then
            attachment = entryNodes[#entryNodes]
        end
        point.position = attachment.WorldCFrame.Position
    end

    table.sort(factoryExitPoints, function(a, b)
        return a.sortingPosition.X > b.sortingPosition.X
    end)
    local beltExitPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Exit")
    local exitNodes = beltExitPart:GetChildren()
    table.sort(exitNodes, function(a, b)
        return a.WorldCFrame.X > b.WorldCFrame.X
    end)
    for i, point in ipairs(factoryExitPoints) do
        local attachment = exitNodes[i]
        point.position = attachment.WorldCFrame.Position
    end

    local conveyorComponents = {}
    for id, conveyorMap in factoryConveyorMap do
        if conveyorComponents[id] ~= nil then
            print("Skipping...")
            continue
        end
        for i, beltComingIn in conveyorMap.beltsIn do
            if beltComingIn.sourceId == "enter" then
                --this belt is coming from the left, offscreen.
                for _, entryPoint in factoryEntryPoints do
                    if beltComingIn.name == entryPoint.name then
                        conveyorComponents[beltComingIn.name] = Conveyor({
                            Name = beltComingIn.name,
                            StartPosition = beltComingIn.inPosition,
                            EndPosition = entryPoint.position,
                            -- MidpointAdjustment = Scene.getMidpointAdjustmentValue(beltComingIn.name),
                        })
                    end
                end
            else
                --Check the other machines, and see where the belt coming in attaches to.
                for _, sourceMachine in factoryConveyorMap do
                    for _, beltLeavingSource in sourceMachine.beltsOut do
                        if beltLeavingSource.name == beltComingIn.name then
                            conveyorComponents[beltComingIn.name] = Conveyor({
                                Name = beltComingIn.name,
                                StartPosition = beltComingIn.inPosition,
                                EndPosition = beltLeavingSource.outPosition,
                                -- MidpointAdjustment = 0.25,
                            })
                        end
                    end
                end
            end
        end
    end

    for _, exitPoint in factoryExitPoints do
        local machine = Dataset:getMachineFromId(exitPoint.sourceId)
        local machinePosition = machine.worldPosition
        local endPosition = worldPositionToVector3(machinePosition)
        conveyorComponents[exitPoint.name] = Conveyor({
            Name = exitPoint.name,
            StartPosition = exitPoint.position,
            EndPosition = worldPositionToVector3(machinePosition) + getConveyorPosition(
                1,
                1,
                0,
                (Constants.MachineAnchorSizes[machine["type"]].Z / 2) * conveyorDepthOffset
            ),
        })
    end

    children = Dash.join(children, machineComponents, conveyorComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(FactoryFloor, props)
end
