local Constants = require(script.Parent.Constants)
local ServerStorage = game:GetService("ServerStorage")
local ImageManifest = {}
local noImage: string = Constants.NoImage --Question mark

function ImageManifest.getManifest()
    local manifest = ServerStorage:FindFirstChild("Factories Plugin Manifest")
    if manifest then
        manifest = require(manifest)
    end
    return manifest
end

function ImageManifest.getImage(imageId)
    local manifest = ImageManifest.getManifest()
    if manifest then
        local image = manifest.images[imageId]
        if image then
            return image
        else
            return noImage --Question mark
        end
    else
        return noImage --Question mark
    end
    return nil
end

return ImageManifest
