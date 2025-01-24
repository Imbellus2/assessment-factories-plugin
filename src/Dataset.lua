local Types = require(script.Parent.Types)
local getTemplateItem = require(script.Parent.Helpers.getTemplateItem)
local getTemplateMachine = require(script.Parent.Helpers.getTemplateMachine)
local Constants = require(script.Parent.Constants)
local Root = script.Parent
local Packages = Root.Packages
local Dash = require(Packages.Dash)
local DatasetInstance = require(script.Parent.DatasetInstance)
local Scene = require(script.Parent.Scene)
local Dataset = {}

Dataset.dataset = {}
Dataset.currentMap = {}
Dataset.items = {}
Dataset.machines = {}

function Dataset:cleanMachines()
    local machines = self.machines
    local items = self.items
    --Clean the machine sources, make sure that it is nil if there are no source ids. We do this because machines in Factories, "sources" might == nil.
    for _, machine in machines do
        if machine["sources"] and #machine["sources"] == 0 then
            machine["sources"] = nil
        end
        local machineType = machine["type"]
        if machineType == Constants.MachineTypes.purchaser then
            machine.sources = nil
            machine["asset"] = Constants.MachineAssetPaths.purchaser
            machine.supportsPowerup = false
        elseif machineType == Constants.MachineTypes.maker then
            machine["asset"] = Constants.MachineAssetPaths.maker
            machine.supportsPowerup = true
        elseif machineType == Constants.MachineTypes.makerSeller then
            machine["asset"] = Constants.MachineAssetPaths.makerSeller
            machine.supportsPowerup = false
        end
    end

    for _, machine in machines do
        --If this is a purchaser, then it should not have any inputs.
        local machineType = machine["type"]
        if machineType == Constants.MachineTypes.maker then
            --Loop through the machines and see if another machine uses this machine as a source.
            --If no machines have this machine as a source, then there's an error.
            local machineIsASourceForAnotherMachine = false
            for _, otherMachine in machines do
                if otherMachine.sources then
                    for _, sourceId in otherMachine.sources do
                        if sourceId == machine.id then
                            machineIsASourceForAnotherMachine = true
                        end
                    end
                end
            end
            if not machineIsASourceForAnotherMachine then
                --Make an error, here
                -- warn("ERROR!", machine.id, "is a maker, but no other machine uses it as a source.")
            end
        elseif machineType == Constants.MachineTypes.purchaser or machineType == Constants.MachineTypes.makerSeller then
            --Make sure there is no delay for non-maker machines.
            machine.defaultProductionDelay = Constants.Defaults.MachineDefaultProductionDelay
        end
    end

    --All machine sources should be used.
    --We need to check each machine, and make sure that all of its sources have outputs that are used by this machine output.
    --Otherwise, you'll get an error when you try to run it in factories.
    for _, machine in machines do
        --If there are no sources, then it's a producer, so skip it
        local inputMachines = machine.sources
        if inputMachines == nil then
            continue
        end

        --Check each item. Make sure that each item requirement is also the output of one of the machine's input machines.
        local outputItems = machine.outputs
        if outputItems == nil then
            debug.warn("Error! Machine", machine.id, "has no outputs!")
            continue
        end

        if machine.outputs then
            for _, itemId in machine.outputs do
                local itemRequirements = items[itemId].requirements
                if machine.sources then
                    for _, inputMachineId in machine.sources do
                        local inputMachine = Dataset:getMachineFromId(inputMachineId)
                        local inputMachineOutputs = inputMachine.outputs
                        if not inputMachineOutputs then
                            warn("Error! Machine", inputMachine.id, "has no outputs!")
                            continue
                        end
                        --Do the outputs from the input machine match the output of this machine?
                        local outputMatch = false
                        for _, outputId in inputMachineOutputs do
                            for _, requirementId in itemRequirements do
                                if outputId == requirementId.itemId then
                                    outputMatch = true
                                end
                            end
                        end
                        if outputMatch == false then
                            warn(
                                `{machine.id} ERROR! {inputMachine.id} is a source for {machine.id}, but none of its outputs are used! This will cause an error in Factories. Update the outputs in {machine.id} so that it uses an item from {inputMachine.id}.`
                            )
                        end
                    end
                end
            end
        end
    end
