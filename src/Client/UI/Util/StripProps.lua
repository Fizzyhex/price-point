local function StripProps(props, toStrip)
    local stripped = table.clone(props)

    for _, value in toStrip do
        stripped[value] = nil
    end

    return stripped
end

return StripProps