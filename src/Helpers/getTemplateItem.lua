return function()
    local template = {
        thumb = "icon-none",
        id = "templateItem",
        requirements = {
            {
                count = 1,
                itemId = "currency",
            },
        },
        asset = "",
        locName = {
            singular = "Template Item",
            plural = "Template Items",
        },
    }
    return template
end