end

function Dataset:cleanItems()
    local items = self.items
    for key, item in pairs(items) do
        --Check the items based on machine type. There are certain requirements for certain machines.
        --Purchasers: Each item should have a cost, and no requirements.
        --Makers: Each item should have requirements, and no cost (Requirement of Currency) and no value (Sale Price)
        --MakerSellers: Each item should have requirements, and a value (Sale Price), but no cost (Requirement of Currency)
        if item.value then
            if typeof(item.value.count) == "string" then
                item.value.count = tonumber(item.value.count)
                print("Converted string to number for", item.id, "item value.count")
            end
        end

        local machineType = self:getMachineTypeFromItemId(item.id)
        if machineType == Constants.MachineTypes.purchaser then
            --Prune the requirements array of anything that is not "currency"
            if #item.requirements == 1 and item.requirements[1].itemId == "currency" then
                --Do nothing
            elseif #item.requirements > 0 then
                local currencyAmount = nil
                for i, requirement in ipairs(items[key].requirements) do
                    if requirement.itemId == "currency" then
                        currencyAmount = requirement.count
                    end
                end
                if currencyAmount then
                    print("Updating requirement for purchaser item to make sure it's only currency...", item.id)
                    items[key].requirements = {}
                    items[key].requirements[1] = { itemId = "currency", count = currencyAmount }
                else
                    print("Adding currency requirement (Sale Cost) to purchaser item...", item.id)
                    items[key].requirements = getTemplateItem().requirements
                end
                if item.value ~= nil then
                    print("Removing value from purchaser item...", item.id)
                    items[key].value = nil
                end
            end
        elseif machineType == Constants.MachineTypes.maker then
            if item.value ~= nil then
                print("Removing value from maker item...", item.id)
                items[key].value = nil
            end
        elseif machineType == Constants.MachineTypes.makerSeller then
            if item.value == nil then
                print("Adding value to makerSeller item...", item.id)
                items[key].value = {
                    count = 5,
                    itemId = "currency",
                }
            end
        end

        item = items[key]
        --If there's more than one requirement, make sure one of them isn't "currency". If so this should be removed. You can't require currency AND another item.
        if item.requirements then
            if #item.requirements > 1 then
                local indexToRemove = nil
                for i, requirement in ipairs(item.requirements) do
                    if requirement.itemId == "currency" then
                        indexToRemove = i
                    end
                end
                if indexToRemove then
                    -- print("Removing item from requirements...", item.requirements[indexToRemove].itemId, indexToRemove)
                    if item.requirements[indexToRemove].itemId == "currency" then
                        table.remove(item.requirements, indexToRemove)
                    end
                    -- print("Result:", item.requirements)
                end
            elseif #item.requirements == 0 then
                item.requirements[1] = { itemId = "currency", count = 0 }
            end

            --Make sure the count is a number, not a string.
            for i, requirement in ipairs(item.requirements) do
                if not requirement.count then
                    print(
                        "Error! Requirement count is nil! Resetting to default requirement.",
                        item.id,
                        item,
                        requirement
                    )
                    local resetRequirement = table.clone(getTemplateItem().requirements)[1]
                    item.requirements[i] = resetRequirement
                else
                    --TODO: Fix this. Does it even work? It should be modifying the item table directly, not the local "requirement" variable
                    requirement.count = tonumber(requirement.count)
                end
            end
        else
            --An item should always have a requirement
            if item.id == "currency" or item.id == "none" then
                item.requirements = nil
            else
                item.requirements = {}
                item.requirements[1] = { itemId = "currency", count = 2 }
            end
        end

        --Check the loc name. Each locName should have a singular and a plural.
        if typeof(item.locName) == "string" then
            print("Renaming locName to singular and plural...", item.locName)
            local unitLocName = {
                singular = item.locName,
                plural = item.locName .. "s",
            }
            item.locName = unitLocName
        end
    end
end

