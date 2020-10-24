PRPCore = nil
TriggerEvent('PRPCore:GetObject', function(obj) PRPCore = obj end)


RegisterNetEvent("stats:upload")
AddEventHandler("stats:upload", function (Name, FirstLast, Citizenid, MoneyTotal, Job, JobLabel, OnDuty)
    local id = GetPlayerIdentifiers(source)[1]
    PRPCore.Functions.ExecuteSql(false, "INSERT INTO stats (`Name`, `SourceID`, `FirstLast`, `Citizenid`, `MoneyTotal`, `Job`, `JobLabel`, `OnDuty`) VALUES ('"..Name.."', '"..id.."', '"..FirstLast.."', '"..Citizenid.."', '"..MoneyTotal.."', '"..Job.."', '"..JobLabel.."', '"..OnDuty.."')")
end)