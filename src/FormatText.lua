local FormatText = {}

FormatText.convertToIdText = function(text)
    local idText

    idText = text:gsub("[^%w_]+", ""):lower()

    return idText
end

FormatText.numbersOnly = function(value)
    if tonumber(value) then
        return tonumber(value)
    else
        value = value:gsub("%D+", "")
        return tonumber(value)
    end
end

return FormatText