function Dataset:checkForErrors()
    local datasetError = Constants.Errors.None
    --Check for duplicate IDs
    for _, machine in self.machines do
        if self:duplicateCoordinatesExist(machine.coordinates) then
            datasetError = Constants.Errors.DuplicateCoordinatesError
            warn(datasetError)
        end
        if machine["type"] == Constants.MachineTypes.invalid then
            datasetError = Constants.Errors.InvalidMachine
            warn(datasetError)
        end
    end
    return datasetError
end

function Dataset:getDataset()
    return DatasetInstance.read()
end

function Dataset:updateDataset(dataset, currentMapIndex)
    assert(dataset, "Dataset error! Dataset is nil!")

    self.dataset = dataset
    self.currentMap = dataset["maps"][currentMapIndex]
    self.items = self.currentMap["items"]
    self.machines = self.currentMap["machines"]

    self:cleanMachines()
    self:cleanItems()

    DatasetInstance.write(dataset)
end

function Dataset:getItemFromId(id)
    return self.items[id]
end

function Dataset:addItem()
    local items = self.items
    local newItem = getTemplateItem()
    local newItemId = self:resolveDuplicateId(newItem["id"], self.items)
    newItem["id"] = newItemId
    items[newItemId] = newItem

    return newItem
end

function Dataset:removeItem(itemKey)
    local items = self.items
    if not self.currentMap then
        self.currentMap = self.dataset["maps"][game.Workspace:GetAttribute("CurrentMapIndex")]
    end
    local machines = self.currentMap["machines"]

    --remove the item as an output from all machines.
    for _, machine in machines do
        local indexToRemove = 0
        for i, output in machine["outputs"] do
            if output == itemKey then
                indexToRemove = i
            end
        end
        table.remove(machine["outputs"], indexToRemove)
    end

    --remove the item as a requirement for all items
    for _, item in items do
        if not item["requirements"] then
            continue
        end
        local indexToRemove = 0
        for i, requirement in item["requirements"] do
            if requirement["itemId"] == itemKey then
                indexToRemove = i
            end
        end
        table.remove(item["requirements"], indexToRemove)
    end

    items[itemKey] = nil
end

function Dataset:updateItemId(itemToUpdate: Types.Item, newId: string)
    if not newId or #newId < 1 then
        return false
    end
    if itemToUpdate.id == newId then
        return true, itemToUpdate
    end
    newId = Dataset:resolveDuplicateId(newId, self.items)

    local originalId = itemToUpdate.id
    local newItem = table.clone(self.items[originalId])

    newItem.id = newId
    self.items[newId] = newItem
    self.items[originalId] = nil

    -- if we're changing the ID, we must also change it wherever it appears as another machine's source
    for i, machine in self.machines do
        if machine["outputs"] then
            for j, machineOutput in machine["outputs"] do
                if machineOutput == originalId then
                    self.machines[i]["outputs"][j] = newId
                end
            end
        end
    end

    for i, item in self.items do
        if item.requirements then
            for j, requirement in item.requirements do
                if requirement.itemId == originalId then
                    local oldCount = requirement.count
                    self.items[i]["requirements"][j] = {
                        itemId = newId,
                        count = oldCount,
                    }
                end
            end
        end
    end
    return true, newItem
end

function Dataset:addRequirementToItem(itemToUpdate: Types.Item, requirementItem: Types.Item)
    if itemToUpdate.id == requirementItem.id then
        print("You cannot add an item to itself as a requirement. Skipping")
        return
    end
    local skip = false
    if itemToUpdate.requirements then
        for _, requirement in itemToUpdate.requirements do
            if requirement.itemId == requirementItem.id then
                skip = true
            end
        end
        if skip then
            print("Item already exists as a requirement. Skipping")
            return
        else
            print("Adding", requirementItem.id, "to", itemToUpdate.id, "as a requirement")
            table.insert(itemToUpdate.requirements, { itemId = requirementItem.id, count = 0 })
        end
    else
        itemToUpdate.requirements = {}
        table.insert(itemToUpdate.requirements, { itemId = requirementItem.id, count = 0 })
    end
end

