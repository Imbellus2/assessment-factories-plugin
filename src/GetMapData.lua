local Scene = require(script.Parent.Scene)
return function()
    --Parse the map nodes from BeltData.
    local beltData = Scene.getBeltMapDataFolder()
    local mapDataForExport = {}
    for _, conveyorFolder: Folder in beltData:GetChildren() do
        local nodeData = {}
        for i, node in ipairs(conveyorFolder:GetChildren()) do
            local position = node.CFrame.Position
            table.insert(nodeData, {
                position = {
                    x = -position.X,
                    y = position.Z,
                    z = position.Y,
                },
                index = i - 1, --Zero-based
            })
        end
        local key = '["' .. conveyorFolder.Name .. '"]'
        mapDataForExport[key] = nodeData
    end
    return mapDataForExport
end
