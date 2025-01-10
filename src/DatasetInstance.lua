local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local Packages = script.Parent.Packages
local Utilities = require(Packages.Utilities)
local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)

--TODO: Make this manage the config folder structure that holds dataset data
local DatasetInstance = {}

function DatasetInstance.read()
    local str = DatasetInstance.getDatasetInstance().Source
    return HttpService:JSONDecode(string.sub(str, #"return [[" + 1, #str - 2))
end

function DatasetInstance.write(dataset: table)
    local datasetInstance = DatasetInstance.getDatasetInstance()
    datasetInstance.Source = "return [[" .. HttpService:JSONEncode(dataset) .. "]]"
end

function DatasetInstance.replaceDatasetInstance(datasetInstance)
    local datasetFolder = getOrCreateFolder("Dataset", game.Workspace)
    if #datasetFolder:GetChildren() then
        datasetFolder:ClearAllChildren()
    end
    datasetInstance.Parent = datasetFolder
end

function DatasetInstance.getDatasetInstance()
    local datasetFolder = Utilities.getValueAtPath(game.Workspace, "Dataset")
    if datasetFolder then
        return datasetFolder:GetChildren()[1]
    end
    return nil
end

function DatasetInstance.checkIfDatasetInstanceExists()
    local instance = DatasetInstance.getDatasetInstance()
    if instance then
        return true
    else
        return false
    end
end

function DatasetInstance.loadTemplateDataset()
    local template = require(script.Parent.Data["dataset_template"])

    local newDatasetInstance = Instance.new("ModuleScript")
    newDatasetInstance.Source = "return [[" .. HttpService:JSONEncode(template) .. "]]"
    newDatasetInstance.Name = "dataset_template"

    DatasetInstance.replaceDatasetInstance(newDatasetInstance)

    return DatasetInstance.read(), newDatasetInstance
end

function DatasetInstance.instantiateNewDatasetInstance()
    local file = StudioService:PromptImportFile()
    if not file then
        return nil
    end

    local newDatasetInstance = Instance.new("ModuleScript")
    newDatasetInstance.Source = "return [[" .. file:GetBinaryContents() .. "]]"
    newDatasetInstance.Name = file.Name:split(".")[1]

    DatasetInstance.replaceDatasetInstance(newDatasetInstance)

    return DatasetInstance.read(), newDatasetInstance
end

function DatasetInstance.updateDatasetInstanceName(name: string)
    DatasetInstance.getDatasetInstance().Name = "dataset_" .. name
end

function DatasetInstance.getDatasetInstanceName()
    local dataset = DatasetInstance.getDatasetInstance()
    if dataset then
        local str = dataset.Name:split("_")
        return str[#str]
    end
    return nil
end

--TODO: Make it so that you can change the name of the dataset
function DatasetInstance.setDatasetInstanceName(name)
    DatasetInstance.getDatasetInstance().Name = name
end

return DatasetInstance
