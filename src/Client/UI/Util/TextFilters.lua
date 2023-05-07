local TextFilters = {}

function TextFilters.MaxLength(maxLength: number)
    return function(input)
        return #input <= maxLength
    end
end

function TextFilters.Min(min: number)
    return function(input)
        local number = tonumber(input)

        if not number then
            return false
        end

        return number >= min
    end
end

function TextFilters.Max(max: number)
    return function(input)
        local number = tonumber(input)

        if not number then
            return false
        end

        return number <= max
    end
end

function TextFilters.WholeNumber()
    return function(input)
        local number = tonumber(input)

        if not number then
            return false
        end

        return math.ceil(number) == number and not string.find(input, "%.")
    end
end

return TextFilters