function Dataset:removeRequirementFromItem(itemToUpdate: Types.Item, requirementId: string)
    local requirementItem = self.items[requirementId]
    if not requirementItem then
        warn("Requirement id ", requirementId, "does not have a corresponding item!")
        return
    end
    if not itemToUpdate.requirements or #itemToUpdate.requirements == 0 then
        warn("Error! Item has no requirements!")
        return
    end
    local indexToRemove = 0
    for i, requirement in ipairs(itemToUpdate.requirements) do
        if requirement.itemId == requirementId then
            indexToRemove = i
            print("Index to remove:", indexToRemove)
        end
    end
    table.remove(itemToUpdate.requirements, indexToRemove)
end

--Returns items, minus the currency and none items
function Dataset:getValidItems(excludeOutputsInUse: boolean)
    local result = {}
    for itemKey, item in self.items do
        local skip = false
        if item.id == "currency" or item.id == "none" then
            skip = true
        elseif excludeOutputsInUse then
            for _, machine in self.machines do
                if machine.outputs then
                    for _, outputId in machine.outputs do
                        if item.id == outputId then
                            skip = true
                        end
                    end
                end
            end
        end

        if skip then
            continue
        end
        result[item.id] = item
    end
    return result
end

function Dataset:getValidRequirementsForItem(item: Types.Item)
    local result = {}
    for _, requirement in ipairs(item.requirements) do
        if requirement.itemId == "currency" or requirement.itemId == "none" then
            continue
        else
            table.insert(result, requirement)
        end
    end
    return result
end

function Dataset:getMachineTypeFromItemId(itemId: string)
    local machineType = Constants.None
    for _, machine in self.machines do
        if machine.outputs then
            for _, outputId in machine.outputs do
                if outputId == itemId then
                    machineType = machine.type
                end
            end
        end
    end
    return machineType
end

function Dataset:resolveDuplicateId(idToCheck: string, tableToCheck: table)
    local dupeCounter = 0
    local function checkIds(id)
        local newId = id
        for _, item in tableToCheck do
            if item.id == id then
                dupeCounter = dupeCounter + 1
                newId = checkIds(idToCheck .. tostring(dupeCounter))
            end
        end
        return newId
    end

    return checkIds(idToCheck)
end

function Dataset:resolveDuplicateCoordinates(coordinatesToCheck: { X: number, Y: number }, tableToCheck: table)
    local dupeCounter = 0
    local function checkCoords(coords)
        local newCoords = coords
        for _, machine: Types.Machine in tableToCheck do
            local dupeXFound = false
            local dupeYFound = false
            if machine.coordinates.X == coords.X then
                dupeXFound = true
            end
            if machine.coordinates.Y == coords.Y then
                dupeYFound = true
            end
            if dupeXFound and dupeYFound then
                dupeCounter = dupeCounter + 1
                newCoords = checkCoords({ X = coords.X, Y = coords.Y + 1 })
            end
        end
        return newCoords
    end
    return checkCoords(coordinatesToCheck)
end

function Dataset:duplicateCoordinatesExist(coordinatesToCheck: { X: number, Y: number })
    local dupeCounter = 0
    for _, machine in self.machines do
        local existingX = false
        local existingY = false
        if machine.coordinates.X == coordinatesToCheck.X then
            existingX = true
        end
        if machine.coordinates.Y == coordinatesToCheck.Y then
            existingY = true
        end
        if existingX and existingY then
            dupeCounter = dupeCounter + 1
        end
    end
    return dupeCounter > 1
end

function Dataset:addMachine()
    local newMachine = getTemplateMachine()
    -- check for duplicate id
    newMachine.id = self:resolveDuplicateId(newMachine.id, self.machines)
    newMachine.coordinates = self:resolveDuplicateCoordinates(newMachine.coordinates, self.machines)

    table.insert(self.machines, newMachine)

    return newMachine
end

function Dataset:removeMachine(machineToRemove: Types.Machine)
    local machines = self.machines
    local indexToRemove = nil
    for i, machine in machines do
        if machine.id == machineToRemove.id then
            indexToRemove = i
        end
    end
    if indexToRemove then
        Scene.removeConveyors(machineToRemove)
        table.remove(machines, indexToRemove)
    end
    --Check other machines. If they have this machine as a source, remove it.
    for _, machine in machines do
        if machine.sources then
            for i, sourceId in ipairs(machine.sources) do
                if sourceId == machineToRemove.id then
                    table.remove(machine.sources, i)
                end
            end
            --A machine should never have an empty table for sources.
            if #machine.sources == 0 then
                machine.sources = nil
            end
        end
    end
