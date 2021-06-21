PRPCore = nil
TriggerEvent('PRPCore:GetObject', function(obj) PRPCore = obj end)

local totalplayers = 0
local playerdatatable ={}

RegisterNetEvent("stats:upload")
AddEventHandler("stats:upload", function (Name, FirstLast, Citizenid, MoneyTotal, Job, JobLabel, OnDuty)
    local id = GetPlayerIdentifiers(source)[1]
    PRPCore.Functions.ExecuteSql(false, "INSERT INTO stats (`Name`, `SourceID`, `FirstLast`, `Citizenid`, `MoneyTotal`, `Job`, `JobLabel`, `OnDuty`) VALUES ('"..Name.."', '"..id.."', '"..FirstLast.."', '"..Citizenid.."', '"..MoneyTotal.."', '"..Job.."', '"..JobLabel.."', '"..OnDuty.."')")
end)

RegisterNetEvent("stats:setmeta")
AddEventHandler("stats:setmeta", function ()
    local Player = PRPCore.Functions.GetPlayer(source)

    if Player ~= nil then
        local playtime = Player.PlayerData.metadata["playtime"]

        if playtime == nil or playtime == "" then
            playtime = 0
        end

        playtime = playtime + 5
        Player.Functions.SetMetaData("playtime", playtime)
    end
end)