PRPCore = nil
TriggerEvent('PRPCore:GetObject', function(obj) PRPCore = obj end)

-- Code

PRPCore.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = PRPCore.Functions.GetPlayer(source)
    TriggerClientEvent('prp-fitbit:use', source)
  end)

RegisterServerEvent('prp-fitbit:server:setValue')
AddEventHandler('prp-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = PRPCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food,
            compass= currentMeta.compass,
            hud = currentMeta.hud,
            hungerThirst = currentMeta.hungerThirst,
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value,
            compass= currentMeta.compass,
            hud = currentMeta.hud,
            hungerThirst = currentMeta.hungerThirst,
        }
    elseif type == "compass" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = currentMeta.food,
            compass = value,
            hud = currentMeta.hud,
            hungerThirst = currentMeta.hungerThirst,
        }
    elseif type == "hud" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = currentMeta.food,
            compass = currentMeta.compass,
            hud = value,
            hungerThirst = currentMeta.hungerThirst,
        }
    elseif type == "hungerThirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = currentMeta.food,
            compass = currentMeta.compass,
            hud = currentMeta.hud,
            hungerThirst = value,
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

PRPCore.Functions.CreateCallback('prp-fitbit:server:HasFitbit', function(source, cb)
    local Ply = PRPCore.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)