end

function Dataset:updateMachineId(machineToUpdate: Types.Machine, id: string)
    local originalId = machineToUpdate.id
    if not id or #id < 1 then
        return false
    end
    id = Dataset:resolveDuplicateId(id, self.machines)
    machineToUpdate.id = id
    --if we're changing the ID, we must also change it wherever it appears as another machine's source
    for i, machine in self.machines do
        if machine["sources"] then
            for j, source in machine["sources"] do
                if source == originalId then
                    self.machines[i]["sources"][j] = id
                end
            end
        end
    end
    return true
end

function Dataset:setMachineType(machineToUpdate: Types.Machine, machineType: string)
    machineToUpdate["type"] = machineType
end

function Dataset:updateMachineProperty(machineToUpdate: Types.Machine, property: string, value: string | number)
    machineToUpdate[property] = value
end

--Add a sourceId to the machine, but also check to make sure it doesn't already exist
function Dataset:addSourceToMachine(machineToUpdate: Types.Machine, sourceMachineId)
    if machineToUpdate.sources then
        for _, sourceId in machineToUpdate.sources do
            --if the sourceId already exists, then do not add another.
            if sourceId == sourceMachineId then
                return
            end
        end
    else
        machineToUpdate.sources = {}
    end
    table.insert(machineToUpdate.sources, sourceMachineId)
end
function Dataset:removeSourceFromMachine(machineToUpdate: Types.Machine, sourceMachineId)
    if machineToUpdate.sources then
        local index = table.find(machineToUpdate.sources, sourceMachineId)
        if index then
            table.remove(machineToUpdate.sources, index)
        end
    end
end

--Add the item id to the outputs of the machine, but check for duplicates.
function Dataset:addOutputToMachine(machineToUpdate: Types.Machine, item: Types.Item)
    if machineToUpdate.outputs then
        for _, itemId in machineToUpdate.outputs do
            if item.id == itemId then
                return
            end
        end
    else
        machineToUpdate.outputs = {}
    end
    table.insert(machineToUpdate.outputs, item.id)
end

function Dataset:removeOutputFromMachine(machineToUpdate: Types.Machine, item: Types.Item)
    if machineToUpdate.outputs then
        local index = table.find(machineToUpdate.outputs, item.id)
        if index then
            table.remove(machineToUpdate.outputs, index)
        end
    end
end

function Dataset:getMachineFromOutputItem(item: Types.Item)
    local machineWithOutput: Types.Machine = nil
    for _, machine in self.machines do
        if machine.outputs then
            for _, outputId in machine.outputs do
                if outputId == item.id then
                    machineWithOutput = machine
                end
            end
        end
    end
    return machineWithOutput
end

function Dataset:getMachineFromMachineAnchor(machineAnchor: Instance)
    local debugId = machineAnchor:GetAttribute("debugId")
    local counter = 0
    local machine = nil
    for _, machineObj in self.machines do
        if machineObj["machineAnchor"] and machineObj["machineAnchor"] == debugId then
            machine = machineObj
            counter += 1
        end
    end

    if counter > 1 then
        print("Error! More than one machine refers to this anchor!")
    end

    return machine
end

function Dataset:getMachineFromId(id)
    local machine = nil
    for _, v in self.machines do
        if v["id"] == id then
            machine = v
        end
    end
    return machine
end

--takes the MachineAnchor name as an input and returns X and Y coordinates.
function Dataset:getCoordinatesFromAnchorName(name)
    local x, y = table.unpack(string.split(string.sub(name, 2, #name - 1), ","))
    x = tonumber(x)
    y = tonumber(y)
    return x, y
end

--returns the machine data in the dataset, based on the coordinates provided
function Dataset:getMachineFromCoordinates(x: number, y: number)
    local machine = nil
    for _, v in self.machines do
        if v["coordinates"]["X"] == x and v["coordinates"]["Y"] == y then
            machine = v
        end
    end
    return machine
end

return Dataset
