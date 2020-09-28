--[[
    args:
        1 = decimal places to floor to
]]
RegisterCommand("copycoords", function(source, args, rawCommand)
    local places = args[1] or nil

    local closure = places ~= nil and function(n)
        return toNDecimalPlaces(n, places)
    end or nil

    SendNUIMessage({
        coords = copyCoords(":x, :y, :z, :h", closure),
    })
end)

--[[
    args:
        1 = decimal places to floor to
]]
RegisterCommand("copycoords-prefixed", function(source, args, rawCommand)
    local places = args[1] or nil

    local closure = places ~= nil and function(n)
        return toNDecimalPlaces(n, places)
    end or nil

    SendNUIMessage({
        coords = copyCoords("x = :x, y = :y, z = :z, h = :h", closure),
    })
end)

--[[
    args:
        1 = decimal places to floor to

    Returns format: "1.11111 2.22222 3.33333"
    - For the /tp command, this can just be pasted straight in, i.e.:

    /copycoords-xyz
    /tp <paste>
]]
RegisterCommand("copycoords-xyz", function(source, args, rawCommand)
    local places = args[1] or nil

    local closure = places ~= nil and function(n)
        return toNDecimalPlaces(n, places)
    end or nil

    SendNUIMessage({
        coords = copyCoords(":x :y :z", closure),
    })
end)

--[[
    args:
        1 = decimal places to floor to
        2 = template, replaces :x, :y, :z and :h with the given coords / heading
]]
RegisterCommand("copycoords-custom", function(source, args, rawCommand)
    local places = args[1] or nil
    local template = args[2] or nil

    if template == nil then
        TriggerEvent("chatMessage", source, "SYSTEM", "error", "You must supply a template, i.e. 'x = :x, y = :y, z = :z, h = :h'")
    end

    local closure = places ~= nil and function(n)
        return toNDecimalPlaces(n, places)
    end or toNDecimalPlaces
    
    SendNUIMessage({
        coords = copyCoords(template, closure),
    })
end)

-- General function to return coords in our given template
function copyCoords(template, closure)
    closure = closure or nil

    local x, y, z, h = getCoordsAndHeading()

    local replaceTable = {
        [":x"] = closure ~= nil and closure(x) or x,
        [":y"] = closure ~= nil and closure(y) or y,
        [":z"] = closure ~= nil and closure(z) or z,
        [":h"] = closure ~= nil and closure(h) or h,
    }

    local out = template

    for find, swapWith in pairs(replaceTable) do
        out = out:gsub(find, swapWith)
    end

    return out
end

function getCoordsAndHeading()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local heading = GetEntityHeading(player)

    local x, y, z = table.unpack(coords)

    return x, y, z, heading
end

-- Floor to n decimal places, floor because we don't want to round the remaining digit up, ever
function toNDecimalPlaces(num, places)
    local multiplier = 10^(places or 0)
    return math.floor(num * multiplier) / multiplier
end

--[[ showcoords command stuff ]]--

local showCoords = false

--[[
    Display the coordinates at the top of the screen, as per the template in the thread
]]
RegisterCommand("showcoords", function()
    showCoords = not showCoords
end)

Citizen.CreateThread(function()
    while true do
        if showCoords then
            sleepTimer = 5

            local x, y, z, h = getCoordsAndHeading()

            DrawGenericText(("~g~X~w~: %s ~g~Y~w~: %s ~g~Z~w~: %s ~g~H~w~: %s"):format(
                toNDecimalPlaces(x, 2),
                toNDecimalPlaces(y, 2),
                toNDecimalPlaces(z, 2),
                toNDecimalPlaces(h, 2)
            ))
        else
            -- Reset the timer if we're not showing coords and check less frequently
            sleepTimer = 250
        end

        Citizen.Wait(sleepTimer)
    end
end)

function DrawGenericText(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(7)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end